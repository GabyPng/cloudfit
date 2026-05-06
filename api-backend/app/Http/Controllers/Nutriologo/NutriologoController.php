<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use App\Models\Nutriologo;
use App\Models\NutritionPlan;
use App\Models\NutritionPlanAssignment;
use App\Models\NutritionPlanMeal;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class NutriologoController extends Controller
{
    private function userColumnExists(string $column): bool
    {
        $columns = Cache::remember('schema_users_columns', 3600, function () {
            return array_flip(Schema::getColumnListing('users'));
        });

        return isset($columns[$column]);
    }

    private function currentNutriologo(Request $request): ?Nutriologo
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return null;
        }

        $cacheKey = 'nutriologo_profile_' . md5($email);

        return Cache::remember($cacheKey, 300, function () use ($email) {
            $user = User::query()
                ->select(['user_id', 'role_id', 'email'])
                ->with('role:role_id,name')
                ->where('email', $email)
                ->first();

            if (!$user) {
                return null;
            }

            $profile = Nutriologo::query()->where('user_id', $user->user_id)->first();
            if ($profile) {
                return $profile;
            }

            $roleName = mb_strtolower((string) ($user->role?->name ?? ''));
            if ($roleName === 'nutriologo') {
                return Nutriologo::query()->create([
                    'user_id' => $user->user_id,
                    'license_number' => 'PENDIENTE',
                    'focus' => 'General',
                    'certificate_uploads' => null,
                ]);
            }

            return null;
        });
    }

    private function latestAssignmentSubquery(int $nutriologoId)
    {
        // MAX(id) por cliente es suficiente: el ID mayor = asignación más reciente.
        // Reduce de 3 subqueries anidados a 1 subquery + 1 JOIN.
        $maxIds = DB::table('nutrition_plan_assignments')
            ->selectRaw('MAX(id) as max_id')
            ->where('nutriologo_id', $nutriologoId)
            ->groupBy('client_id');

        return DB::table('nutrition_plan_assignments as npa_latest')
            ->joinSub($maxIds, 'latest_ids', 'latest_ids.max_id', '=', 'npa_latest.id')
            ->leftJoin('nutrition_plans as np_latest', 'np_latest.id', '=', 'npa_latest.nutrition_plan_id')
            ->select([
                'npa_latest.id as la_id',
                'npa_latest.client_id as la_client_id',
                'npa_latest.nutrition_plan_id as la_plan_id',
                'npa_latest.status as la_status',
                'npa_latest.updated_at as la_updated_at',
                'np_latest.title as la_plan_title',
            ]);
    }

    public function dashboard(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $payload = Cache::remember("nutri_dashboard_{$nutriologo->id}", 30, function () use ($nutriologo) {
            return $this->buildDashboard($nutriologo);
        });

        return response()->json($payload);
    }

    private function buildDashboard($nutriologo): array
    {
        $startOfMonth = now()->startOfMonth();
        $endOfMonth = now()->endOfMonth();

        $assignmentSummary = NutritionPlanAssignment::query()
            ->where('nutriologo_id', $nutriologo->id)
            ->selectRaw('COUNT(*) as total_assignments')
            ->selectRaw("SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_assignments")
            ->selectRaw('COUNT(DISTINCT client_id) as total_clients')
            ->selectRaw(
                "COUNT(DISTINCT CASE
                    WHEN (
                        (assigned_at IS NOT NULL AND assigned_at BETWEEN ? AND ?)
                        OR (created_at BETWEEN ? AND ?)
                    ) THEN client_id
                END) as new_clients_month",
                [
                    $startOfMonth->toDateString(),
                    $endOfMonth->toDateString(),
                    $startOfMonth,
                    $endOfMonth,
                ]
            )
            ->selectRaw(
                "SUM(CASE
                    WHEN status IN ('paused', 'cancelled')
                      OR (ends_at IS NOT NULL AND ends_at < ?)
                    THEN 1 ELSE 0
                END) as alerts_count",
                [now()->toDateString()]
            )
            ->selectRaw(
                '(SELECT COUNT(*) FROM nutrition_plans WHERE nutriologo_id = ? AND is_active = true) as planes_activos',
                [$nutriologo->id]
            )
            ->first();

        $totalAssignments = (int) ($assignmentSummary?->total_assignments ?? 0);
        $activeAssignments = (int) ($assignmentSummary?->active_assignments ?? 0);

        $stats = [
            'total_pacientes'    => (int) ($assignmentSummary?->total_clients ?? 0),
            'nuevos_este_mes'    => (int) ($assignmentSummary?->new_clients_month ?? 0),
            'adherencia_promedio' => $totalAssignments > 0
                ? (int) round(($activeAssignments / $totalAssignments) * 100)
                : 0,
            'alertas_nutricionales' => (int) ($assignmentSummary?->alerts_count ?? 0),
            'planes_activos'     => (int) ($assignmentSummary?->planes_activos ?? 0),
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

        $latestPatientAssignmentIds = DB::query()
            ->fromSub($this->latestAssignmentSubquery($nutriologo->id), 'la')
            ->orderByDesc('la.la_updated_at')
            ->limit(8)
            ->pluck('la.la_id');

        $patientAssignments = NutritionPlanAssignment::query()
            ->with(['client:' . implode(',', $userFields), 'nutritionPlan:id,title'])
            ->whereIn('id', $latestPatientAssignmentIds)
            ->get()
            ->keyBy('id');

        $clientGoals = DB::table('clients')
            ->whereIn('user_id', $patientAssignments->pluck('client_id')->filter()->unique())
            ->pluck('goal', 'user_id');

        $pacientes = $latestPatientAssignmentIds
            ->map(fn ($assignmentId) => $patientAssignments->get($assignmentId))
            ->filter()
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

        return [
            'message' => 'Bienvenido al panel de Nutriologo.',
            'section' => 'nutriologo',
            'stats' => $stats,
            'pacientes' => $pacientes,
            'actividades' => $actividades,
        ];
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
            'users.user_id',
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
            ->where(function ($query) use ($nutriologo) {
                $query->where('clients.nutritionist_id', $nutriologo->user_id)
                    ->orWhereExists(function ($subQuery) use ($nutriologo) {
                        $subQuery->select(DB::raw(1))
                            ->from('nutrition_plan_assignments as npa')
                            ->whereColumn('npa.client_id', 'users.user_id')
                            ->where('npa.nutriologo_id', $nutriologo->id);
                    });
            });

        if ($search !== '') {
            $clientsQuery->where(function ($query) use ($search) {
                $query->where('users.name', 'like', "%{$search}%")
                    ->orWhere('users.email', 'like', "%{$search}%");
            });
        }

        $latestAssignment = $this->latestAssignmentSubquery($nutriologo->id);

        $clientsQuery
            ->leftJoinSub($latestAssignment, 'la', 'la.la_client_id', '=', 'users.user_id')
            ->addSelect([
                DB::raw('la.la_id as assignment_id'),
                DB::raw('la.la_plan_title as current_plan'),
                DB::raw('la.la_plan_id as current_plan_id'),
                DB::raw('la.la_status as status_key'),
                DB::raw('la.la_updated_at as last_update'),
            ]);

        $clients = $clientsQuery
            ->orderBy('users.name')
            ->paginate($perPage)
            ->withQueryString();

        $data = collect($clients->items())->map(function ($client) {
            $statusKey = $client->status_key ?? null;
            $isAlert = in_array($statusKey, ['paused', 'cancelled'], true);

            return [
                'id' => (int) $client->user_id,
                'name' => $client->name,
                'email' => $client->email,
                'avatar_url' => $client->avatar_url,
                'objective' => $client->objective,
                'assignment_id' => $client->assignment_id ? (int) $client->assignment_id : null,
                'current_plan' => $client->current_plan,
                'current_plan_id' => $client->current_plan_id ? (int) $client->current_plan_id : null,
                'status_key' => $statusKey,
                'status' => $isAlert ? 'alerta' : ($statusKey ?: 'sin_plan'),
                'status_label' => match ($statusKey) {
                    'active' => 'Seguimiento activo',
                    'paused' => 'Plan pausado',
                    'completed' => 'Objetivo cumplido',
                    'cancelled' => 'Requiere atención',
                    default => $client->current_plan ? 'Plan asignado' : 'Sin plan asignado',
                },
                'last_update' => $client->last_update
                    ? \Illuminate\Support\Carbon::parse($client->last_update)->diffForHumans()
                    : 'Sin seguimiento reciente',
            ];
        })->values();

        return response()->json([
            'data' => $data,
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

            $mealsData = [];
            foreach (($validated['meals'] ?? []) as $index => $meal) {
                $mealsData[] = [
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
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            if ($mealsData) {
                NutritionPlanMeal::insert($mealsData);
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
            'client_id' => ['required', 'integer', 'exists:users,user_id'],
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
                $mealsData = [];
                foreach (($validated['meals'] ?? []) as $index => $meal) {
                    $mealsData[] = [
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
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                }
                if ($mealsData) {
                    NutritionPlanMeal::insert($mealsData);
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
