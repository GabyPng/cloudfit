<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CoachController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'message' => 'Bienvenido al panel de Coach.',
            'section' => 'coach',
        ]);
    }

    public function clientes()
    {
        return response()->json(['message' => 'Clientes del Coach — por implementar.']);
    }

    public function planes()
    {
        return response()->json(['message' => 'Planes de entrenamiento — por implementar.']);
    }
}
