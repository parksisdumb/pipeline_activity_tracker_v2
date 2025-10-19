import { supabase } from '../lib/supabaseClient';
import { managerService } from './managerService';

export const accountsService = {
  // ENHANCED: Get all accounts with comprehensive role-based access
  async getAccounts(filters = {}) {
    try {
      // Get current user to determine role-based access
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        return { success: false, error: 'Authentication required' };
      }

      console.log('Getting accounts for user:', user?.id);

      // CRITICAL FIX: Use enhanced user profile validation
      const { data: profileValidation, error: validationError } = await supabase?.rpc(
        'validate_user_session_and_profile', 
        { user_uuid: user?.id }
      );

      if (validationError) {
        console.error('Profile validation error:', validationError);
        return { success: false, error: 'Failed to validate user permissions' };
      }

      if (!profileValidation?.success || !profileValidation?.user_data) {
        console.error('User profile validation failed:', profileValidation);
        return { success: false, error: 'User profile not properly configured' };
      }

      const userRole = profileValidation?.user_data?.role;
      const userId = profileValidation?.user_data?.id;
      
      console.log('Validated user role:', userRole, 'User ID:', userId);

      let data = [];

      // ENHANCED: Use new database functions for role-based access
      if (userRole === 'manager') {
        console.log('Fetching accounts using manager function...');
        
        try {
          const { data: managerAccounts, error: managerError } = await supabase?.rpc(
            'get_user_accessible_accounts', 
            { user_uuid: userId }
          );

          if (managerError) {
            console.error('Manager function error details:', managerError);
            throw new Error(`Manager account access error: ${managerError.message}`);
          }

          // CRITICAL FIX: Validate that we received the expected data structure
          if (!Array.isArray(managerAccounts)) {
            console.warn('Manager function returned non-array data:', managerAccounts);
            throw new Error('Manager function returned unexpected data structure');
          }

          data = managerAccounts || [];
          console.log('Manager accounts fetched via function:', data?.length);

        } catch (managerFuncError) {
          console.error('Manager function failed, falling back to service:', managerFuncError);
          
          // Fallback to existing manager service
          const managerAccounts = await managerService?.getAllTenantAccounts(userId);
          
          if (managerAccounts && Array.isArray(managerAccounts)) {
            console.log('Manager tenant accounts fetched via fallback:', managerAccounts?.length);
            
            // Get account IDs to fetch properties
            const accountIds = managerAccounts?.map(account => account?.id)?.filter(Boolean);
            
            // Fetch properties for all accounts at once
            let propertiesByAccount = {};
            if (accountIds?.length > 0) {
              const { data: propertiesData, error: propertiesError } = await supabase
                ?.from('properties')
                ?.select('id, name, stage, account_id')
                ?.in('account_id', accountIds);

              if (!propertiesError) {
                // Group properties by account_id
                propertiesData?.forEach(property => {
                  if (!propertiesByAccount?.[property?.account_id]) {
                    propertiesByAccount[property?.account_id] = [];
                  }
                  propertiesByAccount?.[property?.account_id]?.push(property);
                });
              }
            }
            
            // Transform manager-specific data to match expected structure
            data = managerAccounts?.map(account => ({
              // Core account fields
              id: account?.id,
              name: account?.name,
              company_type: account?.company_type,
              stage: account?.stage,
              city: account?.city,
              state: account?.state,
              email: account?.email,
              phone: account?.phone,
              created_at: account?.created_at,
              updated_at: account?.updated_at,
              notes: account?.notes,
              is_active: account?.is_active !== false,
              
              // Transform assigned reps data
              assigned_reps: account?.assigned_reps || [],
              primary_rep_name: account?.primary_rep_name,
              
              // Create assigned_rep object for compatibility
              assigned_rep: account?.primary_rep_name ? {
                full_name: account?.primary_rep_name,
                id: null,
                email: null
              } : null,
              
              // Add computed fields for UI compatibility
              companyType: account?.company_type,
              assignedRep: account?.primary_rep_name || 'Unassigned',
              lastActivity: account?.updated_at,
              primaryContact: null,
              
              // Properties data
              properties: propertiesByAccount?.[account?.id] || [],
              propertiesCount: (propertiesByAccount?.[account?.id] || [])?.length,
              contacts: [],
              access_type: 'manager_tenant_access'
            })) || [];
          } else {
            console.warn('Manager service returned invalid data:', managerAccounts);
            data = [];
          }
        }
      } else {
        // ENHANCED: Use database function for all other roles
        console.log('Fetching accounts using database function for role:', userRole);
        
        try {
          const { data: userAccounts, error: userAccessError } = await supabase?.rpc(
            'get_user_accessible_accounts', 
            { user_uuid: userId }
          );

          if (userAccessError) {
            console.error('User access function error details:', userAccessError);
            throw new Error(`User account access error: ${userAccessError.message}`);
          }

          // CRITICAL FIX: Validate that we received the expected data structure
          if (!Array.isArray(userAccounts)) {
            console.warn('User access function returned non-array data:', userAccounts);
            throw new Error('User access function returned unexpected data structure');
          }

          data = userAccounts || [];
          console.log('User accounts fetched via function:', data?.length);

        } catch (userFuncError) {
          console.error('User access function failed, falling back to standard query:', userFuncError);
          
          // Fallback to standard query
          let query = supabase?.from('accounts')?.select(`
              *,
              assigned_rep:user_profiles!assigned_rep_id(id, full_name, email),
              properties(id, name, stage),
              contacts(id, first_name, last_name, is_primary_contact)
            `);

          // Apply role-based filtering in fallback
          if (userRole === 'rep') {
            query = query?.eq('assigned_rep_id', userId);
          }

          if (!filters?.showInactive) {
            query = query?.eq('is_active', true);
          }

          const { data: queryData, error } = await query?.order('name');

          if (error) {
            console.error('Fallback accounts query error:', error);
            return { success: false, error: error?.message };
          }

          data = queryData || [];
          console.log('Fallback accounts fetched:', data?.length);
        }
      }

      // Apply client-side filtering if needed
      if (filters && Object.keys(filters)?.length > 0) {
        console.log('Applying client-side filters:', filters);
        
        // FIXED: Remove userId filter as it's not a valid filter parameter
        const { userId: _, ...validFilters } = filters;
        
        if (validFilters?.searchTerm) {
          const searchLower = validFilters?.searchTerm?.toLowerCase();
          data = data?.filter(account => 
            account?.name?.toLowerCase()?.includes(searchLower) ||
            account?.email?.toLowerCase()?.includes(searchLower)
          );
        }

        if (validFilters?.companyType) {
          data = data?.filter(account => account?.company_type === validFilters?.companyType);
        }

        if (validFilters?.stage) {
          data = data?.filter(account => account?.stage === validFilters?.stage);
        }

        if (validFilters?.assignedRep) {
          data = data?.filter(account => 
            account?.assigned_reps?.some(rep => rep?.rep_id === validFilters?.assignedRep) ||
            account?.assigned_rep_id === validFilters?.assignedRep
          );
        }

        if (!validFilters?.showInactive) {
          data = data?.filter(account => account?.is_active !== false);
        }

        // Apply limit if specified
        if (validFilters?.limit && typeof validFilters?.limit === 'number') {
          data = data?.slice(0, validFilters?.limit);
        }

        // Apply sorting
        const sortColumn = validFilters?.sortBy || 'name';
        const sortDirection = validFilters?.sortDirection === 'desc' ? -1 : 1;
        data = data?.sort((a, b) => {
          const aVal = a?.[sortColumn] || '';
          const bVal = b?.[sortColumn] || '';
          return aVal?.toString()?.localeCompare(bVal?.toString()) * sortDirection;
        });
      }

      // Transform data to ensure UI compatibility
      const transformedData = data?.map(account => ({
        ...account,
        // Ensure all required fields exist
        id: account?.id,
        name: account?.name,
        company_type: account?.company_type,
        stage: account?.stage,
        is_active: account?.is_active !== false,
        
        // Computed properties
        propertiesCount: account?.properties_count ?? account?.propertiesCount ?? (account?.properties?.length || 0),
        contactsCount: account?.contacts_count ?? (account?.contacts?.length || 0),
        lastActivity: account?.updated_at,
        primaryContact: account?.contacts?.find(c => c?.is_primary_contact),
        
        // UI-friendly field mappings
        companyType: account?.company_type,
        assignedRep: account?.primary_rep_name || account?.assigned_rep?.full_name || 'Unassigned',
        
        // Manager-specific data
        assignedRepsData: account?.assigned_reps || [],
        primaryRepName: account?.primary_rep_name || account?.assigned_rep?.full_name,
        
        // Ensure arrays exist
        properties: account?.properties || [],
        contacts: account?.contacts || [],
        assigned_reps: account?.assigned_reps || [],
        
        // Add access type for debugging
        access_type: account?.access_type || 'standard_access'
      }));

      console.log('Final transformed accounts:', transformedData?.length);
      console.log('Sample account structure:', transformedData?.[0] ? {
        id: transformedData?.[0]?.id,
        name: transformedData?.[0]?.name,
        role_access: transformedData?.[0]?.access_type,
        properties_count: transformedData?.[0]?.propertiesCount,
        assigned_rep: transformedData?.[0]?.assignedRep
      } : 'No accounts');

      return { success: true, data: transformedData };
    } catch (error) {
      console.error('Accounts service error:', error);
      
      if (error?.message?.includes('Failed to fetch')) {
        return { 
          success: false, 
          error: 'Cannot connect to database. Your Supabase project may be paused or inactive. Please check your Supabase dashboard and resume your project if needed.' 
        };
      }
      
      return { success: false, error: error?.message || 'Failed to load accounts' };
    }
  },

  // Get a single account by ID
  async getAccount(accountId) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      // Enhanced query to fetch comprehensive account data
      const { data, error } = await supabase
        ?.from('accounts')
        ?.select(`
          *,
          assigned_rep:user_profiles!assigned_rep_id(id, full_name, email, phone, role),
          properties(id, name, stage, building_type, square_footage, year_built, address, city, state),
          contacts(id, first_name, last_name, title, email, phone, mobile_phone, stage, is_primary_contact),
          activities(id, activity_type, activity_date, subject, outcome, notes, duration_minutes),
          opportunities(id, name, stage, opportunity_type, bid_value, probability, expected_close_date),
          account_assignments!account_assignments_account_id_fkey(
            id,
            rep_id,
            is_primary,
            assigned_at,
            notes,
            assigned_by,
            rep:user_profiles!account_assignments_rep_id_fkey(id, full_name, email, phone, role),
            assigner:user_profiles!account_assignments_assigned_by_fkey(id, full_name, email)
          )
        `)
        ?.eq('id', accountId)
        ?.single();

      if (error) {
        if (error?.code === 'PGRST116') {
          return { success: false, error: 'Account not found' };
        }
        console.error('Get account error:', error);
        return { success: false, error: error?.message };
      }

      // Transform the data to include computed fields for UI
      const transformedAccount = {
        ...data,
        // Transform assigned reps for UI compatibility
        assigned_reps: data?.account_assignments?.map(assignment => ({
          rep_id: assignment?.rep_id,
          rep_name: assignment?.rep?.full_name,
          rep_email: assignment?.rep?.email,
          rep_phone: assignment?.rep?.phone,
          rep_role: assignment?.rep?.role,
          is_primary: assignment?.is_primary,
          assigned_at: assignment?.assigned_at,
          assignment_notes: assignment?.notes,
          assigned_by_name: assignment?.assigner?.full_name,
          assigned_by_email: assignment?.assigner?.email
        })) || [],
        
        // Add computed fields for UI compatibility
        companyType: data?.company_type,
        primaryContact: data?.contacts?.find(c => c?.is_primary_contact),
        propertiesCount: data?.properties?.length || 0,
        contactsCount: data?.contacts?.length || 0,
        activitiesCount: data?.activities?.length || 0,
        opportunitiesCount: data?.opportunities?.length || 0,
        lastActivity: data?.activities?.length > 0 
          ? data?.activities?.sort((a, b) => new Date(b?.activity_date) - new Date(a?.activity_date))?.[0]?.activity_date
          : data?.updated_at,

        // Legacy compatibility
        primary_rep_name: data?.assigned_rep?.full_name,
        assignedRep: data?.assigned_rep?.full_name || 'Unassigned'
      };

      return { success: true, data: transformedAccount };
    } catch (error) {
      console.error('Service error:', error);
      if (error?.message?.includes('Failed to fetch')) {
        return { 
          success: false, 
          error: 'Cannot connect to database. Your Supabase project may be paused or inactive. Please check your Supabase dashboard and resume your project if needed.' 
        };
      }
      return { success: false, error: 'Failed to load account' };
    }
  },

  // Create a new account - Fixed to handle tenant issues
  async createAccount(accountData) {
    try {
      // Ensure required fields are present
      const requiredFields = ['name', 'company_type'];
      for (const field of requiredFields) {
        if (!accountData?.[field]) {
          return { success: false, error: `${field} is required` };
        }
      }

      // Get current user to handle tenant assignment
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        return { success: false, error: 'Authentication required to create account' };
      }

      // If no assigned rep is provided, assign to current user
      if (!accountData?.assigned_rep_id) {
        accountData.assigned_rep_id = user?.id;
      }

      const { data, error } = await supabase?.from('accounts')?.insert(accountData)?.select(`
          *,
          assigned_rep:user_profiles(id, full_name, email)
        `)?.single();

      if (error) {
        console.error('Create account error:', error);
        
        // Handle specific constraint violations
        if (error?.code === '23505') {
          return { success: false, error: 'An account with this name already exists' };
        }
        
        if (error?.code === '23503') {
          return { success: false, error: 'Invalid assigned representative' };
        }

        // Handle tenant-related errors
        if (error?.message?.includes('tenant')) {
          return { success: false, error: 'Unable to determine organization. Please contact support.' };
        }

        return { success: false, error: error?.message };
      }

      return { success: true, data };
    } catch (error) {
      console.error('Service create error:', error);
      return { success: false, error: 'Failed to create account' };
    }
  },

  // Update an existing account
  async updateAccount(accountId, updates) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      const { data, error } = await supabase?.from('accounts')?.update({ 
        ...updates, 
        updated_at: new Date()?.toISOString() 
      })?.eq('id', accountId)?.select(`
          *,
          assigned_rep:user_profiles(id, full_name, email)
        `)?.single();

      if (error) {
        console.error('Update account error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to update account' };
    }
  },

  // Delete an account
  async deleteAccount(accountId) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      const { error } = await supabase?.from('accounts')?.delete()?.eq('id', accountId);

      if (error) {
        console.error('Delete account error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to delete account' };
    }
  },

  // Bulk update accounts
  async bulkUpdateAccounts(accountIds, updates) {
    if (!accountIds?.length) return { success: false, error: 'No accounts selected' };

    try {
      const { data, error } = await supabase?.from('accounts')?.update({ 
        ...updates, 
        updated_at: new Date()?.toISOString() 
      })?.in('id', accountIds)?.select();

      if (error) {
        console.error('Bulk update error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data, count: data?.length || 0 };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to update accounts' };
    }
  },

  // Get account statistics
  async getAccountStats(filters = {}) {
    try {
      let query = supabase?.from('accounts')?.select('stage, company_type');

      if (!filters?.showInactive) {
        query = query?.eq('is_active', true);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Stats query error:', error);
        return { success: false, error: error?.message };
      }

      // Calculate statistics
      const stats = {
        total: data?.length || 0,
        byStage: {},
        byCompanyType: {},
      };

      data?.forEach(account => {
        // Count by stage
        if (account?.stage) {
          stats.byStage[account.stage] = (stats?.byStage?.[account?.stage] || 0) + 1;
        }

        // Count by company type
        if (account?.company_type) {
          stats.byCompanyType[account.company_type] = (stats?.byCompanyType?.[account?.company_type] || 0) + 1;
        }
      });

      return { success: true, data: stats };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load account statistics' };
    }
  },
};