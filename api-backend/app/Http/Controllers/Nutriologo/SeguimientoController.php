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
        if (!$email) return null;

        return Cache::remember('seguimiento_user_' . md5($email), 300, function () use ($email) {
            return User::query()
                ->select(['user_id', 'name', 'email'])
                ->where('email', $email)
                ->first();
        });
    }

    private function getNutriologoProfile(int $userId): ?Nutriologo
    {
        return Cache::remember('seguimiento_nutriologo_' . $userId, 300, function () use ($userId) {
            return Nutriologo::where('user_id', $userId)->first();
        });
    }

    private function nutriologoClients(int $nutriologoUserId): array
    {
        $nutriologo = $this->getNutriologoProfile($nutriologoUserId);
        if (!$nutriologo) return [];

        return NutritionPlanAssignment::where('nutriologo_id', $nutriologo->id)
            ->pluck('client_id')
            ->unique()
            ->values()
            ->toArray();
    }

    public function pacientes(Request $request)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $clientIds = $this->nutriologoClients($user->user_id);

        $patients = User::whereIn('user_id', $clientIds)
            ->select(['user_id', 'name', 'email'])
            ->get()
            ->map(function ($client) {
                $lastRecord = ProgressRecord::byClient($client->user_id)
                    ->orderByDesc('date')
                    ->first(['date', 'weight_kg', 'adherence_pct']);

                $pendingChanges = DietChangeRequest::byClient($client->user_id)
                    ->pending()
                    ->count();

                return [
                    'id'              => $client->user_id,
                    'name'            => $client->name,
                    'email'           => $client->email,
                    'last_record_date'=> $lastRecord?->date?->toDateString(),
                    'last_weight_kg'  => $lastRecord?->weight_kg,
                    'last_adherence'  => $lastRecord?->adherence_pct,
                    'pending_changes' => $pendingChanges,
                ];
            });

        return response()->json(['data' => $patients]);
    }

    public function historial(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $clientIds = $this->nutriologoClients($user->user_id);
        if (!in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $progress = ProgressRecord::byClient($clientId)
            ->with('author:user_id,name')
            ->orderByDesc('date')
            ->get()
            ->map(fn($r) => [
                'type'           => 'progreso',
                'id'             => $r->id,
                'date'           => $r->date->toDateString(),
                'author_name'    => $r->author?->name,
                'author_role'    => $r->author_role,
                'weight_kg'      => $r->weight_kg,
                'bmi'            => $r->bmi,
                'body_fat_pct'   => $r->body_fat_pct,
                'muscle_mass_kg' => $r->muscle_mass_kg,
                'calories_target'=> $r->calories_target,
                'adherence_pct'  => $r->adherence_pct,
                'notes'          => $r->notes,
                'created_at'     => $r->created_at->toISOString(),
            ]);

        $dietChanges = DietChangeRequest::byClient($clientId)
            ->with('proposer:user_id,name')
            ->orderByDesc('date')
            ->get()
            ->map(fn($d) => [
                'type'           => 'cambio_dieta',
                'id'             => $d->id,
                'date'           => $d->date->toDateString(),
                'proposed_by'    => $d->proposer?->name,
                'change_type'    => $d->change_type,
                'previous_value' => $d->previous_value,
                'new_value'      => $d->new_value,
                'reason'         => $d->reason,
                'status'         => $d->status,
                'client_response'=> $d->client_response,
                'responded_at'   => $d->responded_at?->toISOString(),
                'created_at'     => $d->created_at->toISOString(),
            ]);

        $nutriologoProfile = $this->getNutriologoProfile($user->user_id);
        $planAssignments = collect();
        if ($nutriologoProfile) {
            $planAssignments = NutritionPlanAssignment::where('client_id', $clientId)
                ->where('nutriologo_id', $nutriologoProfile->id)
                ->with('nutritionPlan:id,title,goal,daily_calories')
                ->orderByDesc('assigned_at')
                ->get()
                ->map(fn($a) => [
                    'type'        => 'asignacion_plan',
                    'id'          => $a->id,
                    'date'        => ($a->assigned_at ?? $a->created_at)->toDateString(),
                    'plan_title'  => $a->nutritionPlan?->title,
                    'plan_id'     => $a->nutrition_plan_id,
                    'plan_goal'   => $a->nutritionPlan?->goal,
                    'plan_calories'=> $a->nutritionPlan?->daily_calories,
                    'status'      => $a->status,
                    'notes'       => $a->notes,
                    'starts_at'   => $a->starts_at?->toDateString(),
                    'ends_at'     => $a->ends_at?->toDateString(),
                    'created_at'  => $a->created_at->toISOString(),
                ]);
        }

        $timeline = $progress->concat($dietChanges)->concat($planAssignments)
            ->sortByDesc('date')
            ->values();

        $client = User::find($clientId, ['user_id', 'name', 'email']);

        return response()->json([
            'client'   => $client,
            'timeline' => $timeline,
        ]);
    }

    public function registrarProgreso(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $clientIds = $this->nutriologoClients($user->user_id);
        if (!in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $validated = $request->validate([
            'date'            => 'required|date',
            'weight_kg'       => 'nullable|numeric|min:0|max:500',
            'bmi'             => 'nullable|numeric|min:0|max:100',
            'body_fat_pct'    => 'nullable|numeric|min:0|max:100',
            'muscle_mass_kg'  => 'nullable|numeric|min:0|max:300',
            'calories_target' => 'nullable|integer|min:0',
            'adherence_pct'   => 'nullable|integer|min:0|max:100',
            'notes'           => 'nullable|string|max:2000',
        ]);

        $record = ProgressRecord::create([
            ...$validated,
            'client_id'   => $clientId,
            'author_id'   => $user->user_id,
            'author_role' => 'nutriologo',
        ]);

        return response()->json(['data' => $record], 201);
    }

    public function actualizarProgreso(Request $request, int $recordId)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $record = ProgressRecord::where('id', $recordId)
            ->where('author_id', $user->user_id)
            ->firstOrFail();

        $validated = $request->validate([
            'date'            => 'sometimes|date',
            'weight_kg'       => 'nullable|numeric|min:0|max:500',
            'bmi'             => 'nullable|numeric|min:0|max:100',
            'body_fat_pct'    => 'nullable|numeric|min:0|max:100',
            'muscle_mass_kg'  => 'nullable|numeric|min:0|max:300',
            'calories_target' => 'nullable|integer|min:0',
            'adherence_pct'   => 'nullable|integer|min:0|max:100',
            'notes'           => 'nullable|string|max:2000',
        ]);

        $record->update($validated);

        return response()->json(['data' => $record]);
    }

    public function eliminarProgreso(Request $request, int $recordId)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $record = ProgressRecord::where('id', $recordId)
            ->where('author_id', $user->user_id)
            ->firstOrFail();

        $record->delete();

        return response()->json(['message' => 'Registro eliminado'], 200);
    }

    public function proponerCambioDieta(Request $request, int $clientId)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $clientIds = $this->nutriologoClients($user->user_id);
        if (!in_array($clientId, $clientIds)) {
            return response()->json(['error' => 'Paciente no encontrado'], 404);
        }

        $validated = $request->validate([
            'change_type'    => 'required|in:plan_change,meal_update,macro_adjust,calorie_adjust,observation',
            'reason'         => 'required|string|max:2000',
            'previous_value' => 'nullable|array',
            'new_value'      => 'nullable|array',
            'assignment_id'  => 'nullable|exists:nutrition_plan_assignments,id',
            'date'           => 'required|date',
        ]);

        $dietChange = DietChangeRequest::create([
            ...$validated,
            'client_id'   => $clientId,
            'proposed_by' => $user->user_id,
            'status'      => 'pending',
        ]);

        return response()->json(['data' => $dietChange], 201);
    }

    public function cambiosPendientes(Request $request)
    {
        $user = $this->currentNutriologoUser($request);
        if (!$user) return response()->json(['error' => 'No autenticado'], 401);

        $pending = DietChangeRequest::byProposer($user->user_id)
            ->with('client:user_id,name,email')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn($d) => [
                'id'             => $d->id,
                'client_name'    => $d->client?->name,
                'client_email'   => $d->client?->email,
                'change_type'    => $d->change_type,
                'reason'         => $d->reason,
                'status'         => $d->status,
                'client_response'=> $d->client_response,
                'responded_at'   => $d->responded_at?->toISOString(),
                'date'           => $d->date->toDateString(),
            ]);

        return response()->json(['data' => $pending]);
    }
}
