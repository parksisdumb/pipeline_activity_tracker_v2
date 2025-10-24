import { supabase } from '../lib/supabaseClient';

const getUserContext = async () => {
  try {
    const { data: { user }, error: userError } = await supabase?.auth?.getUser();
    if (userError || !user) {
      return {
        success: false,
        error: userError?.message || 'Authentication required',
        user: null,
        tenantId: null,
        role: null
      };
    }

    const { data: profileValidation, error: validationError } = await supabase
      ?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

    if (validationError) {
      return {
        success: false,
        error: validationError?.message || 'Failed to validate user profile',
        user: null,
        tenantId: null,
        role: null
      };
    }

    if (!profileValidation?.success || !profileValidation?.user_data) {
      return {
        success: false,
        error: profileValidation?.message || 'User profile not properly configured',
        user: null,
        tenantId: null,
        role: null
      };
    }

    const userData = profileValidation?.user_data || {};

    return {
      success: true,
      user: userData,
      tenantId: userData?.tenant_id || null,
      role: userData?.role || null
    };
  } catch (error) {
    console.error('Prospects service context error:', error);
    return {
      success: false,
      error: error?.message || 'Failed to resolve user context',
      user: null,
      tenantId: null,
      role: null
    };
  }
};

export const prospectsService = {
  // FIXED: Get all prospects with proper error handling and RLS compliance
  async getProspects(filters = {}) {
    try {
      console.log('Loading prospects from database...');

      const { success, user, tenantId, error: contextError } = await getUserContext();
      if (!success || !user) {
        console.error('Prospects context error:', contextError);
        return { success: false, error: contextError || 'Authentication required', data: [], totalCount: 0 };
      }

      if (!tenantId) {
        console.error('Prospects service: missing tenant id for user', user?.id);
        return { success: false, error: 'Tenant context missing for current user', data: [], totalCount: 0 };
      }

      console.log('Authenticated user ID:', user?.id, 'Tenant:', tenantId);

      // CRITICAL FIX: Use direct query without complex filtering that might cause RLS issues
      let query = supabase?.from('prospects')?.select(`
        *,
        assigned_user:user_profiles!prospects_assigned_to_fkey(id, full_name, email),
        creator:user_profiles!prospects_created_by_fkey(id, full_name, email)
      `, { count: 'exact' });

      // Apply basic filters only
      const {
        status = null,
        assignedFilter = 'any',
        searchTerm = null,
        limit = 50,
        offset = 0
      } = filters;

      query = query?.eq('tenant_id', tenantId);

      // Apply status filter if provided
      if (status && Array.isArray(status) && status?.length > 0) {
        query = query?.in('status', status);
      }

      // Apply assigned filter
      if (assignedFilter === 'me') {
        query = query?.eq('assigned_to', user?.id);
      } else if (assignedFilter === 'unassigned') {
        query = query?.is('assigned_to', null);
      }

      // Apply search if provided
      if (searchTerm && searchTerm?.trim() !== '') {
        const searchValue = searchTerm?.trim();
        query = query?.or(`name.ilike.%${searchValue}%,domain.ilike.%${searchValue}%`);
      }

      // Apply sorting and pagination
      query = query?.order('created_at', { ascending: false });
      
      if (limit && offset !== undefined) {
        query = query?.range(offset, offset + limit - 1);
      }

      console.log('Executing prospects query...');
      const { data, error, count } = await query;

      if (error) {
        console.error('❌ Prospects query error:', error);
        
        // Handle specific RLS policy errors
        if (error?.message?.includes('RLS')) {
          return { 
            success: false,
            data: [], 
            error: 'Access denied. Please check your user permissions.',
            totalCount: 0
          };
        }
        
        return { 
          success: false,
          data: [], 
          error: error?.message || 'Failed to load prospects',
          totalCount: 0
        };
      }

      // Process the actual database data
      const processedData = (data || [])?.map(prospect => ({
        ...prospect,
        assigned_to_name: prospect?.assigned_user?.full_name || null,
        has_phone: !!prospect?.phone,
        has_website: !!prospect?.website,
        creator_name: prospect?.creator?.full_name || 'Unknown'
      }));

      console.log(`✅ Prospects loaded successfully: ${processedData?.length} items (total: ${count})`);
      
      // Log sample of actual data structure
      if (processedData?.length > 0) {
        console.log('📊 Sample prospect data:', {
          id: processedData?.[0]?.id,
          name: processedData?.[0]?.name,
          status: processedData?.[0]?.status,
          assigned_to: processedData?.[0]?.assigned_to_name
        });
      }

      return {
        success: true,
        data: processedData,
        error: null,
        totalCount: count || processedData?.length || 0
      };
    } catch (error) {
      console.error('❌ Prospects service error:', error);
      
      if (error?.message?.includes('Failed to fetch') || error?.message?.includes('NetworkError')) {
        return { 
          success: false,
          data: [], 
          error: 'Cannot connect to database. Please check your Supabase project status.',
          totalCount: 0
        };
      }
      
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to load prospects from database',
        totalCount: 0
      };
    }
  },

  // FIXED: Get prospect statistics with better error handling
  async getProspectStats() {
    try {
      console.log('📊 Loading prospect statistics...');
      
      const { success, tenantId, error: contextError } = await getUserContext();
      if (!success || !tenantId) {
        console.error('Prospect stats context error:', contextError);
        return { success: false, data: {}, error: contextError || 'Authentication required' };
      }

      const { data, error } = await supabase
        ?.from('prospects')
        ?.select('status, id')
        ?.eq('tenant_id', tenantId);

      if (error) {
        console.error('❌ Error getting prospect stats:', error);
        return { success: false, data: {}, error: error?.message };
      }

      // Count by status from actual data
      const counts = (data || [])?.reduce((acc, prospect) => {
        const status = prospect?.status || 'uncontacted';
        acc[status] = (acc?.[status] || 0) + 1;
        acc.total = (acc?.total || 0) + 1;
        return acc;
      }, {});

      console.log('✅ Prospect stats calculated:', counts);
      return { success: true, data: counts, error: null };
    } catch (error) {
      console.error('❌ Get prospect stats error:', error);
      return { success: false, data: {}, error: 'Failed to get prospect statistics' };
    }
  },

  // FIXED: Get single prospect by ID with proper validation
  async getProspect(id) {
    try {
      if (!id) {
        return { success: false, data: null, error: 'Prospect ID is required' };
      }
      
      console.log('🔍 Fetching prospect by ID:', id);

      const { success, tenantId, error: contextError } = await getUserContext();
      if (!success || !tenantId) {
        console.error('Prospect detail context error:', contextError);
        return { success: false, data: null, error: contextError || 'Authentication required' };
      }

      const { data, error } = await supabase
        ?.from('prospects')
        ?.select(`
          *,
          assigned_user:user_profiles!prospects_assigned_to_fkey(id, full_name, email),
          creator:user_profiles!prospects_created_by_fkey(id, full_name, email)
        `)
        ?.eq('id', id)?.eq('tenant_id', tenantId)
        ?.single();

      if (error) {
        console.error('❌ Error fetching prospect:', error);
        
        if (error?.code === 'PGRST116') {
          return { success: false, data: null, error: 'Prospect not found' };
        }
        
        return { success: false, data: null, error: error?.message || 'Failed to fetch prospect' };
      }

      if (!data) {
        return { success: false, data: null, error: 'Prospect not found' };
      }

      console.log('✅ Prospect loaded:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('❌ Get prospect error:', error);
      return { success: false, data: null, error: 'Failed to load prospect details' };
    }
  },

  // Other methods remain the same but with improved logging...
  async createProspect(prospectData) {
    try {
      console.log('Creating new prospect...');
      
      const { success, user, tenantId, error: contextError } = await getUserContext();
      if (!success || !user) {
        return { success: false, data: null, error: contextError || 'Authentication required' };
      }

      if (!tenantId) {
        return { success: false, data: null, error: 'Tenant context missing for current user' };
      }

      const { data, error } = await supabase
        ?.from('prospects')
        ?.insert([{
          ...prospectData,
          created_by: user?.id,
          tenant_id: tenantId
        }])
        ?.select()
        ?.single();

      if (error) {
        console.error('Error creating prospect:', error);
        return { success: false, data: null, error: error?.message };
      }

      console.log('Prospect created:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('Create prospect error:', error);
      return { success: false, data: null, error: 'Failed to create prospect' };
    }
  },

  async updateProspect(id, updates) {
    try {
      console.log('Updating prospect:', id);

      const { success, tenantId, error: contextError } = await getUserContext();
      if (!success || !tenantId) {
        return { success: false, data: null, error: contextError || 'Authentication required' };
      }
      
      const { data, error } = await supabase
        ?.from('prospects')
        ?.update({
          ...updates,
          last_activity_at: new Date()?.toISOString()
        })
        ?.eq('id', id)
        ?.eq('tenant_id', tenantId)
        ?.select()
        ?.single();

      if (error) {
        console.error('Error updating prospect:', error);
        return { success: false, data: null, error: error?.message };
      }

      console.log('Prospect updated:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('Update prospect error:', error);
      return { success: false, data: null, error: 'Failed to update prospect' };
    }
  },

  // Alias methods for compatibility
  async listProspects(filters = {}, sort = {}, pagination = {}) {
    const combinedFilters = {
      ...filters,
      sortBy: sort?.column || 'created_at',
      sortDirection: sort?.direction || 'desc',
      limit: pagination?.limit || 50,
      offset: pagination?.offset || 0
    };
    return await this.getProspects(combinedFilters);
  },

  async getProspectCounts() {
    return await this.getProspectStats();
  },

  async claimProspect(id) {
    try {
      const { data: { user } } = await supabase?.auth?.getUser();
      if (!user) {
        return { success: false, data: null, error: 'Authentication required' };
      }

      return await this.updateProspect(id, { assigned_to: user?.id });
    } catch (error) {
      return { success: false, data: null, error: 'Failed to claim prospect' };
    }
  },

  async updateStatus(id, status, notes = null) {
    const updates = { status };
    if (notes) updates.notes = notes;
    return await this.updateProspect(id, updates);
  },

  async deleteProspect(id) {
    try {
      console.log('Deleting prospect:', id);

      const { success, tenantId, error: contextError } = await getUserContext();
      if (!success || !tenantId) {
        return { success: false, error: contextError || 'Authentication required' };
      }
      
      const { error } = await supabase
        ?.from('prospects')
        ?.delete()
        ?.eq('id', id)
        ?.eq('tenant_id', tenantId);

      if (error) {
        console.error('Error deleting prospect:', error);
        return { success: false, error: error?.message };
      }

      console.log('Prospect deleted successfully');
      return { success: true, error: null };
    } catch (error) {
      console.error('Delete prospect error:', error);
      return { success: false, error: 'Failed to delete prospect' };
    }
  }
};

export default prospectsService;

