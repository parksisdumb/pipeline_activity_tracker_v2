import React, { useState, useEffect } from 'react';
import Icon from '../../../components/AppIcon';
import { useAuth } from '../../../contexts/AuthContext';
import { activitiesService } from '../../../services/activitiesService';
import { accountsService } from '../../../services/accountsService';
import { contactsService } from '../../../services/contactsService';
import { format } from 'date-fns';

const TodayStats = ({ className = '' }) => {
  const { session, userProfile } = useAuth();
  const authUser = session?.user || null;
  const userId = userProfile?.id || authUser?.id || null;
  const [stats, setStats] = useState({
    todayActivities: 0,
    newAccounts: 0,
    newContacts: 0,
    followUps: 0
  });
  const [loading, setLoading] = useState(true);
  const [refreshKey, setRefreshKey] = useState(0);
  const [dataLoadingStatus, setDataLoadingStatus] = useState({
    accounts: 'loading',
    contacts: 'loading',
    activities: 'loading'
  });

  // FIXED: Load today's stats with comprehensive error handling and real data focus
  useEffect(() => {
    const loadTodayStats = async () => {
      if (!userId) return;
      
      setLoading(true);
      setDataLoadingStatus({ accounts: 'loading', contacts: 'loading', activities: 'loading' });
      
      try {
        console.log('🔍 Loading Today\'s Overview for user:', userId);
        
        // Use current date in YYYY-MM-DD format for precise date matching
        const today = new Date();
        const todayStart = format(today, 'yyyy-MM-dd');
        const todayEnd = format(today, 'yyyy-MM-dd') + 'T23:59:59.999Z';
        
        console.log('📅 Today date range:', todayStart, 'to', todayEnd);

        // CRITICAL FIX: Load actual database data with comprehensive logging
        console.log('🚀 Loading accounts from database...');
        const accountsResult = await accountsService?.getAccounts({
          limit: 200, // Increased limit to ensure we get all data
          showInactive: false
        });

        console.log('🚀 Loading contacts from database...');
        const contactsResult = await contactsService?.getContacts({
          limit: 200, // Increased limit to ensure we get all data
          showInactive: false
        });

        // Load activities stats if the service method exists
        let activitiesResult = null;
        try {
          if (activitiesService?.getActivityStats) {
            console.log('🚀 Loading activities from database...');
            activitiesResult = await activitiesService?.getActivityStats(userId, {
              dateFrom: todayStart + 'T00:00:00.000Z',
              dateTo: todayEnd
            });
          }
        } catch (actError) {
          console.warn('⚠️ Activities service not available:', actError?.message);
        }

        // Update loading status based on results
        setDataLoadingStatus({
          accounts: accountsResult?.success ? 'success' : 'error',
          contacts: contactsResult?.success ? 'success' : 'error', 
          activities: activitiesResult?.success ? 'success' : 'warning'
        });

        // Process accounts data - show ACTUAL database results
        let todayAccountsCount = 0;
        if (accountsResult?.success && Array.isArray(accountsResult?.data)) {
          console.log(`✅ Accounts loaded from database: ${accountsResult?.data?.length} total accounts`);
          
          // Filter accounts created today from the ACTUAL database data
          const todayAccounts = accountsResult?.data?.filter(account => {
            try {
              if (!account?.created_at) return false;
              const createdDate = new Date(account?.created_at);
              const isToday = format(createdDate, 'yyyy-MM-dd') === todayStart;
              
              if (isToday) {
                console.log('📊 Account created today:', account?.name, account?.created_at);
              }
              
              return isToday;
            } catch (dateError) {
              console.warn('⚠️ Invalid account created_at date:', account?.created_at);
              return false;
            }
          });
          
          todayAccountsCount = todayAccounts?.length || 0;
          console.log(`📈 New accounts today: ${todayAccountsCount}`);
        } else {
          console.error('❌ Failed to load accounts:', accountsResult?.error);
        }

        // Process contacts data - show ACTUAL database results
        let todayContactsCount = 0;
        if (contactsResult?.success && Array.isArray(contactsResult?.data)) {
          console.log(`✅ Contacts loaded from database: ${contactsResult?.data?.length} total contacts`);
          
          // Filter contacts created today from the ACTUAL database data
          const todayContacts = contactsResult?.data?.filter(contact => {
            try {
              if (!contact?.created_at) return false;
              const createdDate = new Date(contact?.created_at);
              const isToday = format(createdDate, 'yyyy-MM-dd') === todayStart;
              
              if (isToday) {
                console.log('📊 Contact created today:', contact?.first_name, contact?.last_name, contact?.created_at);
              }
              
              return isToday;
            } catch (dateError) {
              console.warn('⚠️ Invalid contact created_at date:', contact?.created_at);
              return false;
            }
          });
          
          todayContactsCount = todayContacts?.length || 0;
          console.log(`📈 New contacts today: ${todayContactsCount}`);
        } else {
          console.error('❌ Failed to load contacts:', contactsResult?.error);
        }

        // Process activities data
        const todayActivitiesCount = activitiesResult?.success ? (activitiesResult?.data?.total || 0) : 0;
        console.log(`📈 Today's activities: ${todayActivitiesCount}`);

        // For follow-ups, use a simple fallback if the service isn't available
        let todayFollowUpsCount = 0;
        try {
          if (activitiesService?.getUpcomingTasks) {
            const followUpsResult = await activitiesService?.getUpcomingTasks(userId, 20);
            if (followUpsResult?.success && Array.isArray(followUpsResult?.data)) {
              todayFollowUpsCount = followUpsResult?.data?.filter(task => {
                try {
                  const followUpDate = new Date(task?.follow_up_date || task?.due_date);
                  return format(followUpDate, 'yyyy-MM-dd') === todayStart;
                } catch (dateError) {
                  return false;
                }
              })?.length || 0;
            }
          }
        } catch (followUpError) {
          console.warn('⚠️ Follow-ups service not available:', followUpError?.message);
        }

        // CRITICAL: Show REAL database data, not sample data
        const finalStats = {
          todayActivities: todayActivitiesCount,
          newAccounts: todayAccountsCount,
          newContacts: todayContactsCount,
          followUps: todayFollowUpsCount
        };

        setStats(finalStats);

        // Enhanced logging for debugging
        console.log('📊 FINAL TODAY\'S STATS (from actual database):', finalStats);
        console.log('📊 Data loading status:', {
          accounts: `${accountsResult?.success ? 'SUCCESS' : 'FAILED'} - ${accountsResult?.data?.length || 0} records`,
          contacts: `${contactsResult?.success ? 'SUCCESS' : 'FAILED'} - ${contactsResult?.data?.length || 0} records`,
          activities: `${activitiesResult?.success ? 'SUCCESS' : 'LIMITED'} - ${activitiesResult?.data?.total || 0} records`
        });

        // Log any potential data issues
        if (finalStats?.newAccounts === 0 && finalStats?.newContacts === 0) {
          console.log('ℹ️ No new records created today - this is normal if no data was added today');
        }

      } catch (error) {
        console.error('❌ Failed to load today\'s stats:', error);
        
        // Set stats to 0 on error but maintain error status
        setStats({
          todayActivities: 0,
          newAccounts: 0,
          newContacts: 0,
          followUps: 0
        });
        
        setDataLoadingStatus({
          accounts: 'error',
          contacts: 'error', 
          activities: 'error'
        });
      } finally {
        setLoading(false);
      }
    };

    loadTodayStats();
  }, [userId, refreshKey]);

  // Auto-refresh every 60 seconds when tab is active
  useEffect(() => {
    const interval = setInterval(() => {
      if (document.visibilityState === 'visible') {
        console.log('🔄 Auto-refreshing today\'s stats...');
        setRefreshKey(prev => prev + 1);
      }
    }, 60000);

    return () => clearInterval(interval);
  }, []);

  const todayStats = [
    {
      id: 1,
      label: "Today\'s Activities",
      value: stats?.todayActivities,
      change: "Logged today",
      icon: "Activity",
      color: "text-blue-600",
      bgColor: "bg-blue-100",
      status: dataLoadingStatus?.activities
    },
    {
      id: 2,
      label: "New Accounts",
      value: stats?.newAccounts,
      change: "Added today",
      icon: "Building2",
      color: "text-green-600",
      bgColor: "bg-green-100",
      status: dataLoadingStatus?.accounts
    },
    {
      id: 3,
      label: "New Contacts",
      value: stats?.newContacts,
      change: "Added today",
      icon: "UserPlus",
      color: "text-purple-600",
      bgColor: "bg-purple-100",
      status: dataLoadingStatus?.contacts
    },
    {
      id: 4,
      label: "Follow-ups Due",
      value: stats?.followUps,
      change: "Due today",
      icon: "Clock",
      color: "text-orange-600",
      bgColor: "bg-orange-100",
      status: dataLoadingStatus?.activities
    }
  ];

  if (loading) {
    return (
      <div className={`bg-card rounded-xl border border-border p-6 ${className}`}>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-lg font-semibold text-foreground">Today's Overview</h2>
          <div className="animate-spin w-4 h-4 border-2 border-primary border-t-transparent rounded-full" />
        </div>
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)]?.map((_, i) => (
            <div key={i} className="text-center animate-pulse">
              <div className="w-12 h-12 bg-muted rounded-full mx-auto mb-3" />
              <div className="space-y-2">
                <div className="h-6 bg-muted rounded w-8 mx-auto" />
                <div className="h-3 bg-muted rounded w-16 mx-auto" />
              </div>
            </div>
          ))}
        </div>
        <div className="mt-4 text-xs text-muted-foreground text-center">
          Loading actual database data...
        </div>
      </div>
    );
  }

  return (
    <div className={`bg-card rounded-xl border border-border p-6 ${className}`}>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-lg font-semibold text-foreground">Today's Overview</h2>
        <div className="flex items-center gap-2">
          {/* Data status indicator */}
          <div className="flex items-center gap-1">
            {Object.values(dataLoadingStatus)?.every(status => status === 'success') && (
              <div className="w-2 h-2 bg-green-500 rounded-full" title="All data loaded successfully" />
            )}
            {Object.values(dataLoadingStatus)?.some(status => status === 'error') && (
              <div className="w-2 h-2 bg-red-500 rounded-full" title="Some data failed to load" />
            )}
            {Object.values(dataLoadingStatus)?.some(status => status === 'warning') && (
              <div className="w-2 h-2 bg-yellow-500 rounded-full" title="Limited data available" />
            )}
          </div>
          <Icon
            name="RefreshCw"
            size={16}
            className="text-muted-foreground cursor-pointer hover:text-foreground transition-colors"
            onClick={() => setRefreshKey(prev => prev + 1)}
            title="Refresh data"
          />
        </div>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {todayStats?.map((stat) => (
          <div key={stat?.id} className="text-center">
            <div className={`w-12 h-12 rounded-xl flex items-center justify-center mx-auto mb-3 ${stat?.bgColor}`}>
              <Icon 
                name={stat?.icon} 
                size={20} 
                className={stat?.color}
              />
              {/* Status indicator */}
              {stat?.status === 'error' && (
                <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full" title="Failed to load data" />
              )}
              {stat?.status === 'warning' && (
                <div className="absolute -top-1 -right-1 w-3 h-3 bg-yellow-500 rounded-full" title="Limited data" />
              )}
            </div>
            
            <div className="space-y-1">
              <p className="text-2xl font-bold text-foreground">
                {stat?.value}
              </p>
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                {stat?.label}
              </p>
              <p className="text-xs text-muted-foreground">
                {stat?.change}
              </p>
            </div>
          </div>
        ))}
      </div>
      {/* Debug info for development */}
      {import.meta.env.MODE === 'development' && (

        <div className="mt-4 p-2 bg-muted/30 rounded text-xs text-muted-foreground">
          <div className="font-medium mb-1">Database Connection Status:</div>
          <div className="grid grid-cols-3 gap-2 text-xs">
            <div className={`${dataLoadingStatus?.accounts === 'success' ? 'text-green-600' : 'text-red-600'}`}>
              Accounts: {dataLoadingStatus?.accounts}
            </div>
            <div className={`${dataLoadingStatus?.contacts === 'success' ? 'text-green-600' : 'text-red-600'}`}>
              Contacts: {dataLoadingStatus?.contacts}
            </div>
            <div className={`${dataLoadingStatus?.activities === 'success' ? 'text-green-600' : dataLoadingStatus?.activities === 'warning' ? 'text-yellow-600' : 'text-red-600'}`}>
              Activities: {dataLoadingStatus?.activities}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TodayStats;
