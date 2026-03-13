<?php

return [
    'use_emulator' => env('DATACONNECT_EMULATOR', false),
    'emulator_host' => env('DATACONNECT_EMULATOR_HOST', 'localhost'),
    'emulator_port' => env('DATACONNECT_EMULATOR_PORT', 9399),
    'project_id'   => env('FIREBASE_PROJECT_ID', 'demo-cloudfit'),
    'location'     => env('DATACONNECT_LOCATION', 'us-east4'),
    'service_id'   => env('DATACONNECT_SERVICE_ID', 'cloudfit'),
    'connector_id' => env('DATACONNECT_CONNECTOR_ID', 'example'),
];
