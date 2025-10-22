import React, { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import LoginForm from './components/LoginForm';
import ForgotPasswordCard from './components/ForgotPasswordCard';

export default function Login() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isAuthenticated, loading } = useAuth();

  // Redirect authenticated users away from login page
  React.useEffect(() => {
    if (!loading && isAuthenticated) {
      console.log('🔄 Login: Authenticated user detected, redirecting...');
      const redirectTo = location?.state?.from || '/today';
      navigate(redirectTo, { replace: true });
    }
  }, [isAuthenticated, loading, navigate, location?.state?.from]);

  function handleSuccess(target) {
    console.log('✅ Login: Form success, navigating to:', target);
    
    // Multiple navigation strategies
    try {
      navigate(target || '/today', { replace: true });
    } catch (navError) {
      console.warn('⚠️ Login: React Router navigation failed, using fallback:', navError);
      // Fallback to hash navigation
      if (target?.startsWith('/')) {
        window.location.hash = '#' + target;
      } else {
        window.location.hash = '#/today';
      }
    }
  }

  // Show minimal loading state for authenticated users being redirected
  if (loading || isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">{isAuthenticated ? 'Redirecting...' : 'Loading...'}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Welcome back</h1>
          <p className="text-gray-600">Sign in to your Pipeline Activity Tracker account</p>
        </div>
        
        <div className="space-y-6">
          <div className="bg-white py-8 px-6 shadow rounded-lg">
            <LoginForm onSuccess={handleSuccess} />
            
            <div className="mt-6 text-center">
              <p className="text-sm text-gray-600">
                Don't have an account?{' '}
                <button 
                  onClick={() => navigate('/sign-up')}
                  className="font-medium text-blue-600 hover:text-blue-500 focus:outline-none focus:underline transition-colors duration-200"
                >
                  Sign up here
                </button>
              </p>
            </div>
          </div>

          <ForgotPasswordCard />
        </div>
        
        {/* Development helper */}
{import.meta.env.MODE === 'development' ? (
  <div className="text-center">
    <p className="text-xs text-gray-500">
      Development Mode - Check console for authentication logs
    </p>
  </div>
) : null}

    </div>
  </div>
);
}
