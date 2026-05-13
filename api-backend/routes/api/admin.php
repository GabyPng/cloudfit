<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\AnalyticsController;
use App\Http\Controllers\Admin\ProfessionalValidationController;
use App\Http\Controllers\Admin\TicketController;
use Illuminate\Support\Facades\Route;

// Middleware: auth:sanctum + role:admin

Route::get('/dashboard', [AdminController::class, 'dashboard']);
Route::get('/users', [AdminController::class, 'users']);

// ── Professional Validation ────────────────────────────────────────────
Route::get('/professionals', [ProfessionalValidationController::class, 'index']);
Route::get('/professionals/{userId}', [ProfessionalValidationController::class, 'show']);
Route::patch('/professionals/{userId}/verify', [ProfessionalValidationController::class, 'verify']);
Route::patch('/professionals/{userId}/reject', [ProfessionalValidationController::class, 'reject']);

// ── Tickets / Support ──────────────────────────────────────────────────
Route::get('/tickets', [TicketController::class, 'index']);
Route::get('/tickets/{ticketId}', [TicketController::class, 'show']);
Route::patch('/tickets/{ticketId}/status', [TicketController::class, 'updateStatus']);
Route::post('/tickets/{ticketId}/reply', [TicketController::class, 'reply']);

// ── Analytics ──────────────────────────────────────────────────────────
Route::get('/analytics/overview', [AnalyticsController::class, 'overview']);
Route::get('/analytics/growth', [AnalyticsController::class, 'growth']);
Route::get('/analytics/professionals', [AnalyticsController::class, 'professionals']);
Route::get('/analytics/usage', [AnalyticsController::class, 'usage']);
