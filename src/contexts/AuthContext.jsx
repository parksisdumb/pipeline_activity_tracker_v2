import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [session, setSession] = useState(null);
  const [ctx, setCtx] = useState(null);
  const [loading, setLoading] = useState(true);
  const [authError, setAuthError] = useState(null); // define inside the component
  const navigate = useNavigate();
  const location = useLocation();

  // Fetch Supabase session
  const fetchSession = async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) console.error('❌ getSession error:', error.message);
    return data?.session ?? null;
  };

  // Fetch user context via RPC with error handling
  const fetchContext = async () => {
    try {
      const { data, error } = await supabase.rpc('get_session_context');
      if (error) {
        setAuthError(error.message);
        console.warn('RPC get_session_context error:', error.message);
        return null;
      }
      return data;
    } catch (err) {
      setAuthError('Unexpected error fetching session context.');
      console.error('RPC exception:', err);
      return null;
    }
  };

  // Sign out
  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) console.error('❌ Sign-out error:', error.message);
    setSession(null);
    setCtx(null);
    navigate('/login');
  };

  // Initialize and listen for auth state changes
  useEffect(() => {
    let mounted = true;

    // Timeout to avoid infinite spinner
    const timeoutId = setTimeout(() => {
      if (mounted && loading) {
        setAuthError('Session context could not be loaded. Please refresh.');
        setLoading(false);
      }
    }, 15000); // 15 seconds

    async function init() {
      console.log('🔄 AuthContext initializing...');
      const s = await fetchSession();
      if (!mounted) return;

      setSession(s);
      if (s) {
        const context = await fetchContext();
        if (mounted) setCtx(context);
      }
      setLoading(false);
    }

    init();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, newSession) => {
      console.log('🪄 Auth state change:', event);
      setSession(newSession ?? null);

      if (event === 'SIGNED_IN' && newSession) {
      console.log('✅ User signed in — fetching context');
        const context = await fetchContext();
        setCtx(context);
        navigate('/today');
      }

      if (event === 'SIGNED_OUT') {
        console.log('🚪 User signed out — redirecting');
        setCtx(null);
        navigate('/login');
      }
    });

    return () => {
      mounted = false;
      clearTimeout(timeoutId);
      subscription.unsubscribe();
    };
  }, [navigate, location, loading]);

  const value = useMemo(() => {
    const userProfile = ctx?.user_data || null;
    const isAuthenticated = !!session;
    return { session, ctx, userProfile, isAuthenticated, loading, authError, signOut };
  }, [session, ctx, loading, authError]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);

