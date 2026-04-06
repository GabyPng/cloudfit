<?php

namespace App\Http\Controllers\Auth;

use App\Models\Nutriologo;
use App\Models\Role;
use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    private function normalizeRoleValue(?string $rawRole): ?string
    {
        if (!$rawRole) {
            return null;
        }

        $role = mb_strtolower(trim($rawRole));
        $role = str_replace(['á', 'é', 'í', 'ó', 'ú'], ['a', 'e', 'i', 'o', 'u'], $role);

        if ($role === 'administrador') {
            return 'admin';
        }

        return $role;
    }

    private function resolveRoleFromRequest(Request $request): string
    {
        $bodyRole = $this->normalizeRoleValue($request->input('role'));
        $tokenRole = $this->normalizeRoleValue($request->attributes->get('supabase_role'));

        // Priorizar el role explícito del frontend en registro/sync.
        if (in_array($bodyRole, ['cliente', 'coach', 'nutriologo', 'admin'], true)) {
            return $bodyRole;
        }

        if (in_array($tokenRole, ['cliente', 'coach', 'nutriologo', 'admin'], true)) {
            return $tokenRole;
        }

        return 'cliente';
    }

    /**
     * Retorna la información del usuario autenticado extraída del Supabase JWT.
     * El login/registro lo maneja Supabase Auth directamente desde el frontend.
     */
    public function me(Request $request)
    {
        $email = $request->attributes->get('supabase_email');
        $localUser = null;

        if ($email) {
            $localUser = User::query()
                ->with([
                    'role:id,name,description',
                    'nutriologoProfile:id,user_id,license_number,focus,certificate_uploads',
                ])
                ->where('email', $email)
                ->first();
        }

        return response()->json([
            'uid'   => $request->attributes->get('supabase_uid'),
            'email' => $request->attributes->get('supabase_email'),
            'role'  => $request->attributes->get('supabase_role'),
            'local_user' => $localUser,
        ]);
    }

    public function updateMe(Request $request)
    {
        $email = $request->attributes->get('supabase_email');

        if (!$email) {
            return response()->json(['error' => 'No email in token'], 400);
        }

        $validated = $request->validate([
            'name' => ['nullable', 'string', 'max:255'],
            'objective' => ['nullable', 'string', 'max:255'],
            'avatar_url' => ['nullable', 'url', 'max:1000'],
        ]);

        $user = User::query()->where('email', $email)->first();

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        if (array_key_exists('name', $validated)) {
            $user->name = $validated['name'] ?: $user->name;
        }

        if (array_key_exists('objective', $validated)) {
            $user->objective = $validated['objective'];
        }

        if (array_key_exists('avatar_url', $validated)) {
            $user->avatar_url = $validated['avatar_url'];
        }

        $user->save();

        return response()->json([
            'message' => 'Perfil actualizado',
            'user' => $user->load('role:id,name,description'),
        ]);
    }

    /**
     * Sincroniza el usuario autenticado de Supabase con la base de datos local de Laravel.
     * Esto reemplaza la necesidad de un DB Trigger manual.
     */
    public function sync(Request $request)
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) {
            return response()->json(['error' => 'No email in token'], 400);
        }

        $role = $this->resolveRoleFromRequest($request);

        $roleId = Role::query()->where('name', $role)->value('id');
        if (!$roleId) {
            return response()->json(['error' => 'Role not found'], 422);
        }

        $user = User::query()->firstOrNew(['email' => $email]);
        $user->name = $request->input('name', explode('@', $email)[0]);
        $user->role_id = $roleId;

        if ($request->filled('avatar_url')) {
            $user->avatar_url = $request->input('avatar_url');
        }

        if ($request->filled('objective')) {
            $user->objective = $request->input('objective');
        }

        if (!$user->exists) {
            $user->password = '';
        }

        $user->save();

        if ($role === 'nutriologo') {
            $profile = $request->input('profile', []);
            $licenseNumber = trim((string) data_get($profile, 'licenseNumber', ''));
            $focus = trim((string) data_get($profile, 'focus', ''));
            $certificateUploads = data_get($profile, 'certificateUploads');

            if ($licenseNumber === '' || $focus === '') {
                return response()->json([
                    'error' => 'Faltan datos requeridos del perfil de nutriologo (licenseNumber y focus).',
                ], 422);
            }

            Nutriologo::query()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'license_number' => $licenseNumber,
                    'focus' => $focus,
                    'certificate_uploads' => is_array($certificateUploads) ? $certificateUploads : null,
                ]
            );
        }

        return response()->json([
            'message' => 'Usuario sincronizado en base de datos',
            'user' => $user->load('role:id,name,description')
        ]);
    }
}
