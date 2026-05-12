<?php

use App\Http\Controllers\Cliente\ClienteController;
use App\Http\Controllers\Cliente\ClienteNutricionistasController;
use App\Http\Controllers\Cliente\ClienteTicketController;
use App\Http\Controllers\Cliente\ShareController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:cliente,admin

Route::get('/dashboard',          [ClienteController::class, 'dashboard']);
Route::get('/plan-entrenamiento', [ClienteController::class, 'planEntrenamiento']);
Route::get('/plan-nutricional',   [ClienteController::class, 'planNutricional']);
Route::get('/progreso',           [ClienteController::class, 'progreso']);

Route::get('/cambios-dieta', [ClienteController::class, 'cambiosDieta']);
Route::patch('/cambios-dieta/{id}/responder', [ClienteController::class, 'responderCambioDieta']);

// Nutriólogos
Route::get('/nutriologos',                               [ClienteNutricionistasController::class, 'index']);
Route::get('/nutriologos/{nutriologoUserId}',            [ClienteNutricionistasController::class, 'show']);
Route::post('/nutriologos/{nutriologoUserId}/solicitar', [ClienteNutricionistasController::class, 'solicitar']);
Route::get('/solicitudes-nutriologo',                    [ClienteNutricionistasController::class, 'misSolicitudes']);

// ── Soporte / Tickets ──────────────────────────────────────────────────
Route::get('/tickets',                    [ClienteTicketController::class, 'index']);
Route::post('/tickets',                   [ClienteTicketController::class, 'store']);
Route::get('/tickets/{ticketId}',         [ClienteTicketController::class, 'show']);
Route::post('/tickets/{ticketId}/reply',  [ClienteTicketController::class, 'reply']);

// ── Compartir progreso ─────────────────────────────────────────────────
Route::post('/share/progress', [ShareController::class, 'generateProgressLink']);
