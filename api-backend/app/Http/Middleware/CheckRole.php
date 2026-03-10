<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware que verifica el rol del usuario autenticado.
 *
 * Uso en rutas:
 *   ->middleware('role:admin')
 *   ->middleware('role:admin,coach')   ← Acepta cualquiera de los dos roles
 */
class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'No autenticado.'], 401);
        }

        if (! in_array($user->role, $roles)) {
            return response()->json([
                'message' => 'No tienes permiso para acceder a este recurso.',
                'required_roles' => $roles,
                'your_role'      => $user->role,
            ], 403);
        }

        return $next($request);
    }
}
