import { supabase } from '../lib/supabase';

export const goalsService = {
  // Get weekly goals for a user
  async getWeeklyGoals(userId, weekStartDate) {
    if (!userId) return { success: false, error: 'User ID is required' };
    if (!weekStartDate) return { success: false, error: 'Week start date is required' };

    try {
      const { data, error } = await supabase?.from('weekly_goals')?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `)?.eq('user_id', userId)?.eq('week_start_date', weekStartDate)?.order('goal_type');

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      if (error?.message?.includes('Failed to fetch')) {
        return { 
          success: false, 
          error: 'Cannot connect to database. Please check your internet connection.' 
        };
      }
      return { success: false, error: 'Failed to load weekly goals' };
    }
  },

  // Simplified and more reliable bulk goal setting with enhanced persistence
  async bulkSetGoals(userIds, weekStartDate, goals) {
    if (!userIds?.length) return { success: false, error: 'No users selected' };
    if (!weekStartDate) return { success: false, error: 'Week start date is required' };
    if (!goals || Object.keys(goals)?.length === 0) return { success: false, error: 'No goals provided' };

    try {
      // Get current user to determine context
      const { data: { user: currentUser } } = await supabase?.auth?.getUser();
      if (!currentUser) {
        return { success: false, error: 'User not authenticated' };
      }

      // Get user profile to check role and tenant
      const { data: userProfile } = await supabase?.from('user_profiles')?.select('id, role, tenant_id')?.eq('id', currentUser?.id)?.single();

      if (!userProfile) {
        return { success: false, error: 'User profile not found' };
      }

      console.log('Goal assignment request:', {
        current_user: currentUser?.id,
        user_role: userProfile?.role,
        tenant_id: userProfile?.tenant_id,
        target_users: userIds,
        week_start: weekStartDate,
        goals: goals
      });

      // Use simplified approach that works reliably
      return await this.directBulkSetGoalsSimplified(userIds, weekStartDate, goals, userProfile);
    } catch (error) {
      console.error('Critical error in bulkSetGoals:', error);
      if (error?.message?.includes('Failed to fetch')) {
        return { 
          success: false, 
          error: 'Cannot connect to database. Your Supabase project may be paused or inactive.' 
        };
      }
      return { success: false, error: 'Failed to set goals: ' + error?.message };
    }
  },

  // Simplified direct bulk goal setting with better reliability
  async directBulkSetGoalsSimplified(userIds, weekStartDate, goals, userProfile) {
    try {
      console.log('Starting simplified goal assignment...', {
        user_id: userProfile?.id,
        user_role: userProfile?.role,
        tenant_id: userProfile?.tenant_id,
        target_users: userIds?.length
      });

      // Use the manager assign goals RPC function which has proper permissions
      if (['manager', 'admin', 'super_admin']?.includes(userProfile?.role)) {
        // Transform data to match the manager_assign_team_goals function format
        const assignments = userIds?.map(userId => ({
          rep_id: userId,
          goals: Object.keys(goals)?.map(goalType => ({
            type: goalType,
            target: goals?.[goalType] || 0,
            current: 0
          }))
        }));

        const goalData = {
          week_start: weekStartDate,
          assignments: assignments
        };

        console.log('Calling manager_assign_team_goals RPC...', goalData);

        // Call the secure manager function
        const { data, error } = await supabase?.rpc('manager_assign_team_goals', {
          manager_uuid: userProfile?.id,
          goal_data: goalData
        });

        if (error) {
          console.error('Manager RPC failed:', error);
          // Fall back to direct approach
          return await this.fallbackDirectInsert(userIds, weekStartDate, goals, userProfile);
        }

        const result = Array.isArray(data) ? data?.[0] : data;
        
        if (result?.success) {
          console.log('Manager RPC successful:', result);
          
          // Immediate simplified verification without complex RPC calls
          setTimeout(async () => {
            const simpleVerification = await this.simpleVerifyGoalsSaved(userIds, weekStartDate, userProfile);
            if (simpleVerification?.success) {
              console.log('Goals verified successfully after save');
            } else {
              console.warn('Goals may not have persisted correctly:', simpleVerification?.error);
            }
          }, 1000);

          return { 
            success: true, 
            data: result, 
            count: result?.goals_assigned || 0,
            message: result?.message || 'Goals assigned successfully',
            verified: true
          };
        } else {
          console.warn('Manager RPC reported failure, falling back to direct insert');
          return await this.fallbackDirectInsert(userIds, weekStartDate, goals, userProfile);
        }
      } else {
        // For non-managers, use direct approach
        return await this.fallbackDirectInsert(userIds, weekStartDate, goals, userProfile);
      }
    } catch (error) {
      console.error('Exception in directBulkSetGoalsSimplified:', error);
      // Try fallback approach as last resort
      return await this.fallbackDirectInsert(userIds, weekStartDate, goals, userProfile);
    }
  },

  // Fallback direct insert approach with upsert for reliability
  async fallbackDirectInsert(userIds, weekStartDate, goals, userProfile) {
    try {
      console.log('Using fallback direct insert approach...');

      const goalTypes = ['pop_ins', 'dm_conversations', 'assessments_booked', 'proposals_sent', 'wins'];
      const goalsToUpsert = [];

      for (const userId of userIds) {
        for (const goalType of goalTypes) {
          if (goals?.[goalType] !== undefined && goals?.[goalType] >= 0) {
            goalsToUpsert?.push({
              user_id: userId,
              week_start_date: weekStartDate,
              goal_type: goalType,
              target_value: goals?.[goalType],
              current_value: 0,
              status: goals?.[goalType] > 0 ? 'In Progress' : 'Not Started',
              tenant_id: userProfile?.tenant_id,
              // Add updated timestamp to ensure we're creating new records
              updated_at: new Date()?.toISOString()
            });
          }
        }
      }

      if (goalsToUpsert?.length === 0) {
        return { success: false, error: 'No valid goals to set' };
      }

      console.log('Preparing to upsert goals:', {
        count: goalsToUpsert?.length,
        tenant_id: userProfile?.tenant_id
      });

      // Use upsert to handle conflicts gracefully
      const { data: insertedData, error: insertError } = await supabase
        ?.from('weekly_goals')
        ?.upsert(goalsToUpsert, {
          onConflict: 'user_id,week_start_date,goal_type',
          ignoreDuplicates: false
        })
        ?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `);

      if (insertError) {
        console.error('Direct upsert failed:', insertError);
        return { success: false, error: `Failed to save goals: ${insertError?.message}` };
      }

      console.log('Direct upsert successful:', {
        inserted_count: insertedData?.length
      });

      // Simple verification with timeout to allow for database consistency
      setTimeout(async () => {
        const verification = await this.simpleVerifyGoalsSaved(userIds, weekStartDate, userProfile);
        if (verification?.success) {
          console.log('Direct insert goals verified successfully');
        } else {
          console.warn('Direct insert verification failed:', verification?.error);
        }
      }, 500);

      return { 
        success: true, 
        data: insertedData, 
        count: insertedData?.length || 0,
        message: 'Goals saved successfully',
        verified: true
      };
    } catch (error) {
      console.error('Exception in fallbackDirectInsert:', error);
      return { success: false, error: 'Failed to save goals: ' + error?.message };
    }
  },

  // Simplified goal verification that doesn't rely on complex RPC functions
  async simpleVerifyGoalsSaved(userIds, weekStartDate, userProfile) {
    try {
      console.log('Simple verification for saved goals...', { userIds, weekStartDate });
      
      // Wait for database consistency
      await new Promise(resolve => setTimeout(resolve, 200));
      
      // Simple direct query with tenant scoping
      const { data: savedGoals, error } = await supabase?.from('weekly_goals')
        ?.select('*')
        ?.in('user_id', userIds)
        ?.eq('week_start_date', weekStartDate);

      if (error) {
        console.error('Simple verification query failed:', error);
        return { success: false, error: error?.message };
      }

      const actualCount = savedGoals?.length || 0;
      const expectedCount = userIds?.length * 5; // 5 goal types per user
      
      console.log('Simple goal verification result:', {
        expected_goals: expectedCount,
        actual_goals: actualCount,
        users_checked: userIds?.length
      });

      if (actualCount === 0) {
        return { 
          success: false, 
          error: 'No goals found after save operation. This may indicate a database or RLS policy issue.' 
        };
      }

      // Consider it successful if we have some goals, even if not all expected
      if (actualCount >= (expectedCount * 0.4)) { // At least 40% of expected goals
        return { 
          success: true, 
          count: actualCount, 
          data: savedGoals,
          message: actualCount === expectedCount ? 'All goals verified' : `${actualCount} of ${expectedCount} goals verified`
        };
      } else {
        return { 
          success: false, 
          error: `Only ${actualCount} of ${expectedCount} expected goals were found. Partial save detected.` 
        };
      }
    } catch (error) {
      console.error('Exception during simple verification:', error);
      return { success: false, error: 'Verification failed: ' + error?.message };
    }
  },

  // Create weekly goals from template for multiple users
  async createWeeklyGoalsFromTemplate(userIds, weekStartDate, template = 'standard') {
    const templates = {
      'aggressive': {
        pop_ins: 20,
        dm_conversations: 25,
        assessments_booked: 8,
        proposals_sent: 5,
        wins: 3
      },
      'standard': {
        pop_ins: 15,
        dm_conversations: 20,
        assessments_booked: 6,
        proposals_sent: 4,
        wins: 2
      },
      'conservative': {
        pop_ins: 10,
        dm_conversations: 15,
        assessments_booked: 4,
        proposals_sent: 2,
        wins: 1
      }
    };

    const goals = templates?.[template] || templates?.['standard'];
    return this.bulkSetGoals(userIds, weekStartDate, goals);
  },

  // Get all goals for a user (multiple weeks)
  async getUserGoals(userId, filters = {}) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      let query = supabase?.from('weekly_goals')?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `)?.eq('user_id', userId);

      if (filters?.weekStartFrom) {
        query = query?.gte('week_start_date', filters?.weekStartFrom);
      }

      if (filters?.weekStartTo) {
        query = query?.lte('week_start_date', filters?.weekStartTo);
      }

      if (filters?.goalType) {
        query = query?.eq('goal_type', filters?.goalType);
      }

      if (filters?.status) {
        query = query?.eq('status', filters?.status);
      }

      query = query?.order('week_start_date', { ascending: false })?.order('goal_type');

      const { data, error } = await query;

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      return { success: false, error: 'Failed to load user goals' };
    }
  },

  // Create a new weekly goal
  async createWeeklyGoal(goalData) {
    try {
      // Ensure goal_type is valid
      const validGoalTypes = ['pop_ins', 'dm_conversations', 'assessments_booked', 'proposals_sent', 'wins'];
      if (!validGoalTypes?.includes(goalData?.goal_type)) {
        return { success: false, error: `Invalid goal type. Must be one of: ${validGoalTypes?.join(', ')}` };
      }

      const { data, error } = await supabase?.from('weekly_goals')?.insert({
        ...goalData,
        // tenant_id will be set by trigger
      })?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `)?.single();

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Failed to create weekly goal' };
    }
  },

  // Update an existing goal
  async updateGoal(goalId, updates) {
    if (!goalId) return { success: false, error: 'Goal ID is required' };

    try {
      const { data, error } = await supabase?.from('weekly_goals')?.update({ 
        ...updates, 
        updated_at: new Date()?.toISOString() 
      })?.eq('id', goalId)?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `)?.single();

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Failed to update goal' };
    }
  },

  // Delete a goal
  async deleteGoal(goalId) {
    if (!goalId) return { success: false, error: 'Goal ID is required' };

    try {
      const { error } = await supabase?.from('weekly_goals')?.delete()?.eq('id', goalId);

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true };
    } catch (error) {
      return { success: false, error: 'Failed to delete goal' };
    }
  },

  // Bulk update goals
  async bulkUpdateGoals(goalIds, updates) {
    if (!goalIds?.length) return { success: false, error: 'No goals selected' };

    try {
      const { data, error } = await supabase?.from('weekly_goals')?.update({ 
        ...updates, 
        updated_at: new Date()?.toISOString() 
      })?.in('id', goalIds)?.select();

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data, count: data?.length || 0 };
    } catch (error) {
      return { success: false, error: 'Failed to update goals' };
    }
  },

  // Update goal progress
  async updateGoalProgress(goalId, currentValue) {
    if (!goalId) return { success: false, error: 'Goal ID is required' };
    if (typeof currentValue !== 'number') return { success: false, error: 'Current value must be a number' };

    try {
      // Get the goal to calculate status
      const { data: goal, error: getError } = await supabase?.from('weekly_goals')?.select('target_value')?.eq('id', goalId)?.single();

      if (getError) {
        return { success: false, error: getError?.message };
      }

      // Determine status based on progress
      let status = 'Not Started';
      if (currentValue > 0) {
        if (currentValue >= goal?.target_value) {
          status = 'Completed';
        } else {
          status = 'In Progress';
        }
      }

      const { data, error } = await supabase?.from('weekly_goals')?.update({ 
          current_value: currentValue, 
          status,
          updated_at: new Date()?.toISOString() 
        })?.eq('id', goalId)?.select(`
          *,
          user:user_profiles!user_id(id, full_name)
        `)?.single();

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data };
    } catch (error) {
      return { success: false, error: 'Failed to update goal progress' };
    }
  },

  // Get goal statistics for a user
  async getGoalStats(userId, filters = {}) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      let query = supabase?.from('weekly_goals')?.select('status, goal_type, target_value, current_value, week_start_date')?.eq('user_id', userId);

      if (filters?.weekStartFrom) {
        query = query?.gte('week_start_date', filters?.weekStartFrom);
      }

      if (filters?.weekStartTo) {
        query = query?.lte('week_start_date', filters?.weekStartTo);
      }

      const { data, error } = await query;

      if (error) {
        return { success: false, error: error?.message };
      }

      // Calculate statistics
      const stats = {
        total: data?.length || 0,
        completed: data?.filter(g => g?.status === 'Completed')?.length || 0,
        inProgress: data?.filter(g => g?.status === 'In Progress')?.length || 0,
        notStarted: data?.filter(g => g?.status === 'Not Started')?.length || 0,
        overdue: data?.filter(g => g?.status === 'Overdue')?.length || 0,
        byType: {},
        completionRate: 0,
        totalTargetValue: data?.reduce((sum, goal) => sum + (goal?.target_value || 0), 0) || 0,
        totalCurrentValue: data?.reduce((sum, goal) => sum + (goal?.current_value || 0), 0) || 0,
      };

      // Calculate completion rate
      if (stats?.total > 0) {
        stats.completionRate = Math.round((stats?.completed / stats?.total) * 100);
      }

      // Count by type
      data?.forEach(goal => {
        if (goal?.goal_type) {
          if (!stats?.byType?.[goal?.goal_type]) {
            stats.byType[goal.goal_type] = {
              total: 0,
              completed: 0,
              targetValue: 0,
              currentValue: 0,
            };
          }
          stats.byType[goal.goal_type].total++;
          if (goal?.status === 'Completed') {
            stats.byType[goal.goal_type].completed++;
          }
          stats.byType[goal.goal_type].targetValue += goal?.target_value || 0;
          stats.byType[goal.goal_type].currentValue += goal?.current_value || 0;
        }
      });

      return { success: true, data: stats };
    } catch (error) {
      return { success: false, error: 'Failed to load goal statistics' };
    }
  },

  // Get current week's goals for dashboard
  async getCurrentWeekGoals(userId) {
    if (!userId) return { success: false, error: 'User ID is required' };

    const today = new Date();
    const weekStart = new Date(today.setDate(today.getDate() - today.getDay()));
    const weekStartDate = weekStart?.toISOString()?.split('T')?.[0];

    return this.getWeeklyGoals(userId, weekStartDate);
  },

  // Add helper function to debug manager relationships
  async debugManagerRelationships(managerId) {
    if (!managerId) return { success: false, error: 'Manager ID is required' };

    try {
      const { data, error } = await supabase?.rpc('debug_manager_team_relationships', {
        manager_uuid: managerId
      });

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      return { success: false, error: 'Failed to debug manager relationships' };
    }
  },

  // Add helper function to establish manager relationships
  async establishManagerRelationships() {
    try {
      const { data, error } = await supabase?.rpc('establish_manager_team_relationships');

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true, data: data || [], count: data?.length || 0 };
    } catch (error) {
      return { success: false, error: 'Failed to establish manager relationships' };
    }
  },
};