// CloudFit — supabase-config.js
// Inicializa el cliente Supabase para el frontend web.

const SUPABASE_URL  = 'https://xvadhouuqrlhirrfuanq.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here'; // Reemplaza con tu SUPABASE_ANON_KEY

// Inicializar cliente Supabase (desde CDN)
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Backend base URL
const API_BASE = 'http://localhost:8000/api';

console.log('[CloudFit] Supabase client initialized.');
