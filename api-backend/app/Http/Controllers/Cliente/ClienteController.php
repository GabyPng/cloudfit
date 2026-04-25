<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use App\Models\DietChangeRequest;
use App\Models\User;
use Illuminate\Http\Request;

class ClienteController extends Controller
{
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
        return response()->json(['message' => 'Plan nutricional — por implementar.']);
    }

    public function progreso(Request $request)
    {
        return response()->json(['message' => 'Progreso del cliente — por implementar.']);
    }

    public function cambiosDieta(Request $request)
    {
        $clientUser = User::where('email', $request->attributes->get('supabase_email'))->first();
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
        $clientUser = User::where('email', $request->attributes->get('supabase_email'))->first();
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
