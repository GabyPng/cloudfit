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

class NutriologoController extends Controller
{
    private function currentNutriologo(Request $request): ?Nutriologo
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return null;
        }

        $user = User::query()->where('email', $email)->first();
        if (!$user) {
            return null;
        }

        return Nutriologo::query()->where('user_id', $user->id)->first();
    }

    public function dashboard(Request $request)
    {
        $nutriologo = $this->currentNutriologo($request);
        if (!$nutriologo) {
            return response()->json(['error' => 'No user in token'], 401);
        }

        $stats = [
            'clientes_asignados' => NutritionPlanAssignment::query()
                ->where('nutriologo_id', $nutriologo->id)
                ->distinct('client_id')
                ->count('client_id'),
            'planes_totales' => NutritionPlan::query()
                ->where('nutriologo_id', $nutriologo->id)
                ->count(),
            'asignaciones_activas' => NutritionPlanAssignment::query()
                ->where('nutriologo_id', $nutriologo->id)
                ->where('status', 'active')
                ->count(),
        ];

        return response()->json([
            'message' => 'Bienvenido al panel de Nutriologo.',
            'section' => 'nutriologo',
            'stats' => $stats,
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

        $clientsQuery = User::query()
            ->select('users.id', 'users.name', 'users.email', 'users.avatar_url', 'users.objective')
            ->whereExists(function ($query) use ($nutriologo) {
                $query->select(DB::raw(1))
                    ->from('nutrition_plan_assignments as npa')
                    ->whereColumn('npa.client_id', 'users.id')
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
            ->with(['meals', 'assignments.client:id,name,email'])
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
