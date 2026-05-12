<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use App\Models\Client;
use App\Models\Nutriologo;
use App\Models\NutritionPlanAssignment;
use App\Models\NutritionPlan;
use App\Models\NutriologoContactRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class PerfilController extends Controller
{
    private function currentNutriologoAndUser(Request $request): ?array
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) return null;

        $user = Cache::remember('perfil_user_' . md5($email), 300, function () use ($email) {
            return User::select(['user_id', 'name', 'email'])
                ->where('email', $email)
                ->first();
        });

        if (!$user) return null;

        $nutriologo = Nutriologo::where('user_id', $user->user_id)->first();

        if (!$nutriologo) {
            $nutriologo = Nutriologo::create([
                'user_id'        => $user->user_id,
                'license_number' => 'PENDIENTE',
                'focus'          => 'General',
            ]);
        }

        Cache::forget('perfil_nutriologo_' . $user->user_id);

        return compact('user', 'nutriologo');
    }

    public function show(Request $request)
    {
        $ctx = $this->currentNutriologoAndUser($request);
        if (!$ctx) return response()->json(['error' => 'No autenticado'], 401);

        ['user' => $user, 'nutriologo' => $nutriologo] = $ctx;

        $totalPatients = NutritionPlanAssignment::where('nutriologo_id', $nutriologo->id)
            ->distinct('client_id')
            ->count('client_id');

        $activePatients = NutritionPlanAssignment::where('nutriologo_id', $nutriologo->id)
            ->where('status', 'active')
            ->distinct('client_id')
            ->count('client_id');

        $totalPlans = NutritionPlan::where('nutriologo_id', $nutriologo->id)->count();

        $pendingRequests = NutriologoContactRequest::byNutriologo($nutriologo->id)
            ->pending()
            ->count();

        return response()->json([
            'data' => [
                'user_id'            => $user->user_id,
                'name'               => $user->name,
                'email'              => $user->email,
                'license_number'     => $nutriologo->license_number,
                'focus'              => $nutriologo->focus,
                'bio'                => $nutriologo->bio,
                'specialties'        => $nutriologo->specialties ?? [],
                'experience_years'   => $nutriologo->experience_years,
                'location'           => $nutriologo->location,
                'consultation_price' => $nutriologo->consultation_price,
                'profile_visible'    => $nutriologo->profile_visible,
                'social_links'       => $nutriologo->social_links ?: new \stdClass(),
                'phone'              => $nutriologo->phone,
                'stats' => [
                    'total_patients'   => $totalPatients,
                    'active_patients'  => $activePatients,
                    'total_plans'      => $totalPlans,
                    'pending_requests' => $pendingRequests,
                ],
            ],
        ]);
    }

    public function update(Request $request)
    {
        $ctx = $this->currentNutriologoAndUser($request);
        if (!$ctx) return response()->json(['error' => 'No autenticado'], 401);

        ['nutriologo' => $nutriologo] = $ctx;

        $validated = $request->validate([
            'bio'                => 'nullable|string|max:2000',
            'specialties'        => 'nullable|array',
            'specialties.*'      => 'string|max:60',
            'experience_years'   => 'nullable|integer|min:0|max:50',
            'location'           => 'nullable|string|max:100',
            'consultation_price' => 'nullable|numeric|min:0|max:99999',
            'profile_visible'    => 'sometimes|boolean',
            'social_links'       => 'nullable|array',
            'social_links.instagram' => 'nullable|string|max:100',
            'social_links.website'   => 'nullable|url|max:255',
            'social_links.facebook'  => 'nullable|string|max:100',
            'phone'              => 'nullable|string|max:20',
            'focus'              => 'nullable|string|max:100',
        ]);

        $nutriologo->update($validated);

        Cache::forget('perfil_nutriologo_' . $nutriologo->user_id);

        return response()->json([
            'message' => 'Perfil actualizado.',
            'data'    => $nutriologo->fresh(),
        ]);
    }

    public function solicitudes(Request $request)
    {
        $ctx = $this->currentNutriologoAndUser($request);
        if (!$ctx) return response()->json(['error' => 'No autenticado'], 401);

        ['nutriologo' => $nutriologo] = $ctx;

        $status = $request->query('status', 'pending');
        $allowed = ['pending', 'accepted', 'rejected', 'all'];
        if (!in_array($status, $allowed)) $status = 'pending';

        $query = NutriologoContactRequest::byNutriologo($nutriologo->id)
            ->with([
                'client:user_id,name,email,avatar_url',
                'clientProfile:user_id,goal,birth_date',
            ])
            ->orderByDesc('created_at');

        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $solicitudes = $query->get()->map(function ($r) {
            $age = null;
            if ($r->clientProfile?->birth_date) {
                $age = now()->diffInYears($r->clientProfile->birth_date);
            }
            return [
                'id'                 => $r->id,
                'client_id'          => $r->client_id,
                'client_name'        => $r->client?->name,
                'client_email'       => $r->client?->email,
                'client_avatar'      => $r->client?->avatar_url,
                'client_goal'        => $r->clientProfile?->goal,
                'client_age'         => $age,
                'message'            => $r->message,
                'status'             => $r->status,
                'nutriologo_response'=> $r->nutriologo_response,
                'responded_at'       => $r->responded_at?->toISOString(),
                'created_at'         => $r->created_at->toISOString(),
            ];
        });

        return response()->json(['data' => $solicitudes]);
    }

    public function responderSolicitud(Request $request, int $id)
    {
        $ctx = $this->currentNutriologoAndUser($request);
        if (!$ctx) return response()->json(['error' => 'No autenticado'], 401);

        ['nutriologo' => $nutriologo] = $ctx;

        $solicitud = NutriologoContactRequest::byNutriologo($nutriologo->id)
            ->where('id', $id)
            ->firstOrFail();

        if ($solicitud->status !== 'pending') {
            return response()->json(['error' => 'Esta solicitud ya fue respondida.'], 422);
        }

        $validated = $request->validate([
            'status'   => 'required|in:accepted,rejected',
            'response' => 'nullable|string|max:500',
        ]);

        DB::transaction(function () use ($solicitud, $validated, $nutriologo) {
            $solicitud->update([
                'status'               => $validated['status'],
                'nutriologo_response'  => $validated['response'] ?? null,
                'responded_at'         => now(),
            ]);

            if ($validated['status'] === 'accepted') {
                // Assign this nutriólogo to the client's profile
                Client::updateOrCreate(
                    ['user_id' => $solicitud->client_id],
                    ['nutritionist_id' => $nutriologo->user_id]
                );

                // Reject any other pending requests from this client to other nutriólogos
                NutriologoContactRequest::where('client_id', $solicitud->client_id)
                    ->where('id', '!=', $solicitud->id)
                    ->where('status', 'pending')
                    ->update(['status' => 'rejected', 'responded_at' => now()]);
            } elseif ($validated['status'] === 'rejected') {
                // If this nutriólogo was already assigned, remove the link
                Client::where('user_id', $solicitud->client_id)
                    ->where('nutritionist_id', $nutriologo->user_id)
                    ->update(['nutritionist_id' => null]);
            }
        });

        return response()->json([
            'message' => $validated['status'] === 'accepted'
                ? 'Solicitud aceptada. El cliente ahora es tu paciente.'
                : 'Solicitud rechazada.',
            'data' => $solicitud->fresh(),
        ]);
    }
}
