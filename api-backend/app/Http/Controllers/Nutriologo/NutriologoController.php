<?php

namespace App\Http\Controllers\Nutriologo;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class NutriologoController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'message' => 'Bienvenido al panel de Nutriólogo.',
            'section' => 'nutriologo',
        ]);
    }

    public function clientes()
    {
        return response()->json(['message' => 'Clientes del Nutriólogo — por implementar.']);
    }

    public function planes()
    {
        return response()->json(['message' => 'Planes nutricionales — por implementar.']);
    }
}
