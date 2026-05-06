<?php

namespace App\Services\Chatbot;

use App\Models\Nutriologo;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class QueryExecutor
{
    public static function execute(string $intent, User $user, array $params = []): mixed
    {
        return match ($intent) {
            'coach.client_list' => self::coachClientList($user->id),
            'coach.client_routines' => self::coachClientRoutines($user->id, $params['client_id'] ?? null),
            'coach.routine_detail' => self::coachRoutineDetail($user->id, $params['routine_id'] ?? null),
            'coach.client_progress' => self::coachClientProgress($user->id, $params['client_id'] ?? null),
            'coach.exercise_search' => self::coachExerciseSearch($user->id, (string) ($params['search_term'] ?? '')),

            'nutri.client_list' => self::nutriClientList($user->id),
            'nutri.client_plans' => self::nutriClientPlans($user->id, $params['client_id'] ?? null),
            'nutri.plan_detail' => self::nutriPlanDetail($user->id, $params['plan_id'] ?? null),
            'nutri.plan_macros' => self::nutriPlanMacros($user->id, $params['plan_id'] ?? null),
            'nutri.client_active_plan' => self::nutriClientActivePlan($user->id, $params['client_id'] ?? null),
            'nutri.meal_detail' => self::nutriMealDetail($user->id, $params['plan_id'] ?? null),

            'client.my_routines' => self::clientMyRoutines($user->id),
            'client.routine_detail' => self::clientRoutineDetail($user->id, $params['routine_id'] ?? null),
            'client.my_nutrition' => self::clientMyNutrition($user->id),
            'client.my_meals' => self::clientMyMeals($user->id),
            'client.my_macros' => self::clientMyMacros($user->id),
            'client.my_coach' => self::clientMyCoach($user->id),
            'client.my_nutri' => self::clientMyNutri($user->id),
            'client.general_tip' => [],

            default => ['error' => 'Intent no reconocido.'],
        };
    }

    private static function coachClientList(int $coachUserId): array
    {
        return DB::table('clients as c')
            ->join('users as u', 'u.user_id', '=', 'c.user_id')
            ->where('c.coach_id', $coachUserId)
            ->select('u.user_id as id', 'u.name', 'u.email', 'u.created_at')
            ->orderBy('u.name')
            ->get()
            ->toArray();
    }

    private static function coachClientRoutines(int $coachUserId, mixed $clientId): mixed
    {
        $clientId = (int) $clientId;
        if ($clientId <= 0) {
            return ['error' => 'Se requiere client_id.'];
        }

        $owns = DB::table('clients')
            ->where('user_id', $clientId)
            ->where('coach_id', $coachUserId)
            ->exists();

        if (! $owns) {
            return ['error' => 'No tienes permiso para ver datos de este cliente.'];
        }

        return DB::table('routines')
            ->where('client_id', $clientId)
            ->where('coach_id', $coachUserId)
            ->select('id', 'name', 'description', 'is_active', 'created_at')
            ->latest('created_at')
            ->get()
            ->toArray();
    }

    private static function coachRoutineDetail(int $coachUserId, mixed $routineId): mixed
    {
        $routineId = (int) $routineId;
        if ($routineId <= 0) {
            return ['error' => 'Se requiere routine_id.'];
        }

        $routine = DB::table('routines')
            ->where('id', $routineId)
            ->where('coach_id', $coachUserId)
            ->first();

        if (! $routine) {
            return ['error' => 'Rutina no encontrada o sin permiso.'];
        }

        $exercises = DB::table('routine_exercises')
            ->where('routine_id', $routineId)
            ->select('exercise_name', 'sets', 'reps', 'rest_time', 'notes', 'order')
            ->orderBy('order')
            ->get()
            ->toArray();

        return [
            'routine' => $routine,
            'exercises' => $exercises,
        ];
    }

    private static function coachClientProgress(int $coachUserId, mixed $clientId): mixed
    {
        $clientId = (int) $clientId;
        if ($clientId <= 0) {
            return ['error' => 'Se requiere client_id.'];
        }

        $owns = DB::table('clients')
            ->where('user_id', $clientId)
            ->where('coach_id', $coachUserId)
            ->exists();

        if (! $owns) {
            return ['error' => 'No tienes permiso para ver datos de este cliente.'];
        }

        $routines = DB::table('routines')
            ->where('client_id', $clientId)
            ->where('coach_id', $coachUserId)
            ->select('id', 'name', 'is_active', 'created_at')
            ->get();

        return [
            'total_routines' => $routines->count(),
            'active_routines' => $routines->where('is_active', true)->count(),
            'inactive_routines' => $routines->where('is_active', false)->count(),
            'routines' => $routines->values()->toArray(),
        ];
    }

    private static function coachExerciseSearch(int $coachUserId, string $term): mixed
    {
        $term = trim($term);
        if ($term === '') {
            return ['error' => 'Se requiere search_term para buscar ejercicios.'];
        }

        return DB::table('routine_exercises as re')
            ->join('routines as r', 'r.id', '=', 're.routine_id')
            ->where('r.coach_id', $coachUserId)
            ->where(function ($query) use ($term) {
                $query->where('re.exercise_name', 'like', "%{$term}%")
                    ->orWhere('re.notes', 'like', "%{$term}%");
            })
            ->select('re.exercise_name', 're.sets', 're.reps', 're.rest_time', 're.notes')
            ->distinct()
            ->limit(10)
            ->get()
            ->toArray();
    }

    private static function nutriClientList(int $nutriUserId): mixed
    {
        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        return DB::table('users')
            ->where(function ($q) use ($nutriUserId, $nutriologoId) {
                $q->whereExists(function ($sub) use ($nutriologoId) {
                    $sub->select(DB::raw(1))
                        ->from('nutrition_plan_assignments as npa')
                        ->whereColumn('npa.client_id', 'users.user_id')
                        ->where('npa.nutriologo_id', $nutriologoId);
                })->orWhereExists(function ($sub) use ($nutriUserId) {
                    $sub->select(DB::raw(1))
                        ->from('clients as c')
                        ->whereColumn('c.user_id', 'users.user_id')
                        ->where('c.nutritionist_id', $nutriUserId);
                });
            })
            ->select('users.user_id as id', 'users.name', 'users.email')
            ->distinct()
            ->orderBy('users.name')
            ->get()
            ->toArray();
    }

    private static function nutriClientPlans(int $nutriUserId, mixed $clientId): mixed
    {
        $clientId = (int) $clientId;
        if ($clientId <= 0) {
            return ['error' => 'Se requiere client_id.'];
        }

        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        $owns = DB::table('nutrition_plan_assignments')
            ->where('client_id', $clientId)
            ->where('nutriologo_id', $nutriologoId)
            ->exists();

        if (! $owns) {
            return ['error' => 'No tienes permiso para ver datos de este cliente.'];
        }

        return DB::table('nutrition_plan_assignments as npa')
            ->join('nutrition_plans as np', 'np.id', '=', 'npa.nutrition_plan_id')
            ->where('npa.client_id', $clientId)
            ->where('npa.nutriologo_id', $nutriologoId)
            ->select('np.id', 'np.title', 'np.goal', 'np.daily_calories', 'np.macro_targets', 'npa.status', 'npa.starts_at', 'npa.ends_at')
            ->latest('npa.created_at')
            ->get()
            ->toArray();
    }

    private static function nutriPlanDetail(int $nutriUserId, mixed $planId): mixed
    {
        $planId = (int) $planId;
        if ($planId <= 0) {
            return ['error' => 'Se requiere plan_id.'];
        }

        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        $plan = DB::table('nutrition_plans')
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologoId)
            ->first();

        if (! $plan) {
            return ['error' => 'Plan no encontrado o sin permiso.'];
        }

        $meals = DB::table('nutrition_plan_meals')
            ->where('nutrition_plan_id', $planId)
            ->select('meal_type', 'name', 'portion', 'calories', 'protein_g', 'carbs_g', 'fat_g', 'notes', 'position')
            ->orderBy('position')
            ->get()
            ->toArray();

        return [
            'plan' => $plan,
            'meals' => $meals,
        ];
    }

    private static function nutriPlanMacros(int $nutriUserId, mixed $planId): mixed
    {
        $planId = (int) $planId;
        if ($planId <= 0) {
            return ['error' => 'Se requiere plan_id.'];
        }

        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        $data = DB::table('nutrition_plans')
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologoId)
            ->select('title', 'daily_calories', 'macro_targets')
            ->first();

        return $data ?: ['error' => 'Plan no encontrado o sin permiso.'];
    }

    private static function nutriClientActivePlan(int $nutriUserId, mixed $clientId): mixed
    {
        $clientId = (int) $clientId;
        if ($clientId <= 0) {
            return ['error' => 'Se requiere client_id.'];
        }

        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        $plan = DB::table('nutrition_plan_assignments as npa')
            ->join('nutrition_plans as np', 'np.id', '=', 'npa.nutrition_plan_id')
            ->where('npa.client_id', $clientId)
            ->where('npa.nutriologo_id', $nutriologoId)
            ->where('npa.status', 'active')
            ->select('np.id', 'np.title', 'np.goal', 'np.daily_calories', 'np.macro_targets', 'npa.starts_at', 'npa.ends_at')
            ->latest('npa.created_at')
            ->first();

        return $plan ?: ['error' => 'No se encontró un plan activo para este cliente.'];
    }

    private static function nutriMealDetail(int $nutriUserId, mixed $planId): mixed
    {
        $planId = (int) $planId;
        if ($planId <= 0) {
            return ['error' => 'Se requiere plan_id.'];
        }

        $nutriologoId = self::nutriologoIdFromUserId($nutriUserId);
        if (! $nutriologoId) {
            return ['error' => 'No se encontró perfil de nutriólogo.'];
        }

        $owns = DB::table('nutrition_plans')
            ->where('id', $planId)
            ->where('nutriologo_id', $nutriologoId)
            ->exists();

        if (! $owns) {
            return ['error' => 'No tienes permiso para ver este plan.'];
        }

        return DB::table('nutrition_plan_meals')
            ->where('nutrition_plan_id', $planId)
            ->select('meal_type', 'name', 'portion', 'calories', 'protein_g', 'carbs_g', 'fat_g', 'notes', 'position')
            ->orderBy('position')
            ->get()
            ->toArray();
    }

    private static function clientMyRoutines(int $userId): array
    {
        return DB::table('routines')
            ->where('client_id', $userId)
            ->select('id', 'name', 'description', 'is_active', 'created_at')
            ->latest('created_at')
            ->get()
            ->toArray();
    }

    private static function clientRoutineDetail(int $userId, mixed $routineId): mixed
    {
        $routineId = (int) $routineId;
        if ($routineId <= 0) {
            return ['error' => 'Se requiere routine_id.'];
        }

        $routine = DB::table('routines')
            ->where('id', $routineId)
            ->where('client_id', $userId)
            ->first();

        if (! $routine) {
            return ['error' => 'Rutina no encontrada o sin permiso.'];
        }

        $exercises = DB::table('routine_exercises')
            ->where('routine_id', $routineId)
            ->select('exercise_name', 'sets', 'reps', 'rest_time', 'notes', 'order')
            ->orderBy('order')
            ->get()
            ->toArray();

        return [
            'routine' => $routine,
            'exercises' => $exercises,
        ];
    }

    private static function clientMyNutrition(int $userId): mixed
    {
        $plan = DB::table('nutrition_plan_assignments as npa')
            ->join('nutrition_plans as np', 'np.id', '=', 'npa.nutrition_plan_id')
            ->where('npa.client_id', $userId)
            ->where('npa.status', 'active')
            ->select('np.id', 'np.title', 'np.goal', 'np.daily_calories', 'np.macro_targets', 'npa.starts_at', 'npa.ends_at')
            ->latest('npa.created_at')
            ->first();

        return $plan ?: ['error' => 'No tienes un plan nutricional activo.'];
    }

    private static function clientMyMeals(int $userId): mixed
    {
        $assignment = DB::table('nutrition_plan_assignments')
            ->where('client_id', $userId)
            ->where('status', 'active')
            ->latest('created_at')
            ->first();

        if (! $assignment) {
            return ['error' => 'No tienes un plan nutricional activo.'];
        }

        return DB::table('nutrition_plan_meals')
            ->where('nutrition_plan_id', $assignment->nutrition_plan_id)
            ->select('meal_type', 'name', 'portion', 'calories', 'protein_g', 'carbs_g', 'fat_g', 'notes', 'position')
            ->orderBy('position')
            ->get()
            ->toArray();
    }

    private static function clientMyMacros(int $userId): mixed
    {
        $macros = DB::table('nutrition_plan_assignments as npa')
            ->join('nutrition_plans as np', 'np.id', '=', 'npa.nutrition_plan_id')
            ->where('npa.client_id', $userId)
            ->where('npa.status', 'active')
            ->select('np.title', 'np.daily_calories', 'np.macro_targets')
            ->latest('npa.created_at')
            ->first();

        return $macros ?: ['error' => 'No tienes un plan nutricional activo.'];
    }

    private static function clientMyCoach(int $userId): mixed
    {
        $coachId = DB::table('clients')->where('user_id', $userId)->value('coach_id');
        if (! $coachId) {
            return ['error' => 'No tienes coach asignado.'];
        }

        return DB::table('users')
            ->where('user_id', $coachId)
            ->select('user_id as id', 'name', 'email')
            ->first();
    }

    private static function clientMyNutri(int $userId): mixed
    {
        $nutri = DB::table('nutrition_plan_assignments as npa')
            ->join('nutriologos as n', 'n.id', '=', 'npa.nutriologo_id')
            ->join('users as u', 'u.user_id', '=', 'n.user_id')
            ->where('npa.client_id', $userId)
            ->where('npa.status', 'active')
            ->select('u.user_id as id', 'u.name', 'u.email', 'n.focus')
            ->latest('npa.created_at')
            ->first();

        return $nutri ?: ['error' => 'No tienes nutriólogo asignado actualmente.'];
    }

    private static function nutriologoIdFromUserId(int $userId): ?int
    {
        return Nutriologo::query()->where('user_id', $userId)->value('id');
    }
}
