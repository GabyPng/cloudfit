<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Gemini AI Configuration
    |--------------------------------------------------------------------------
    |
    | Integración con Google Gemini API para el asistente virtual CloudFit.
    | Obtén tu API key gratuita en: https://aistudio.google.com/apikey
    |
    */

    'api_key' => env('GEMINI_API_KEY', 'AIzaSyDW4x4L46fwMJSvTWlWhjXkf_9dUXA1gbM'),
    'model' => env('GEMINI_MODEL', 'gemini-2.0-flash'),
    'enabled' => env('GEMINI_ENABLED', true),
];
