<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExerciseController;

Route::controller(ExerciseController::class)->group(function () {
    Route::get('/', 'index');
    Route::get('/{id}', 'show');
    Route::get('/category/{category}', 'getByCategory');
    Route::get('/difficulty/{difficulty}', 'getByDifficulty');
});
