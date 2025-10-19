import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Link } from 'react-router-dom';
import { Lock, CheckCircle, AlertTriangle, Loader, ArrowRight, Eye, EyeOff } from 'lucide-react';
import { supabase } from '../../lib/supabaseClient';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';

const PasswordResetPage = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  
  const [resetState, setResetState] = useState('checking'); // 'checking', 'ready', 'success', 'error'
  const [message, setMessage] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [passwordData, setPasswordData] = useState({
    password: '',
    confirmPassword: ''
  });
  const [passwordStrength, setPasswordStrength] = useState({
    score: 0,
    requirements: {
      length: false,
      uppercase: false,
      lowercase: false,
      number: false,
      special: false
    }
  });
  const [userEmail, setUserEmail] = useState('');

  // Check password strength
  useEffect(() => {
    const checkPasswordStrength = (password) => {
      if (!password) {
        setPasswordStrength({
          score: 0,
          requirements: {
            length: false,
            uppercase: false,
            lowercase: false,
            number: false,
            special: false
          }
        });
        return;
      }

      const requirements = {
        length: password?.length >= 8,
        uppercase: /[A-Z]/?.test(password),
        lowercase: /[a-z]/?.test(password),
        number: /\d/?.test(password),
        special: /[!@#$%^&*(),.?":{}|<>]/?.test(password)
      };

      const score = Object.values(requirements)?.filter(Boolean)?.length;

      setPasswordStrength({
        score,
        requirements
      });
    };

    checkPasswordStrength(passwordData?.password);
  }, [passwordData?.password]);

  // CRITICAL FIX: Enhanced PKCE token processing for password reset
  useEffect(() => {
    const processPasswordReset = async () => {
      try {
        setResetState('checking');
        setMessage('Validating password reset link...');

        // Get all URL parameters for comprehensive handling
        const access_token = searchParams?.get('access_token');
        const refresh_token = searchParams?.get('refresh_token');
        const type = searchParams?.get('type');
        const code = searchParams?.get('code');
        const token = searchParams?.get('token');
        const error_code = searchParams?.get('error_code');
        const error_description = searchParams?.get('error_description');

        // Enhanced logging for debugging
        console.log('Password reset parameters detected:', {
          access_token: !!access_token,
          refresh_token: !!refresh_token,
          type,
          code: !!code,
          token: !!token,
          error_code,
          error_description,
          fullUrl: window?.location?.href,
          timestamp: new Date()?.toISOString()
        });

        // Handle errors from URL first
        if (error_code || error_description) {
          const errorMsg = error_description || `Reset link error: ${error_code}`;
          console.error('URL error detected:', errorMsg);
          setMessage(errorMsg);
          setResetState('error');
          return;
        }

        // CRITICAL FIX: Enhanced PKCE token handling with better error messages
        if (token && token?.startsWith('pkce_')) {
          console.log('PKCE token detected for password reset:', token?.substring(0, 20) + '...');
          setMessage('Processing PKCE password reset token...');
          
          try {
            // CRITICAL: Add timeout and retry logic for PKCE token exchange
            const exchangePromise = supabase?.auth?.exchangeCodeForSession(token);
            const timeoutPromise = new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Token exchange timeout')), 30000)
            );
            
            const { data: sessionData, error: sessionError } = await Promise.race([
              exchangePromise,
              timeoutPromise
            ]);
            
            console.log('PKCE exchange result:', {
              hasSession: !!sessionData?.session,
              hasUser: !!sessionData?.user,
              error: sessionError?.message,
              timestamp: new Date()?.toISOString()
            });

            if (sessionError) {
              console.error('PKCE token exchange failed:', sessionError);
              
              // CRITICAL FIX: Enhanced error handling for specific PKCE issues
              if (sessionError?.message?.includes('expired') || 
                  sessionError?.message?.includes('invalid_grant') ||
                  sessionError?.message?.includes('token_expired')) {
                setMessage('This password reset link has expired. Password reset links are only valid for a limited time. Please request a new password reset link.');
              } else if (sessionError?.message?.includes('code_verifier') ||
                         sessionError?.message?.includes('code_challenge') ||
                         sessionError?.message?.includes('pkce')) {
                setMessage('Invalid password reset link format. Please ensure you clicked the exact link from your email and did not copy/paste or modify the URL.');
              } else if (sessionError?.message?.includes('Invalid login credentials') ||
                         sessionError?.message?.includes('unauthorized')) {
                setMessage('This password reset link is no longer valid. Please request a new password reset from the login page.');
              } else if (sessionError?.message?.includes('network') ||
                         sessionError?.message?.includes('fetch')) {
                setMessage('Network connection issue. Please check your internet connection and try again, or request a new password reset link.');
              } else {
                setMessage(`Password reset link processing failed: ${sessionError?.message || 'Unknown error'}. Please request a new password reset link.`);
              }
              setResetState('error');
              return;
            }

            if (sessionData?.session?.user || sessionData?.user) {
              const user = sessionData?.session?.user || sessionData?.user;
              setUserEmail(user?.email || '');
              console.log('PKCE session established for password reset:', user?.email);
              setMessage('Password reset link verified! Please enter your new password below.');
              setResetState('ready');
            } else {
              console.warn('PKCE exchange successful but no user/session returned');
              setMessage('Password reset link processed, but no user session found. This may indicate the link has already been used. Please request a new password reset link.');
              setResetState('error');
            }
          } catch (tokenError) {
            console.error('PKCE token processing error:', tokenError);
            
            if (tokenError?.message?.includes('timeout')) {
              setMessage('Password reset link processing timed out. This may indicate a network issue or expired link. Please try again or request a new password reset link.');
            } else if (tokenError?.message?.includes('Failed to fetch') ||
                       tokenError?.message?.includes('NetworkError')) {
              setMessage('Cannot connect to authentication service. Please check your internet connection and try again.');
            } else {
              setMessage('Failed to process password reset link. Please request a new password reset link.');
            }
            setResetState('error');
          }
          return;
        }

        // Handle regular code-based password recovery (fallback)
        if (code && (type === 'recovery' || !type)) {
          console.log('Regular code detected for password reset');
          setMessage('Processing password reset code...');
          
          try {
            // Add timeout for code exchange as well
            const exchangePromise = supabase?.auth?.exchangeCodeForSession(code);
            const timeoutPromise = new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Code exchange timeout')), 30000)
            );
            
            const { data: sessionData, error: sessionError } = await Promise.race([
              exchangePromise,
              timeoutPromise
            ]);
            
            console.log('Code exchange result:', {
              hasSession: !!sessionData?.session,
              hasUser: !!sessionData?.user,
              error: sessionError?.message,
              timestamp: new Date()?.toISOString()
            });

            if (sessionError) {
              console.error('Code exchange error:', sessionError);
              
              // CRITICAL FIX: Enhanced PKCE error detection in regular code flow
              if (sessionError?.message?.includes('code_challenge') || 
                  sessionError?.message?.includes('pkce') ||
                  sessionError?.message?.includes('code_verifier')) {
                console.log('PKCE challenge detected in regular code - this should be handled as PKCE token');
                setMessage('This appears to be a PKCE-enabled password reset link. Please ensure you are using the exact link from your email without any modifications.');
                setResetState('error');
                return;
              }

              if (sessionError?.message?.includes('expired') || 
                  sessionError?.message?.includes('invalid_grant')) {
                setMessage('Password reset link has expired. Please request a new password reset link.');
              } else {
                setMessage('Invalid password reset link. Please request a new password reset link.');
              }
              setResetState('error');
              return;
            }

            if (sessionData?.session?.user || sessionData?.user) {
              const user = sessionData?.session?.user || sessionData?.user;
              setUserEmail(user?.email || '');
              console.log('Regular code session established for password reset:', user?.email);
              setMessage('Password reset link verified! Please enter your new password below.');
              setResetState('ready');
            } else {
              setMessage('Invalid password reset link. Please request a new password reset link.');
              setResetState('error');
            }
          } catch (exchangeError) {
            console.error('Code exchange processing error:', exchangeError);
            
            if (exchangeError?.message?.includes('timeout')) {
              setMessage('Password reset processing timed out. Please try again or request a new password reset link.');
            } else {
              setMessage('Failed to process password reset link. Please request a new password reset link.');
            }
            setResetState('error');
          }
          return;
        }

        // Handle token-based recovery (older flow)
        if (token && !token?.startsWith('pkce_') && (type === 'recovery' || !type)) {
          console.log('Legacy token detected for password reset');
          setMessage('Processing legacy password reset token...');
          
          try {
            // Try to use token with exchangeCodeForSession
            const { data: sessionData, error: sessionError } = await supabase?.auth?.exchangeCodeForSession(token);
            
            if (sessionError) {
              console.error('Legacy token exchange error:', sessionError);
              setMessage('Password reset link has expired or is invalid. Please request a new password reset link.');
              setResetState('error');
              return;
            }

            if (sessionData?.session?.user || sessionData?.user) {
              const user = sessionData?.session?.user || sessionData?.user;
              setUserEmail(user?.email || '');
              console.log('Legacy token session established for password reset:', user?.email);
              setMessage('Password reset link verified! Please enter your new password below.');
              setResetState('ready');
            } else {
              setMessage('Invalid password reset link. Please request a new password reset link.');
              setResetState('error');
            }
          } catch (tokenError) {
            console.error('Legacy token processing error:', tokenError);
            setMessage('Failed to process password reset link. Please request a new password reset link.');
            setResetState('error');
          }
          return;
        }

        // Handle direct access_token + refresh_token flow
        if (access_token && refresh_token && type === 'recovery') {
          console.log('Direct tokens detected for password reset');
          setMessage('Processing direct authentication tokens...');
          
          try {
            // Set the session with provided tokens
            const { data: sessionData, error: sessionError } = await supabase?.auth?.setSession({
              access_token,
              refresh_token
            });

            console.log('Direct token session result:', {
              hasSession: !!sessionData?.session,
              hasUser: !!sessionData?.user,
              error: sessionError?.message,
              timestamp: new Date()?.toISOString()
            });

            if (sessionError) {
              console.error('Direct token session error:', sessionError);
              setMessage('Failed to validate password reset tokens. The link may have expired.');
              setResetState('error');
              return;
            }

            if (sessionData?.session?.user) {
              setUserEmail(sessionData?.session?.user?.email || '');
              console.log('Direct token session established for password reset:', sessionData?.session?.user?.email);
              setMessage('Password reset tokens verified! Please enter your new password below.');
              setResetState('ready');
            } else {
              setMessage('Invalid password reset session. Please request a new password reset link.');
              setResetState('error');
            }
          } catch (error) {
            console.error('Direct token processing error:', error);
            setMessage('Failed to process password reset tokens. Please try requesting a new password reset link.');
            setResetState('error');
          }
          return;
        }

        // If no valid parameters detected, show error with helpful message
        console.log('No valid password reset parameters found');
        setMessage('Invalid password reset link. This may happen if the link is incomplete, has been modified, or is from an old email. Please request a new password reset from the login page.');
        setResetState('error');

      } catch (error) {
        console.error('Password reset processing error:', error);
        setMessage('An unexpected error occurred during password reset processing. Please try requesting a new password reset link.');
        setResetState('error');
      }
    };

    processPasswordReset();
  }, [searchParams]);

  // Enhanced password update with better session handling and error messages
  const handlePasswordUpdate = async (e) => {
    e?.preventDefault();

    // Validation
    if (!passwordData?.password || !passwordData?.confirmPassword) {
      setMessage('Please fill in both password fields.');
      return;
    }

    if (passwordData?.password !== passwordData?.confirmPassword) {
      setMessage('Passwords do not match. Please check and try again.');
      return;
    }

    if (passwordStrength?.score < 4) {
      setMessage('Password does not meet security requirements. Please ensure it meets all criteria listed below.');
      return;
    }

    setIsProcessing(true);
    setMessage('Updating your password...');

    try {
      // CRITICAL FIX: Enhanced session validation before password update
      const { data: currentSession, error: sessionError } = await supabase?.auth?.getSession();
      
      if (sessionError) {
        console.error('Session check error:', sessionError);
        setMessage('Unable to verify your session. Please request a new password reset link.');
        setResetState('error');
        setIsProcessing(false);
        return;
      }
      
      if (!currentSession?.session) {
        console.error('No valid session for password update');
        setMessage('Your password reset session has expired. Please request a new password reset link.');
        setResetState('error');
        setIsProcessing(false);
        return;
      }

      // Verify session is still valid and not expired
      const sessionExpiry = new Date(currentSession?.session?.expires_at || 0);
      const now = new Date();
      
      if (sessionExpiry <= now) {
        console.error('Session expired:', { sessionExpiry, now });
        setMessage('Your password reset session has expired. Please request a new password reset link.');
        setResetState('error');
        setIsProcessing(false);
        return;
      }

      console.log('Updating password for user:', currentSession?.session?.user?.email);

      // CRITICAL FIX: Enhanced password update with retry logic
      let updateAttempts = 0;
      const maxAttempts = 3;
      let updateResult = null;

      while (updateAttempts < maxAttempts) {
        try {
          updateResult = await supabase?.auth?.updateUser({
            password: passwordData?.password
          });
          
          if (!updateResult?.error) {
            break; // Success, exit retry loop
          }
          
          // If we get a session error, don't retry
          if (updateResult?.error?.message?.includes('session') || 
              updateResult?.error?.message?.includes('expired')) {
            break;
          }
          
          updateAttempts++;
          if (updateAttempts < maxAttempts) {
            console.log(`Password update attempt ${updateAttempts} failed, retrying...`);
            await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second before retry
          }
        } catch (attemptError) {
          console.error(`Password update attempt ${updateAttempts + 1} error:`, attemptError);
          updateAttempts++;
          if (updateAttempts < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, 1000));
          } else {
            throw attemptError;
          }
        }
      }

      const { data, error } = updateResult || {};

      if (error) {
        console.error('Password update error:', error);
        
        // Enhanced error handling for password update
        if (error?.message?.includes('session_not_found') || 
            error?.message?.includes('expired') ||
            error?.message?.includes('unauthorized')) {
          setMessage('Your password reset session has expired or is invalid. Please request a new password reset link.');
          setResetState('error');
        } else if (error?.message?.includes('password')) {
          setMessage('Password update failed. Please ensure your password meets all requirements and try again.');
        } else if (error?.message?.includes('network') || 
                   error?.message?.includes('fetch')) {
          setMessage('Network error occurred while updating password. Please check your connection and try again.');
        } else {
          setMessage(error?.message || 'Failed to update password. Please try again.');
        }
        return;
      }

      if (data?.user) {
        console.log('Password updated successfully for:', data?.user?.email);
        setMessage('Password updated successfully! Redirecting to login...');
        setResetState('success');
        
        // Clear form
        setPasswordData({ password: '', confirmPassword: '' });
        
        // CRITICAL FIX: Enhanced session cleanup and redirect
        try {
          // Sign out to clear the password reset session
          await supabase?.auth?.signOut();
          
          // Clear any cached session data
          if (typeof window !== 'undefined' && window?.localStorage) {
            Object.keys(window?.localStorage)
              ?.filter(key => key?.startsWith('supabase.auth'))
              ?.forEach(key => window?.localStorage?.removeItem(key));
          }
        } catch (signOutError) {
          console.warn('Error during sign out after password reset:', signOutError);
          // Continue with redirect even if sign out fails
        }
        
        // Add delay before redirect to show success message
        setTimeout(() => {
          navigate('/login', {
            state: {
              message: 'Password updated successfully! Please sign in with your new password.',
              email: userEmail,
              type: 'success'
            },
            replace: true
          });
        }, 3000);
      } else {
        console.error('Password update returned no user data');
        setMessage('Password update completed but no confirmation received. Please try signing in with your new password.');
        
        setTimeout(() => {
          navigate('/login', {
            state: {
              email: userEmail,
              message: 'Password may have been updated. Please try signing in.',
              type: 'info'
            },
            replace: true
          });
        }, 2000);
      }

    } catch (error) {
      console.error('Password update error:', error);
      
      if (error?.message?.includes('Failed to fetch') || 
          error?.message?.includes('NetworkError')) {
        setMessage('Cannot connect to authentication service. Please check your internet connection and try again.');
      } else if (error?.message?.includes('timeout')) {
        setMessage('Request timed out. Please try again or request a new password reset link.');
      } else if (error?.message?.includes('session')) {
        setMessage('Your session has expired. Please request a new password reset link.');
        setResetState('error');
      } else {
        setMessage('An unexpected error occurred. Please try again or request a new password reset link.');
      }
    } finally {
      setIsProcessing(false);
    }
  };

  // Handle form input changes
  const handleInputChange = (field, value) => {
    setPasswordData(prev => ({
      ...prev,
      [field]: value
    }));
    
    // Clear message when user starts typing
    if (message && !message?.includes('verified')) {
      setMessage('');
    }
  };

  // Loading state with enhanced messaging
  if (resetState === 'checking') {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10 text-center">
            <Loader className="h-8 w-8 animate-spin mx-auto text-blue-600 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Validating Reset Link</h2>
            <p className="text-gray-600">
              {message || 'Please wait while we validate your password reset link...'}
            </p>
            <div className="mt-4 text-xs text-gray-500">
              Processing authentication tokens securely...
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center mb-8">
          <div className="mx-auto h-12 w-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
            <Lock className="h-6 w-6 text-blue-600" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900">
            {resetState === 'success' ? 'Password Updated' : 
             resetState === 'error' ? 'Reset Link Issue' : 'Reset Your Password'}
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            {resetState === 'ready' && userEmail && `Resetting password for ${userEmail}`}
          </p>
        </div>

        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          
          {/* Success State */}
          {resetState === 'success' && (
            <div className="text-center">
              <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-green-800 mb-2">Password Updated Successfully!</h3>
              <p className="text-sm text-green-700 mb-4">{message}</p>
              <div className="flex items-center justify-center text-blue-600">
                <Loader className="h-4 w-4 animate-spin mr-2" />
                Redirecting to login...
              </div>
            </div>
          )}

          {/* Error State */}
          {resetState === 'error' && (
            <div className="text-center">
              <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-red-800 mb-2">Password Reset Failed</h3>
              <p className="text-sm text-red-700 mb-6">{message}</p>
              
              <div className="space-y-3">
                <Link 
                  to="/login"
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center"
                >
                  <ArrowRight className="h-4 w-4 mr-2" />
                  Back to Login
                </Link>
                
                <Link
                  to="/password-reset-request"
                  className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center"
                >
                  Request New Reset Link
                </Link>
              </div>

              {/* Enhanced troubleshooting info */}
              <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-md text-left">
                <h4 className="text-sm font-medium text-yellow-800 mb-2">Troubleshooting Tips:</h4>
                <ul className="text-xs text-yellow-700 space-y-1">
                  <li>• Make sure you clicked the exact link from your email</li>
                  <li>• Password reset links expire after a certain time</li>
                  <li>• If the link was forwarded, it may not work properly</li>
                  <li>• Try requesting a new password reset link</li>
                </ul>
              </div>
            </div>
          )}

          {/* Password Reset Form */}
          {resetState === 'ready' && (
            <div>
              {/* Status Message */}
              {message && (
                <div className={`mb-6 p-4 rounded-md text-sm ${
                  message?.includes('verified') 
                    ? 'bg-green-50 text-green-700 border border-green-200' : message?.includes('error') || message?.includes('failed')
                    ? 'bg-red-50 text-red-700 border border-red-200' :'bg-blue-50 text-blue-700 border border-blue-200'
                }`}>
                  {message}
                </div>
              )}

              <form onSubmit={handlePasswordUpdate} className="space-y-6">
                {/* New Password Field */}
                <div>
                  <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                    New Password
                  </label>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPassword ? "text" : "password"}
                      required
                      value={passwordData?.password}
                      onChange={(e) => handleInputChange('password', e?.target?.value)}
                      className="pr-10"
                      placeholder="Enter your new password"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    >
                      {showPassword ? 
                        <EyeOff className="h-4 w-4 text-gray-400" /> : 
                        <Eye className="h-4 w-4 text-gray-400" />
                      }
                    </button>
                  </div>
                </div>

                {/* Password Strength Indicator */}
                {passwordData?.password && (
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <span className="text-xs font-medium text-gray-700">Password Strength:</span>
                      <div className="flex-1 bg-gray-200 rounded-full h-1.5">
                        <div 
                          className={`h-1.5 rounded-full transition-all duration-300 ${
                            passwordStrength?.score <= 2 ? 'bg-red-500' :
                            passwordStrength?.score <= 3 ? 'bg-yellow-500': 'bg-green-500'
                          }`}
                          style={{ width: `${(passwordStrength?.score / 5) * 100}%` }}
                        />
                      </div>
                      <span className={`text-xs font-medium ${
                        passwordStrength?.score <= 2 ? 'text-red-600' :
                        passwordStrength?.score <= 3 ? 'text-yellow-600': 'text-green-600'
                      }`}>
                        {passwordStrength?.score <= 2 ? 'Weak' :
                         passwordStrength?.score <= 3 ? 'Good' : 'Strong'}
                      </span>
                    </div>

                    {/* Password Requirements */}
                    <div className="grid grid-cols-1 gap-1 text-xs">
                      {[
                        { key: 'length', label: 'At least 8 characters' },
                        { key: 'uppercase', label: 'One uppercase letter' },
                        { key: 'lowercase', label: 'One lowercase letter' },
                        { key: 'number', label: 'One number' },
                        { key: 'special', label: 'One special character' }
                      ]?.map(requirement => (
                        <div key={requirement?.key} className={`flex items-center space-x-2 ${
                          passwordStrength?.requirements?.[requirement?.key] ? 'text-green-600' : 'text-gray-500'
                        }`}>
                          <CheckCircle className={`h-3 w-3 ${
                            passwordStrength?.requirements?.[requirement?.key] ? 'text-green-500' : 'text-gray-300'
                          }`} />
                          <span>{requirement?.label}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Confirm Password Field */}
                <div>
                  <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-1">
                    Confirm New Password
                  </label>
                  <div className="relative">
                    <Input
                      id="confirmPassword"
                      type={showConfirmPassword ? "text" : "password"}
                      required
                      value={passwordData?.confirmPassword}
                      onChange={(e) => handleInputChange('confirmPassword', e?.target?.value)}
                      className="pr-10"
                      placeholder="Confirm your new password"
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    >
                      {showConfirmPassword ? 
                        <EyeOff className="h-4 w-4 text-gray-400" /> : 
                        <Eye className="h-4 w-4 text-gray-400" />
                      }
                    </button>
                  </div>
                  
                  {/* Password Match Indicator */}
                  {passwordData?.confirmPassword && (
                    <div className={`mt-1 text-xs ${
                      passwordData?.password === passwordData?.confirmPassword ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {passwordData?.password === passwordData?.confirmPassword ? 
                        '✓ Passwords match' : '✗ Passwords do not match'}
                    </div>
                  )}
                </div>

                {/* Submit Button */}
                <Button
                  type="submit"
                  disabled={isProcessing || passwordStrength?.score < 4 || passwordData?.password !== passwordData?.confirmPassword}
                  className="w-full"
                  size="lg"
                >
                  {isProcessing ? (
                    <>
                      <Loader className="h-4 w-4 animate-spin mr-2" />
                      Updating Password...
                    </>
                  ) : (
                    <>
                      <Lock className="h-4 w-4 mr-2" />
                      Update Password
                    </>
                  )}
                </Button>
              </form>

              {/* Security Notice */}
              <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-md">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <Lock className="h-5 w-5 text-blue-400" />
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-blue-800">Security Notice</h3>
                    <div className="mt-2 text-sm text-blue-700">
                      <p>After updating your password, you'll be signed out and redirected to the login page. Please sign in with your new password to continue.</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer Links */}
        <div className="mt-6 text-center">
          <div className="text-sm text-gray-600 space-x-4">
            <Link to="/login" className="text-blue-600 hover:text-blue-700 font-medium">
              Back to Login
            </Link>
            <span>•</span>
            <Link to="/sign-up" className="text-blue-600 hover:text-blue-700 font-medium">
              Create Account
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PasswordResetPage;