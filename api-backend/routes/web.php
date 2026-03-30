<?php

use Illuminate\Support\Facades\Route;

// Catch-all route to serve the SPA layout for any URL so React Router can handle it.
Route::get('/{any}', function () {
    return view('layouts.app');
})->where('any', '.*');
