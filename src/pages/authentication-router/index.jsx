import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

export default function AuthenticationRouter() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, loading, validateAndRedirect, userProfile, getUserRole } = useAuth();
  const [error, setError] = useState(null);
  const [processingMessage, setProcessingMessage] = useState('Authenticating...');

  useEffect(() => {
    const handleAuthCallback = async () => {
      if (loading) {
        setProcessingMessage('Loading authentication state...');
        return;
      }

      try {
        // Handle different authentication callback scenarios
        const urlParams = new URLSearchParams(location.search);
        const currentPath = location?.pathname;
        
        // Enhanced detection for various auth callback patterns
        const hasAuthParams = urlParams?.has('access_token') || 
                             urlParams?.has('refresh_token') || 
                             urlParams?.has('token_hash') ||
                             urlParams?.has('type') ||
                             urlParams?.has('code') ||
                             currentPath?.includes('/auth');

        console.log('[AuthRouter] Processing auth callback:', {
          path: currentPath,
          hasAuthParams,
          searchParams: urlParams?.toString(),
          user: user?.id ? 'present' : 'none',
          userRole: getUserRole?.()
        });

        if (hasAuthParams) {
          // Authentication callback detected - validate session
          setProcessingMessage('Validating session and profile...');
          
          try {
            const validationResult = await validateAndRedirect();
            
            if (validationResult?.success) {
              setProcessingMessage('Authentication successful! Redirecting...');
              console.log('✅ Validation successful, redirecting to:', validationResult?.redirectUrl);
              
              // Wait a moment for state updates, then redirect
              setTimeout(() => {
                navigate(validationResult?.redirectUrl || '/today', { replace: true });
              }, 1000);
            } else {
              throw new Error(validationResult?.error || 'Profile validation failed');
            }
          } catch (validationError) {
            console.error('❌ Authentication callback validation error:', validationError);
            
            // Enhanced error handling with specific messages
            let errorMessage = 'Authentication validation failed';
            const errorMsg = validationError?.message || '';
            
            if (errorMsg?.includes('profile')) {
              errorMessage = 'Please complete your profile setup';
            } else if (errorMsg?.includes('session') || errorMsg?.includes('expired')) {
              errorMessage = 'Your session has expired. Please sign in again.';
            } else if (errorMsg?.includes('tenant') || errorMsg?.includes('permission') || errorMsg?.includes('access')) {
              errorMessage = 'Access denied. Please contact your administrator.';
            } else if (errorMsg?.includes('not found') || errorMsg?.includes('exist')) {
              errorMessage = 'User account not found. Please contact your administrator.';
            } else {
              errorMessage = errorMsg || 'Authentication failed. Please try signing in again.';
            }
            
            console.error('Formatted error message:', errorMessage);
            setError(`User profile validation failed: ${errorMessage}`);
            
            // Redirect to login with error message after delay
            setTimeout(() => {
              navigate('/login', { 
                state: { message: errorMessage },
                replace: true 
              });
            }, 3000);
          }
        } else if (user && userProfile) {
          // User already authenticated with complete profile - redirect to appropriate dashboard
          setProcessingMessage('User authenticated, redirecting to dashboard...');
          
          const userRole = getUserRole?.();
          const redirectUrl = userRole === 'super_admin' ? '/super-admin-dashboard' :
                             userRole === 'admin' ? '/admin-dashboard' :
                             userRole === 'manager' ? '/manager-dashboard' : '/today';
          
          console.log('🎯 Authenticated user redirect:', { userRole, redirectUrl });
          
          navigate(redirectUrl, { replace: true });
        } else if (user && !userProfile) {
          // User authenticated but profile not loaded - wait for profile
          setProcessingMessage('Loading user profile...');
          
          // Wait for profile to load or timeout after 5 seconds
          const profileTimeout = setTimeout(() => {
            console.warn('⚠️ Profile loading timeout - redirecting to profile setup');
            navigate('/profile-creation', { replace: true });
          }, 5000);
          
          // Clear timeout if component unmounts
          return () => clearTimeout(profileTimeout);
        } else {
          // No authentication parameters and no user
          setProcessingMessage('No authentication found. Redirecting to login...');
          
          setTimeout(() => {
            navigate('/login', { 
              state: { message: 'Please sign in to continue' },
              replace: true 
            });
          }, 1500);
        }
      } catch (error) {
        console.error('❌ Authentication router error:', error);
        setError('An unexpected error occurred during authentication');
        
        // Fallback error handling
        setTimeout(() => {
          navigate('/login', { 
            state: { message: 'An error occurred. Please try signing in again.' },
            replace: true 
          });
        }, 2000);
      }
    };

    handleAuthCallback();
  }, [loading, location?.search, location?.pathname, user, userProfile, navigate, validateAndRedirect, getUserRole]);

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center p-8">
          <div className="mb-6">
            <div className="mx-auto h-16 w-16 bg-red-100 rounded-full flex items-center justify-center">
              <svg className="h-8 w-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 18.5c-.77.833.192 2.5 1.732 2.5z" />
              </svg>
            </div>
          </div>
          <h2 className="text-lg font-medium text-gray-900 mb-2">Authentication Error</h2>
          <p className="text-gray-600 mb-6 max-w-md">{error}</p>
          <div className="space-y-3">
            <button
              onClick={() => navigate('/login')}
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors w-full sm:w-auto"
            >
              Return to Login
            </button>
            <div className="text-sm text-gray-500">
              Redirecting automatically in a few seconds...
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">{processingMessage}</p>
          <div className="mt-4 text-sm text-gray-500">
            This may take a moment...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <div className="animate-pulse mb-4">
          <div className="h-4 bg-gray-200 rounded w-48 mx-auto mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-32 mx-auto"></div>
        </div>
        <p className="text-gray-600 mt-4">{processingMessage}</p>
      </div>
    </div>
  );
}