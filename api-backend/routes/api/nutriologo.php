<?php

use App\Http\Controllers\Nutriologo\NutriologoController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:nutriologo

Route::get('/dashboard', [NutriologoController::class, 'dashboard']);
Route::get('/clientes',  [NutriologoController::class, 'clientes']);
Route::get('/planes',    [NutriologoController::class, 'planes']);
Route::get('/planes/{planId}', [NutriologoController::class, 'planDetalle']);
Route::post('/planes',   [NutriologoController::class, 'storePlan']);
Route::put('/planes/{planId}', [NutriologoController::class, 'updatePlan']);
Route::delete('/planes/{planId}', [NutriologoController::class, 'destroyPlan']);
Route::post('/planes/{planId}/asignar', [NutriologoController::class, 'assignPlan']);
Route::patch('/asignaciones/{assignmentId}/status', [NutriologoController::class, 'updateAssignmentStatus']);

// Otras del nutriólogo:
// Route::apiResource('/planes', PlanNutricionalController::class);
// Route::post('/clientes/{id}/asignar-dieta', [NutriologoController::class, 'asignarDieta']);
