<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Nutriologo;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class AuthController extends Controller
{
    private function usersHasColumn(string $column): bool
    {
        static $userColumns = null;

        if ($userColumns === null) {
            $userColumns = array_flip(Schema::getColumnListing('users'));
        }

        return isset($userColumns[$column]);
    }

    private function normalizeRoleValue(?string $rawRole): ?string
    {
        if (! $rawRole) {
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
                    'role:role_id,name,description',
                    'nutriologoProfile:id,user_id,license_number,focus,certificate_uploads',
                ])
                ->where('email', $email)
                ->first();
        }

        return response()->json([
            'uid' => $request->attributes->get('supabase_uid'),
            'email' => $request->attributes->get('supabase_email'),
            'role' => $request->attributes->get('supabase_role'),
            'local_user' => $localUser,
        ]);
    }

    public function updateMe(Request $request)
    {
        $email = $request->attributes->get('supabase_email');

        if (! $email) {
            return response()->json(['error' => 'No email in token'], 400);
        }

        $validated = $request->validate([
            'name' => ['nullable', 'string', 'max:255'],
            'objective' => ['nullable', 'string', 'max:255'],
            'avatar_url' => ['nullable', 'url', 'max:1000'],
        ]);

        $user = User::query()->where('email', $email)->first();

        if (! $user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        if (array_key_exists('name', $validated)) {
            $user->name = $validated['name'] ?: $user->name;
        }

        if (array_key_exists('objective', $validated) && $this->usersHasColumn('objective')) {
            $user->objective = $validated['objective'];
        }

        if (array_key_exists('avatar_url', $validated) && $this->usersHasColumn('avatar_url')) {
            $user->avatar_url = $validated['avatar_url'];
        }

        $user->save();

        return response()->json([
            'message' => 'Perfil actualizado',
            'user' => $user->load('role:role_id,name,description'),
        ]);
    }

    /**
     * Sincroniza el usuario autenticado de Supabase con la base de datos local de Laravel.
     * Esto reemplaza la necesidad de un DB Trigger manual.
     */
    public function sync(Request $request)
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return response()->json(['error' => 'No email in token'], 400);
        }

        $existingUser = User::where('email', $email)->first();

        if ($existingUser && $existingUser->role_id) {
            $roleModel = Role::find($existingUser->role_id);
            if (! $roleModel) {
                return response()->json(['error' => 'Rol inválido para el usuario'], 422);
            }
            $roleId = $existingUser->role_id;
            $role = $roleModel->name;
        } else {
            $role = $this->resolveRoleFromRequest($request);

            $roleId = Role::query()->where('name', $role)->value('role_id');
            if (! $roleId) {
                return response()->json(['error' => 'Role not found'], 422);
            }
        }

        $user = User::firstOrNew(['email' => $email]);
        $user->name = $request->input('name', explode('@', $email)[0]);

        $supabaseUid = $request->attributes->get('supabase_uid');
        if ($supabaseUid && empty($user->supabase_id)) {
            $user->supabase_id = $supabaseUid;
        }

        if (! $existingUser) {
            $user->role_id = $roleId;
        }

        if ($request->filled('avatar_url') && $this->usersHasColumn('avatar_url')) {
            $user->avatar_url = $request->input('avatar_url');
        }

        if ($request->filled('objective') && $this->usersHasColumn('objective')) {
            $user->objective = $request->input('objective');
        }

        if (! $user->exists) {
            $user->password = '';
        }

        $user->save();

        if ($role === 'nutriologo') {
            $profile = $request->input('profile', []);
            $licenseNumber = trim((string) data_get($profile, 'licenseNumber', data_get($profile, 'license_number', 'PENDIENTE')));
            $focus = trim((string) data_get($profile, 'focus', 'General'));
            $certificateUploads = data_get($profile, 'certificateUploads', data_get($profile, 'certificate_uploads'));

            if ($licenseNumber === '') {
                $licenseNumber = 'PENDIENTE';
            }

            if ($focus === '') {
                $focus = 'General';
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

        // Actualizar metadatos en Supabase
        if ($supabaseUid) {
            $this->updateSupabaseMetadata($supabaseUid, $role);
        } else {
            Log::warning('No supabase_uid found for user', ['email' => $email]);
        }

        return response()->json([
            'message' => 'Usuario sincronizado en base de datos',
            'user' => $user->load('role:role_id,name,description'),
        ]);
    }

    private function updateSupabaseMetadata($supabaseUid, $role)
    {
        if (! $supabaseUid) {
            return;
        }

        try {
            $response = Http::withoutVerifying()->withHeaders([
                'Authorization' => 'Bearer '.config('supabase.service_role_key'),
                'Content-Type' => 'application/json',
            ])->patch(config('supabase.url').'/auth/v1/admin/users/'.$supabaseUid, [
                'user_metadata' => ['role' => $role],
            ]);

            if ($response->successful()) {
                Log::info("Metadatos actualizados para $supabaseUid con role=$role");
            } else {
                Log::error('Error al actualizar metadatos: '.$response->body());
            }
        } catch (\Exception $e) {
            Log::error('Excepción al actualizar metadatos: '.$e->getMessage());
        }
    }
}
