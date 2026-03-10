<?php

use App\Http\Controllers\Coach\CoachController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:coach

Route::get('/dashboard', [CoachController::class, 'dashboard']);
Route::get('/clientes',  [CoachController::class, 'clientes']);
Route::get('/planes',    [CoachController::class, 'planes']);

// Otras del coach:
// Route::apiResource('/planes', PlanEntrenamientoController::class);
// Route::post('/clientes/{id}/asignar-plan', [CoachController::class, 'asignarPlan']);
