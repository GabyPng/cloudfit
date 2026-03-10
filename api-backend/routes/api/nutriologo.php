<?php

use App\Http\Controllers\Nutriologo\NutriologoController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:nutriologo

Route::get('/dashboard', [NutriologoController::class, 'dashboard']);
Route::get('/clientes',  [NutriologoController::class, 'clientes']);
Route::get('/planes',    [NutriologoController::class, 'planes']);

// Otras del nutriólogo:
// Route::apiResource('/planes', PlanNutricionalController::class);
// Route::post('/clientes/{id}/asignar-dieta', [NutriologoController::class, 'asignarDieta']);
