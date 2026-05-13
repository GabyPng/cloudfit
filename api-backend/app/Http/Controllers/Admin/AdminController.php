<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
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

    public function users(Request $request)
    {
        $search = $request->query('search');
        $role = $request->query('role');
        $page = (int) $request->query('page', 1);
        $per = 20;

        $query = User::with('role:role_id,name')
            ->when($search, fn ($q) => $q->where(fn ($q2) => $q2->where('name', 'ilike', "%{$search}%")
                ->orWhere('email', 'ilike', "%{$search}%")
            ))
            ->when($role, fn ($q) => $q->whereHas('role', fn ($q2) => $q2->where('name', $role)))
            ->orderBy('created_at', 'desc');

        $paginated = $query->paginate($per, ['user_id', 'name', 'email', 'avatar_url', 'created_at', 'role_id'], 'page', $page);

        return response()->json([
            'data' => $paginated->map(fn ($u) => [
                'user_id' => $u->user_id,
                'name' => $u->name,
                'email' => $u->email,
                'avatar_url' => $u->avatar_url,
                'role' => $u->role?->name,
                'created_at' => $u->created_at?->toISOString(),
            ]),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }
}
