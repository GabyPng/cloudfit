<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CoachController extends Controller
{
    public function dashboard(Request $request)
    {
        return response()->json([
            'message' => 'Bienvenido al panel de Coach.',
            'uid'     => $request->attributes->get('supabase_uid'),
        ]);
    }

    public function clientes(Request $request)
    {
        // TODO: Implementar consulta a Supabase DB
        return response()->json(['message' => 'Listado de clientes — por implementar con Supabase.'], 501);
    }

    public function planes(Request $request)
    {
        return response()->json(['message' => 'Planes de entrenamiento — por implementar.']);
    }
}
