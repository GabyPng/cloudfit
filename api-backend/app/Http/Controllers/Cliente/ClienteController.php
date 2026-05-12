<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use App\Models\DietChangeRequest;
use App\Models\NutritionPlanAssignment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ClienteController extends Controller
{
    private function clientUser(Request $request): ?User
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) return null;

        return Cache::remember('client_user_' . md5($email), 300, fn() => User::where('email', $email)->first());
    }

    public function dashboard(Request $request)
    {
        return response()->json([
            'message' => 'Bienvenido a tu panel, ' . $request->user()->name . '.',
            'section' => 'cliente',
        ]);
    }

    public function planEntrenamiento(Request $request)
    {
        return response()->json(['message' => 'Plan de entrenamiento — por implementar.']);
    }

    public function planNutricional(Request $request)
    {
        $clientUser = $this->clientUser($request);
        if (!$clientUser) return response()->json(['error' => 'No autenticado'], 401);

        $assignment = NutritionPlanAssignment::where('client_id', $clientUser->user_id)
            ->where('status', 'active')
            ->with(['nutritionPlan.meals' => fn($q) => $q->orderBy('position')])
            ->latest('assigned_at')
            ->first();

        if (!$assignment) return response()->json(['data' => null], 404);

        $plan = $assignment->nutritionPlan;

        return response()->json([
            'data' => [
                'id'             => $plan->id,
                'title'          => $plan->title,
                'description'    => $plan->description,
                'goal'           => $plan->goal,
                'daily_calories' => $plan->daily_calories,
                'macro_targets'  => $plan->macro_targets,
                'is_active'      => $plan->is_active,
                'starts_at'      => $assignment->starts_at?->toDateString(),
                'ends_at'        => $assignment->ends_at?->toDateString(),
                'meals'          => $plan->meals->map(fn($m) => [
                    'id'          => $m->id,
                    'meal_type'   => $m->meal_type,
                    'name'        => $m->name,
                    'portion'     => $m->portion,
                    'calories'    => $m->calories,
                    'protein_g'   => $m->protein_g,
                    'carbs_g'     => $m->carbs_g,
                    'fat_g'       => $m->fat_g,
                    'notes'       => $m->notes,
                    'position'    => $m->position,
                ]),
            ],
        ]);
    }

    public function progreso(Request $request)
    {
        return response()->json(['message' => 'Progreso del cliente — por implementar.']);
    }

    public function cambiosDieta(Request $request)
    {
        $clientUser = $this->clientUser($request);
        if (!$clientUser) return response()->json(['error' => 'No autenticado'], 401);

        $changes = DietChangeRequest::byClient($clientUser->user_id)
            ->with('proposer:user_id,name')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn($d) => [
                'id'             => $d->id,
                'proposed_by'    => $d->proposer?->name,
                'change_type'    => $d->change_type,
                'previous_value' => $d->previous_value,
                'new_value'      => $d->new_value,
                'reason'         => $d->reason,
                'status'         => $d->status,
                'client_response'=> $d->client_response,
                'responded_at'   => $d->responded_at?->toISOString(),
                'date'           => $d->date->toDateString(),
            ]);

        return response()->json(['data' => $changes]);
    }

    public function responderCambioDieta(Request $request, int $id)
    {
        $clientUser = $this->clientUser($request);
        if (!$clientUser) return response()->json(['error' => 'No autenticado'], 401);

        $change = DietChangeRequest::where('id', $id)
            ->where('client_id', $clientUser->user_id)
            ->where('status', 'pending')
            ->firstOrFail();

        $validated = $request->validate([
            'status'          => 'required|in:approved,rejected',
            'client_response' => 'nullable|string|max:1000',
        ]);

        $change->update([
            'status'          => $validated['status'],
            'client_response' => $validated['client_response'] ?? null,
            'responded_at'    => now(),
        ]);

        return response()->json(['data' => $change]);
    }
}
