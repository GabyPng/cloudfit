<?php

return [
    'project_id'  => env('FIREBASE_PROJECT_ID', 'demo-cloudfit'),
    'emulator'    => env('FIREBASE_AUTH_EMULATOR', true),
    'credentials' => env('FIREBASE_CREDENTIALS'), // ruta al JSON de service account (solo producción)
];
