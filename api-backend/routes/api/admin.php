<?php

use App\Http\Controllers\Admin\AdminController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:admin

Route::get('/dashboard', [AdminController::class, 'dashboard']);
Route::get('/users',     [AdminController::class, 'users']);

// Otras del admin:
// Route::apiResource('/users', UserManagementController::class);
// Route::get('/reportes', [ReporteController::class, 'index']);
