<?php

use App\Http\Controllers\Cliente\ClienteController;
use App\Http\Controllers\Cliente\ClienteNutricionistasController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:cliente,admin

Route::get('/dashboard',          [ClienteController::class, 'dashboard']);
Route::get('/plan-entrenamiento', [ClienteController::class, 'planEntrenamiento']);
Route::get('/plan-nutricional',   [ClienteController::class, 'planNutricional']);
Route::get('/progreso',           [ClienteController::class, 'progreso']);

Route::get('/cambios-dieta', [ClienteController::class, 'cambiosDieta']);
Route::patch('/cambios-dieta/{id}/responder', [ClienteController::class, 'responderCambioDieta']);

// Nutriólogos (buscar, ver perfil, enviar solicitud)
Route::get('/nutriologos',                              [ClienteNutricionistasController::class, 'index']);
Route::get('/nutriologos/{nutriologoUserId}',           [ClienteNutricionistasController::class, 'show']);
Route::post('/nutriologos/{nutriologoUserId}/solicitar',[ClienteNutricionistasController::class, 'solicitar']);
Route::get('/solicitudes-nutriologo',                   [ClienteNutricionistasController::class, 'misSolicitudes']);

// Otras del cliente:
// Route::post('/progreso',          [ClienteController::class, 'registrarProgreso']);
// Route::get('/recompensas',        [RecompensaController::class, 'index']);
