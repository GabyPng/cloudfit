<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Supabase Configuration
    |--------------------------------------------------------------------------
    | SUPABASE_URL         → https://<project-id>.supabase.co
    | SUPABASE_ANON_KEY    → Clave pública (safe for client-side)
    | SUPABASE_SERVICE_KEY → Clave de service role (server-side only, ¡nunca exponer!)
    | SUPABASE_JWT_SECRET  → JWT secret para verificar tokens (Settings > API)
    */

    'url'         => env('SUPABASE_URL', ''),
    'anon_key'    => env('SUPABASE_ANON_KEY', ''),
    'service_key' => env('SUPABASE_SERVICE_ROLE_KEY', ''),
    'jwt_secret'  => env('SUPABASE_JWT_SECRET'),
    'jwt_public_key' => env('SUPABASE_JWT_PUBLIC_KEY'),
    'db_url'      => env('SUPABASE_DB_URL', ''),
];
