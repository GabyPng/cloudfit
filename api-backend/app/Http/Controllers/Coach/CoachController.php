<?php

namespace App\Http\Controllers\Coach;

use App\Http\Controllers\Controller;
use App\Services\DataConnectService;
use Illuminate\Http\Request;

class CoachController extends Controller
{
    public function __construct(private DataConnectService $dc) {}

    public function dashboard(Request $request)
    {
        return response()->json([
            'message' => 'Bienvenido al panel de Coach.',
            'uid'     => $request->attributes->get('firebase_uid'),
        ]);
    }

    public function clientes(Request $request)
    {
        $idToken = $request->attributes->get('firebase_token');
        $data    = $this->dc->getMisClientes($idToken);

        return response()->json($data);
    }

    public function planes(Request $request)
    {
        return response()->json(['message' => 'Planes de entrenamiento — por implementar.']);
    }
}
