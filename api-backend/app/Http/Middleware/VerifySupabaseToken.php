<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\JWK;
use Firebase\JWT\ExpiredException;
use Firebase\JWT\SignatureInvalidException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class VerifySupabaseToken
{
    private function normalizeRole(?string $rawRole): ?string
    {
        if ($rawRole === null || trim((string) $rawRole) === '') {
            return null;
        }

        $role = mb_strtoupper(trim((string) $rawRole));
        $role = str_replace(['Á', 'É', 'Í', 'Ó', 'Ú'], ['A', 'E', 'I', 'O', 'U'], $role);

        return match ($role) {
            'ADMIN', 'ADMINISTRADOR' => 'ADMINISTRADOR',
            'COACH' => 'COACH',
            'NUTRIOLOGO' => 'NUTRIOLOGO',
            'CLIENTE' => 'CLIENTE',
            'AUTHENTICATED', 'ANON', 'ANONYMOUS' => null,
            default => null,
        };
    }

    private function extractRoleClaim(array $payload): string
    {
        $candidates = [
            data_get($payload, 'user_metadata.role'),
            data_get($payload, 'app_metadata.role'),
            data_get($payload, 'raw_user_meta_data.role'),
            data_get($payload, 'raw_app_meta_data.role'),
            $payload['role'] ?? null,
        ];

        foreach ($candidates as $candidate) {
            $normalized = $this->normalizeRole(is_scalar($candidate) ? (string) $candidate : null);
            if ($normalized) {
                return $normalized;
            }
        }

        return 'CLIENTE';
    }

    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['message' => 'Token requerido.'], 401);
        }

        try {
            // Obtén JWKS desde Supabase (cacheado 1 hora)
            $jwks = Cache::remember('supabase_jwks', 3600, function () {
                $supabaseUrl = config('supabase.url');
                if (!$supabaseUrl) {
                    throw new \RuntimeException('SUPABASE_URL no configurada');
                }
                
                $jwksUrl = "{$supabaseUrl}/auth/v1/.well-known/jwks.json";

                $response = Http::timeout(10)
                    ->withoutVerifying()
                    ->get($jwksUrl);

                if (!$response->successful()) {
                    throw new \RuntimeException('Fallo al obtener JWKS: ' . $response->status());
                }

                return $response->json();
            });

            if (!isset($jwks['keys']) || empty($jwks['keys'])) {
                throw new \RuntimeException('JWKS vacío o sin claves');
            }

            $keys = JWK::parseKeySet($jwks);
            $decoded = JWT::decode($token, $keys);
            $payload = (array) $decoded;

            // Almacena datos en los atributos del request
            $request->attributes->set('supabase_uid', $payload['sub'] ?? null);
            $request->attributes->set('supabase_email', $payload['email'] ?? null);
            $request->attributes->set('supabase_token', $token);
            
            // Extrae el rol real de metadata de la app/usuario y evita usar el rol genérico de Supabase.
            $request->attributes->set('supabase_role', $this->extractRoleClaim($payload));

        } catch (ExpiredException $e) {
            return response()->json(['message' => 'Token expirado.'], 401);
        } catch (SignatureInvalidException $e) {
            return response()->json(['message' => 'Firma inválida.'], 401);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Token inválido.'], 401);
        }

        return $next($request);
    }
}
