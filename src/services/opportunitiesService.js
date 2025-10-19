import { supabase } from '../lib/supabaseClient';

export const opportunitiesService = {
  // Get opportunity types (static data from enum)
  getOpportunityTypes() {
    return [
      { value: 'new_construction', label: 'New Construction' },
      { value: 'inspection', label: 'Inspection' },
      { value: 'repair', label: 'Repair' },
      { value: 'maintenance', label: 'Maintenance' },
      { value: 're_roof', label: 'Re-roof' }
    ];
  },

  // Get opportunity stages (static data from enum)
  getOpportunityStages() {
    return [
      { value: 'identified', label: 'Identified' },
      { value: 'qualified', label: 'Qualified' },
      { value: 'proposal_sent', label: 'Proposal Sent' },
      { value: 'negotiation', label: 'Negotiation' },
      { value: 'won', label: 'Won' },
      { value: 'lost', label: 'Lost' }
    ];
  },

  // FIXED: Get all opportunities with proper error handling and comprehensive data loading
  async getOpportunities(filters = {}) {
    try {
      console.log('🔍 Loading opportunities from database...');

      // Get current user for RLS compliance
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('❌ Authentication required for opportunities:', userError);
        return { success: false, error: 'Authentication required', data: [], totalCount: 0 };
      }

      console.log('✅ Authenticated user ID:', user?.id);

      // CRITICAL FIX: Simplified direct query to avoid RLS and complex function issues
      let query = supabase?.from('opportunities')?.select(`
          *,
          account:accounts(id, name, company_type, stage as account_stage),
          property:properties(id, name, building_type, address, city, state),
          contact:contacts(id, first_name, last_name, email),
          assigned_rep:user_profiles!opportunities_assigned_rep_id_fkey(id, full_name, email),
          creator:user_profiles!opportunities_created_by_fkey(id, full_name, email)
        `, { count: 'exact' });

      // Apply basic filters from parameters
      const {
        stage = null,
        opportunity_type = null,
        assignedTo = null,
        searchTerm = null,
        sortBy = 'created_at',
        sortDirection = 'desc',
        limit = 50,
        offset = 0
      } = filters;

      // Apply stage filter
      if (stage && Array.isArray(stage) && stage?.length > 0) {
        query = query?.in('stage', stage);
      } else if (stage && typeof stage === 'string') {
        query = query?.eq('stage', stage);
      }

      // Apply opportunity type filter
      if (opportunity_type) {
        query = query?.eq('opportunity_type', opportunity_type);
      }

      // Apply assigned rep filter
      if (assignedTo === 'me') {
        query = query?.eq('assigned_rep_id', user?.id);
      } else if (assignedTo === 'unassigned') {
        query = query?.is('assigned_rep_id', null);
      } else if (assignedTo && assignedTo !== 'all') {
        query = query?.eq('assigned_rep_id', assignedTo);
      }

      // Apply search filter
      if (searchTerm && searchTerm?.trim() !== '') {
        const searchValue = searchTerm?.trim();
        query = query?.or(`name.ilike.%${searchValue}%,description.ilike.%${searchValue}%`);
      }

      // Apply sorting
      const validSortColumns = ['name', 'stage', 'bid_value', 'probability', 'expected_close_date', 'created_at'];
      const sortColumn = validSortColumns?.includes(sortBy) ? sortBy : 'created_at';
      query = query?.order(sortColumn, { ascending: sortDirection === 'asc' });

      // Apply pagination
      if (limit && offset !== undefined) {
        query = query?.range(offset, offset + limit - 1);
      }

      console.log('🚀 Executing opportunities query...');
      const { data, error, count } = await query;

      if (error) {
        console.error('❌ Opportunities query error:', error);
        
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
          error: error?.message || 'Failed to load opportunities',
          totalCount: 0
        };
      }

      // Process the actual database data
      const processedData = (data || [])?.map(opportunity => ({
        ...opportunity,
        // Computed fields for UI compatibility
        accountName: opportunity?.account?.name || 'No Account',
        propertyName: opportunity?.property?.name || null,
        propertyAddress: opportunity?.property ? 
          `${opportunity?.property?.address || ''}, ${opportunity?.property?.city || ''}, ${opportunity?.property?.state || ''}`?.replace(/^,\s*|,\s*$/g, '') || 'Property Address' 
          : null,
        contactName: opportunity?.contact ? 
          `${opportunity?.contact?.first_name || ''} ${opportunity?.contact?.last_name || ''}`?.trim() || opportunity?.contact?.email 
          : null,
        assignedRepName: opportunity?.assigned_rep?.full_name || 'Unassigned',
        creatorName: opportunity?.creator?.full_name || 'Unknown',
        
        // Value formatting for UI
        formattedBidValue: opportunity?.bid_value ? `$${Number(opportunity?.bid_value)?.toLocaleString()}` : null,
        probabilityDisplay: opportunity?.probability ? `${opportunity?.probability}%` : null,
        
        // Status indicators
        isHighValue: opportunity?.bid_value && Number(opportunity?.bid_value) >= 100000,
        isHighProbability: opportunity?.probability && Number(opportunity?.probability) >= 75,
        daysToClose: opportunity?.expected_close_date ? 
          Math.ceil((new Date(opportunity?.expected_close_date) - new Date()) / (1000 * 60 * 60 * 24)) 
          : null,
        
        // Flags for UI
        hasProperty: !!opportunity?.property,
        hasContact: !!opportunity?.contact,
        hasAssignedRep: !!opportunity?.assigned_rep
      }));

      console.log(`✅ Opportunities loaded successfully: ${processedData?.length} items (total: ${count})`);
      
      // Log sample of actual data structure
      if (processedData?.length > 0) {
        console.log('📊 Sample opportunity data:', {
          id: processedData?.[0]?.id,
          name: processedData?.[0]?.name,
          stage: processedData?.[0]?.stage,
          bid_value: processedData?.[0]?.formattedBidValue,
          account: processedData?.[0]?.accountName,
          property: processedData?.[0]?.propertyName
        });
      }

      return {
        success: true,
        data: processedData,
        error: null,
        totalCount: count || processedData?.length || 0
      };
    } catch (error) {
      console.error('❌ Opportunities service error:', error);
      
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
        error: error?.message || 'Failed to load opportunities from database',
        totalCount: 0
      };
    }
  },

  // FIXED: Get single opportunity by ID with comprehensive data
  async getOpportunity(opportunityId) {
    if (!opportunityId) return { success: false, error: 'Opportunity ID is required' };

    try {
      console.log('🔍 Fetching opportunity by ID:', opportunityId);

      const { data, error } = await supabase?.from('opportunities')?.select(`
          *,
          account:accounts(id, name, company_type, stage, email, phone, city, state),
          property:properties(id, name, building_type, address, city, state, square_footage),
          contact:contacts(id, first_name, last_name, email, phone, title),
          assigned_rep:user_profiles!opportunities_assigned_rep_id_fkey(id, full_name, email, phone),
          creator:user_profiles!opportunities_created_by_fkey(id, full_name, email),
          activities(id, activity_type, activity_date, subject, outcome, notes)
        `)?.eq('id', opportunityId)?.single();

      if (error) {
        console.error('❌ Error fetching opportunity:', error);
        
        if (error?.code === 'PGRST116') {
          return { success: false, error: 'Opportunity not found' };
        }
        
        return { success: false, error: error?.message || 'Failed to fetch opportunity' };
      }

      if (!data) {
        return { success: false, error: 'Opportunity not found' };
      }

      // Transform data for UI compatibility
      const transformedOpportunity = {
        ...data,
        accountName: data?.account?.name || 'No Account',
        propertyName: data?.property?.name || null,
        contactName: data?.contact ? 
          `${data?.contact?.first_name || ''} ${data?.contact?.last_name || ''}`?.trim() 
          : null,
        assignedRepName: data?.assigned_rep?.full_name || 'Unassigned',
        formattedBidValue: data?.bid_value ? `$${Number(data?.bid_value)?.toLocaleString()}` : '$0',
        recentActivities: (data?.activities || [])?.sort((a, b) => 
          new Date(b?.activity_date) - new Date(a?.activity_date)
        )?.slice(0, 5)
      };

      console.log('✅ Opportunity loaded:', transformedOpportunity?.name);
      return { success: true, data: transformedOpportunity };
    } catch (error) {
      console.error('❌ Get opportunity error:', error);
      return { success: false, error: 'Failed to load opportunity details' };
    }
  },

  // FIXED: Get opportunity statistics with better error handling
  async getOpportunityStats() {
    try {
      console.log('📊 Loading opportunity statistics...');

      // Simple query to get all opportunities for statistics
      const { data, error } = await supabase
        ?.from('opportunities')
        ?.select('stage, bid_value, probability, expected_close_date');

      if (error) {
        console.error('❌ Error getting opportunity stats:', error);
        return { success: false, data: {}, error: error?.message };
      }

      // Calculate statistics from actual data
      const now = new Date();
      const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

      const stats = {
        total: data?.length || 0,
        byStage: {},
        totalValue: 0,
        averageValue: 0,
        highProbability: 0,
        closingThisMonth: 0,
        overdue: 0
      };

      (data || [])?.forEach(opportunity => {
        // Count by stage
        const stage = opportunity?.stage || 'prospect';
        stats.byStage[stage] = (stats?.byStage?.[stage] || 0) + 1;

        // Value calculations
        const bidValue = Number(opportunity?.bid_value) || 0;
        stats.totalValue += bidValue;

        // High probability count (>= 75%)
        if (opportunity?.probability >= 75) {
          stats.highProbability += 1;
        }

        // Closing this month
        if (opportunity?.expected_close_date) {
          const closeDate = new Date(opportunity?.expected_close_date);
          if (closeDate >= thisMonth && closeDate < nextMonth) {
            stats.closingThisMonth += 1;
          }
          // Overdue opportunities
          if (closeDate < now && opportunity?.stage !== 'won' && opportunity?.stage !== 'lost') {
            stats.overdue += 1;
          }
        }
      });

      // Calculate average
      if (stats?.total > 0) {
        stats.averageValue = stats?.totalValue / stats?.total;
      }

      // Format values for display
      stats.formattedTotalValue = `$${stats?.totalValue?.toLocaleString()}`;
      stats.formattedAverageValue = `$${Math.round(stats?.averageValue)?.toLocaleString()}`;

      console.log('✅ Opportunity stats calculated:', stats);
      return { success: true, data: stats };
    } catch (error) {
      console.error('❌ Get opportunity stats error:', error);
      return { success: false, data: {}, error: 'Failed to get opportunity statistics' };
    }
  },

  // Get opportunities by account ID
  async getOpportunitiesByAccount(accountId) {
    if (!accountId) return { success: false, error: 'Account ID is required', data: [] };

    try {
      console.log('🔍 Loading opportunities for account:', accountId);

      const { data, error } = await supabase
        ?.from('opportunities')
        ?.select(`
          *,
          property:properties(id, name),
          contact:contacts(id, first_name, last_name),
          assigned_rep:user_profiles(id, full_name)
        `)
        ?.eq('account_id', accountId)
        ?.order('created_at', { ascending: false });

      if (error) {
        console.error('❌ Get opportunities by account error:', error);
        return { success: false, error: error?.message, data: [] };
      }

      console.log(`✅ Account opportunities loaded: ${data?.length} items`);
      return { success: true, data: data || [] };
    } catch (error) {
      console.error('❌ Get opportunities by account service error:', error);
      return { success: false, error: 'Failed to load account opportunities', data: [] };
    }
  },

  // FIXED: Pipeline metrics with direct data processing
  async getPipelineMetrics() {
    try {
      console.log('📊 Loading pipeline metrics...');
      
      // Get all opportunities for metrics calculation
      const { data, error } = await supabase
        ?.from('opportunities')
        ?.select('stage, bid_value, probability');

      if (error) {
        console.error('❌ Pipeline metrics error:', error);
        return { 
          success: false,
          data: [], 
          error: error?.message || 'Failed to fetch pipeline metrics'
        };
      }

      // Calculate metrics by stage from actual data
      const stageMetrics = {};
      
      (data || [])?.forEach(opp => {
        const stage = opp?.stage || 'identified';
        if (!stageMetrics?.[stage]) {
          stageMetrics[stage] = {
            count_opportunities: 0,
            total_value: 0,
            total_probability: 0
          };
        }
        
        stageMetrics[stage].count_opportunities += 1;
        stageMetrics[stage].total_value += parseFloat(opp?.bid_value || 0);
        stageMetrics[stage].total_probability += parseFloat(opp?.probability || 0);
      });

      // Transform to expected format
      const transformedData = Object.keys(stageMetrics)?.map(stage => {
        const metrics = stageMetrics?.[stage];
        const stageInfo = this.getOpportunityStages()?.find(s => s?.value === stage);
        
        return {
          stage,
          label: stageInfo?.label || stage?.replace(/_/g, ' ')?.replace(/\b\w/g, l => l?.toUpperCase()),
          count_opportunities: metrics?.count_opportunities,
          total_value: metrics?.total_value,
          avg_probability: metrics?.count_opportunities > 0 
            ? metrics?.total_probability / metrics?.count_opportunities 
            : 0
        };
      });

      // Ensure all stages are represented
      const allStages = this.getOpportunityStages();
      const completeMetrics = allStages?.map(stageInfo => {
        const existingMetric = transformedData?.find(m => m?.stage === stageInfo?.value);
        return existingMetric || {
          stage: stageInfo?.value,
          label: stageInfo?.label,
          count_opportunities: 0,
          total_value: 0,
          avg_probability: 0
        };
      });

      console.log(`✅ Pipeline metrics calculated: ${completeMetrics?.length} stages`);
      console.log('📊 Total opportunities in pipeline:', data?.length);
      
      return { success: true, data: completeMetrics, error: null };
    } catch (error) {
      console.error('❌ getPipelineMetrics error:', error);
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to load pipeline metrics'
      };
    }
  },

  // FIXED: Get single opportunity with proper error handling
  async getOpportunityById(opportunityId) {
    try {
      if (!opportunityId) {
        return { success: false, data: null, error: 'Opportunity ID is required' };
      }

      console.log('🔍 Fetching opportunity by ID:', opportunityId);

      const { data, error } = await supabase?.from('opportunities')?.select(`
          *,
          account:accounts(id, name, company_type, email, phone),
          property:properties(id, name, building_type, address, square_footage),
          assigned_rep:user_profiles!assigned_to(id, full_name, email)
        `)?.eq('id', opportunityId)?.single();

      if (error) {
        console.error('❌ Error fetching opportunity:', error);
        
        if (error?.code === 'PGRST116') {
          return { success: false, data: null, error: 'Opportunity not found' };
        }
        
        return { success: false, data: null, error: error?.message || 'Failed to fetch opportunity' };
      }

      console.log('✅ Opportunity loaded:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('❌ Get opportunity error:', error);
      return { 
        success: false,
        data: null, 
        error: error?.message || 'Opportunity not found'
      };
    }
  },

  // Create new opportunity with logging
  async createOpportunity(opportunityData) {
    try {
      console.log('🆕 Creating new opportunity...');
      
      // Validate required fields
      if (!opportunityData?.name || !opportunityData?.opportunity_type) {
        return { success: false, data: null, error: 'Opportunity name and type are required' };
      }

      // Process numeric fields
      const processedData = {
        ...opportunityData,
        bid_value: opportunityData?.bid_value ? parseFloat(opportunityData?.bid_value) : null,
        probability: opportunityData?.probability ? parseInt(opportunityData?.probability) : null,
      };

      const { data, error } = await supabase?.from('opportunities')?.insert([processedData])?.select(`
          *,
          account:accounts(id, name, company_type),
          property:properties(id, name, building_type, address),
          assigned_rep:user_profiles!assigned_to(id, full_name, email)
        `)?.single();

      if (error) {
        console.error('❌ Error creating opportunity:', error);
        return { success: false, data: null, error: error?.message || 'Failed to create opportunity' };
      }

      console.log('✅ Opportunity created:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('❌ Create opportunity error:', error);
      return { 
        success: false,
        data: null, 
        error: error?.message || 'Failed to create opportunity'
      };
    }
  },

  // Update existing opportunity
  async updateOpportunity(opportunityId, updates) {
    try {
      if (!opportunityId) {
        return { success: false, data: null, error: 'Opportunity ID is required' };
      }

      console.log('🔄 Updating opportunity:', opportunityId);

      // Process numeric fields
      const processedUpdates = { ...updates };
      if (processedUpdates?.bid_value !== undefined) {
        processedUpdates.bid_value = processedUpdates?.bid_value ? parseFloat(processedUpdates?.bid_value) : null;
      }
      if (processedUpdates?.probability !== undefined) {
        processedUpdates.probability = processedUpdates?.probability ? parseInt(processedUpdates?.probability) : null;
      }

      const { data, error } = await supabase?.from('opportunities')?.update(processedUpdates)?.eq('id', opportunityId)?.select(`
          *,
          account:accounts(id, name, company_type),
          property:properties(id, name, building_type, address),
          assigned_rep:user_profiles!assigned_to(id, full_name, email)
        `)?.single();

      if (error) {
        console.error('❌ Error updating opportunity:', error);
        return { success: false, data: null, error: error?.message || 'Failed to update opportunity' };
      }

      console.log('✅ Opportunity updated:', data?.name);
      return { success: true, data, error: null };
    } catch (error) {
      console.error('❌ Update opportunity error:', error);
      return { 
        success: false,
        data: null, 
        error: error?.message || 'Failed to update opportunity'
      };
    }
  },

  // Delete opportunity
  async deleteOpportunity(opportunityId) {
    try {
      if (!opportunityId) {
        return { success: false, error: 'Opportunity ID is required' };
      }

      console.log('🗑️ Deleting opportunity:', opportunityId);

      const { error } = await supabase?.from('opportunities')?.delete()?.eq('id', opportunityId);

      if (error) {
        console.error('❌ Error deleting opportunity:', error);
        return { success: false, error: error?.message || 'Failed to delete opportunity' };
      }

      console.log('✅ Opportunity deleted successfully');
      return { success: true, error: null };
    } catch (error) {
      console.error('❌ Delete opportunity error:', error);
      return { 
        success: false,
        error: error?.message || 'Failed to delete opportunity'
      };
    }
  },

  // Get available accounts for dropdown
  async getAvailableAccounts() {
    try {
      const { data, error } = await supabase?.from('accounts')?.select('id, name, company_type, city, state')?.eq('is_active', true)?.order('name');

      if (error) {
        console.error('❌ Error fetching accounts:', error);
        return { success: false, data: [], error: error?.message || 'Failed to fetch accounts' };
      }

      return { success: true, data: data || [], error: null };
    } catch (error) {
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to fetch accounts'
      };
    }
  },

  // Get available properties for dropdown
  async getAvailableProperties() {
    try {
      const { data, error } = await supabase?.from('properties')?.select('id, name, building_type, address, city, state, account:accounts(id, name)')?.order('name');

      if (error) {
        console.error('❌ Error fetching properties:', error);
        return { success: false, data: [], error: error?.message || 'Failed to fetch properties' };
      }

      return { success: true, data: data || [], error: null };
    } catch (error) {
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to fetch properties'
      };
    }
  },

  // Get available sales reps for assignment
  async getAvailableReps() {
    try {
      const { data, error } = await supabase?.from('user_profiles')?.select('id, full_name, email, role')?.in('role', ['rep', 'manager'])?.eq('is_active', true)?.order('full_name');

      if (error) {
        console.error('❌ Error fetching representatives:', error);
        return { success: false, data: [], error: error?.message || 'Failed to fetch representatives' };
      }

      return { success: true, data: data || [], error: null };
    } catch (error) {
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to fetch representatives'
      };
    }
  },

  // Utility methods
  calculateWeightedValue(bidValue, probability) {
    const value = parseFloat(bidValue) || 0;
    const prob = parseInt(probability) || 0;
    if (!value || !prob) return 0;
    return (value * prob) / 100;
  },

  formatBidValue(value, currency = 'USD') {
    const numValue = parseFloat(value) || 0;
    if (numValue === 0) return '$0';
    
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency || 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    })?.format(numValue);
  },

  getStageProgress(stage) {
    const stageProgressMap = {
      'identified': 20,
      'qualified': 40,
      'proposal_sent': 60,
      'negotiation': 80,
      'won': 100,
      'lost': 0
    };
    return stageProgressMap?.[stage] || 0;
  }
};

export default opportunitiesService;