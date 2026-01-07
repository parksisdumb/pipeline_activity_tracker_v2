import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import QuickActionButton from '../../components/ui/QuickActionButton';
import NextBestActions from './components/NextBestActions';
import QuickLogButton from './components/QuickLogButton';
import ScoreboardMini from './components/ScoreboardMini';
import ReviewMode from './components/ReviewMode';
import GrowMode from './components/GrowMode';
import TenantCalendar from './components/TenantCalendar';
import LogActivityModal from './components/LogActivityModal';
import { useAuth } from '../../contexts/AuthContext';

const TodayPage = () => {
  const navigate = useNavigate();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [showLogActivityModal, setShowLogActivityModal] = useState(false);
  const [prefillQueueItem, setPrefillQueueItem] = useState(null);
  const [logMode, setLogMode] = useState('default');
  const [startTask, setStartTask] = useState(null);
  const [prefillActivityType, setPrefillActivityType] = useState(null);
  const [prefillMotion, setPrefillMotion] = useState(null);
  const [prefillDirection, setPrefillDirection] = useState(null);
  const [createdFromGrow, setCreatedFromGrow] = useState(false);
  const [viewMode, setViewMode] = useState('execute');
  const [completedTaskId, setCompletedTaskId] = useState(null);
  const [queueRefreshToken, setQueueRefreshToken] = useState(0);
  const { ctx, userProfile, loading } = useAuth();

  // Keep role reactive (updates after user data loads)
  const [userRole, setUserRole] = useState('rep');

  useEffect(() => {
    if (userProfile?.role) {
      setUserRole(userProfile.role);
    }
  }, [userProfile]);

  // dY`? Add the standalone debug snippet right here
  useEffect(() => {
    console.log('dY- TodayPage userProfile:', userProfile);
    console.log('dYZ- TodayPage userRole:', userRole);
  }, [userProfile, userRole]);

  useEffect(() => {
    // Set page title
    document.title = 'Today - Pipeline Activity Tracker';
  }, []);

  const handleToggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  const handleToggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };

  const handleOpenLogActivity = () => {
    setPrefillQueueItem(null);
    setLogMode('default');
    setStartTask(null);
    setPrefillActivityType(null);
    setPrefillMotion(null);
    setPrefillDirection(null);
    setCreatedFromGrow(false);
    setShowLogActivityModal(true);
  };

  const handleStartQueueItem = (queueItem) => {
    setPrefillQueueItem(queueItem || null);
    setLogMode('start');
    setStartTask(queueItem?.task || null);
    const taskType = queueItem?.taskType;
    const defaultActivityType = taskType === 'follow_up'
      ? 'Phone Call'
      : taskType === 'admin' || taskType === 'system'
        ? 'Follow-up'
        : 'Phone Call';
    setPrefillActivityType(defaultActivityType);
    setPrefillMotion(null);
    if (queueItem?.sourceType === 'task') {
      const direction = taskType === 'follow_up'
        ? 'outbound'
        : taskType === 'admin' || taskType === 'system'
          ? 'internal'
          : null;
      setPrefillDirection(direction);
    } else {
      setPrefillDirection(null);
    }
    setCreatedFromGrow(false);
    setShowLogActivityModal(true);
  };

  const handleStartGrowTouch = () => {
    setPrefillQueueItem(null);
    setLogMode('default');
    setStartTask(null);
    setPrefillActivityType('Phone Call');
    setPrefillMotion('prospecting');
    setPrefillDirection('outbound');
    setCreatedFromGrow(true);
    setShowLogActivityModal(true);
  };

  const handleCloseLogActivity = () => {
    setShowLogActivityModal(false);
    setPrefillQueueItem(null);
    setLogMode('default');
    setStartTask(null);
    setPrefillActivityType(null);
    setPrefillMotion(null);
    setPrefillDirection(null);
    setCreatedFromGrow(false);
  };

  const handleTaskCompleted = (completedTask) => {
    if (!completedTask?.id) return;
    setCompletedTaskId(completedTask.id);
    setQueueRefreshToken(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Mobile Header */}
      <div className="lg:hidden">
        <Header 
          userRole={userRole}
          onMenuToggle={handleToggleMobileMenu}
          isMenuOpen={mobileMenuOpen}
        />
      </div>

      {/* Desktop Sidebar */}
      <div className="hidden lg:block">
        <SidebarNavigation
          userRole={userRole}
          isCollapsed={sidebarCollapsed}
          onToggleCollapse={handleToggleSidebar}
        />
      </div>

      {/* Mobile Sidebar Overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={handleToggleMobileMenu} />
          <SidebarNavigation
            userRole={userRole}
            isCollapsed={false}
            onToggleCollapse={handleToggleMobileMenu}
            className="relative z-10"
          />
        </div>
      )}

      {/* Main Content */}
      <main 
        className={`transition-all duration-200 ease-out pt-16 lg:pt-0 ${
          sidebarCollapsed ? 'lg:ml-16' : 'lg:ml-60'
        }`}
      >
        <div className="p-6 max-w-7xl mx-auto space-y-6">
          {/* Welcome Section */}
          <div className="mb-8">
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold text-foreground mb-2">
                  {userProfile?.full_name ? (
                    <>Good morning, {userProfile.full_name}!</>
                  ) : (
                  <>Good morning!</>
                  )}
                </h1>
                <p className="text-muted-foreground">
                  {userRole === 'admin' ? 'Manage users, accounts, and system settings from your admin dashboard.' : 'Ready to make today productive? Start by logging your field activities.'}
                </p>
              </div>
              {userRole !== 'admin' && (
                <div className="inline-flex rounded-full border border-border bg-muted/30 p-1">
                  <button
                    type="button"
                    onClick={() => setViewMode('execute')}
                    className={`px-4 py-1.5 text-sm font-medium rounded-full transition-colors ${
                      viewMode === 'execute'
                        ? 'bg-card text-foreground shadow-sm'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                  >
                    Execute
                  </button>
                  <button
                    type="button"
                    onClick={() => setViewMode('grow')}
                    className={`px-4 py-1.5 text-sm font-medium rounded-full transition-colors ${
                      viewMode === 'grow'
                        ? 'bg-card text-foreground shadow-sm'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                  >
                    Grow
                  </button>
                  <button
                    type="button"
                    onClick={() => setViewMode('review')}
                    className={`px-4 py-1.5 text-sm font-medium rounded-full transition-colors ${
                      viewMode === 'review'
                        ? 'bg-card text-foreground shadow-sm'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                  >
                    Review
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Admin-specific content */}
          {userRole === 'admin' ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <div className="bg-card rounded-lg border border-border p-6">
                <h3 className="text-lg font-semibold text-foreground mb-2">Admin Actions</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Quick access to administrative functions
                </p>
                <div className="space-y-2">
                  <button 
                    onClick={() => navigate('/admin-dashboard')}
                    className="w-full bg-primary text-primary-foreground py-2 px-4 rounded-md hover:bg-primary/90 transition-colors"
                  >
                    Go to Admin Dashboard
                  </button>
                </div>
              </div>
              
              <div className="bg-card rounded-lg border border-border p-6">
                <h3 className="text-lg font-semibold text-foreground mb-2">User Management</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Add and manage system users
                </p>
                <div className="space-y-2">
                  <button 
                    onClick={() => navigate('/admin-dashboard?tab=users')}
                    className="w-full bg-secondary text-secondary-foreground py-2 px-4 rounded-md hover:bg-secondary/80 transition-colors"
                  >
                    Manage Users
                  </button>
                </div>
              </div>
              
              <div className="bg-card rounded-lg border border-border p-6">
                <h3 className="text-lg font-semibold text-foreground mb-2">System Overview</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  View accounts, properties, and contacts
                </p>
                <div className="space-y-2">
                  <button 
                    onClick={() => navigate('/accounts')}
                    className="w-full bg-muted text-muted-foreground py-2 px-4 rounded-md hover:bg-muted/80 transition-colors"
                  >
                    View All Data
                  </button>
                </div>
              </div>

              {/* Tenant Calendar for Admin */}
              <div className="md:col-span-2 lg:col-span-3">
                <TenantCalendar />
              </div>
            </div>
          ) : (
            <>
              {viewMode === 'execute' ? (
                <>
                  {/* Scoreboard Mini */}
                  <ScoreboardMini />

                  {/* Quick Log */}
                  <QuickLogButton onLogActivity={handleOpenLogActivity} />

                  {/* Next Best Actions */}
                  <NextBestActions
                    onStartQueueItem={handleStartQueueItem}
                    completedTaskId={completedTaskId}
                    refreshToken={queueRefreshToken}
                  />
                </>
              ) : viewMode === 'grow' ? (
                <GrowMode onLogTouch={handleStartGrowTouch} />
              ) : (
                <ReviewMode />
              )}
            </>
          )}

          {/* Additional Context for Mobile Users */}
          <div className="lg:hidden bg-card rounded-lg border border-border p-6">
            <div className="text-center">
              <h3 className="text-lg font-semibold text-foreground mb-2">
                {userRole === 'admin' ? 'Admin Interface' : 'Field-Optimized Design'}
              </h3>
              <p className="text-sm text-muted-foreground mb-4">
                {userRole === 'admin' ? 'Access all administrative functions through the sidebar navigation.' : 'This interface is designed for quick data entry while you\'re on the go. Large buttons and streamlined workflows help you log activities in under 10 seconds.'}
              </p>
              {userRole !== 'admin' && (
                <div className="flex items-center justify-center space-x-4 text-xs text-muted-foreground">
                  <div className="flex items-center space-x-1">
                    <div className="w-2 h-2 bg-success rounded-full"></div>
                    <span>Touch-friendly</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <div className="w-2 h-2 bg-success rounded-full"></div>
                    <span>Fast entry</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <div className="w-2 h-2 bg-success rounded-full"></div>
                    <span>Offline capable</span>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>

      {/* Floating Action Button for Mobile (not for admin) */}
      {userRole !== 'admin' && (
        <QuickActionButton variant="floating" onClick={handleOpenLogActivity} />
      )}

      {/* Log Activity Modal */}
      <LogActivityModal
        isOpen={showLogActivityModal}
        onClose={handleCloseLogActivity}
        onLogged={handleCloseLogActivity}
        onTaskCompleted={handleTaskCompleted}
        prefillQueueItem={prefillQueueItem}
        mode={logMode}
        task={startTask}
        prefillEntity={prefillQueueItem?.entity || null}
        prefillType={prefillActivityType}
        prefillActivityType={prefillActivityType}
        prefillMotion={prefillMotion}
        prefillDirection={prefillDirection}
        createdFromGrow={createdFromGrow}
      />
    </div>
  );
};

export default TodayPage;
