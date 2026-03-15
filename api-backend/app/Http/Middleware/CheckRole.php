<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Verifica el rol del usuario extraído del Firebase ID Token.
 * Debe usarse después del middleware firebase.auth.
 *
 * Uso en rutas:
 *   ->middleware('role:admin')
 *   ->middleware('role:admin,coach')   ← Acepta cualquiera de los dos roles
 */
class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $role = $request->attributes->get('firebase_role');

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
