<?php

use App\Http\Controllers\Coach\CoachController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:coach

Route::get('/dashboard', [CoachController::class, 'dashboard']);
Route::get('/clientes',  [CoachController::class, 'clientes']);
Route::get('/planes',    [CoachController::class, 'planes']);

<<<<<<< Updated upstream
// Otras del coach:
// Route::apiResource('/planes', PlanEntrenamientoController::class);
// Route::post('/clientes/{id}/asignar-plan', [CoachController::class, 'asignarPlan']);
=======
// ── Rutinas Module ─────────────────────────────────────────────────────

// Clients (for the routines panel)
Route::get('/rutinas/clients',                  [RutinasController::class, 'clientsList']);
Route::get('/rutinas/clients/{id}',             [RutinasController::class, 'clientDetail']);
Route::get('/rutinas/clients/{id}/routines',    [RutinasController::class, 'clientRoutinesList']);

// Routines
Route::get('/rutinas/routines',       [RutinasController::class, 'routinesList']);
Route::post('/rutinas/routines',      [RutinasController::class, 'routineStore']);
Route::put('/rutinas/routines/{id}',  [RutinasController::class, 'routineUpdate']);
Route::delete('/rutinas/routines/{id}', [RutinasController::class, 'routineDestroy']);

// Exercises (sub-resource)
Route::get('/rutinas/routines/{id}/exercises',          [RutinasController::class, 'exercisesList']);
Route::post('/rutinas/routines/{id}/exercises',         [RutinasController::class, 'exerciseStore']);
Route::patch('/rutinas/routines/{id}/exercises/reorder', [RutinasController::class, 'exercisesReorder']);
Route::put('/rutinas/exercises/{id}',    [RutinasController::class, 'exerciseUpdate']);
Route::delete('/rutinas/exercises/{id}', [RutinasController::class, 'exerciseDestroy']);

// Assignments
Route::post('/rutinas/assignments',               [RutinasController::class, 'assignmentStore']);
Route::get('/rutinas/assignments',                 [RutinasController::class, 'assignmentsList']);
Route::patch('/rutinas/assignments/{id}/status',   [RutinasController::class, 'assignmentStatus']);
>>>>>>> Stashed changes
