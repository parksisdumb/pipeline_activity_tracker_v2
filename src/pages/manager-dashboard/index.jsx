import React, { useState, useEffect } from 'react';
import { Helmet } from 'react-helmet';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import QuickActionButton from '../../components/ui/QuickActionButton';
import MetricsCard from './components/MetricsCard';
import TeamPerformanceTable from './components/TeamPerformanceTable';
import WeekSelector from './components/WeekSelector';
import FunnelMetrics from './components/FunnelMetrics';
import QuickActions from './components/QuickActions';
import TeamSummaryCards from './components/TeamSummaryCards';
import { managerService } from '../../services/managerService';
import { propertiesService } from '../../services/propertiesService';
import { accountsService } from '../../services/accountsService';
import { useAuth } from '../../contexts/AuthContext';
import { Users, Calendar, UserPlus, Eye } from 'lucide-react';
import { AssignRepsModal } from './components/AssignRepsModal';
import Button from '../../components/ui/Button';


const ManagerDashboard = () => {
  const { session, userProfile, ctx, loading: authLoading } = useAuth();
  const [currentWeek, setCurrentWeek] = useState(new Date());
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  
  // Data states
  const [teamMetrics, setTeamMetrics] = useState([]);
  const [teamData, setTeamData] = useState([]);
  const [funnelData, setFunnelData] = useState({});
  const [summaryData, setSummaryData] = useState({});
  const [isDashboardLoading, setIsDashboardLoading] = useState(true);
  const [error, setError] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [accountsCount, setAccountsCount] = useState(0);
  const [propertiesCount, setPropertiesCount] = useState(0);
  const [selectedAccount, setSelectedAccount] = useState(null);
  const [showAssignModal, setShowAssignModal] = useState(false);

  const managerId = userProfile?.id
    || userProfile?.user_id
    || userProfile?.user_uuid
    || userProfile?.uuid
    || ctx?.user_data?.user_id
    || ctx?.user_data?.id
    || session?.user?.id
    || session?.user?.user_metadata?.user_id
    || session?.user?.user_metadata?.user_uuid
    || null;

  // Get week start date for queries
  const getWeekStartDate = (date) => {
    const weekStart = new Date(date);
    weekStart?.setDate(weekStart?.getDate() - weekStart?.getDay());
    return weekStart?.toISOString()?.split('T')?.[0];
  };

  // Load all dashboard data
  const loadDashboardData = async () => {
    if (!managerId) return;
    
    setIsDashboardLoading(true);
    setError(null);
    
    try {
      const weekStartDate = getWeekStartDate(currentWeek);
      
      // Load all manager data in parallel
      const [
        teamPerformanceResult,
        teamMetricsResult,
        funnelMetricsResult,
        teamSummaryResult
      ] = await Promise.all([
        managerService?.getTeamPerformance(managerId, weekStartDate),
        managerService?.getTeamMetrics(managerId, weekStartDate),
        managerService?.getTeamFunnelMetrics(managerId),
        managerService?.getTeamSummary(managerId)
      ]);

      // Handle team performance data
      if (teamPerformanceResult?.success) {
        const teamData = teamPerformanceResult?.data || [];
        setTeamData(teamData);
        
        // Log for debugging
        console.log('Team performance data loaded:', teamData);
        
        if (teamData?.length === 0) {
          console.warn('No team performance data found - check manager hierarchy setup');
        }
      } else {
        console.error('Failed to load team performance:', teamPerformanceResult?.error);
        setError(`Team data error: ${teamPerformanceResult?.error}`);
      }

      // Handle team metrics
      if (teamMetricsResult?.success) {
        const metrics = teamMetricsResult?.data;
        console.log('Team metrics loaded:', metrics);
        
        // Transform metrics into cards format - handle array format from function
        const metricsData = Array.isArray(metrics) ? metrics?.[0] : metrics;
        
        const metricsCards = [
          {
            title: 'Pop-ins',
            current: metricsData?.calls_actual || 0,
            target: metricsData?.calls_target || 0,
            icon: 'MapPin',
            color: 'accent',
            trend: Math.random() * 20 - 10 // TODO: Calculate real trend
          },
          {
            title: 'DM Conversations',
            current: metricsData?.emails_actual || 0,
            target: metricsData?.emails_target || 0,
            icon: 'MessageCircle',
            color: 'success',
            trend: Math.random() * 20 - 10
          },
          {
            title: 'Assessments Booked',
            current: metricsData?.meetings_actual || 0,
            target: metricsData?.meetings_target || 0,
            icon: 'Calendar',
            color: 'warning',
            trend: Math.random() * 20 - 10
          },
          {
            title: 'Proposals Sent',
            current: metricsData?.assessments_actual || 0,
            target: metricsData?.assessments_target || 0,
            icon: 'FileText',
            color: 'accent',
            trend: Math.random() * 20 - 10
          },
          {
            title: 'Accounts Added',
            current: Math.floor(Math.random() * 10), // TODO: Add to function
            target: 15,
            icon: 'Trophy',
            color: 'success',
            trend: Math.random() * 20 - 10
          }
        ];
        
        setTeamMetrics(metricsCards);
      } else {
        console.error('Failed to load team metrics:', teamMetricsResult?.error);
        setError(`Metrics error: ${teamMetricsResult?.error}`);
      }

      // Handle funnel data
      if (funnelMetricsResult?.success) {
        setFunnelData(funnelMetricsResult?.data || {});
        console.log('Funnel data loaded:', funnelMetricsResult?.data);
      } else {
        console.error('Failed to load funnel metrics:', funnelMetricsResult?.error);
      }

      // Handle summary data - ensure proper format for TeamSummaryCards
      if (teamSummaryResult?.success) {
        // Pass the raw data from function - TeamSummaryCards will handle the transformation
        setSummaryData(teamSummaryResult?.data || {});
        console.log('Summary data loaded:', teamSummaryResult?.data);
      } else {
        console.error('Failed to load team summary:', teamSummaryResult?.error);
      }

      // ENHANCED: Load ALL tenant accounts (not just team-assigned accounts)
      try {
        const accountsData = await managerService?.getAllTenantAccounts(managerId);
        let resolvedAccountsCount = accountsData?.length || 0;
        setAccounts(accountsData);
        setAccountsCount(resolvedAccountsCount);
        console.log('Enhanced tenant accounts loaded:', resolvedAccountsCount, 'total accounts');
        // Also load tenant property count for summary cards
        try {
          const propertiesResult = await propertiesService?.getProperties();
          if (propertiesResult?.success) {
            setPropertiesCount(propertiesResult?.data?.length || 0);
            console.log('Tenant properties loaded:', propertiesResult?.data?.length || 0);
          } else {
            console.warn('Failed to load tenant properties:', propertiesResult?.error);
            setPropertiesCount(0);
          }
        } catch (propError) {
          console.error('Error loading tenant properties:', propError);
          setPropertiesCount(0);
        }
      } catch (error) {
        console.error('Error loading tenant accounts:', error);
        // Fallback to legacy method if new method fails
        try {
          const fallbackAccountsData = await managerService?.getAccessibleAccountsWithAssignments(managerId);
          setAccounts(fallbackAccountsData);
          resolvedAccountsCount = fallbackAccountsData?.length || 0;
          setAccountsCount(resolvedAccountsCount);
          console.log('Fallback to legacy account access');
          try {
            const propertiesResult = await propertiesService?.getProperties();
            if (propertiesResult?.success) {
              setPropertiesCount(propertiesResult?.data?.length || 0);
              console.log('Tenant properties loaded (fallback path):', propertiesResult?.data?.length || 0);
            } else {
              console.warn('Failed to load tenant properties (fallback):', propertiesResult?.error);
              setPropertiesCount(0);
            }
          } catch (propError) {
            console.error('Error loading tenant properties (fallback):', propError);
            setPropertiesCount(0);
          }
        } catch (fallbackError) {
          console.error('Both account loading methods failed:', fallbackError);
          setError('Failed to load accessible accounts');
        }
      }

      // Additional fallback: load tenant accounts directly if still zero
      try {
        if (!accounts?.length && !accountsCount) {
          const accountsResult = await accountsService?.getAccounts();
          if (accountsResult?.success) {
            const fallbackAllAccounts = accountsResult?.data || [];
            setAccounts(fallbackAllAccounts);
            setAccountsCount(fallbackAllAccounts?.length || 0);
            console.log('Tenant accounts loaded via direct accountsService fallback:', fallbackAllAccounts?.length || 0);
          } else {
            console.warn('Direct accountsService fallback failed:', accountsResult?.error);
          }
        }
      } catch (directErr) {
        console.error('Error loading tenant accounts via direct fallback:', directErr);
      }

    } catch (error) {
      console.error('Dashboard loading error:', error);
      setError('Failed to load dashboard data. Please check your connection and try again.');
    } finally {
      setIsDashboardLoading(false);
    }
  };

  // Load data when component mounts or week changes
  useEffect(() => {
    if (!managerId) return;
    loadDashboardData();
  }, [managerId, currentWeek]);

  const handleWeekChange = (newWeek) => {
    setCurrentWeek(newWeek);
  };

  const toggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
  };

  // Transform team performance data for table
  const transformedTeamData = teamData?.map(member => ({
    id: member?.user_id,
    name: member?.full_name || member?.email?.split('@')?.[0] || 'Unknown User',
    email: member?.email,
    role: member?.role,
    popIns: { 
      current: member?.calls_actual || 0, 
      target: member?.calls_target || 0 
    },
    dmConversations: { 
      current: member?.emails_actual || 0, 
      target: member?.emails_target || 0 
    },
    assessments: { 
      current: member?.meetings_actual || 0, 
      target: member?.meetings_target || 0 
    },
    proposals: { 
      current: member?.assessments_actual || 0, 
      target: member?.assessments_target || 0 
    },
    wins: { 
      current: member?.total_activities || 0, 
      target: member?.accounts_assigned || 10 
    },
    showRate: member?.calls_progress || 0,
    winRate: member?.performance_score || Math.round(Math.random() * 100),
    totalAccounts: member?.accounts_assigned || 0,
    weeklyActivities: member?.total_activities || 0
  })) || [];

  const loadAccounts = async () => {
    if (!managerId) return;
    try {
      // ENHANCED: Use new tenant-wide account access
      const accountsData = await managerService?.getAllTenantAccounts(managerId);
      setAccounts(accountsData);
    } catch (error) {
      console.error('Error loading accounts:', error);
      // Fallback to legacy method
      try {
        const fallbackAccountsData = await managerService?.getAccessibleAccountsWithAssignments(managerId);
        setAccounts(fallbackAccountsData);
      } catch (fallbackError) {
        console.error('Both account loading methods failed:', fallbackError);
        setError('Failed to load accessible accounts');
      }
    }
  };

  const handleAssignReps = (account) => {
    setSelectedAccount(account);
    setShowAssignModal(true);
  };

  const handleAssignSuccess = () => {
    loadAccounts(); // Refresh accounts data
  };

  if (authLoading && !managerId) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary"></div>
          <p className="mt-4 text-muted-foreground">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  if (!authLoading && !managerId) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center px-6 text-center">
        <div className="space-y-4 max-w-md">
          <h2 className="text-xl font-semibold text-foreground">Manager access required</h2>
          <p className="text-sm text-muted-foreground">
            We could not determine your manager profile. Please sign out and sign back in, or contact your administrator if you believe this is an error.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Helmet>
        <title>Manager Dashboard - Pipeline Activity Tracker</title>
        <meta name="description" content="Comprehensive team oversight with real-time goal tracking and performance analytics for sales managers." />
      </Helmet>
      <div className="min-h-screen bg-background">
        {/* Mobile Header */}
        <div className="lg:hidden">
          <Header 
            userRole="manager"
            onMenuToggle={toggleMobileMenu}
            isMenuOpen={isMobileMenuOpen}
          />
        </div>

        {/* Desktop Sidebar */}
        <div className="hidden lg:block">
          <SidebarNavigation
            userRole="manager"
            isCollapsed={sidebarCollapsed}
            onToggleCollapse={toggleSidebar}
          />
        </div>

        {/* Mobile Sidebar Overlay */}
        {isMobileMenuOpen && (
          <div className="lg:hidden fixed inset-0 z-50">
            <div className="fixed inset-0 bg-background/80 backdrop-blur-sm" onClick={toggleMobileMenu} />
            <SidebarNavigation
              userRole="manager"
              isCollapsed={false}
              onToggleCollapse={() => {}}
              className="relative z-10"
            />
          </div>
        )}

        {/* Main Content */}
        <main className={`transition-all duration-200 ease-out ${
          sidebarCollapsed ? 'lg:ml-16' : 'lg:ml-60'
        } pt-16 lg:pt-0`}>
          <div className="p-6 space-y-6">
            {/* Error Message */}
            {error && (
              <div className="bg-destructive/10 border border-destructive/20 text-destructive px-4 py-3 rounded">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">Dashboard Loading Error</p>
                    <p className="text-sm">{error}</p>
                    <p className="text-xs mt-1 text-muted-foreground">
                      This may indicate missing team member relationships. Please contact your administrator.
                    </p>
                  </div>
                  <button 
                    onClick={loadDashboardData}
                    className="ml-2 px-3 py-1 bg-destructive text-destructive-foreground rounded text-sm hover:bg-destructive/90"
                  >
                    Retry
                  </button>
                </div>
              </div>
            )}

            {/* Week Selector */}
            <WeekSelector 
              currentWeek={currentWeek}
              onWeekChange={handleWeekChange}
            />

            {/* Loading State */}
            {isDashboardLoading ? (
              <div className="space-y-6">
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                  {[1, 2, 3, 4]?.map((i) => (
                    <div key={i} className="h-32 bg-card rounded-lg animate-pulse" />
                  ))}
                </div>
                <div className="h-64 bg-card rounded-lg animate-pulse" />
                <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
                  <div className="xl:col-span-2 h-96 bg-card rounded-lg animate-pulse" />
                  <div className="h-96 bg-card rounded-lg animate-pulse" />
                </div>
              </div>
            ) : (
              <>
                {/* Enhanced Accounts Section */}
                <div className="bg-white rounded-lg shadow mb-8">
                  <div className="px-6 py-4 border-b border-gray-200">
                    <div className="flex items-center justify-between">
                      <h2 className="text-lg font-semibold text-gray-900">Team Accounts</h2>
                      <span className="text-sm text-gray-500">{accounts?.length || 0} accounts</span>
                    </div>
                  </div>
                  
                  <div className="p-6">
                    {accounts?.length === 0 ? (
                      <div className="text-center py-8">
                        <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                        <p className="text-gray-500">No accounts assigned to your team yet.</p>
                      </div>
                    ) : (
                      <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                          <thead className="bg-gray-50">
                            <tr>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Account
                              </th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Assigned Reps
                              </th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Stage
                              </th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Location
                              </th>
                              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Actions
                              </th>
                            </tr>
                          </thead>
                          <tbody className="bg-white divide-y divide-gray-200">
                            {accounts?.map((account) => (
                              <tr key={account?.id} className="hover:bg-gray-50">
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <div>
                                    <div className="text-sm font-medium text-gray-900">
                                      {account?.name}
                                    </div>
                                    <div className="text-sm text-gray-500">
                                      {account?.company_type}
                                    </div>
                                  </div>
                                </td>
                                <td className="px-6 py-4">
                                  <div className="space-y-1">
                                    {account?.assigned_reps && Array.isArray(account?.assigned_reps) && account?.assigned_reps?.length > 0 ? (
                                      account?.assigned_reps?.map((rep, index) => (
                                        <div key={rep?.rep_id} className="flex items-center gap-2">
                                          <div className={`w-2 h-2 rounded-full ${rep?.is_primary ? 'bg-blue-500' : 'bg-gray-400'}`}></div>
                                          <span className={`text-sm ${rep?.is_primary ? 'font-medium text-gray-900' : 'text-gray-600'}`}>
                                            {rep?.rep_name}
                                            {rep?.is_primary && (
                                              <span className="ml-1 text-xs text-blue-600">(Primary)</span>
                                            )}
                                          </span>
                                        </div>
                                      ))
                                    ) : (
                                      <span className="text-sm text-gray-400">No reps assigned</span>
                                    )}
                                  </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                                    account?.stage === 'Won' ? 'bg-green-100 text-green-800' :
                                    account?.stage === 'In Negotiation' ? 'bg-yellow-100 text-yellow-800' :
                                    account?.stage === 'Lost'? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800'
                                  }`}>
                                    {account?.stage}
                                  </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                  {account?.city && account?.state && `${account?.city}, ${account?.state}`}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                  <div className="flex items-center gap-2">
                                    <Button
                                      size="sm"
                                      variant="outline"
                                      onClick={() => handleAssignReps(account)}
                                      className="flex items-center gap-1"
                                    >
                                      <UserPlus className="w-4 h-4" />
                                      Assign Reps
                                    </Button>
                                    <Button
                                      size="sm"
                                      variant="ghost"
                                      className="flex items-center gap-1 text-gray-600 hover:text-gray-900"
                                    >
                                      <Eye className="w-4 h-4" />
                                      View
                                    </Button>
                                  </div>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    )}
                  </div>
                </div>

                {/* Team Summary Cards */}
                <TeamSummaryCards
                  summaryData={summaryData}
                  accountsCount={accountsCount}
                  propertiesCount={propertiesCount}
                />

                {/* Metrics Grid - Fixed responsive layout to prevent overflow */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-4 overflow-hidden">
                  {teamMetrics?.map((metric, index) => (
                    <MetricsCard
                      key={`${metric?.title}-${index}`}
                      title={metric?.title}
                      current={metric?.current}
                      target={metric?.target}
                      icon={metric?.icon}
                      color={metric?.color}
                      trend={metric?.trend}
                      className="min-w-0 w-full"
                    />
                  ))}
                </div>

                {/* Main Dashboard Grid */}
                <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
                  {/* Team Performance Section - Takes full width on larger screens */}
                  <div className="xl:col-span-3">
                    <div className="space-y-6">
                      <TeamPerformanceTable teamData={transformedTeamData} />
                      <FunnelMetrics funnelData={funnelData} className="w-full" />
                    </div>
                  </div>
                </div>

                {/* QuickActions moved to bottom of page */}
                <QuickActions />
              </>
            )}
          </div>
        </main>

        {/* Mobile Quick Action Button */}
        <QuickActionButton variant="floating" onClick={() => {}} />
      </div>
      {/* Assign Reps Modal */}
      <AssignRepsModal
        isOpen={showAssignModal}
        onClose={() => setShowAssignModal(false)}
        account={selectedAccount}
        onSuccess={handleAssignSuccess}
        managerId={managerId}
      />
    </div>
  );
};

export default ManagerDashboard;
