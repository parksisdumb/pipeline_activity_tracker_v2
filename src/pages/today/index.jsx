import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import QuickActionButton from '../../components/ui/QuickActionButton';
import ActivityLogButton from './components/ActivityLogButton';
import WeeklyGoalsProgress from './components/WeeklyGoalsProgress';
import RecentActivities from './components/RecentActivities';
import QuickActions from './components/QuickActions';
import TodayStats from './components/TodayStats';
import YourTasks from './components/YourTasks';
import CreateTaskModal from '../create-task-modal';
import AddAccountModal from '../../components/ui/AddAccountModal';
import AddContactModal from '../../components/ui/AddContactModal';
import AddPropertyModal from '../../components/ui/AddPropertyModal';
import LogActivityModal from './components/LogActivityModal';
import { useAuth } from '../../contexts/AuthContext';
import Button from '../../components/ui/Button';

const TodayPage = () => {
  const navigate = useNavigate();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [showCreateTaskModal, setShowCreateTaskModal] = useState(false);
  const [showAddAccountModal, setShowAddAccountModal] = useState(false);
  const [showAddContactModal, setShowAddContactModal] = useState(false);
  const [showAddPropertyModal, setShowAddPropertyModal] = useState(false);
  const [showLogActivityModal, setShowLogActivityModal] = useState(false);
  const { ctx, userProfile, loading } = useAuth();

  // Keep role reactive (updates after user data loads)
  const [userRole, setUserRole] = useState('rep');

  useEffect(() => {
    if (userProfile?.role) {
      setUserRole(userProfile.role);
    }
  }, [userProfile]);

  // 👇 Add the standalone debug snippet right here
  useEffect(() => {
    console.log('🧭 TodayPage userProfile:', userProfile);
    console.log('🎭 TodayPage userRole:', userRole);
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

  const handleOpenCreateTaskModal = () => {
    setShowCreateTaskModal(true);
  };

  const handleCloseCreateTaskModal = () => {
    setShowCreateTaskModal(false);
  };

  const handleTaskCreated = (newTask) => {
    // Task created successfully, modal will close automatically
    console.log('New task created:', newTask);
    // You can add any additional logic here, like refreshing task lists
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
            <h1 className="text-2xl lg:text-3xl font-bold text-foreground mb-2">
              {userProfile?.full_name ? (
                <>Good morning, {userProfile.full_name}! 👋</>
              ) : (
              <>Good morning! 👋</>
              )}
            </h1>
            <p className="text-muted-foreground">
              {userRole === 'admin' ? 'Manage users, accounts, and system settings from your admin dashboard.' : 'Ready to make today productive? Start by logging your field activities.'}
            </p>
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
              {/* Today's Overview */}
              <TodayStats />

              {/* Primary Action - Log Activity */}
              <div className="space-y-3">
                <ActivityLogButton onLogActivity={() => setShowLogActivityModal(true)} />
                <Button
                  onClick={() => setShowAddAccountModal(true)}
                  size="lg"
                  className="w-full h-14 text-lg font-semibold"
                  iconName="PlusCircle"
                  iconPosition="left"
                >
                  Add Account
                </Button>
                <Button
                  onClick={() => setShowAddContactModal(true)}
                  size="lg"
                  variant="outline"
                  className="w-full h-14 text-lg font-semibold"
                  iconName="UserPlus"
                  iconPosition="left"
                >
                  Add Contact
                </Button>
                <Button
                  onClick={() => setShowAddPropertyModal(true)}
                  size="lg"
                  variant="secondary"
                  className="w-full h-14 text-lg font-semibold"
                  iconName="Building2"
                  iconPosition="left"
                >
                  Add Property
                </Button>
              </div>

              {/* Main Content Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Left Column - Primary Content */}
                <div className="lg:col-span-2 space-y-6">
                  {/* Your Tasks Section */}
                  <YourTasks onCreateTask={handleOpenCreateTaskModal} />

                  {/* Recent Activities */}
                  <RecentActivities />
                </div>

                {/* Right Column - Secondary Content */}
                <div className="space-y-6">
                  {/* Weekly Goals Progress */}
                  <WeeklyGoalsProgress />

                  {/* Quick Actions */}
                  <QuickActions />
                </div>
              </div>
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
        <QuickActionButton variant="floating" onClick={() => setShowLogActivityModal(true)} />
      )}

      {/* Create Task Modal */}
      <CreateTaskModal
        isOpen={showCreateTaskModal}
        onClose={handleCloseCreateTaskModal}
        onTaskCreated={handleTaskCreated}
      />

      {/* Add Account Modal */}
      <AddAccountModal
        isOpen={showAddAccountModal}
        onClose={() => setShowAddAccountModal(false)}
        onAccountAdded={() => setShowAddAccountModal(false)}
      />

      {/* Add Contact Modal */}
      <AddContactModal
        isOpen={showAddContactModal}
        onClose={() => setShowAddContactModal(false)}
        onContactAdded={() => setShowAddContactModal(false)}
      />

      {/* Add Property Modal */}
      <AddPropertyModal
        isOpen={showAddPropertyModal}
        onClose={() => setShowAddPropertyModal(false)}
        onPropertyAdded={() => setShowAddPropertyModal(false)}
      />

      {/* Log Activity Modal */}
      <LogActivityModal
        isOpen={showLogActivityModal}
        onClose={() => setShowLogActivityModal(false)}
        onLogged={() => setShowLogActivityModal(false)}
      />
    </div>
  );
};

export default TodayPage;
