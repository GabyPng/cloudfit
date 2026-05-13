<?php

use App\Http\Controllers\Coach\CoachWebController;
use Illuminate\Support\Facades\Route;

// ── Coach Web Dashboard ──────────────────────────────────────────────────
Route::middleware('coach.web')
    ->prefix('coach')
    ->name('coach.')
    ->group(function () {
        Route::get('/', [CoachWebController::class, 'inicio'])->name('inicio');
        Route::get('/clientes', [CoachWebController::class, 'clientes'])->name('clientes');
        Route::get('/rutinas', [CoachWebController::class, 'rutinas'])->name('rutinas');
        Route::get('/progreso', [CoachWebController::class, 'progreso'])->name('progreso');
        Route::get('/perfil', [CoachWebController::class, 'perfil'])->name('perfil');
    });

// ── SPA catch-all (React Router) ─────────────────────────────────────────
Route::get('/{any}', function () {
    return view('layouts.app');
})->where('any', '.*');
