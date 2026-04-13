<?php

use App\Http\Controllers\Chatbot\ChatbotController;
use Illuminate\Support\Facades\Route;

Route::post('/message', [ChatbotController::class, 'message']);
Route::get('/buttons', [ChatbotController::class, 'buttons']);