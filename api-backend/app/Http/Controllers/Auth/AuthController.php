<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    /**
     * Retorna la información del usuario autenticado extraída del Supabase JWT.
     * El login/registro lo maneja Supabase Auth directamente desde el frontend.
     */
    public function me(Request $request)
    {
        return response()->json([
            'uid'   => $request->attributes->get('supabase_uid'),
            'email' => $request->attributes->get('supabase_email'),
            'role'  => $request->attributes->get('supabase_role'),
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

        // Obtiene el rol del JWT (del middleware), con fallback al request body
        $supabaseRole = $request->attributes->get('supabase_role');
        $role = $supabaseRole 
            ? strtolower($supabaseRole)
            : $request->input('role', 'cliente');

        $user = \App\Models\User::firstOrCreate(
            ['email' => $email],
            [
                'name' => $request->input('name', explode('@', $email)[0]),
                'password' => '', // Ya no usamos esta contraseña local
                'role' => $role,
            ]
        );

        return response()->json([
            'message' => 'Usuario sincronizado en base de datos',
            'user' => $user
        ]);
    }
}
