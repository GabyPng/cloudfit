<?php

namespace Tests\Support;

use Firebase\JWT\JWT;

/**
 * Genera JWTs firmados con RS256 para pruebas del middleware VerifySupabaseToken.
 * Usa firebase/php-jwt (ya instalado) con un par de claves RSA estático para
 * evitar dependencia de openssl_pkey_new(), que puede fallar según configuración del SO.
 */
class JwtTestHelper
{
    // Par RSA de 2048 bits pregenerado exclusivamente para testing.
    private const PRIVATE_KEY = <<<'PEM'
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDKrpGQ6Abq1ruk
RI+J+8BQh2D4IHOT28y50IG7bc+sJUlr3JXKN2e1OezUXvOJgvHYZctZBAFqPRn+
eHleMfsglM7GOONyrtWt/moTHRK0UfTQ/oRtmm83o5udJnWTYtjfP+tYoKpkz7X1
6Cr2Gy/BRpd4/lqXbyQIUanuFhbTrUw+ZrNXYGQC7KpGEim8UHBOOC9vCyTYB7P8
efkKxgxO7SNe9UEsM8LeJRpljJpQE+zDXzxCWLTa1TJGyvLRg1A/CbL+Khe3Zm0P
v9+3pQFd/7IRyVKGkM/iGkOyPvUUq0mOn4aa8cF9kNf30N//MtFYYQK4kZxF9Qm7
cpA+ujeRAgMBAAECggEAAR+XFHXIxgfzKc2sewAPeJLLhYyOf3EOMTB3651H86UQ
Q14JYYHNnBpKVwIAuRAl/YRQ7Hkidd+JU5kA2TYPNYbFn6Ekl5fi/NAmb90vI5s5
r2fdvYrH14fbXrNeHvdDCve8evUHBMCG+mozRMJxURGuWMAWKfU2fqpPNg/eyAUR
F/xRjduhsOm1WKil216zdngImXCxRjMPRxmrRJ/lWs0LNs1heQ7LaDmObOYnQ1yr
nPX+hyGpki6tPOVdGCT0ivRDibEewSk32mUntxQez4+oSEpI0WdhD8m5BsHFF9Om
EXefVUcSWKsIqdJ+oIaKJCRkD7Fbt6GKD6ffG3fdgQKBgQD6naqRwNnDZNUHPbu7
YkwtAbwg2t3qnQT/EXSNzdR2LNyxGhA3TunGqS1pEw23E+HugBVrMz8XCZQYCiMp
QZkKYKUR3YwWeagfj2G8FwdJuUVN82j/bXXYHawM3cqivM5BZXQdHmpu2C0CPCGC
0U7LilyhIPMJT8wdclvWwEQzcQKBgQDPCUaWGXpvmysCy7u6Rphgx0ol2p8+4zXR
K+VE+YZNlNVpvpK9y3tXomfRa3VveCVTRMxhF2xIH6jBvWBwOsgjDClvpmh7USSo
VYxmD7rdv4fvhQvazkNWymWJH6dYcRBgWU9+swmdLjIXuoQ73ZurHc6tSzX7crg0
NWc7ohH2IQKBgGEpPzfCzKo0LWLhTCcZtO69/XG/aMnMlmNNISLY6cXnHqiKsj6/
GWMrs69I88hGrREKF0O4Wn1T+VZYl8km5W5giZ6jhewwvj1+GSYSx4CNk5DlDY/5
n/Zpiopycl0lVdGEw7+GSz0uEkULivJss1+2BLNzUsYJadkAvRpE8CwBAoGBAJgc
AoZJFdFluYYGVViYgV+pS+rf4tv7ZxDVJU813NynGtzkLT/QfkB2i7wrLU7GgPXa
uCYlZWLgD8a38mDCb0SArPjg1Ca2CS68G7jomaxOCfuKTpllrcfYUB0c6oBqIVQI
igVWWRvoUtloKbsqKDLiZXSgq3qgYIHLMpt3iabBAoGAYTZ3epSrUZXruat04IYq
2xHLbk3hI22EJ9kvRIhDae5qgK1lsbJhkw8F4k5sPnZ3yeEKQ8zI22N0uH6KPVXu
KtbQ+uUh18WAopKyRn0PD7lAHcEdIG2+cwFGqlYJo0SXvSllZG5yCvRir/q3uJ2j
O5Bjw6jvyQsX4oRO9kJUXFo=
-----END PRIVATE KEY-----
PEM;

    // Valores n y e del JWKS derivados de la clave pública anterior.
    private const JWK_N = 'yq6RkOgG6ta7pESPifvAUIdg-CBzk9vMudCBu23PrCVJa9yVyjdntTns1F7ziYLx2GXLWQQBaj0Z_nh5XjH7IJTOxjjjcq7Vrf5qEx0StFH00P6EbZpvN6ObnSZ1k2LY3z_rWKCqZM-19egq9hsvwUaXeP5al28kCFGp7hYW061MPmazV2BkAuyqRhIpvFBwTjgvbwsk2Aez_Hn5CsYMTu0jXvVBLDPC3iUaZYyaUBPsw188Qli02tUyRsry0YNQPwmy_ioXt2ZtD7_ft6UBXf-yEclShpDP4hpDsj71FKtJjp-GmvHBfZDX99Df_zLRWGECuJGcRfUJu3KQPro3kQ';

    private const JWK_E = 'AQAB';

    /**
     * Devuelve [privateKeyPem, jwks] para usar en tests con Http::fake().
     *
     * @return array{0: string, 1: array}
     */
    public static function generateKeyPair(): array
    {
        $jwks = [
            'keys' => [[
                'kty' => 'RSA',
                'use' => 'sig',
                'alg' => 'RS256',
                'kid' => 'test-key-ci',
                'n' => self::JWK_N,
                'e' => self::JWK_E,
            ]],
        ];

        return [self::PRIVATE_KEY, $jwks];
    }

    /**
     * Devuelve un JWT válido firmado con la clave privada de testing.
     *
     * @param  string  $privateKeyPem  Ignorado; se usa la clave estática de testing
     * @param  array  $overrides  Campos que sobreescriben el payload por defecto
     */
    public static function makeToken(string $privateKeyPem, array $overrides = []): string
    {
        $payload = array_merge([
            'iss' => 'https://placeholder.supabase.co/auth/v1',
            'sub' => 'test-uid-ci',
            'aud' => 'authenticated',
            'exp' => time() + 3600,
            'iat' => time(),
            'email' => 'ci-test@cloudfit.com',
            'role' => 'authenticated',
            'user_metadata' => ['role' => 'CLIENTE'],
        ], $overrides);

        return JWT::encode($payload, self::PRIVATE_KEY, 'RS256', 'test-key-ci');
    }
}
