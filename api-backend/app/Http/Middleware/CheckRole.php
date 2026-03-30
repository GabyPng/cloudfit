<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
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
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $role = $request->attributes->get('supabase_role');

        if (! $role) {
            return response()->json([
                'message' => 'No se encontró el rol del usuario en el token.',
            ], 403);
        }

        if (! in_array($role, $roles)) {
            return response()->json([
                'message'        => 'No tienes permiso para acceder a este recurso.',
                'required_roles' => $roles,
                'your_role'      => $role,
            ], 403);
        }

        return $next($request);
    }
}
