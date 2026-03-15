<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;

class VerifyFirebaseToken
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (! $token) {
            return response()->json(['message' => 'Token requerido.'], 401);
        }

        try {
            $payload = config('firebase.emulator')
                ? $this->decodeWithoutVerification($token)
                : $this->verifyWithFirebase($token);

            $request->attributes->set('firebase_uid',   $payload['sub']   ?? $payload['user_id'] ?? null);
            $request->attributes->set('firebase_email', $payload['email'] ?? null);
            $request->attributes->set('firebase_role',  $payload['role']  ?? null); // custom claim
            $request->attributes->set('firebase_token', $token);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Token inválido.', 'error' => $e->getMessage()], 401);
        }

        return $next($request);
    }

    private function verifyWithFirebase(string $token): array
    {
        $factory = (new Factory)->withProjectId(config('firebase.project_id'));
        $auth    = $factory->createAuth();
        $verified = $auth->verifyIdToken($token);

        return $verified->claims()->all();
    }

    /**
     * En modo emulador no verificamos la firma del JWT.
     * Solo decodificamos el payload para extraer uid, email y role.
     */
    private function decodeWithoutVerification(string $token): array
    {
        $parts = explode('.', $token);

        if (count($parts) !== 3) {
            throw new \InvalidArgumentException('Formato JWT inválido.');
        }

        $padded  = str_pad(strtr($parts[1], '-_', '+/'), strlen($parts[1]) % 4, '=', STR_PAD_RIGHT);
        $payload = json_decode(base64_decode($padded), true);

        if (! $payload) {
            throw new \InvalidArgumentException('No se pudo decodificar el token.');
        }

        return $payload;
    }
}
