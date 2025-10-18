import React, { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../lib/supabase';

const AuthCtx = createContext(null);

export function AuthProvider({ children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [ctx, setCtx] = useState(null);
  const [authError, setAuthError] = useState(null);
  const mountedRef = useRef(false);
  const lastRedirectRef = useRef(null);

  function safeNavigate(path) {
    if (!path) return;
    if (lastRedirectRef?.current === path) return;
    lastRedirectRef.current = path;
    if (location?.pathname !== path) {
      console.log('🎯 AuthContext: Navigating to:', path);
      navigate(path, { replace: true });
    }
  }

  async function fetchSession() {
    try {
      const res = await supabase?.auth?.getSession?.();
      return res?.data?.session ?? null;
    } catch (e) {
      console.error('getSession failed', e);
      return null;
    }
  }

  async function fetchContext() {
    try {
      const { data, error } = await supabase?.rpc?.('get_session_context');
      if (error) {
        console.warn('⚠️ get_session_context RPC error:', error?.message);
        setAuthError(error?.message);
        // Return a fallback success context for authenticated users
        return { success: true, redirect_url: '/today', message: 'RPC fallback mode' };
      }
      if (data && typeof data === 'object') {
        setAuthError(null);
        return data;
      }
      console.warn('⚠️ get_session_context returned invalid data:', data);
      return { success: true, redirect_url: '/today', message: 'Data fallback mode' };
    } catch (e) {
      console.error('get_session_context exception:', e);
      setAuthError(e?.message);
      // Return a fallback success context for authenticated users
      return { success: true, redirect_url: '/today', message: 'Exception fallback mode' };
    }
  }

  async function signOut() {
    try {
      console.log('🔓 AuthContext: Starting signout process...');
      
      // Call Supabase signout
      const { error } = await supabase?.auth?.signOut();
      if (error) {
        console.error('❌ AuthContext: Supabase signout error:', error);
        return { success: false, error: error?.message || 'Signout failed' };
      }
      
      // Clear local state immediately after successful signout
      setSession(null);
      setCtx(null);
      setAuthError(null);
      
      console.log('✅ AuthContext: Signout successful, state cleared');
      return { success: true };
      
    } catch (error) {
      console.error('💥 AuthContext: Signout exception:', error);
      return { success: false, error: error?.message || 'Signout failed' };
    }
  }

  useEffect(() => {
    mountedRef.current = true;
    let timeoutId;

    async function init() {
      timeoutId = setTimeout(() => {
        if (mountedRef?.current) {
          console.log('⏰ AuthContext: Init timeout reached, stopping loading');
          setLoading(false);
        }
      }, 6000);
      
      console.log('🔄 AuthContext: Initializing...');
      const s = await fetchSession();
      if (!mountedRef?.current) return;
      
      console.log('📋 AuthContext: Session fetched:', s ? 'exists' : 'none');
      setSession(s);
      
      if (s) {
        // If user is authenticated, fetch context and handle redirect
        const payload = await fetchContext();
        if (!mountedRef?.current) return;
        setCtx(payload);
        setLoading(false);
        
        // Redirect authenticated user if needed
        if (payload?.redirect_url && payload?.redirect_url !== location?.pathname) {
          console.log('🎯 AuthContext: Init redirect to:', payload?.redirect_url);
          safeNavigate(payload?.redirect_url);
        }
      } else {
        // No session, clear context and stop loading
        setCtx(null);
        setLoading(false);
      }
    }
    
    init();

    const { data: authListener } = supabase?.auth?.onAuthStateChange?.(async (event, newSession) => {
      if (!mountedRef?.current) return;
      console.log('🔄 AuthContext: Auth state change:', event);
      
      setSession(newSession ?? null);
      
      if (event === 'SIGNED_IN' && newSession) {
        console.log('✅ AuthContext: User signed in, fetching context...');
        const payload = await fetchContext();
        if (!mountedRef?.current) return;
        setCtx(payload);
        
        // Handle redirect for successful login
        const targetUrl = payload?.redirect_url || '/today';
        if (location?.pathname === '/login' || location?.pathname === '/sign-up') {
          console.log('🎯 AuthContext: Login success, redirecting to:', targetUrl);
          safeNavigate(targetUrl);
        }
      } else if (event === 'SIGNED_OUT') {
        console.log('🚪 AuthContext: User signed out, clearing context and redirecting to login');
        setCtx(null);
        setAuthError(null);
        safeNavigate('/login');
      } else if (newSession && event !== 'TOKEN_REFRESHED') {
        // Handle other auth events with session
        const payload = await fetchContext();
        if (!mountedRef?.current) return;
        setCtx(payload);
      }
    }) ?? { data: null };

    return () => {
      mountedRef.current = false;
      clearTimeout(timeoutId);
      try { authListener?.subscription?.unsubscribe?.(); } catch {}
    };
  }, [navigate, location?.pathname]);

  const value = useMemo(() => {
    const user = session?.user || null;
    const userProfile = ctx?.user_data || null;
    const isSuperAdmin = userProfile?.role === 'super_admin' || false;
    const isAuthenticated = !!session;
    
    return { 
      session, 
      loading, 
      ctx, 
      user,
      userProfile,
      isSuperAdmin,
      isAuthenticated,
      authError,
      signOut
    };
  }, [session, loading, ctx, authError]);

  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
}

export function useAuth() {
  return useContext(AuthCtx);
}