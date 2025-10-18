import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(url, key, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    storage: window.localStorage, // ✅ explicitly persist sessions
  },
});

// 👇 This line makes it accessible from the browser console
import { supabase } from '@/lib/supabaseClient'
;
