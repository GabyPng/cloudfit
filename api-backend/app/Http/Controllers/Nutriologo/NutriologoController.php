<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use App\Models\Nutriologo;
use App\Models\NutritionPlan;
use App\Models\NutritionPlanAssignment;
use App\Models\NutritionPlanMeal;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class NutriologoController extends Controller
{
    private function userColumnExists(string $column): bool
    {
        static $userColumns = null;

        if ($userColumns === null) {
            $userColumns = array_flip(Schema::getColumnListing('users'));
        }

        return isset($userColumns[$column]);
    }

    private function currentNutriologo(Request $request): ?Nutriologo
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return null;
        }

        $user = User::query()->with('role:role_id,name')->where('email', $email)->first();
        if (!$user) {
            return null;
        }

        $profile = Nutriologo::query()->where('user_id', $user->id)->first();
        if ($profile) {
            return $profile;
        }

        $roleName = mb_strtolower((string) ($user->role?->name ?? ''));
        if ($roleName === 'nutriologo') {
            return Nutriologo::query()->create([
                'user_id' => $user->id,
                'license_number' => 'PENDIENTE',
                'focus' => 'General',
                'certificate_uploads' => null,
            ]);
        }

        return null;
    }

    public function dashboard(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $assignmentsBase = NutritionPlanAssignment::query()
            ->where('nutriologo_id', $nutriologo->id);

        $totalAssignments = (clone $assignmentsBase)->count();
        $activeAssignments = (clone $assignmentsBase)
            ->where('status', 'active')
            ->count();

        $stats = [
            'total_pacientes' => (clone $assignmentsBase)
                ->distinct('client_id')
                ->count('client_id'),
            'nuevos_este_mes' => (clone $assignmentsBase)
                ->where(function ($query) {
                    $query->whereBetween('assigned_at', [now()->startOfMonth()->toDateString(), now()->endOfMonth()->toDateString()])
                        ->orWhereBetween('created_at', [now()->startOfMonth(), now()->endOfMonth()]);
                })
                ->distinct('client_id')
                ->count('client_id'),
            'adherencia_promedio' => $totalAssignments > 0
                ? (int) round(($activeAssignments / $totalAssignments) * 100)
                : 0,
            'alertas_nutricionales' => (clone $assignmentsBase)
                ->where(function ($query) {
                    $query->whereIn('status', ['paused', 'cancelled'])
                        ->orWhere(function ($subQuery) {
                            $subQuery->whereNotNull('ends_at')
                                ->whereDate('ends_at', '<', now()->toDateString());
                        });
                })
                ->count(),
            'planes_activos' => NutritionPlan::query()
                ->where('nutriologo_id', $nutriologo->id)
                ->where('is_active', true)
                ->count(),
        ];

        $statusLabels = [
            'active' => 'Seguimiento activo',
            'paused' => 'Plan pausado',
            'completed' => 'Objetivo cumplido',
            'cancelled' => 'Requiere atención',
        ];

        $userFields = ['user_id', 'name', 'email'];

        if ($this->userColumnExists('avatar_url')) {
            $userFields[] = 'avatar_url';
        }

        if ($this->userColumnExists('objective')) {
            $userFields[] = 'objective';
        }

        $patientAssignments = NutritionPlanAssignment::query()
            ->with(['client:' . implode(',', $userFields), 'nutritionPlan:id,title'])
            ->where('nutriologo_id', $nutriologo->id)
            ->latest('updated_at')
            ->get();

        $clientGoals = DB::table('clients')
            ->whereIn('user_id', $patientAssignments->pluck('client_id')->filter()->unique())
            ->pluck('goal', 'user_id');

        $pacientes = $patientAssignments
            ->unique('client_id')
            ->take(8)
            ->values()
            ->map(function ($assignment) use ($statusLabels, $clientGoals) {
                $status = $assignment->status ?? 'active';
                $isAlert = in_array($status, ['paused', 'cancelled'], true)
                    || ($assignment->ends_at && $assignment->ends_at->isPast());

                return [
                    'id' => $assignment->client?->id,
                    'nombre' => $assignment->client?->name ?? 'Paciente sin nombre',
                    'avatar_url' => $assignment->client?->avatar_url ?? null,
                    'plan_nombre' => $assignment->nutritionPlan?->title ?? 'Sin plan asignado',
                    'estado' => $isAlert ? 'alerta' : 'activo',
                    'estado_label' => $statusLabels[$status] ?? 'Seguimiento activo',
                    'ultimo_registro' => optional($assignment->updated_at)->diffForHumans() ?? 'Sin registro reciente',
                    'objetivo' => $assignment->client?->objective
                        ?: ($clientGoals->get($assignment->client_id) ?: 'Sin objetivo registrado'),
                ];
            });

        $actividades = NutritionPlanAssignment::query()
            ->with(['client:user_id,name', 'nutritionPlan:id,title'])
            ->where('nutriologo_id', $nutriologo->id)
            ->latest('updated_at')
            ->take(6)
            ->get()
            ->map(function ($assignment) {
                $type = match ($assignment->status) {
                    'completed' => 'objetivo_cumplido',
                    'paused', 'cancelled' => 'alerta_nutricional',
                    default => 'plan_asignado',
                };

                $detail = match ($assignment->status) {
                    'completed' => 'completó su plan ' . ($assignment->nutritionPlan?->title ?? 'nutricional'),
                    'paused' => 'tiene su plan en pausa',
                    'cancelled' => 'requiere revisión de seguimiento',
                    default => 'tiene activo el plan ' . ($assignment->nutritionPlan?->title ?? 'nutricional'),
                };

                return [
                    'tipo' => $type,
                    'cliente_nombre' => $assignment->client?->name ?? 'Paciente',
                    'detalle' => $detail,
                    'tiempo_hace' => optional($assignment->updated_at)->diffForHumans() ?? 'Hace un momento',
                ];
            });

        return response()->json([
            'message' => 'Bienvenido al panel de Nutriologo.',
            'section' => 'nutriologo',
            'stats' => $stats,
            'pacientes' => $pacientes,
            'actividades' => $actividades,
        ]);
    }

    public function clientes(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $search = trim((string) $request->query('search', ''));
        $perPage = (int) $request->query('per_page', 10);
        $perPage = max(1, min($perPage, 50));

        $clientSelects = [
            'users.user_id as id',
            'users.name',
            'users.email',
            $this->userColumnExists('avatar_url') ? 'users.avatar_url' : DB::raw('NULL as avatar_url'),
            $this->userColumnExists('objective')
                ? DB::raw("COALESCE(users.objective, clients.goal, 'Sin objetivo registrado') as objective")
                : DB::raw("COALESCE(clients.goal, 'Sin objetivo registrado') as objective"),
        ];

        $clientsQuery = User::query()
            ->leftJoin('clients', 'clients.user_id', '=', 'users.user_id')
            ->select($clientSelects)
            ->whereExists(function ($query) use ($nutriologo) {
                $query->select(DB::raw(1))
                    ->from('nutrition_plan_assignments as npa')
                    ->whereColumn('npa.client_id', 'users.user_id')
                    ->where('npa.nutriologo_id', $nutriologo->id);
            });

        if ($search !== '') {
            $clientsQuery->where(function ($query) use ($search) {
                $query->where('users.name', 'like', "%{$search}%")
                    ->orWhere('users.email', 'like', "%{$search}%");
            });
        }

        $clients = $clientsQuery
            ->orderBy('users.name')
            ->paginate($perPage)
            ->withQueryString();

        return response()->json([
            'data' => $clients->items(),
            'meta' => [
                'current_page' => $clients->currentPage(),
                'last_page' => $clients->lastPage(),
                'per_page' => $clients->perPage(),
                'total' => $clients->total(),
                'has_more' => $clients->hasMorePages(),
            ],
        ]);
    }

    public function planes(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $search = trim((string) $request->query('search', ''));
        $perPage = (int) $request->query('per_page', 10);
        $perPage = max(1, min($perPage, 50));

        $plansQuery = NutritionPlan::query()
            ->withCount(['meals', 'assignments'])
            ->where('nutriologo_id', $nutriologo->id);

        if ($search !== '') {
            $plansQuery->where(function ($query) use ($search) {
                $query->where('title', 'like', "%{$search}%")
                    ->orWhere('goal', 'like', "%{$search}%");
            });
        }

        $plans = $plansQuery
            ->latest()
            ->paginate($perPage)
            ->withQueryString();

        return response()->json([
            'data' => $plans->items(),
            'meta' => [
                'current_page' => $plans->currentPage(),
                'last_page' => $plans->lastPage(),
                'per_page' => $plans->perPage(),
                'total' => $plans->total(),
                'has_more' => $plans->hasMorePages(),
            ],
        ]);
    }

    public function planDetalle(Request $request, int $planId)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $plan = NutritionPlan::query()
            ->with(['meals', 'assignments.client:user_id,name,email'])
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologo->id)
            ->first();

        if (!$plan) {
            return response()->json(['error' => 'Plan no encontrado.'], 404);
        }

        return response()->json(['data' => $plan]);
    }

    public function storePlan(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'goal' => ['nullable', 'string', 'max:255'],
            'daily_calories' => ['nullable', 'integer', 'min:0', 'max:20000'],
            'macro_targets' => ['nullable', 'array'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'meals' => ['nullable', 'array'],
            'meals.*.meal_type' => ['required_with:meals', 'in:desayuno,colacion_1,comida,colacion_2,cena'],
            'meals.*.name' => ['required_with:meals', 'string', 'max:255'],
            'meals.*.portion' => ['nullable', 'string', 'max:255'],
            'meals.*.calories' => ['nullable', 'integer', 'min:0', 'max:10000'],
            'meals.*.protein_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.carbs_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.fat_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.notes' => ['nullable', 'string'],
        ]);

        $plan = DB::transaction(function () use ($validated, $nutriologo) {
            $plan = NutritionPlan::query()->create([
                'nutriologo_id' => $nutriologo->id,
                'title' => $validated['title'],
                'description' => $validated['description'] ?? null,
                'goal' => $validated['goal'] ?? null,
                'daily_calories' => $validated['daily_calories'] ?? null,
                'macro_targets' => $validated['macro_targets'] ?? null,
                'starts_at' => $validated['starts_at'] ?? null,
                'ends_at' => $validated['ends_at'] ?? null,
                'is_active' => true,
            ]);

            foreach (($validated['meals'] ?? []) as $index => $meal) {
                NutritionPlanMeal::query()->create([
                    'nutrition_plan_id' => $plan->id,
                    'meal_type' => $meal['meal_type'],
                    'name' => $meal['name'],
                    'portion' => $meal['portion'] ?? null,
                    'calories' => $meal['calories'] ?? null,
                    'protein_g' => $meal['protein_g'] ?? null,
                    'carbs_g' => $meal['carbs_g'] ?? null,
                    'fat_g' => $meal['fat_g'] ?? null,
                    'notes' => $meal['notes'] ?? null,
                    'position' => $index,
                ]);
            }

            return $plan->load('meals');
        });

        return response()->json([
            'message' => 'Plan nutricional creado.',
            'data' => $plan,
        ], 201);
    }

    public function assignPlan(Request $request, int $planId)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $plan = NutritionPlan::query()
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologo->id)
            ->first();

        if (!$plan) {
            return response()->json(['error' => 'Plan no encontrado.'], 404);
        }

        $validated = $request->validate([
            'client_id' => ['required', 'integer', 'exists:users,id'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'notes' => ['nullable', 'string'],
        ]);

        $assignment = NutritionPlanAssignment::query()->updateOrCreate(
            [
                'nutrition_plan_id' => $plan->id,
                'client_id' => $validated['client_id'],
                'starts_at' => $validated['starts_at'] ?? null,
            ],
            [
                'nutriologo_id' => $nutriologo->id,
                'assigned_at' => now()->toDateString(),
                'ends_at' => $validated['ends_at'] ?? null,
                'status' => 'active',
                'notes' => $validated['notes'] ?? null,
            ]
        );

        return response()->json([
            'message' => 'Plan asignado correctamente.',
            'data' => $assignment,
        ], 201);
    }

    public function updatePlan(Request $request, int $planId)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $plan = NutritionPlan::query()
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologo->id)
            ->first();

        if (!$plan) {
            return response()->json(['error' => 'Plan no encontrado.'], 404);
        }

        $validated = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'goal' => ['nullable', 'string', 'max:255'],
            'daily_calories' => ['nullable', 'integer', 'min:0', 'max:20000'],
            'macro_targets' => ['nullable', 'array'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'is_active' => ['sometimes', 'boolean'],
            'meals' => ['nullable', 'array'],
            'meals.*.meal_type' => ['required_with:meals', 'in:desayuno,colacion_1,comida,colacion_2,cena'],
            'meals.*.name' => ['required_with:meals', 'string', 'max:255'],
            'meals.*.portion' => ['nullable', 'string', 'max:255'],
            'meals.*.calories' => ['nullable', 'integer', 'min:0', 'max:10000'],
            'meals.*.protein_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.carbs_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.fat_g' => ['nullable', 'numeric', 'min:0', 'max:9999.99'],
            'meals.*.notes' => ['nullable', 'string'],
        ]);

        $plan = DB::transaction(function () use ($plan, $validated) {
            $plan->fill([
                'title' => $validated['title'] ?? $plan->title,
                'description' => $validated['description'] ?? $plan->description,
                'goal' => $validated['goal'] ?? $plan->goal,
                'daily_calories' => $validated['daily_calories'] ?? $plan->daily_calories,
                'macro_targets' => $validated['macro_targets'] ?? $plan->macro_targets,
                'starts_at' => array_key_exists('starts_at', $validated) ? $validated['starts_at'] : $plan->starts_at,
                'ends_at' => array_key_exists('ends_at', $validated) ? $validated['ends_at'] : $plan->ends_at,
                'is_active' => $validated['is_active'] ?? $plan->is_active,
            ]);
            $plan->save();

            if (array_key_exists('meals', $validated)) {
                $plan->meals()->delete();
                foreach (($validated['meals'] ?? []) as $index => $meal) {
                    NutritionPlanMeal::query()->create([
                        'nutrition_plan_id' => $plan->id,
                        'meal_type' => $meal['meal_type'],
                        'name' => $meal['name'],
                        'portion' => $meal['portion'] ?? null,
                        'calories' => $meal['calories'] ?? null,
                        'protein_g' => $meal['protein_g'] ?? null,
                        'carbs_g' => $meal['carbs_g'] ?? null,
                        'fat_g' => $meal['fat_g'] ?? null,
                        'notes' => $meal['notes'] ?? null,
                        'position' => $index,
                    ]);
                }
            }

            return $plan->load('meals');
        });

        return response()->json([
            'message' => 'Plan nutricional actualizado.',
            'data' => $plan,
        ]);
    }

    public function destroyPlan(Request $request, int $planId)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $plan = NutritionPlan::query()
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologo->id)
            ->first();

        if (!$plan) {
            return response()->json(['error' => 'Plan no encontrado.'], 404);
        }

        $plan->delete();

        return response()->json([
            'message' => 'Plan nutricional eliminado.',
        ]);
    }

    public function updateAssignmentStatus(Request $request, int $assignmentId)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $assignment = NutritionPlanAssignment::query()
            ->where('id', $assignmentId)
            ->where('nutriologo_id', $nutriologo->id)
            ->first();

        if (!$assignment) {
            return response()->json(['error' => 'Asignacion no encontrada.'], 404);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:active,paused,completed,cancelled'],
            'notes' => ['nullable', 'string'],
            'ends_at' => ['nullable', 'date'],
        ]);

        $assignment->status = $validated['status'];
        if (array_key_exists('notes', $validated)) {
            $assignment->notes = $validated['notes'];
        }
        if (array_key_exists('ends_at', $validated)) {
            $assignment->ends_at = $validated['ends_at'];
        }
        $assignment->save();

        return response()->json([
            'message' => 'Estado de asignacion actualizado.',
            'data' => $assignment,
        ]);
    }
}
