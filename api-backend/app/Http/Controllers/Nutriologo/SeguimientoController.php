<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use App\Models\DietChangeRequest;
use App\Models\Nutriologo;
use App\Models\NutritionPlanAssignment;
use App\Models\ProgressRecord;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SeguimientoController extends Controller
{
    private function currentNutriologoUser(Request $request): ?User
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return Cache::remember('seguimiento_user_'.md5($email), 300, function () use ($email) {
            return User::query()
                ->select(['user_id', 'name', 'email'])
                ->where('email', $email)
                ->first();
        });
    }

    private function getNutriologoProfile(int $userId): ?Nutriologo
    {
        return Cache::remember('seguimiento_nutriologo_'.$userId, 300, function () use ($userId) {
            return Nutriologo::where('user_id', $userId)->first();
        });
    }

    private function nutriologoClients(int $nutriologoUserId): array
    {
        $nutriologo = $this->getNutriologoProfile($nutriologoUserId);
        if (! $nutriologo) {
            return [];
        }

        // distinct() en DB, no en PHP
        return NutritionPlanAssignment::where('nutriologo_id', $nutriologo->id)
            ->distinct()
            ->pluck('client_id')
            ->toArray();
    }

    public function pacientes(Request $request)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $clientIds = $this->nutriologoClients($user->user_id);

        if (empty($clientIds)) {
            return response()->json(['data' => []]);
        }

        $patients = User::whereIn('user_id', $clientIds)
            ->select(['user_id', 'name', 'email'])
            ->get();

        // Un solo query para el último registro de progreso por cliente (MAX id = más reciente)
        $lastRecords = DB::table('progress_records as pr')
            ->joinSub(
                DB::table('progress_records')
                    ->selectRaw('client_id, MAX(id) as max_id')
                    ->whereIn('client_id', $clientIds)
                    ->groupBy('client_id'),
                'latest',
                fn ($join) => $join->on('pr.id', '=', 'latest.max_id')
            )
            ->select(['pr.client_id', 'pr.date', 'pr.weight_kg', 'pr.adherence_pct'])
            ->get()
            ->keyBy('client_id');

        // Un solo query para contar cambios de dieta pendientes por cliente
        $pendingCounts = DB::table('diet_change_requests')
            ->selectRaw('client_id, COUNT(*) as cnt')
            ->whereIn('client_id', $clientIds)
            ->where('status', 'pending')
            ->groupBy('client_id')
            ->pluck('cnt', 'client_id');

        $result = $patients->map(function ($client) use ($lastRecords, $pendingCounts) {
            $rec = $lastRecords->get($client->user_id);

            return [
                'id' => $client->user_id,
                'name' => $client->name,
                'email' => $client->email,
                'last_record_date' => $rec ? \Illuminate\Support\Carbon::parse($rec->date)->toDateString() : null,
                'last_weight_kg' => $rec?->weight_kg,
                'last_adherence' => $rec?->adherence_pct,
                'pending_changes' => (int) ($pendingCounts->get($client->user_id, 0)),
            ];
        });

        return response()->json(['data' => $result]);
    }

    public function historial(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $clientIds = $this->nutriologoClients($user->user_id);
        if (! in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $progress = ProgressRecord::byClient($clientId)
            ->with('author:user_id,name')
            ->orderByDesc('date')
            ->limit(150)
            ->get()
            ->map(fn ($r) => [
                'type' => 'progreso',
                'id' => $r->id,
                'date' => $r->date->toDateString(),
                'author_name' => $r->author?->name,
                'author_role' => $r->author_role,
                'weight_kg' => $r->weight_kg,
                'bmi' => $r->bmi,
                'body_fat_pct' => $r->body_fat_pct,
                'muscle_mass_kg' => $r->muscle_mass_kg,
                'calories_target' => $r->calories_target,
                'adherence_pct' => $r->adherence_pct,
                'notes' => $r->notes,
                'created_at' => $r->created_at->toISOString(),
            ]);

        $dietChanges = DietChangeRequest::byClient($clientId)
            ->with('proposer:user_id,name')
            ->orderByDesc('date')
            ->limit(150)
            ->get()
            ->map(fn ($d) => [
                'type' => 'cambio_dieta',
                'id' => $d->id,
                'date' => $d->date->toDateString(),
                'proposed_by' => $d->proposer?->name,
                'change_type' => $d->change_type,
                'previous_value' => $d->previous_value,
                'new_value' => $d->new_value,
                'reason' => $d->reason,
                'status' => $d->status,
                'client_response' => $d->client_response,
                'responded_at' => $d->responded_at?->toISOString(),
                'created_at' => $d->created_at->toISOString(),
            ]);

        $nutriologoProfile = $this->getNutriologoProfile($user->user_id);
        $planAssignments = collect();
        if ($nutriologoProfile) {
            $planAssignments = NutritionPlanAssignment::where('client_id', $clientId)
                ->where('nutriologo_id', $nutriologoProfile->id)
                ->with('nutritionPlan:id,title,goal,daily_calories')
                ->orderByDesc('assigned_at')
                ->get()
                ->map(fn ($a) => [
                    'type' => 'asignacion_plan',
                    'id' => $a->id,
                    'date' => ($a->assigned_at ?? $a->created_at)->toDateString(),
                    'plan_title' => $a->nutritionPlan?->title,
                    'plan_id' => $a->nutrition_plan_id,
                    'plan_goal' => $a->nutritionPlan?->goal,
                    'plan_calories' => $a->nutritionPlan?->daily_calories,
                    'status' => $a->status,
                    'notes' => $a->notes,
                    'starts_at' => $a->starts_at?->toDateString(),
                    'ends_at' => $a->ends_at?->toDateString(),
                    'created_at' => $a->created_at->toISOString(),
                ]);
        }

        $timeline = $progress->concat($dietChanges)->concat($planAssignments)
            ->sortByDesc('date')
            ->values();

        $client = User::find($clientId, ['user_id', 'name', 'email']);

        return response()->json([
            'client' => $client,
            'timeline' => $timeline,
        ]);
    }

    public function registrarProgreso(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $clientIds = $this->nutriologoClients($user->user_id);
        if (! in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $validated = $request->validate([
            'date' => 'required|date',
            'weight_kg' => 'nullable|numeric|min:0|max:500',
            'bmi' => 'nullable|numeric|min:0|max:100',
            'body_fat_pct' => 'nullable|numeric|min:0|max:100',
            'muscle_mass_kg' => 'nullable|numeric|min:0|max:300',
            'calories_target' => 'nullable|integer|min:0',
            'adherence_pct' => 'nullable|integer|min:0|max:100',
            'notes' => 'nullable|string|max:2000',
        ]);

        $record = ProgressRecord::create([
            ...$validated,
            'client_id' => $clientId,
            'author_id' => $user->user_id,
            'author_role' => 'nutriologo',
        ]);

        return response()->json(['data' => $record], 201);
    }

    public function actualizarProgreso(Request $request, int $recordId)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $record = ProgressRecord::where('id', $recordId)
            ->where('author_id', $user->user_id)
            ->firstOrFail();

        $validated = $request->validate([
            'date' => 'sometimes|date',
            'weight_kg' => 'nullable|numeric|min:0|max:500',
            'bmi' => 'nullable|numeric|min:0|max:100',
            'body_fat_pct' => 'nullable|numeric|min:0|max:100',
            'muscle_mass_kg' => 'nullable|numeric|min:0|max:300',
            'calories_target' => 'nullable|integer|min:0',
            'adherence_pct' => 'nullable|integer|min:0|max:100',
            'notes' => 'nullable|string|max:2000',
        ]);

        $record->update($validated);

        return response()->json(['data' => $record]);
    }

    public function eliminarProgreso(Request $request, int $recordId)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $record = ProgressRecord::where('id', $recordId)
            ->where('author_id', $user->user_id)
            ->firstOrFail();

        $record->delete();

        return response()->json(['message' => 'Registro eliminado'], 200);
    }

    public function proponerCambioDieta(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $clientIds = $this->nutriologoClients($user->user_id);
        if (! in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $validated = $request->validate([
            'change_type' => 'required|in:plan_change,meal_update,macro_adjust,calorie_adjust,observation',
            'reason' => 'required|string|max:2000',
            'previous_value' => 'nullable|array',
            'new_value' => 'nullable|array',
            'assignment_id' => 'nullable|exists:nutrition_plan_assignments,id',
            'date' => 'required|date',
        ]);

        $dietChange = DietChangeRequest::create([
            ...$validated,
            'client_id' => $clientId,
            'proposed_by' => $user->user_id,
            'status' => 'pending',
        ]);

        return response()->json(['data' => $dietChange], 201);
    }

    public function cambiosPendientes(Request $request)
    {
        $user = $this->currentNutriologoUser($request);
        if (! $user) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $pending = DietChangeRequest::byProposer($user->user_id)
            ->with('client:user_id,name,email')
            ->orderByDesc('created_at')
            ->limit(100)
            ->get()
            ->map(fn ($d) => [
                'id' => $d->id,
                'client_name' => $d->client?->name,
                'client_email' => $d->client?->email,
                'change_type' => $d->change_type,
                'reason' => $d->reason,
                'status' => $d->status,
                'client_response' => $d->client_response,
                'responded_at' => $d->responded_at?->toISOString(),
                'date' => $d->date->toDateString(),
            ]);

        return response()->json(['data' => $pending]);
    }
}
