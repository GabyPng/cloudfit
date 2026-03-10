<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — CloudFit Backend
|--------------------------------------------------------------------------
|
| Hub central de rutas. Cada perfil tiene su propio archivo en routes/api/
| con sus rutas protegidas por el middleware correspondiente.
|
| Estructura de acceso:
|   POST   /api/register       → Público
|   POST   /api/login          → Público
|   POST   /api/logout         → auth:sanctum
|   GET    /api/me             → auth:sanctum
|   GET    /api/admin/*        → auth:sanctum + role:admin
|   GET    /api/coach/*        → auth:sanctum + role:coach
|   GET    /api/nutriologo/*   → auth:sanctum + role:nutriologo
|   GET    /api/cliente/*      → auth:sanctum + role:cliente,admin
|
*/

// ── Autenticación (público + protegido) ─────────────────────────────────
require __DIR__ . '/api/auth.php';

// ── Administrador ────────────────────────────────────────────────────────
Route::middleware(['auth:sanctum', 'role:admin'])
    ->prefix('admin')
    ->group(base_path('routes/api/admin.php'));

// ── Coach ─────────────────────────────────────────────────────────────────
Route::middleware(['auth:sanctum', 'role:coach'])
    ->prefix('coach')
    ->group(base_path('routes/api/coach.php'));

// ── Nutriólogo ────────────────────────────────────────────────────────────
Route::middleware(['auth:sanctum', 'role:nutriologo'])
    ->prefix('nutriologo')
    ->group(base_path('routes/api/nutriologo.php'));

// ── Cliente ────────────────────────────────────────────────────────────────
// El admin también puede acceder para consultar datos de sus clientes
Route::middleware(['auth:sanctum', 'role:cliente,admin'])
    ->prefix('cliente')
    ->group(base_path('routes/api/cliente.php'));
