import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../lib/supabaseClient';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [session, setSession] = useState(null);
  const [ctx, setCtx] = useState(null);
  const [loading, setLoading] = useState(true);
  const [authError, setAuthError] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();

  const fetchContext = async () => {
    try {
      const { data, error } = await supabase.rpc('get_session_context');

      if (error) {
        throw error;
      }

      if (!data?.success || !data?.user_data) {
        const message = data?.error || 'User context unavailable';
        console.warn('get_session_context returned failure:', data);
        setAuthError(message);
        return null;
      }

      setAuthError(null);
      return data;
    } catch (err) {
      const message = err?.message || 'Failed to load user context';
      console.error('get_session_context RPC failed:', err);
      setAuthError(message);
      return null;
    }
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) {
      console.error('Sign-out error:', error.message);
    }
    setSession(null);
    setCtx(null);
    setAuthError(null);
    setLoading(false);
    navigate('/login');
  };

  useEffect(() => {
    let mounted = true;

    const loadContext = () => {
      fetchContext().then((context) => {
        if (!mounted) {
          return;
        }
        setCtx(context);
      });
    };

    const initAuth = async () => {
      const { data, error } = await supabase.auth.getSession();

      if (!mounted) {
        return;
      }

      if (error) {
        console.error('getSession error:', error.message);
      }

      const currentSession = data?.session ?? null;

      if (currentSession) {
        setSession(currentSession);
        loadContext();
      } else {
        setSession(null);
        setCtx(null);
        setAuthError(null);
      }

      setLoading(false);
    };

    initAuth();

    const { data: listener } = supabase.auth.onAuthStateChange((event, newSession) => {
      if (!mounted) {
        return;
      }

      setSession(newSession);

      if (event === 'SIGNED_IN' && newSession) {
        loadContext();
        setLoading(false);
        navigate('/today');
        return;
      }

      if (event === 'TOKEN_REFRESHED' && newSession) {
        return;
      }

      if (event === 'SIGNED_OUT') {
        setCtx(null);
        setAuthError(null);
        setLoading(false);
        navigate('/login');
      }
    });

    return () => {
      mounted = false;
      listener?.subscription?.unsubscribe();
    };
  }, [navigate, location]);

  const value = useMemo(() => {
    const sessionUser = session?.user || null;
    const userProfile = ctx?.user_data || null;
    const isAuthenticated = !!sessionUser;
    return { 
      session, 
      user: sessionUser,
      ctx, 
      userProfile, 
      isAuthenticated, 
      loading, 
      authError, 
      signOut 
    };
  }, [session, ctx, loading, authError]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);
