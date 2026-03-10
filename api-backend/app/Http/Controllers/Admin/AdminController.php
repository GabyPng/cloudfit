<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'message' => 'Bienvenido al panel de Administrador.',
            'section' => 'admin',
        ]);
    }

    public function users()
    {
        return response()->json(['message' => 'Listado de usuarios — por implementar.']);
    }
}
