import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Mail, AlertTriangle, CheckCircle, Loader } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

const PasswordResetRequest = () => {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success', 'error', 'info'
  const [userStatus, setUserStatus] = useState(null);
  const { sendPasswordReset, adminForcePasswordReset, isAuthenticated, isSuperAdmin, supabase } = useAuth();

  // Enhanced email validation
  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex?.test(email);
  };

  // Check user account status before sending reset
  const checkUserStatus = async (userEmail) => {
    try {
      const { data, error } = await supabase?.rpc('get_user_auth_status', {
        user_email: userEmail
      });

      if (error) {
        console.warn('Could not check user status:', error);
        return null;
      }

      return data?.[0] || null;
    } catch (error) {
      console.warn('Error checking user status:', error);
      return null;
    }
  };

  // Handle password reset request
  const handlePasswordReset = async (e) => {
    e?.preventDefault();
    
    if (!validateEmail(email)) {
      setMessage('Please enter a valid email address.');
      setMessageType('error');
      return;
    }

    setIsLoading(true);
    setMessage('');
    setUserStatus(null);

    try {
      // First check user account status
      const status = await checkUserStatus(email);
      
      if (status) {
        setUserStatus(status);
        
        // Handle different account statuses
        if (!status?.user_exists) {
          setMessage(`No account found with email address: ${email}. Please check the email address or create a new account.`);
          setMessageType('error');
          setIsLoading(false);
          return;
        }
        
        if (!status?.email_confirmed) {
          setMessage('This email address has not been verified yet. Please check your email for the verification link, or contact support for assistance.');
          setMessageType('error');
          setIsLoading(false);
          return;
        }
        
        if (!status?.can_reset_password) {
          setMessage(status?.message || 'Password reset is not available for this account. Please contact support for assistance.');
          setMessageType('error');
          setIsLoading(false);
          return;
        }
      }

      // Send password reset email
      const result = await sendPasswordReset(email);
      
      if (result?.success) {
        setMessage(`Password reset email sent to ${email}. Please check your inbox (and spam folder) for instructions to reset your password.`);
        setMessageType('success');
        setEmail(''); // Clear email field on success
      } else {
        // Handle specific error messages
        let errorMessage = result?.error || 'Failed to send password reset email.';
        
        if (errorMessage?.includes('rate limit')) {
          errorMessage = 'Too many reset requests. Please wait a few minutes before trying again.';
        } else if (errorMessage?.includes('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (errorMessage?.includes('network') || errorMessage?.includes('fetch')) {
          errorMessage = 'Connection error. Please check your internet connection and try again.';
        }
        
        setMessage(errorMessage);
        setMessageType('error');
      }
    } catch (error) {
      console.error('Password reset error:', error);
      setMessage('An unexpected error occurred. Please try again or contact support if the problem persists.');
      setMessageType('error');
    } finally {
      setIsLoading(false);
    }
  };

  // Handle admin force password reset (for super admins)
  const handleAdminForceReset = async () => {
    if (!isSuperAdmin || !validateEmail(email)) {
      return;
    }

    setIsLoading(true);
    setMessage('');

    try {
      const result = await adminForcePasswordReset(email);
      
      if (result?.success) {
        setMessage(`Administrative password reset initiated for ${email}. The user will need to complete password setup on their next login.`);
        setMessageType('success');
      } else {
        setMessage(result?.error?.message || 'Failed to initiate administrative password reset.');
        setMessageType('error');
      }
    } catch (error) {
      console.error('Admin password reset error:', error);
      setMessage('Administrative reset failed. Please try again.');
      setMessageType('error');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        {/* Back to Login Link */}
        <Link 
          to="/login" 
          className="flex items-center text-blue-600 hover:text-blue-700 mb-6 transition-colors"
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to Login
        </Link>

        {/* Header */}
        <div className="text-center">
          <h2 className="text-3xl font-bold text-gray-900">Reset Your Password</h2>
          <p className="mt-2 text-sm text-gray-600">
            Enter your email address and we'll send you instructions to reset your password.
          </p>
        </div>
      </div>
      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          {/* Password Reset Form */}
          <form onSubmit={handlePasswordReset} className="space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                Email Address
              </label>
              <div className="mt-1 relative">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e?.target?.value)}
                  className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  placeholder="Enter your email address"
                  disabled={isLoading}
                />
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <Mail className="h-4 w-4 text-gray-400" />
                </div>
              </div>
            </div>

            {/* User Status Display */}
            {userStatus && (
              <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
                <h4 className="text-sm font-medium text-blue-800 mb-2">Account Status</h4>
                <div className="text-xs text-blue-700 space-y-1">
                  <div>Status: <span className="font-medium">{userStatus?.account_status}</span></div>
                  <div>Email Verified: <span className="font-medium">{userStatus?.email_confirmed ? 'Yes' : 'No'}</span></div>
                  <div>Password Set: <span className="font-medium">{userStatus?.password_set ? 'Yes' : 'No'}</span></div>
                  {userStatus?.last_sign_in && (
                    <div>Last Login: <span className="font-medium">{new Date(userStatus.last_sign_in)?.toLocaleDateString()}</span></div>
                  )}
                </div>
              </div>
            )}

            {/* Message Display */}
            {message && (
              <div className={`rounded-md p-4 ${
                messageType === 'success' ? 'bg-green-50 border border-green-200' 
                  : messageType === 'error' ? 'bg-red-50 border border-red-200' : 'bg-blue-50 border border-blue-200'
              }`}>
                <div className="flex">
                  <div className="flex-shrink-0">
                    {messageType === 'success' ? (
                      <CheckCircle className="h-5 w-5 text-green-400" />
                    ) : messageType === 'error' ? (
                      <AlertTriangle className="h-5 w-5 text-red-400" />
                    ) : (
                      <Mail className="h-5 w-5 text-blue-400" />
                    )}
                  </div>
                  <div className="ml-3">
                    <p className={`text-sm ${
                      messageType === 'success' ? 'text-green-700' 
                        : messageType === 'error' ? 'text-red-700' : 'text-blue-700'
                    }`}>
                      {message}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Submit Button */}
            <div>
              <button
                type="submit"
                disabled={isLoading || !email}
                className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {isLoading ? (
                  <>
                    <Loader className="h-4 w-4 mr-2 animate-spin" />
                    Sending Reset Email...
                  </>
                ) : (
                  <>
                    <Mail className="h-4 w-4 mr-2" />
                    Send Reset Email
                  </>
                )}
              </button>
            </div>

            {/* Admin Force Reset Button */}
            {isSuperAdmin && email && validateEmail(email) && (
              <div className="border-t pt-4">
                <button
                  type="button"
                  onClick={handleAdminForceReset}
                  disabled={isLoading}
                  className="w-full flex justify-center py-2 px-4 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-red-50 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {isLoading ? (
                    <>
                      <Loader className="h-4 w-4 mr-2 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      <AlertTriangle className="h-4 w-4 mr-2" />
                      Admin: Force Password Reset
                    </>
                  )}
                </button>
                <p className="mt-2 text-xs text-gray-500 text-center">
                  Administrative function: Forces user to reset password on next login
                </p>
              </div>
            )}
          </form>

          {/* Additional Help */}
          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">Need help?</span>
              </div>
            </div>

            <div className="mt-4 text-center">
              <div className="space-y-2 text-sm text-gray-600">
                <p>• Check your spam/junk folder for the reset email</p>
                <p>• Make sure you're using the correct email address</p>
                <p>• Reset emails may take a few minutes to arrive</p>
              </div>
              
              <div className="mt-4">
                <Link 
                  to="/login" 
                  className="text-blue-600 hover:text-blue-700 text-sm font-medium"
                >
                  Back to Login
                </Link>
                {' | '}
                <Link 
                  to="/sign-up" 
                  className="text-blue-600 hover:text-blue-700 text-sm font-medium"
                >
                  Create Account
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PasswordResetRequest;