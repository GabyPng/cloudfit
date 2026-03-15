<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    /**
     * Retorna la información del usuario autenticado extraída del Firebase ID Token.
     * El login/registro lo maneja Firebase Auth directamente desde el frontend.
     */
    public function me(Request $request)
    {
        return response()->json([
            'uid'   => $request->attributes->get('firebase_uid'),
            'email' => $request->attributes->get('firebase_email'),
            'role'  => $request->attributes->get('firebase_role'),
        ]);
    }
}
