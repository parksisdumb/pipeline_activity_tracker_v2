import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Link } from 'react-router-dom';
import { Mail, CheckCircle, AlertTriangle, Loader, ArrowRight, RefreshCw } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

const MagicLinkAuthentication = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { 
    user, 
    loading, 
    sendMagicLink, 
    completeProfileSetup,
    checkPasswordSetupNeeded,
    isAuthenticated 
  } = useAuth();

  const [authState, setAuthState] = useState('checking'); // 'checking', 'success', 'error', 'setup_needed', 'request_new'
  const [message, setMessage] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [email, setEmail] = useState('');
  const [needsSetup, setNeedsSetup] = useState(false);
  const [setupData, setSetupData] = useState({
    fullName: '',
    role: 'rep',
    organization: ''
  });

  // Enhanced URL parameter processing
  useEffect(() => {
    const processAuthCallback = async () => {
      try {
        setAuthState('checking');
        setMessage('Processing authentication...');

        // Get URL parameters
        const access_token = searchParams?.get('access_token');
        const refresh_token = searchParams?.get('refresh_token');
        const token_type = searchParams?.get('token_type');
        const type = searchParams?.get('type');
        const code = searchParams?.get('code');
        const error_code = searchParams?.get('error_code');
        const error_description = searchParams?.get('error_description');

        // Handle errors from URL
        if (error_code || error_description) {
          const errorMsg = error_description || `Authentication error: ${error_code}`;
          setMessage(errorMsg);
          setAuthState('error');
          return;
        }

        // Handle password recovery - redirect any recovery payload (code OR tokens) to password reset flow
        if (type === 'recovery' || code) {
          console.log('Password recovery detected in magic-link page, redirecting to password-reset');
          
          const currentParams = new URLSearchParams(searchParams?.toString());
          
          // Ensure type is set correctly
          currentParams.set('type', 'recovery');
          
          navigate(`/password-reset?${currentParams.toString()}`, { replace: true });
          return;
        }

        // Handle email confirmation
        if (type === 'signup' || type === 'email_change') {
          if (access_token && refresh_token) {
            // Set the session with tokens
            const { data: sessionData, error: sessionError } = await supabase?.auth?.setSession({
              access_token,
              refresh_token
            });

            if (sessionError) {
              console.error('Session setting error:', sessionError);
              setMessage('Failed to confirm email. The link may have expired.');
              setAuthState('error');
              return;
            }

            if (sessionData?.user) {
              setMessage('Email confirmed successfully! Setting up your account...');
              
              // Check if user needs profile setup
              const needsPasswordSetup = await checkPasswordSetupNeeded(sessionData?.user?.id);
              
              if (needsPasswordSetup) {
                setNeedsSetup(true);
                setEmail(sessionData?.user?.email || '');
                setAuthState('setup_needed');
                setMessage('Email confirmed! Please complete your profile setup.');
              } else {
                setAuthState('success');
                setMessage('Email confirmed! Redirecting to your dashboard...');
                setTimeout(() => {
                  navigate('/today');
                }, 2000);
              }
            }
          } else {
            setMessage('Invalid confirmation link. Please request a new one.');
            setAuthState('error');
          }
          return;
        }

        // Handle magic link sign in
        if (type === 'magiclink' && access_token) {
          // Set the session with tokens
          const { data: sessionData, error: sessionError } = await supabase?.auth?.setSession({
            access_token,
            refresh_token
          });

          if (sessionError) {
            console.error('Magic link session error:', sessionError);
            setMessage('Magic link authentication failed. The link may have expired.');
            setAuthState('error');
            return;
          }

          if (sessionData?.user) {
            setMessage('Magic link authentication successful! Redirecting...');
            setAuthState('success');
            setTimeout(() => {
              navigate('/today');
            }, 2000);
          }
          return;
        }

        // If user is already authenticated, redirect
        if (isAuthenticated) {
          setMessage('You are already signed in! Redirecting...');
          setAuthState('success');
          setTimeout(() => {
            navigate('/today');
          }, 1500);
          return;
        }

        // If no specific type, show magic link request form
        setAuthState('request_new');

      } catch (error) {
        console.error('Authentication callback processing error:', error);
        setMessage('An unexpected error occurred during authentication. Please try again.');
        setAuthState('error');
      }
    };

    if (!loading) {
      processAuthCallback();
    }
  }, [searchParams, navigate, loading, isAuthenticated, checkPasswordSetupNeeded]);

  // Handle profile setup completion
  const handleProfileSetup = async (e) => {
    e?.preventDefault();
    
    if (!setupData?.fullName?.trim()) {
      setMessage('Please enter your full name.');
      return;
    }

    setIsProcessing(true);
    setMessage('Setting up your profile...');

    try {
      const result = await completeProfileSetup(setupData);
      
      if (result?.success) {
        setMessage('Profile setup completed! Redirecting to your dashboard...');
        setTimeout(() => {
          navigate(result?.redirectTo || '/today');
        }, 2000);
      } else {
        setMessage(result?.error?.message || 'Failed to complete profile setup. Please try again.');
      }
    } catch (error) {
      console.error('Profile setup error:', error);
      setMessage('Profile setup failed. Please try again.');
    } finally {
      setIsProcessing(false);
    }
  };

  // Handle sending new magic link
  const handleSendMagicLink = async (e) => {
    e?.preventDefault();
    
    if (!email?.trim() || !email?.includes('@')) {
      setMessage('Please enter a valid email address.');
      return;
    }

    setIsProcessing(true);
    setMessage('Sending magic link...');

    try {
      const result = await sendMagicLink(email);
      
      if (result?.success) {
        setMessage(`Magic link sent to ${email}! Please check your email (including spam folder) and click the link to sign in.`);
      } else {
        setMessage(result?.error || 'Failed to send magic link. Please try again.');
      }
    } catch (error) {
      console.error('Magic link send error:', error);
      setMessage('Failed to send magic link. Please try again.');
    } finally {
      setIsProcessing(false);
    }
  };

  // Loading state
  if (loading || authState === 'checking') {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10 text-center">
            <Loader className="h-8 w-8 animate-spin mx-auto text-blue-600 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Processing Authentication</h2>
            <p className="text-gray-600">{message || 'Please wait while we process your request...'}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold text-gray-900">
            {authState === 'success' ? 'Authentication Successful' :
             authState === 'setup_needed' ? 'Complete Your Profile' :
             authState === 'error'? 'Authentication Failed' : 'Sign In with Magic Link'}
          </h2>
        </div>

        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          
          {/* Success State */}
          {authState === 'success' && (
            <div className="text-center">
              <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-green-800 mb-2">Success!</h3>
              <p className="text-sm text-green-700 mb-4">{message}</p>
              <div className="flex items-center justify-center text-blue-600">
                <Loader className="h-4 w-4 animate-spin mr-2" />
                Redirecting...
              </div>
            </div>
          )}

          {/* Error State */}
          {authState === 'error' && (
            <div className="text-center">
              <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-red-800 mb-2">Authentication Failed</h3>
              <p className="text-sm text-red-700 mb-6">{message}</p>
              
              <div className="space-y-3">
                <Link 
                  to="/login"
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center"
                >
                  <ArrowRight className="h-4 w-4 mr-2" />
                  Back to Login
                </Link>
                
                <button
                  onClick={() => {
                    setAuthState('request_new');
                    setMessage('');
                  }}
                  className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center"
                >
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Try Again
                </button>
              </div>
            </div>
          )}

          {/* Profile Setup State */}
          {authState === 'setup_needed' && (
            <div>
              <div className="text-center mb-6">
                <CheckCircle className="h-8 w-8 text-green-500 mx-auto mb-2" />
                <p className="text-sm text-green-700">{message}</p>
              </div>

              <form onSubmit={handleProfileSetup} className="space-y-4">
                <div>
                  <label htmlFor="fullName" className="block text-sm font-medium text-gray-700">
                    Full Name *
                  </label>
                  <input
                    id="fullName"
                    type="text"
                    required
                    value={setupData?.fullName}
                    onChange={(e) => setSetupData(prev => ({ ...prev, fullName: e?.target?.value }))}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    placeholder="Enter your full name"
                  />
                </div>

                <div>
                  <label htmlFor="role" className="block text-sm font-medium text-gray-700">
                    Role
                  </label>
                  <select
                    id="role"
                    value={setupData?.role}
                    onChange={(e) => setSetupData(prev => ({ ...prev, role: e?.target?.value }))}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  >
                    <option value="rep">Sales Representative</option>
                    <option value="manager">Manager</option>
                    <option value="admin">Administrator</option>
                  </select>
                </div>

                <div>
                  <label htmlFor="organization" className="block text-sm font-medium text-gray-700">
                    Organization
                  </label>
                  <input
                    id="organization"
                    type="text"
                    value={setupData?.organization}
                    onChange={(e) => setSetupData(prev => ({ ...prev, organization: e?.target?.value }))}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    placeholder="Enter your organization name"
                  />
                </div>

                <button
                  type="submit"
                  disabled={isProcessing}
                  className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isProcessing ? (
                    <>
                      <Loader className="h-4 w-4 animate-spin mr-2" />
                      Setting up...
                    </>
                  ) : (
                    'Complete Setup'
                  )}
                </button>
              </form>
            </div>
          )}

          {/* Request New Magic Link State */}
          {authState === 'request_new' && (
            <div>
              <div className="text-center mb-6">
                <Mail className="h-8 w-8 text-blue-600 mx-auto mb-2" />
                <p className="text-sm text-gray-600">
                  Enter your email address to receive a sign-in link
                </p>
              </div>

              <form onSubmit={handleSendMagicLink} className="space-y-4">
                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                    Email Address
                  </label>
                  <input
                    id="email"
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e?.target?.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    placeholder="Enter your email address"
                  />
                </div>

                {message && (
                  <div className={`p-3 rounded-md text-sm ${
                    message?.includes('sent') 
                      ? 'bg-green-50 text-green-700 border border-green-200' :'bg-red-50 text-red-700 border border-red-200'
                  }`}>
                    {message}
                  </div>
                )}

                <button
                  type="submit"
                  disabled={isProcessing}
                  className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isProcessing ? (
                    <>
                      <Loader className="h-4 w-4 animate-spin mr-2" />
                      Sending...
                    </>
                  ) : (
                    <>
                      <Mail className="h-4 w-4 mr-2" />
                      Send Magic Link
                    </>
                  )}
                </button>
              </form>

              <div className="mt-4 text-center">
                <Link 
                  to="/login"
                  className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                >
                  Back to Login
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default MagicLinkAuthentication;
