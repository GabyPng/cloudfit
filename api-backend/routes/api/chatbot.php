<?php

use App\Http\Controllers\Chatbot\ChatbotController;
use Illuminate\Support\Facades\Route;

// ✅ Con el middleware de Supabase
Route::middleware('supabase.auth')->post('/message', [ChatbotController::class, 'message']);