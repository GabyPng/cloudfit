<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

/**
 * Verifica el rol del usuario extraído del Supabase JWT.
 * Debe usarse después del middleware supabase.auth.
 *
 * Uso en rutas:
 *   ->middleware('role:ADMINISTRADOR')
 *   ->middleware('role:COACH,ADMINISTRADOR')   ← Acepta cualquiera de los dos roles
 */
class CheckRole
{
    private function normalizeRole(?string $rawRole): ?string
    {
        if ($rawRole === null || trim((string) $rawRole) === '') {
            return null;
        }

        $role = mb_strtoupper(trim((string) $rawRole));
        $role = str_replace(['Á', 'É', 'Í', 'Ó', 'Ú'], ['A', 'E', 'I', 'O', 'U'], $role);

        return match ($role) {
            'ADMIN', 'ADMINISTRADOR' => 'ADMINISTRADOR',
            'COACH' => 'COACH',
            'NUTRIOLOGO' => 'NUTRIOLOGO',
            'CLIENTE' => 'CLIENTE',
            default => null,
        };
    }

    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $requiredRoles = array_values(array_filter(array_map(fn ($role) => $this->normalizeRole($role), $roles)));
        $requestRole = $this->normalizeRole($request->attributes->get('supabase_role'));

        if ($requestRole && in_array($requestRole, $requiredRoles, true)) {
            return $next($request);
        }

        $email = (string) ($request->attributes->get('supabase_email') ?? '');
        if ($email !== '') {
            $localRole = Cache::remember('user_role_' . md5($email), 300, fn() =>
                User::query()
                    ->with('role:role_id,name')
                    ->where('email', $email)
                    ->first()?->role?->name
            );

            $normalizedLocalRole = $this->normalizeRole($localRole);

            if ($normalizedLocalRole && in_array($normalizedLocalRole, $requiredRoles, true)) {
                $request->attributes->set('supabase_role', $normalizedLocalRole);
                return $next($request);
            }
        }

        if (! $requestRole) {
            return response()->json([
                'message' => 'No se encontró el rol del usuario en el token ni en la base local.',
            ], 403);
        }

        return response()->json([
            'message'        => 'No tienes permiso para acceder a este recurso.',
            'required_roles' => $requiredRoles,
            'your_role'      => $requestRole,
        ], 403);
    }
}
