<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ClienteController extends Controller
{
    public function dashboard(Request $request)
    {
        return response()->json([
            'message' => 'Bienvenido a tu panel, ' . $request->user()->name . '.',
            'section' => 'cliente',
        ]);
    }

    public function planEntrenamiento(Request $request)
    {
        return response()->json(['message' => 'Plan de entrenamiento — por implementar.']);
    }

    public function planNutricional(Request $request)
    {
        return response()->json(['message' => 'Plan nutricional — por implementar.']);
    }

    public function progreso(Request $request)
    {
        return response()->json(['message' => 'Progreso del cliente — por implementar.']);
    }
}
