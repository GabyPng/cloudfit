<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\Support\JwtTestHelper;
use Tests\TestCase;

/**
 * Verifica el comportamiento de autenticación en las rutas protegidas de Cloudfit.
 *
 * Equivalente al test.js del pipeline educativo, adaptado a Laravel + Supabase JWT.
 * Las llamadas HTTP a Supabase JWKS son interceptadas con Http::fake() para no
 * depender de conexión externa en CI.
 */
class ProtectedRoutesTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Rutas que requieren autenticación (supabase.auth).
     * Todas deben devolver 401 sin token.
     */
    private array $rutasProtegidas = [
        ['GET',  '/api/me'],
        ['GET',  '/api/admin/dashboard'],
        ['GET',  '/api/coach/dashboard'],
        ['GET',  '/api/nutriologo/dashboard'],
        ['GET',  '/api/cliente/dashboard'],
    ];

    protected function setUp(): void
    {
        parent::setUp();
        Cache::forget('supabase_jwks');
    }

    // ── Tests de rechazo sin token ────────────────────────────────────────

    /** @test */
    public function rutas_protegidas_devuelven_401_sin_token(): void
    {
        foreach ($this->rutasProtegidas as [$method, $uri]) {
            $response = $this->json($method, $uri);

            $response->assertStatus(401)
                ->assertJsonFragment(['message' => 'Token requerido.']);
        }
    }

    // ── Tests de rechazo con token inválido ──────────────────────────────

    /** @test */
    public function ruta_me_devuelve_401_con_token_malformado(): void
    {
        // El JWKS está vacío: firebase/jwt no puede verificar → lanza excepción → 401
        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response(['keys' => []], 200),
        ]);

        $this->withToken('este.no.es.un.jwt.valido')
            ->getJson('/api/me')
            ->assertStatus(401);
    }

    /** @test */
    public function ruta_me_devuelve_401_con_token_expirado(): void
    {
        [$privateKey, $jwks] = JwtTestHelper::generateKeyPair();

        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response($jwks, 200),
        ]);

        $tokenExpirado = JwtTestHelper::makeToken($privateKey, [
            'exp' => time() - 3600, // ya expiró
            'iat' => time() - 7200,
        ]);

        $this->withToken($tokenExpirado)
            ->getJson('/api/me')
            ->assertStatus(401)
            ->assertJsonFragment(['message' => 'Token expirado.']);
    }

    // ── Tests de rechazo por rol insuficiente ────────────────────────────

    /** @test */
    public function ruta_admin_devuelve_403_con_rol_cliente(): void
    {
        [$privateKey, $jwks] = JwtTestHelper::generateKeyPair();

        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response($jwks, 200),
        ]);

        $token = JwtTestHelper::makeToken($privateKey, [
            'user_metadata' => ['role' => 'CLIENTE'],
        ]);

        $this->withToken($token)
            ->getJson('/api/admin/dashboard')
            ->assertStatus(403);
    }

    /** @test */
    public function ruta_coach_devuelve_403_con_rol_cliente(): void
    {
        [$privateKey, $jwks] = JwtTestHelper::generateKeyPair();

        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response($jwks, 200),
        ]);

        $token = JwtTestHelper::makeToken($privateKey, [
            'user_metadata' => ['role' => 'CLIENTE'],
        ]);

        $this->withToken($token)
            ->getJson('/api/coach/dashboard')
            ->assertStatus(403);
    }

    /** @test */
    public function ruta_nutriologo_devuelve_403_con_rol_coach(): void
    {
        [$privateKey, $jwks] = JwtTestHelper::generateKeyPair();

        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response($jwks, 200),
        ]);

        $token = JwtTestHelper::makeToken($privateKey, [
            'user_metadata' => ['role' => 'COACH'],
        ]);

        $this->withToken($token)
            ->getJson('/api/nutriologo/dashboard')
            ->assertStatus(403);
    }

    // ── Test de token válido pasa el middleware ───────────────────────────

    /** @test */
    public function token_valido_pasa_el_middleware_de_autenticacion(): void
    {
        [$privateKey, $jwks] = JwtTestHelper::generateKeyPair();

        Http::fake([
            '*/auth/v1/.well-known/jwks.json' => Http::response($jwks, 200),
        ]);

        $token = JwtTestHelper::makeToken($privateKey, [
            'user_metadata' => ['role' => 'CLIENTE'],
        ]);

        // El middleware deja pasar el token → el controlador responde (puede ser 404
        // si el usuario no existe en BD local, pero definitivamente NO es 401).
        $response = $this->withToken($token)->getJson('/api/me');

        $this->assertNotEquals(401, $response->status(), 'El middleware rechazó un token válido.');
    }
}
