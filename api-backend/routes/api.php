<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — CloudFit Backend
|--------------------------------------------------------------------------
|
| Autenticación: Firebase ID Token (Bearer)
|   El middleware firebase.auth verifica el token y extrae uid, email y role.
|   El middleware role:{rol} restringe el acceso por rol.
|
| Estructura de acceso:
|   GET    /api/me             → firebase.auth
|   GET    /api/admin/*        → firebase.auth + role:ADMINISTRADOR
|   GET    /api/coach/*        → firebase.auth + role:COACH
|   GET    /api/nutriologo/*   → firebase.auth + role:NUTRIOLOGO
|   GET    /api/cliente/*      → firebase.auth + role:CLIENTE,ADMINISTRADOR
|
*/

// ── Info del usuario autenticado ────────────────────────────────────────
Route::middleware('firebase.auth')
    ->get('/me', [\App\Http\Controllers\Auth\AuthController::class, 'me']);

// ── Administrador ────────────────────────────────────────────────────────
Route::middleware(['firebase.auth', 'role:ADMINISTRADOR'])
    ->prefix('admin')
    ->group(base_path('routes/api/admin.php'));

// ── Coach ─────────────────────────────────────────────────────────────────
Route::middleware(['firebase.auth', 'role:COACH'])
    ->prefix('coach')
    ->group(base_path('routes/api/coach.php'));

// ── Nutriólogo ────────────────────────────────────────────────────────────
Route::middleware(['firebase.auth', 'role:NUTRIOLOGO'])
    ->prefix('nutriologo')
    ->group(base_path('routes/api/nutriologo.php'));

// ── Cliente ────────────────────────────────────────────────────────────────
Route::middleware(['firebase.auth', 'role:CLIENTE,ADMINISTRADOR'])
    ->prefix('cliente')
    ->group(base_path('routes/api/cliente.php'));
