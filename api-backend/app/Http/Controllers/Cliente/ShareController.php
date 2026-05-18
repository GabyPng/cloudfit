<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class ShareController extends Controller
{
    public function generateProgressLink(Request $request)
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return response()->json(['error' => 'No autenticado'], 401);
        }

        $user = User::where('email', $email)->first();
        if (! $user) {
            return response()->json(['error' => 'Usuario no encontrado'], 404);
        }

        $token = Str::random(32);
        $ttl = 24 * 60; // 24 hours in minutes

        Cache::put("progress_share_{$token}", [
            'user_id' => $user->user_id,
            'name' => $user->name,
            'created_at' => now()->toISOString(),
        ], now()->addMinutes($ttl));

        $url = url('/share/'.$token);

        return response()->json([
            'token' => $token,
            'url' => $url,
            'expires_in' => $ttl * 60,
        ]);
    }

    public function showProgress(string $token)
    {
        $data = Cache::get("progress_share_{$token}");

        if (! $data) {
            return response()->json(['error' => 'Enlace inválido o expirado.'], 404);
        }

        return response()->json([
            'data' => [
                'name' => $data['name'],
                'shared_at' => $data['created_at'],
            ],
        ]);
    }
}
