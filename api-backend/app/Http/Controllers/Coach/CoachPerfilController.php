<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Models\Coach;
use App\Models\User;
use Illuminate\Http\Request;

class CoachPerfilController extends Controller
{
    private function currentCoach(Request $request): ?array
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        $user = User::select(['user_id', 'name', 'email', 'avatar_url'])
            ->where('email', $email)
            ->first();

        if (! $user) {
            return null;
        }

        $coach = Coach::firstOrCreate(['user_id' => $user->user_id]);

        return compact('user', 'coach');
    }

    public function show(Request $request)
    {
        $ctx = $this->currentCoach($request);
        if (! $ctx) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        ['user' => $user, 'coach' => $coach] = $ctx;

        return response()->json([
            'data' => [
                'user_id' => $user->user_id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar_url' => $user->avatar_url,
                'bio' => $coach->bio,
                'specialty' => $coach->specialty,
                'specialties' => $coach->specialties ?? [],
                'experience_years' => $coach->experience_years,
                'location' => $coach->location,
                'session_price' => $coach->session_price,
                'profile_visible' => $coach->profile_visible,
                'social_links' => $coach->social_links ?: new \stdClass,
                'phone' => $coach->phone,
                'is_verified' => $coach->is_verified,
                'certificate_uploads' => $coach->certificate_uploads ?? [],
            ],
        ]);
    }

    public function update(Request $request)
    {
        $ctx = $this->currentCoach($request);
        if (! $ctx) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        ['coach' => $coach] = $ctx;

        $validated = $request->validate([
            'bio' => 'nullable|string|max:2000',
            'specialty' => 'nullable|string|max:100',
            'specialties' => 'nullable|array',
            'specialties.*' => 'string|max:60',
            'experience_years' => 'nullable|integer|min:0|max:50',
            'location' => 'nullable|string|max:100',
            'session_price' => 'nullable|numeric|min:0|max:99999',
            'profile_visible' => 'sometimes|boolean',
            'social_links' => 'nullable|array',
            'social_links.instagram' => 'nullable|string|max:100',
            'social_links.website' => 'nullable|url|max:255',
            'social_links.facebook' => 'nullable|string|max:100',
            'phone' => 'nullable|string|max:20',
        ]);

        $coach->update($validated);

        return response()->json(['message' => 'Perfil actualizado.', 'data' => $coach->fresh()]);
    }

    public function uploadCertificates(Request $request)
    {
        $ctx = $this->currentCoach($request);
        if (! $ctx) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        ['coach' => $coach] = $ctx;

        $validated = $request->validate([
            'certificates' => 'required|array|max:3',
            'certificates.*' => [
                'required',
                'array',
            ],
        ]);

        $existing = $coach->certificate_uploads ?? [];
        $merged = array_merge($existing, $validated['certificates']);

        $coach->update(['certificate_uploads' => $merged]);

        return response()->json(['message' => 'Certificados actualizados.', 'data' => $merged]);
    }
}
