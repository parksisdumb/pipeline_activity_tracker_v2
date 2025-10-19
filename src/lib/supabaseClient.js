import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// ✅ Enable session persistence and auto-refresh explicitly
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,          // <-- this ensures sessions survive refresh
    autoRefreshToken: true,        // <-- keeps tokens fresh
    detectSessionInUrl: true,      // <-- allows magic link / email logins to complete
    storage: window.localStorage,  // <-- explicitly set to localStorage
  },
});

window.supabase = supabase; // helpful for debugging

