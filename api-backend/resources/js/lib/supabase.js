import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://xvadhouuqrlhirrfuanq.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2YWRob3V1cXJsaGlycmZ1YW5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQzMjg5ODUsImV4cCI6MjA4OTkwNDk4NX0.0zWSPg8gOXPDmIotY2dcIrN1geBww6vjbh8z7jWHsw8';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
