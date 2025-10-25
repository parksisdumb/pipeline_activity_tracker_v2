import { supabase } from '../lib/supabaseClient';

export const propertiesService = {
  // FIXED: Get all properties with proper error handling and comprehensive data loading
  async getProperties(filters = {}) {
    try {
      console.log('🔍 Loading properties from database...');

      // Get current user for RLS compliance
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('❌ Authentication required for properties:', userError);
        return { success: false, error: 'Authentication required', data: [], totalCount: 0 };
      }

      console.log('✅ Authenticated user ID:', user?.id);

      // CRITICAL FIX: Validate user profile to enforce tenant isolation
      const {
        data: profileValidation,
        error: validationError,
      } = await supabase?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

      if (validationError) {
        console.error('✖ Failed to validate user profile for properties:', validationError);
        return {
          success: false,
          error: 'Failed to validate user permissions.',
          data: [],
          totalCount: 0,
        };
      }

      if (!profileValidation?.success || !profileValidation?.user_data?.tenant_id) {
        console.error('Tenant validation failed for properties:', profileValidation);
        return {
          success: false,
          error: 'Tenant information missing. Please contact support.',
          data: [],
          totalCount: 0,
        };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      // Tenant-scoped query
      let query = supabase?.from('properties')?.select(`
          *,
          account:accounts(id, name, company_type, stage, email, phone),
          contacts:contacts(count),
          opportunities:opportunities(count)
        `, { count: 'exact' })?.eq('tenant_id', tenantId);

      // Apply filters from parameters
      const {
        accountId = null,
        buildingType = null,
        stage = null,
        searchTerm = null,
        sortBy = 'name',
        sortDirection = 'asc',
        limit = 50,
        offset = 0,
        showInactive = false
      } = filters;

      // Apply account filter
      if (accountId) {
        query = query?.eq('account_id', accountId);
      }

      // Apply building type filter
      if (buildingType) {
        query = query?.eq('building_type', buildingType);
      }

      // Apply stage filter
      if (stage) {
        query = query?.eq('stage', stage);
      }

      // Apply search filter
      if (searchTerm && searchTerm?.trim() !== '') {
        const searchValue = searchTerm?.trim();
        query = query?.or(`name.ilike.%${searchValue}%,address.ilike.%${searchValue}%,city.ilike.%${searchValue}%`);
      }

      // Apply active filter
      // NOTE: Legacy schemas might not include an is_active column.
      // We filter client-side below when the flag exists.

      // Apply sorting
      const validSortColumns = ['name', 'building_type', 'stage', 'city', 'state', 'created_at'];
      const sortColumn = validSortColumns?.includes(sortBy) ? sortBy : 'name';
      query = query?.order(sortColumn, { ascending: sortDirection === 'asc' });

      // Apply pagination
      if (limit && offset !== undefined) {
        query = query?.range(offset, offset + limit - 1);
      }

      console.log('🚀 Executing properties query...');
      const { data, error, count } = await query;

      if (error) {
        console.error('❌ Properties query error:', error);
        
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
          error: error?.message || 'Failed to load properties',
          totalCount: 0
        };
      }

      // Process the actual database data
      let processedData = (data || [])?.map(property => ({
        ...property,
        // Computed fields for UI compatibility
        accountName: property?.account?.name || 'No Account',
        fullAddress: property?.address && property?.city && property?.state ? 
          `${property?.address}, ${property?.city}, ${property?.state}` : 
          property?.address || 'Address Not Available',
        
        // Count fields from join
        contactsCount: property?.contacts?.[0]?.count || 0,
        opportunitiesCount: property?.opportunities?.[0]?.count || 0,
        
        // Format square footage
        formattedSquareFootage: property?.square_footage ? 
          `${Number(property?.square_footage)?.toLocaleString()} sq ft` : 
          null,
        
        // Status indicators
        hasAccount: !!property?.account,
        hasContacts: (property?.contacts?.[0]?.count || 0) > 0,
        hasOpportunities: (property?.opportunities?.[0]?.count || 0) > 0,
        
        // Year built formatting
        buildYear: property?.year_built || null,
        propertyAge: property?.year_built ? 
          new Date()?.getFullYear() - property?.year_built : 
          null
      }));

      if (!showInactive) {
        const hasIsActiveColumn = processedData?.some(prop => Object.prototype.hasOwnProperty.call(prop, 'is_active'));
        if (hasIsActiveColumn) {
          processedData = processedData?.filter(property => property?.is_active !== false);
        }
      }

      console.log(`✅ Properties loaded successfully: ${processedData?.length} items (total: ${count})`);
      
      // Log sample of actual data structure
      if (processedData?.length > 0) {
        console.log('📊 Sample property data:', {
          id: processedData?.[0]?.id,
          name: processedData?.[0]?.name,
          building_type: processedData?.[0]?.building_type,
          account: processedData?.[0]?.accountName,
          address: processedData?.[0]?.fullAddress
        });
      }

      return {
        success: true,
        data: processedData,
        error: null,
        totalCount: count || processedData?.length || 0
      };
    } catch (error) {
      console.error('❌ Properties service error:', error);
      
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
        error: error?.message || 'Failed to load properties from database',
        totalCount: 0
      };
    }
  },

  // FIXED: Get single property by ID with comprehensive data
  async getProperty(propertyId) {
    if (!propertyId) return { success: false, error: 'Property ID is required' };

    try {
      console.log('🔍 Fetching property by ID:', propertyId);

      const {
        data: { user },
        error: userError,
      } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('✖ Authentication required for property details:', userError);
        return { success: false, error: 'Authentication required' };
      }

      const {
        data: profileValidation,
        error: validationError,
      } = await supabase?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

      if (validationError) {
        console.error('✖ Failed to validate user profile for property details:', validationError);
        return { success: false, error: 'Failed to validate user permissions' };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      const { data, error } = await supabase
        ?.from('properties')
        ?.select(`
          *,
          account:accounts(id, name, company_type, stage, email, phone, city, state),
          contacts(id, first_name, last_name, email, phone, title, is_primary_contact),
          opportunities(id, name, stage, bid_value, probability, expected_close_date),
          activities(id, activity_type, activity_date, subject, outcome, notes)
        `)
        ?.eq('id', propertyId)
        ?.eq('tenant_id', tenantId)
        ?.single();

      if (error) {
        console.error('❌ Error fetching property:', error);
        
        if (error?.code === 'PGRST116') {
          return { success: false, error: 'Property not found' };
        }
        
        return { success: false, error: error?.message || 'Failed to fetch property' };
      }

      if (!data) {
        return { success: false, error: 'Property not found' };
      }

      // Transform data for UI compatibility
      const transformedProperty = {
        ...data,
        accountName: data?.account?.name || 'No Account',
        fullAddress: data?.address && data?.city && data?.state ? 
          `${data?.address}, ${data?.city}, ${data?.state}` : 
          data?.address || 'Address Not Available',
        primaryContact: data?.contacts?.find(c => c?.is_primary_contact),
        contactsCount: data?.contacts?.length || 0,
        opportunitiesCount: data?.opportunities?.length || 0,
        activitiesCount: data?.activities?.length || 0,
        formattedSquareFootage: data?.square_footage ? 
          `${Number(data?.square_footage)?.toLocaleString()} sq ft` : 
          'Not specified',
        recentActivities: (data?.activities || [])?.sort((a, b) => 
          new Date(b?.activity_date) - new Date(a?.activity_date)
        )?.slice(0, 5),
        activeOpportunities: (data?.opportunities || [])?.filter(opp => 
          opp?.stage !== 'won' && opp?.stage !== 'lost'
        )
      };

      console.log('✅ Property loaded:', transformedProperty?.name);
      return { success: true, data: transformedProperty };
    } catch (error) {
      console.error('❌ Get property error:', error);
      return { success: false, error: 'Failed to load property details' };
    }
  },

  // FIXED: Get property statistics with better error handling
  async getPropertyStats() {
    try {
      console.log('📊 Loading property statistics...');

      const {
        data: { user },
        error: userError,
      } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('✖ Authentication required for property stats:', userError);
        return { success: false, data: {}, error: 'Authentication required' };
      }

      const {
        data: profileValidation,
        error: validationError,
      } = await supabase?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

      if (validationError) {
        console.error('✖ Failed to validate user profile for property stats:', validationError);
        return { success: false, data: {}, error: 'Failed to validate user permissions' };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      // Simple query to get all properties for statistics
      let { data, error } = await supabase
        ?.from('properties')
        ?.select('building_type, stage, square_footage, is_active')
        ?.eq('tenant_id', tenantId);

      if (error && error?.message?.includes('column') && error?.message?.includes('is_active')) {
        console.warn('is_active column missing from properties; retrying stats query without it');
        const fallback = await supabase
          ?.from('properties')
          ?.select('building_type, stage, square_footage')
          ?.eq('tenant_id', tenantId);
        data = fallback?.data;
        error = fallback?.error;
      }

      if (error) {
        console.error('❌ Error getting property stats:', error);
        return { success: false, data: {}, error: error?.message };
      }

      // Calculate statistics from actual data
      const stats = {
        total: data?.length || 0,
        active: (() => {
          const hasIsActiveColumn = data?.some(prop => Object.prototype.hasOwnProperty.call(prop, 'is_active'));
          if (hasIsActiveColumn) {
            return data?.filter(p => p?.is_active !== false)?.length || 0;
          }
          return data?.length || 0;
        })(),
        byBuildingType: {},
        byStage: {},
        totalSquareFootage: 0,
        averageSquareFootage: 0
      };

      (data || [])?.forEach(property => {
        // Count by building type
        const buildingType = property?.building_type || 'unknown';
        stats.byBuildingType[buildingType] = (stats?.byBuildingType?.[buildingType] || 0) + 1;

        // Count by stage
        const stage = property?.stage || 'prospect';
        stats.byStage[stage] = (stats?.byStage?.[stage] || 0) + 1;

        // Square footage calculations
        const sqft = Number(property?.square_footage) || 0;
        if (sqft > 0) {
          stats.totalSquareFootage += sqft;
        }
      });

      // Calculate average square footage
      const propertiesWithSqft = data?.filter(p => Number(p?.square_footage) > 0)?.length || 0;
      if (propertiesWithSqft > 0) {
        stats.averageSquareFootage = Math.round(stats?.totalSquareFootage / propertiesWithSqft);
      }

      // Format values for display
      stats.formattedTotalSquareFootage = `${stats?.totalSquareFootage?.toLocaleString()} sq ft`;
      stats.formattedAverageSquareFootage = `${stats?.averageSquareFootage?.toLocaleString()} sq ft`;

      console.log('✅ Property stats calculated:', stats);
      return { success: true, data: stats };
    } catch (error) {
      console.error('❌ Get property stats error:', error);
      return { success: false, data: {}, error: 'Failed to get property statistics' };
    }
  },

  // Get properties by account
  async getPropertiesByAccount(accountId, filters = {}) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      console.log('🔍 Loading properties for account:', accountId);

      const {
        data: { user },
        error: userError,
      } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('✖ Authentication required for account properties:', userError);
        return { success: false, error: 'Authentication required', data: [] };
      }

      const {
        data: profileValidation,
        error: validationError,
      } = await supabase?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

      if (validationError) {
        console.error('✖ Failed to validate user profile for account properties:', validationError);
        return { success: false, error: 'Failed to validate user permissions', data: [] };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      const { data, error } = await supabase
        ?.from('properties')
        ?.select(`
          *,
          contacts(id, first_name, last_name, email),
          opportunities(id, name, stage, bid_value)
        `)
        ?.eq('account_id', accountId)
        ?.eq('tenant_id', tenantId)
        ?.order('name');

      if (error) {
        console.error('❌ Get properties by account error:', error);
        return { success: false, error: error?.message, data: [] };
      }

      // Transform data for UI
      const transformedData = (data || [])?.map(property => ({
        ...property,
        contactsCount: property?.contacts?.length || 0,
        opportunitiesCount: property?.opportunities?.length || 0,
        fullAddress: property?.address && property?.city && property?.state ? 
          `${property?.address}, ${property?.city}, ${property?.state}` : 
          property?.address || 'Address Not Available'
      }));

      console.log(`✅ Account properties loaded: ${transformedData?.length} items`);
      return { success: true, data: transformedData };
    } catch (error) {
      console.error('❌ Get properties by account service error:', error);
      return { success: false, error: 'Failed to load account properties', data: [] };
    }
  },

  // Get user's assigned accounts for property creation
  async getUserAssignedAccounts() {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        return { success: false, error: userError?.message || 'Authentication required' };
      }

      const { data: profileValidation, error: validationError } = await supabase
        ?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

      if (validationError || !profileValidation?.success) {
        return { success: false, error: validationError?.message || 'Failed to validate user profile' };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      if (!tenantId) {
        return { success: false, error: 'Unable to resolve tenant context for current user' };
      }

      const { data, error } = await supabase
        ?.from('accounts')
        ?.select('id, name, company_type, stage, assigned_rep_id')
        ?.eq('tenant_id', tenantId)
        ?.order('name');

      if (error) {
        console.error('Get tenant accounts error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load accounts' };
    }
  }
};

export default propertiesService;
