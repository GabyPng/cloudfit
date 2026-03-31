<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — CloudFit Backend
|--------------------------------------------------------------------------
|
| Autenticación: Supabase JWT (Bearer token)
|   El middleware supabase.auth verifica el token y extrae uid, email y role.
|   El middleware role:{rol} restringe el acceso por rol.
|
| Estructura de acceso:
|   GET    /api/me             → supabase.auth
|   GET    /api/admin/*        → supabase.auth + role:ADMINISTRADOR
|   GET    /api/coach/*        → supabase.auth + role:COACH
|   GET    /api/nutriologo/*   → supabase.auth + role:NUTRIOLOGO
|   GET    /api/cliente/*      → supabase.auth + role:CLIENTE,ADMINISTRADOR
|
*/

// ── Info y sincronización del usuario autenticado ───────────────────────
Route::middleware('supabase.auth')->group(function () {
    Route::get('/me', [\App\Http\Controllers\Auth\AuthController::class, 'me']);
    Route::put('/me', [\App\Http\Controllers\Auth\AuthController::class, 'updateMe']);
    Route::post('/sync', [\App\Http\Controllers\Auth\AuthController::class, 'sync']);
});

// ── Chatbot (todos los roles autenticados) ────────────────────────────────
Route::middleware('supabase.auth')
    ->prefix('chatbot')
    ->group(base_path('routes/api/chatbot.php'));

// ── Administrador ────────────────────────────────────────────────────────
Route::middleware(['supabase.auth', 'role:ADMINISTRADOR'])
    ->prefix('admin')
    ->group(base_path('routes/api/admin.php'));

// ── Coach ─────────────────────────────────────────────────────────────────
Route::middleware(['supabase.auth', 'role:COACH'])
    ->prefix('coach')
    ->group(base_path('routes/api/coach.php'));

// ── Nutriólogo ────────────────────────────────────────────────────────────
Route::middleware(['supabase.auth', 'role:NUTRIOLOGO'])
    ->prefix('nutriologo')
    ->group(base_path('routes/api/nutriologo.php'));

// ── Cliente ────────────────────────────────────────────────────────────────
Route::middleware(['supabase.auth', 'role:CLIENTE,ADMINISTRADOR'])
    ->prefix('cliente')
    ->group(base_path('routes/api/cliente.php'));
