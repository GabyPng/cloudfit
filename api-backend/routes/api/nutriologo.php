<?php

use App\Http\Controllers\Nutriologo\NutriologoController;
use App\Http\Controllers\Nutriologo\PerfilController;
use App\Http\Controllers\Nutriologo\SeguimientoController;
use App\Http\Controllers\Nutriologo\WeeklyNutritionPlanController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:nutriologo

Route::get('/dashboard', [NutriologoController::class, 'dashboard']);
Route::get('/clientes', [NutriologoController::class, 'clientes']);
Route::get('/planes', [NutriologoController::class, 'planes']);
Route::get('/planes/{planId}', [NutriologoController::class, 'planDetalle']);
Route::post('/planes', [NutriologoController::class, 'storePlan']);
Route::put('/planes/{planId}', [NutriologoController::class, 'updatePlan']);
Route::delete('/planes/{planId}', [NutriologoController::class, 'destroyPlan']);
Route::post('/planes/{planId}/asignar', [NutriologoController::class, 'assignPlan']);
Route::patch('/asignaciones/{assignmentId}/status', [NutriologoController::class, 'updateAssignmentStatus']);
Route::get('/weekly-plan/{clientId}', [WeeklyNutritionPlanController::class, 'show']);
Route::post('/weekly-plan/{clientId}', [WeeklyNutritionPlanController::class, 'save']);

// ── Perfil ──
Route::get('/perfil', [PerfilController::class, 'show']);
Route::put('/perfil', [PerfilController::class, 'update']);
Route::get('/perfil/solicitudes', [PerfilController::class, 'solicitudes']);
Route::patch('/perfil/solicitudes/{id}', [PerfilController::class, 'responderSolicitud']);

// ── Seguimiento ──
Route::get('/seguimiento/pacientes', [SeguimientoController::class, 'pacientes']);
Route::get('/seguimiento/cambios-pendientes', [SeguimientoController::class, 'cambiosPendientes']);
Route::get('/seguimiento/{clientId}/historial', [SeguimientoController::class, 'historial']);
Route::post('/seguimiento/{clientId}/progreso', [SeguimientoController::class, 'registrarProgreso']);
Route::put('/seguimiento/progreso/{recordId}', [SeguimientoController::class, 'actualizarProgreso']);
Route::delete('/seguimiento/progreso/{recordId}', [SeguimientoController::class, 'eliminarProgreso']);
Route::post('/seguimiento/{clientId}/cambio-dieta', [SeguimientoController::class, 'proponerCambioDieta']);

// Otras del nutriólogo:
// Route::apiResource('/planes', PlanNutricionalController::class);
// Route::post('/clientes/{id}/asignar-dieta', [NutriologoController::class, 'asignarDieta']);
