<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use App\Models\Nutriologo;
use App\Models\NutriologoContactRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ClienteNutricionistasController extends Controller
{
    private function currentClientId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return Cache::remember('client_user_id_'.md5($email), 300, function () use ($email) {
            return User::where('email', $email)->value('user_id');
        });
    }

    /**
     * GET /api/cliente/nutriologos
     * Browse visible nutritionists with basic profile.
     */
    public function index(Request $request): JsonResponse
    {
        $clientId = $this->currentClientId($request);
        if (! $clientId) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $nutriologos = Nutriologo::query()
            ->where('profile_visible', true)
            ->with('user:user_id,name,email,avatar_url')
            ->get()
            ->map(fn ($n) => [
                'user_id' => $n->user_id,
                'nutriologo_id' => $n->id,
                'name' => $n->user?->name,
                'email' => $n->user?->email,
                'avatar_url' => $n->user?->avatar_url,
                'focus' => $n->focus,
                'bio' => $n->bio ? mb_substr($n->bio, 0, 120).(mb_strlen($n->bio ?? '') > 120 ? '…' : '') : null,
                'specialties' => $n->specialties ?? [],
                'experience_years' => $n->experience_years,
                'location' => $n->location,
                'consultation_price' => $n->consultation_price,
            ]);

        return response()->json(['data' => $nutriologos]);
    }

    /**
     * GET /api/cliente/nutriologos/{nutriologoUserId}
     * Full public profile of a nutritionist + request status for this client.
     */
    public function show(Request $request, int $nutriologoUserId): JsonResponse
    {
        $clientId = $this->currentClientId($request);
        if (! $clientId) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $nutriologo = Nutriologo::where('user_id', $nutriologoUserId)
            ->where('profile_visible', true)
            ->with('user:user_id,name,email,avatar_url')
            ->first();

        if (! $nutriologo) {
            return response()->json(['error' => 'Nutriólogo no encontrado o perfil no visible.'], 404);
        }

        $solicitud = NutriologoContactRequest::where('nutriologo_id', $nutriologo->id)
            ->where('client_id', $clientId)
            ->latest()
            ->first();

        // True when the client already has an accepted relationship with a *different* nutriólogo
        $hasActiveNutritionist = NutriologoContactRequest::where('client_id', $clientId)
            ->where('status', 'accepted')
            ->where('nutriologo_id', '!=', $nutriologo->id)
            ->exists();

        return response()->json([
            'data' => [
                'user_id' => $nutriologo->user_id,
                'nutriologo_id' => $nutriologo->id,
                'name' => $nutriologo->user?->name,
                'email' => $nutriologo->user?->email,
                'avatar_url' => $nutriologo->user?->avatar_url,
                'license_number' => $nutriologo->license_number,
                'focus' => $nutriologo->focus,
                'bio' => $nutriologo->bio,
                'specialties' => $nutriologo->specialties ?? [],
                'experience_years' => $nutriologo->experience_years,
                'location' => $nutriologo->location,
                'consultation_price' => $nutriologo->consultation_price,
                'phone' => $nutriologo->phone,
                'social_links' => $nutriologo->social_links ?: new \stdClass,
                'has_active_nutritionist' => $hasActiveNutritionist,
                'request' => $solicitud ? [
                    'id' => $solicitud->id,
                    'status' => $solicitud->status,
                    'message' => $solicitud->message,
                    'nutriologo_response' => $solicitud->nutriologo_response,
                    'responded_at' => $solicitud->responded_at?->toISOString(),
                    'created_at' => $solicitud->created_at->toISOString(),
                ] : null,
            ],
        ]);
    }

    /**
     * POST /api/cliente/nutriologos/{nutriologoUserId}/solicitar
     * Send or re-send a contact request to a nutritionist.
     */
    public function solicitar(Request $request, int $nutriologoUserId): JsonResponse
    {
        $clientId = $this->currentClientId($request);
        if (! $clientId) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $nutriologo = Nutriologo::where('user_id', $nutriologoUserId)->first();
        if (! $nutriologo) {
            return response()->json(['error' => 'Nutriólogo no encontrado.'], 404);
        }

        $validated = $request->validate([
            'message' => 'nullable|string|max:500',
        ]);

        // Block if the client already has an accepted relationship with ANY nutriólogo
        $activeWithOther = NutriologoContactRequest::where('client_id', $clientId)
            ->where('status', 'accepted')
            ->first();

        if ($activeWithOther) {
            return response()->json([
                'message' => 'Ya tienes un nutriólogo asignado. Finaliza esa relación antes de contactar a otro.',
                'code' => 'has_active_nutritionist',
            ], 422);
        }

        // Check for existing request with this specific nutriólogo
        $existing = NutriologoContactRequest::where('nutriologo_id', $nutriologo->id)
            ->where('client_id', $clientId)
            ->first();

        if ($existing && in_array($existing->status, ['pending', 'accepted'])) {
            return response()->json([
                'message' => $existing->status === 'accepted'
                    ? 'Ya tienes una solicitud aceptada con este nutriólogo.'
                    : 'Ya tienes una solicitud pendiente con este nutriólogo.',
                'data' => [
                    'id' => $existing->id,
                    'status' => $existing->status,
                ],
            ], 422);
        }

        // Create or re-activate a rejected request (unique constraint: update if exists)
        $solicitud = NutriologoContactRequest::updateOrCreate(
            ['nutriologo_id' => $nutriologo->id, 'client_id' => $clientId],
            [
                'message' => $validated['message'] ?? null,
                'status' => 'pending',
                'nutriologo_response' => null,
                'responded_at' => null,
            ]
        );

        return response()->json([
            'message' => 'Solicitud enviada. El nutriólogo revisará tu solicitud pronto.',
            'data' => [
                'id' => $solicitud->id,
                'status' => $solicitud->status,
                'created_at' => $solicitud->created_at->toISOString(),
            ],
        ], 201);
    }

    /**
     * GET /api/cliente/solicitudes-nutriologo
     * List all requests made by this client.
     */
    public function misSolicitudes(Request $request): JsonResponse
    {
        $clientId = $this->currentClientId($request);
        if (! $clientId) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $solicitudes = NutriologoContactRequest::where('client_id', $clientId)
            ->with('nutriologo.user:user_id,name,email,avatar_url')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($s) => [
                'id' => $s->id,
                'status' => $s->status,
                'message' => $s->message,
                'nutriologo_response' => $s->nutriologo_response,
                'responded_at' => $s->responded_at?->toISOString(),
                'created_at' => $s->created_at->toISOString(),
                'nutriologo_name' => $s->nutriologo?->user?->name,
                'nutriologo_email' => $s->nutriologo?->user?->email,
                'nutriologo_avatar' => $s->nutriologo?->user?->avatar_url,
                'nutriologo_focus' => $s->nutriologo?->focus,
                'nutriologo_user_id' => $s->nutriologo?->user_id,
            ]);

        return response()->json(['data' => $solicitudes]);
    }
}
