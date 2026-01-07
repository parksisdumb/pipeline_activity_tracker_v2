import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';

// Import all page components
import Today from './pages/today';
import Accounts from './pages/accounts-list';
import Prospects from './pages/prospects-list';
import Properties from './pages/properties-list';
import Opportunities from './pages/opportunities-list';
import Contacts from './pages/contacts-list';
import WeeklyGoals from './pages/weekly-goals';
import Login from './pages/login';
import SignUp from './pages/sign-up';
import Home from './pages/home';
import ContactDetails from './pages/contact-details';
import AccountDetails from './pages/account-details';
import PropertyDetails from './pages/property-details';
import OpportunityDetails from './pages/opportunity-details';
import TaskManagement from './pages/task-management';
import TaskDetails from './pages/task-details';
import Activities from './pages/activities';
import LogActivity from './pages/log-activity';
import ProspectDetails from './pages/prospect-details';
import Documents from './pages/documents';
import Profile from './pages/profile';
import UserProfile from './pages/user-profile';
import EmailConfirmation from './pages/email-confirmation';
import PasswordResetRequest from './pages/password-reset-request';
import PasswordReset from './pages/password-reset';
import PasswordResetConfirmation from './pages/password-reset-confirmation';
import ProfileCreation from './pages/profile-creation';
import PasswordSetup from './pages/password-setup';
import TemporaryPasswordSetup from './pages/temporary-password-setup';
import MagicLinkAuthentication from './pages/magic-link-authentication';
import AuthenticationRouter from './pages/authentication-router';
import AdminDashboard from './pages/admin-dashboard';
import ManagerDashboard from './pages/manager-dashboard';
import SuperAdminDashboard from './pages/super-admin-dashboard';
import SuperAdminUserManagement from './pages/super-admin-user-management';
import NotFound from './pages/NotFound';
import { useAuth } from './contexts/AuthContext';
import {
  FEATURE_PROSPECTS,
  FEATURE_TEAM_DASHBOARD,
  FEATURE_WEEKLY_GOALS
} from './config/features';

// Enhanced Protected component with robust error handling and session fallback
function Protected({ children, allowRoles }) {
  const { loading, ctx, session, authError, isAuthenticated } = useAuth();

  // Show loading spinner during authentication
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center space-y-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="text-gray-600 text-sm">Loading application...</p>
        </div>
      </div>
    );
  }

  // Enhanced session-based fallback: Allow authenticated users even if RPC context is missing/failing
  if (session && (!ctx || ctx?.message?.includes('fallback mode'))) {
    console.log('🔄 Protected: Session exists, using fallback access mode');
    return children;
  }

  // Show auth error but still allow session-based access for authenticated users
  if (authError && session) {
    console.warn('⚠️ Protected: Auth error with valid session, allowing fallback access:', authError);
    return children;
  }

  // If we have context but it indicates failure, and no session, redirect to login
  if (!session && ctx?.success === false) {
    const target = ctx?.redirect_url || '/login';
    console.log('🔒 Protected: No session and context failure, redirecting to:', target);
    return <Navigate to={target} replace />;
  }

  // If no session at all, redirect to login
  if (!session) {
    console.log('🔒 Protected: No session, redirecting to login');
    return <Navigate to="/login" replace />;
  }

  // Handle context-based redirects (only if different from current path)
  if (ctx?.redirect_url && ctx?.redirect_url !== '/today' && 
      ctx?.redirect_url !== window?.location?.pathname &&
      !ctx?.message?.includes('fallback mode')) {
    console.log('🎯 Protected: Context-based redirect to:', ctx?.redirect_url);
    return <Navigate to={ctx?.redirect_url} replace />;
  }

  // Role-based access control (with fallback to session data)
  if (allowRoles) {
    const userRole = ctx?.user_data?.role || session?.user?.user_metadata?.role;
    if (userRole && !allowRoles?.includes(userRole)) {
      console.log('🚫 Protected: Insufficient role, redirecting to /today');
      return <Navigate to="/today" replace />;
    }
  }

  // All checks passed - render protected content
  console.log('✅ Protected: Access granted');
  return children;
}

// Main routing component with single BrowserRouter instance
export default function AppRoutes() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Public/Authentication routes - No protection needed */}
          <Route path="/login" element={<Login />} />
          <Route path="/sign-up" element={<SignUp />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/register" element={<SignUp />} />
          
          {/* Authentication callback routes */}
          <Route path="/auth-callback" element={<AuthenticationRouter />} />
          <Route path="/auth/callback" element={<AuthenticationRouter />} />
          <Route path="/confirm" element={<AuthenticationRouter />} />
          <Route path="/email-confirmation" element={<EmailConfirmation />} />
          
          {/* Password management routes */}
          <Route path="/password-reset-request" element={<PasswordResetRequest />} />
          <Route path="/password-reset" element={<PasswordReset />} />
          <Route path="/password-reset-confirmation" element={<PasswordResetConfirmation />} />
          <Route path="/password-setup" element={<PasswordSetup />} />
          <Route path="/temporary-password-setup" element={<TemporaryPasswordSetup />} />
          
          {/* Profile setup routes */}
          <Route path="/profile-creation" element={<ProfileCreation />} />
          <Route path="/magic-link-authentication" element={<MagicLinkAuthentication />} />

          {/* Protected routes - Main application */}
          <Route path="/" element={<Navigate to="/today" replace />} />
          <Route path="/home" element={<Protected><Home /></Protected>} />
          <Route path="/today" element={<Protected><Today /></Protected>} />
          
          {/* Core CRM functionality - All roles can access */}
          <Route path="/accounts" element={<Protected><Accounts /></Protected>} />
          <Route path="/accounts/:id" element={<Protected><AccountDetails /></Protected>} />
          <Route
            path="/prospects"
            element={FEATURE_PROSPECTS ? <Protected><Prospects /></Protected> : <Navigate to="/today" replace />}
          />
          <Route
            path="/prospects/:id"
            element={FEATURE_PROSPECTS ? <Protected><ProspectDetails /></Protected> : <Navigate to="/today" replace />}
          />
          <Route path="/properties" element={<Protected><Properties /></Protected>} />
          <Route path="/properties/:id" element={<Protected><PropertyDetails /></Protected>} />
          <Route path="/opportunities" element={<Protected><Opportunities /></Protected>} />
          <Route path="/opportunities/:id" element={<Protected><OpportunityDetails /></Protected>} />
          <Route path="/contacts" element={<Protected><Contacts /></Protected>} />
          <Route path="/contacts/:id" element={<Protected><ContactDetails /></Protected>} />
          
          {/* Task and activity management */}
          <Route path="/tasks" element={<Protected><TaskManagement /></Protected>} />
          <Route path="/tasks/:id" element={<Protected><TaskDetails /></Protected>} />
          <Route path="/activities" element={<Protected><Activities /></Protected>} />
          <Route path="/log-activity" element={<Protected><LogActivity /></Protected>} />
          
          {/* Goal management - Role restricted */}
          <Route
            path="/weekly-goals"
            element={
              FEATURE_WEEKLY_GOALS ? (
                <Protected allowRoles={['admin','manager','rep']}>
                  <WeeklyGoals />
                </Protected>
              ) : (
                <Navigate to="/today" replace />
              )
            }
          />
          <Route
            path="/goals"
            element={
              FEATURE_WEEKLY_GOALS ? (
                <Protected allowRoles={['admin','manager','rep']}>
                  <WeeklyGoals />
                </Protected>
              ) : (
                <Navigate to="/today" replace />
              )
            }
          />
          
          {/* Document and profile management */}
          <Route path="/documents" element={<Protected><Documents /></Protected>} />
          <Route path="/profile" element={<Protected><Profile /></Protected>} />
          <Route path="/user-profile" element={<Protected><UserProfile /></Protected>} />
          
          {/* Administrative dashboards - Role restricted */}
          <Route path="/admin-dashboard" element={
            <Protected allowRoles={['admin']}>
              <AdminDashboard />
            </Protected>
          } />
          <Route
            path="/manager-dashboard"
            element={
              FEATURE_TEAM_DASHBOARD ? (
                <Protected allowRoles={['manager']}>
                  <ManagerDashboard />
                </Protected>
              ) : (
                <Navigate to="/today" replace />
              )
            }
          />
          <Route path="/super-admin-dashboard" element={
            <Protected allowRoles={['super_admin']}>
              <SuperAdminDashboard />
            </Protected>
          } />
          <Route path="/super-admin-user-management" element={
            <Protected allowRoles={['super_admin']}>
              <SuperAdminUserManagement />
            </Protected>
          } />
          
          {/* 404 and catch-all routes */}
          <Route path="/404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/today" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
