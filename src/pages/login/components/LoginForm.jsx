import React, { useState } from 'react';
import { supabase } from '../../../lib/supabaseClient';

export default function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  async function handleSubmit(e) {
    e?.preventDefault();
    setErrorMsg('');
    setSubmitting(true);

    try {
      console.log('🔐 LoginForm: Starting login process...');
      
      const { data: signInData, error: signInError } = await supabase?.auth?.signInWithPassword({
        email: email?.trim(),
        password,
      });
      
      if (signInError) {
        console.error('❌ LoginForm: Sign in error:', signInError);
        const msg = signInError?.message?.toLowerCase() || '';
        if (msg?.includes('email not confirmed')) {
          setErrorMsg('Please confirm your email before logging in. Check your inbox for a confirmation link.');
        } else if (msg?.includes('invalid login credentials')) {
          setErrorMsg('Invalid email or password. Please check your credentials and try again.');
        } else if (msg?.includes('too many requests')) {
          setErrorMsg('Too many login attempts. Please wait a few minutes before trying again.');
        } else {
          setErrorMsg(signInError?.message || 'Login failed. Please try again.');
        }
        return;
      }
      
      if (!signInData?.session) {
        console.warn('⚠️ LoginForm: Login succeeded but no session created');
        setErrorMsg('Login succeeded but no session was created. Please check your email confirmation settings.');
        return;
      }
      
      console.log('✅ LoginForm: Login successful, user authenticated');
      
      // Replace navigate with window.location redirect
      setTimeout(() => {
        const currentPath = window?.location?.pathname;
        if (currentPath === '/login' || currentPath === '/sign-up') {
          console.log('🎯 LoginForm: Still on login page, manually redirecting to /today');
          window.location.href = '/today';
        }
      }, 500);
      
    } catch (err) {
      console.error('💥 LoginForm: Unexpected login error:', err);
      if (err?.message?.includes('Failed to fetch')) {
        setErrorMsg('Cannot connect to authentication service. Please check your internet connection.');
      } else {
        setErrorMsg('Unexpected error during login. Please try again.');
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {errorMsg ? (
        <div className="p-3 text-sm text-red-600 bg-red-50 border border-red-200 rounded-md">
          {errorMsg}
        </div>
      ) : null}
      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700">
          Email Address
        </label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          required
          value={email}
          onChange={(e) => setEmail(e?.target?.value)}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
          placeholder="Enter your email"
        />
      </div>
      <div>
        <label htmlFor="password" className="block text-sm font-medium text-gray-700">
          Password
        </label>
        <input
          id="password"
          type="password"
          autoComplete="current-password"
          required
          value={password}
          onChange={(e) => setPassword(e?.target?.value)}
          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
          placeholder="Enter your password"
        />
      </div>
      <button
        type="submit"
        disabled={submitting}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {submitting ? (
          <span className="flex items-center">
            <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Signing in...
          </span>
        ) : (
          'Sign In'
        )}
      </button>
    </form>
  );
}