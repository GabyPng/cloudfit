<?php

use App\Http\Controllers\Coach\CoachController;
use App\Http\Controllers\Coach\CoachPerfilController;
use App\Http\Controllers\Coach\ProgresoController;
use App\Http\Controllers\Coach\RutinasController;
use App\Http\Controllers\Coach\WeeklyPlanController;
use Illuminate\Support\Facades\Route;

// Middleware: supabase.auth + role:COACH (applied in api.php)

Route::get('/dashboard', [CoachController::class, 'dashboard']);
Route::get('/clientes', [CoachController::class, 'clientes']);
Route::get('/planes', [CoachController::class, 'planes']);

// ── Rutinas Module ─────────────────────────────────────────────────────

// Clients (for the routines panel)
Route::get('/rutinas/clients', [RutinasController::class, 'clientsList']);
Route::get('/rutinas/clients/{id}', [RutinasController::class, 'clientDetail']);
Route::get('/rutinas/clients/{id}/routines', [RutinasController::class, 'clientRoutinesList']);

// Routines
Route::get('/rutinas/routines', [RutinasController::class, 'routinesList']);
Route::post('/rutinas/routines', [RutinasController::class, 'routineStore']);
Route::put('/rutinas/routines/{id}', [RutinasController::class, 'routineUpdate']);
Route::delete('/rutinas/routines/{id}', [RutinasController::class, 'routineDestroy']);

// Exercises (sub-resource)
Route::get('/rutinas/routines/{id}/exercises', [RutinasController::class, 'exercisesList']);
Route::post('/rutinas/routines/{id}/exercises', [RutinasController::class, 'exerciseStore']);
Route::patch('/rutinas/routines/{id}/exercises/reorder', [RutinasController::class, 'exercisesReorder']);
Route::put('/rutinas/exercises/{id}', [RutinasController::class, 'exerciseUpdate']);
Route::delete('/rutinas/exercises/{id}', [RutinasController::class, 'exerciseDestroy']);

// Assignments
Route::post('/rutinas/assignments', [RutinasController::class, 'assignmentStore']);
Route::get('/rutinas/assignments', [RutinasController::class, 'assignmentsList']);
Route::patch('/rutinas/assignments/{id}/status', [RutinasController::class, 'assignmentStatus']);

// ── Weekly Plan Module ─────────────────────────────────────────────────
Route::get('/weekly-plan/{clientId}', [WeeklyPlanController::class, 'show']);
Route::post('/weekly-plan/{clientId}', [WeeklyPlanController::class, 'save']);

// ── Progreso Module ────────────────────────────────────────────────────

// ── Perfil del Coach ───────────────────────────────────────────────────
Route::get('/perfil', [CoachPerfilController::class, 'show']);
Route::put('/perfil', [CoachPerfilController::class, 'update']);
Route::post('/perfil/certificates', [CoachPerfilController::class, 'uploadCertificates']);

// ── Progreso Module ────────────────────────────────────────────────────

Route::get('/progreso/clients', [ProgresoController::class, 'clientsList']);
Route::get('/progreso/clients/{id}/composicion', [ProgresoController::class, 'composicion']);
Route::get('/progreso/clients/{id}/fuerza', [ProgresoController::class, 'fuerza']);
Route::get('/progreso/clients/{id}/fatiga', [ProgresoController::class, 'fatiga']);
