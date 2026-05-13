<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Coach;
use App\Models\Nutriologo;
use App\Models\User;
use Illuminate\Http\Request;

class ProfessionalValidationController extends Controller
{
    private function adminUserId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return User::where('email', $email)->value('user_id');
    }

    public function index(Request $request)
    {
        $status = $request->query('status'); // pending | verified | rejected | all

        $coaches = Coach::with('user:user_id,name,email,avatar_url')
            ->when($status === 'pending', fn ($q) => $q->where('is_verified', false)->whereNull('rejection_reason'))
            ->when($status === 'verified', fn ($q) => $q->where('is_verified', true))
            ->when($status === 'rejected', fn ($q) => $q->where('is_verified', false)->whereNotNull('rejection_reason'))
            ->get()
            ->map(fn ($c) => $this->formatProfessional($c, 'coach'));

        $nutriologos = Nutriologo::with('user:user_id,name,email,avatar_url')
            ->when($status === 'pending', fn ($q) => $q->where('is_verified', false)->whereNull('rejection_reason'))
            ->when($status === 'verified', fn ($q) => $q->where('is_verified', true))
            ->when($status === 'rejected', fn ($q) => $q->where('is_verified', false)->whereNotNull('rejection_reason'))
            ->get()
            ->map(fn ($n) => $this->formatProfessional($n, 'nutriologo'));

        $all = $coaches->concat($nutriologos)->sortByDesc('created_at')->values();

        return response()->json(['data' => $all]);
    }

    public function show(int $userId)
    {
        $coach = Coach::with('user:user_id,name,email,avatar_url')->where('user_id', $userId)->first();
        if ($coach) {
            return response()->json(['data' => $this->formatProfessional($coach, 'coach')]);
        }

        $nutriologo = Nutriologo::with('user:user_id,name,email,avatar_url')->where('user_id', $userId)->first();
        if ($nutriologo) {
            return response()->json(['data' => $this->formatProfessional($nutriologo, 'nutriologo')]);
        }

        return response()->json(['error' => 'Profesionista no encontrado.'], 404);
    }

    public function verify(Request $request, int $userId)
    {
        $adminId = $this->adminUserId($request);

        $updated = false;

        if ($coach = Coach::where('user_id', $userId)->first()) {
            $coach->update([
                'is_verified' => true,
                'verified_at' => now(),
                'verified_by' => $adminId,
                'rejection_reason' => null,
            ]);
            $updated = true;
        }

        if ($nutriologo = Nutriologo::where('user_id', $userId)->first()) {
            $nutriologo->update([
                'is_verified' => true,
                'verified_at' => now(),
                'verified_by' => $adminId,
                'rejection_reason' => null,
            ]);
            $updated = true;
        }

        if (! $updated) {
            return response()->json(['error' => 'Profesionista no encontrado.'], 404);
        }

        return response()->json(['message' => 'Profesionista verificado.']);
    }

    public function reject(Request $request, int $userId)
    {
        $validated = $request->validate([
            'reason' => 'required|string|max:500',
        ]);

        $adminId = $this->adminUserId($request);
        $updated = false;

        if ($coach = Coach::where('user_id', $userId)->first()) {
            $coach->update([
                'is_verified' => false,
                'verified_at' => null,
                'verified_by' => $adminId,
                'rejection_reason' => $validated['reason'],
            ]);
            $updated = true;
        }

        if ($nutriologo = Nutriologo::where('user_id', $userId)->first()) {
            $nutriologo->update([
                'is_verified' => false,
                'verified_at' => null,
                'verified_by' => $adminId,
                'rejection_reason' => $validated['reason'],
            ]);
            $updated = true;
        }

        if (! $updated) {
            return response()->json(['error' => 'Profesionista no encontrado.'], 404);
        }

        return response()->json(['message' => 'Profesionista rechazado.']);
    }

    private function formatProfessional($model, string $type): array
    {
        $user = $model->user;
        $uploads = $model->certificate_uploads ?? [];

        return [
            'user_id' => $model->user_id,
            'type' => $type,
            'name' => $user?->name,
            'email' => $user?->email,
            'avatar_url' => $user?->avatar_url,
            'is_verified' => (bool) $model->is_verified,
            'verified_at' => $model->verified_at?->toISOString(),
            'rejection_reason' => $model->rejection_reason,
            'certificate_uploads' => $uploads,
            'created_at' => $model->created_at?->toISOString(),
            // type-specific
            'license_number' => $model->license_number ?? null,
            'focus' => $model->focus ?? null,
            'specialty' => $model->specialty ?? null,
            'experience_years' => $model->experience_years ?? null,
            'bio' => $model->bio ?? null,
        ];
    }
}
