<?php

namespace Tests\Support;

use Firebase\JWT\JWT;

/**
 * Genera JWTs firmados con RS256 para pruebas del middleware VerifySupabaseToken.
 * Usa firebase/php-jwt (ya instalado) y OpenSSL (built-in en PHP).
 */
class JwtTestHelper
{
    /**
     * Genera un par de claves RSA y devuelve [privateKeyPem, jwks].
     * El JWKS puede ser mockeado con Http::fake() en los tests.
     *
     * @return array{0: string, 1: array}
     */
    public static function generateKeyPair(): array
    {
        $res = openssl_pkey_new([
            'digest_alg'       => 'sha256',
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]);

        openssl_pkey_export($res, $privateKeyPem);
        $details = openssl_pkey_get_details($res);

        $jwks = [
            'keys' => [[
                'kty' => 'RSA',
                'use' => 'sig',
                'alg' => 'RS256',
                'kid' => 'test-key-ci',
                'n'   => rtrim(strtr(base64_encode($details['rsa']['n']), '+/', '-_'), '='),
                'e'   => rtrim(strtr(base64_encode($details['rsa']['e']), '+/', '-_'), '='),
            ]],
        ];

        return [$privateKeyPem, $jwks];
    }

    /**
     * Devuelve un JWT válido firmado con la clave privada dada.
     *
     * @param  string  $privateKeyPem  Clave privada en formato PEM
     * @param  array   $overrides      Campos que sobreescriben el payload por defecto
     */
    public static function makeToken(string $privateKeyPem, array $overrides = []): string
    {
        $payload = array_merge([
            'iss'           => 'https://placeholder.supabase.co/auth/v1',
            'sub'           => 'test-uid-ci',
            'aud'           => 'authenticated',
            'exp'           => time() + 3600,
            'iat'           => time(),
            'email'         => 'ci-test@cloudfit.com',
            'role'          => 'authenticated',
            'user_metadata' => ['role' => 'CLIENTE'],
        ], $overrides);

        return JWT::encode($payload, $privateKeyPem, 'RS256', 'test-key-ci');
    }
}
