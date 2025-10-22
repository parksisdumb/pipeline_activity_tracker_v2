import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// ✅ Persistent session + explicit key for stability
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,          // keep session alive
    autoRefreshToken: true,        // refresh before expiration
    detectSessionInUrl: true,      // magic link handling
    storage: window.localStorage,  // store in browser localStorage
  },
});

window.supabase = supabase; // for debugging in console

