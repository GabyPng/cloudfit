<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Firebase\JWT\JWK;
use Firebase\JWT\JWT;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware para autenticar al coach en las vistas web usando el token de Supabase.
 *
 * El token se puede enviar como:
 *   - Cookie 'supabase_token'
 *   - Sesión 'supabase_token'
 *   - Header Authorization: Bearer <token>
 */
class AuthenticateCoachWeb
{
    public function handle(Request $request, Closure $next): Response
    {
        if (Auth::check()) {
            return $next($request);
        }

        $token = $request->cookie('supabase_token')
              ?? $request->session()->get('supabase_token')
              ?? $request->bearerToken();

        if (! $token) {
            return redirect('/login')->with('error', 'Debes iniciar sesión.');
        }

        try {
            $jwks = Cache::remember('supabase_jwks', 3600, function () {
                $url = config('supabase.url').'/auth/v1/.well-known/jwks.json';
                $response = Http::timeout(10)->withoutVerifying()->get($url);
                if (! $response->successful()) {
                    throw new \RuntimeException('No se pudo obtener JWKS');
                }

                return $response->json();
            });

            $keys = JWK::parseKeySet($jwks);
            $decoded = (array) JWT::decode($token, $keys);

            $email = $decoded['email'] ?? null;
            if (! $email) {
                return redirect('/login')->with('error', 'Token sin email.');
            }

            $user = User::with('role')->where('email', $email)->first();
            if (! $user || ! $user->hasRole('coach')) {
                return redirect('/login')->with('error', 'Acceso denegado.');
            }

            Auth::login($user);
        } catch (\Exception $e) {
            return redirect('/login')->with('error', 'Sesión inválida.');
        }

        return $next($request);
    }
}
