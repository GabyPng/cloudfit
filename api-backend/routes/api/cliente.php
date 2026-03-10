<?php

use App\Http\Controllers\Cliente\ClienteController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:cliente,admin

Route::get('/dashboard',          [ClienteController::class, 'dashboard']);
Route::get('/plan-entrenamiento', [ClienteController::class, 'planEntrenamiento']);
Route::get('/plan-nutricional',   [ClienteController::class, 'planNutricional']);
Route::get('/progreso',           [ClienteController::class, 'progreso']);

// Otras del cliente:
// Route::post('/progreso',          [ClienteController::class, 'registrarProgreso']);
// Route::get('/recompensas',        [RecompensaController::class, 'index']);
