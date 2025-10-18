import React, { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import Button from '../components/ui/Button';

const NotFound = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleGoHome = () => {
    try {
      navigate('/today', { replace: true });
    } catch (error) {
      console.error('Navigation error:', error);
      window.location.href = '/today';
    }
  };

  const handleGoBack = () => {
    try {
      if (window.history?.length > 1) {
        navigate(-1);
      } else {
        navigate('/today', { replace: true });
      }
    } catch (error) {
      console.error('Navigation error:', error);
      window.location.href = '/today';
    }
  };

  // Log 404 for debugging in development
  React.useEffect(() => {
    if (process.env?.NODE_ENV === 'development') {
      console.warn(`404 Error - Page not found: ${location?.pathname}`);
    }
  }, [location?.pathname]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 p-4">
      <div className="text-center max-w-md">
        <div className="flex justify-center mb-6">
          <div className="relative">
            <h1 className="text-9xl font-bold text-blue-600 opacity-20">404</h1>
          </div>
        </div>

        <h2 className="text-2xl font-medium text-gray-900 mb-2">Page Not Found</h2>
        <p className="text-gray-600 mb-2">
          The page you're looking for doesn't exist.
        </p>
        
        {/* Show the requested path in development */}
        {process.env?.NODE_ENV === 'development' && (
          <p className="text-sm text-gray-500 mb-6 font-mono bg-gray-100 p-2 rounded">
            Requested: {location?.pathname}
          </p>
        )}
        
        {process.env?.NODE_ENV !== 'development' && (
          <p className="text-gray-600 mb-8">
            Let's get you back on track!
          </p>
        )}

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button
            variant="outline"
            onClick={handleGoBack}
            className="flex items-center justify-center"
          >
            <svg 
              className="w-4 h-4 mr-2" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M15 19l-7-7 7-7" 
              />
            </svg>
            Go Back
          </Button>

          <Button
            onClick={handleGoHome}
            className="flex items-center justify-center"
          >
            <svg 
              className="w-4 h-4 mr-2" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" 
              />
            </svg>
            Back to Dashboard
          </Button>
        </div>

        {/* Quick navigation suggestions */}
        <div className="mt-8 pt-6 border-t border-gray-200">
          <p className="text-sm text-gray-500 mb-4">Quick links:</p>
          <div className="flex flex-wrap gap-2 justify-center">
            {[
              { path: '/today', label: 'Dashboard' },
              { path: '/contacts', label: 'Contacts' },
              { path: '/accounts', label: 'Accounts' },
              { path: '/opportunities', label: 'Opportunities' },
              { path: '/tasks', label: 'Tasks' }
            ]?.map(({ path, label }) => (
              <button
                key={path}
                onClick={() => {
                  try {
                    navigate(path);
                  } catch (error) {
                    window.location.href = path;
                  }
                }}
                className="text-sm text-blue-600 hover:text-blue-800 underline"
              >
                {label}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotFound;