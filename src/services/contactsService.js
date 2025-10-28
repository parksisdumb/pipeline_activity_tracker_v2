import { supabase } from '../lib/supabaseClient';

export const contactsService = {
  // FIXED: Get all contacts with comprehensive logging and simplified queries
  async getContacts(filters = {}) {
    try {
      console.log('🔍 Loading contacts from database...');

            // Get current user and tenant for scoped access
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        console.error('✖ Authentication required for contacts:', userError);
        return { success: false, error: 'Authentication required', data: [] };
      }

      const { data: profileValidation, error: validationError } = await supabase?.rpc(
        'validate_user_session_and_profile',
        { user_uuid: user?.id }
      );

      if (validationError) {
        console.error('✖ Failed to validate user profile for contacts:', validationError);
        return { success: false, error: 'Failed to validate user permissions', data: [] };
      }

      if (!profileValidation?.success || !profileValidation?.user_data?.tenant_id) {
        console.error('Tenant validation failed for contacts:', profileValidation);
        return { success: false, error: 'Tenant information missing. Please contact support.', data: [] };
      }

      const tenantId = profileValidation?.user_data?.tenant_id;

      // Tenant-scoped query
      let query = supabase?.from('contacts')?.select(`
          *,
          account:accounts(id, name, company_type, city, state)
        `, { count: 'exact' })?.eq('tenant_id', tenantId);

      // Apply basic filters only
// Apply basic filters only
      const {
        searchQuery = null,
        accountId = null,
        isPrimary = null,
        sortBy = 'last_name',
        sortDirection = 'asc',
        limit = 50,
        offset = 0
      } = filters;

      // Apply search filter
      if (searchQuery && searchQuery?.trim() !== '') {
        const searchValue = searchQuery?.trim();
        query = query?.or(`first_name.ilike.%${searchValue}%,last_name.ilike.%${searchValue}%,email.ilike.%${searchValue}%`);
      }

      // Apply account filter
      if (accountId) {
        query = query?.eq('account_id', accountId);
      }

      // Apply primary contact filter
      if (isPrimary !== null) {
        query = query?.eq('is_primary_contact', isPrimary);
      }

      // Apply sorting
      const validSortColumns = ['first_name', 'last_name', 'email', 'title', 'created_at'];
      const sortColumn = validSortColumns?.includes(sortBy) ? sortBy : 'last_name';
      query = query?.order(sortColumn, { ascending: sortDirection === 'asc' });

      // Apply pagination
      if (limit && offset !== undefined) {
        query = query?.range(offset, offset + limit - 1);
      }

      console.log('🚀 Executing contacts query...');
      const { data, error, count } = await query;

      if (error) {
        console.error('❌ Contacts query error:', error);
        
        // Handle specific RLS policy errors
        if (error?.message?.includes('RLS')) {
          return { 
            success: false, 
            error: 'Access denied. Please check your user permissions.',
            data: []
          };
        }
        
        return { 
          success: false, 
          error: error?.message || 'Failed to load contacts', 
          data: [] 
        };
      }

      // Process the actual database data
      const processedData = (data || [])?.map(contact => ({
        ...contact,
        fullName: `${contact?.first_name || ''} ${contact?.last_name || ''}`?.trim(),
        displayName: contact?.first_name && contact?.last_name 
          ? `${contact?.first_name} ${contact?.last_name}` 
          : contact?.email || 'Unnamed Contact',
        accountName: contact?.account?.name || 'No Account',
        hasPhone: !!(contact?.phone || contact?.mobile_phone),
        hasEmail: !!contact?.email,
        isPrimaryContact: !!contact?.is_primary_contact
      }));

      console.log(`✅ Contacts loaded successfully: ${processedData?.length} items (total: ${count})`);
      
      // Log sample of actual data structure
      if (processedData?.length > 0) {
        console.log('📊 Sample contact data:', {
          id: processedData?.[0]?.id,
          name: processedData?.[0]?.displayName,
          email: processedData?.[0]?.email,
          account: processedData?.[0]?.accountName,
          is_primary: processedData?.[0]?.isPrimaryContact
        });
      }

      return { success: true, data: processedData, totalCount: count || 0 };
    } catch (error) {
      console.error('❌ Contacts service error:', error);
      
      if (error?.message?.includes('Failed to fetch') || error?.message?.includes('NetworkError')) {
        return { 
          success: false, 
          error: 'Cannot connect to database. Please check your Supabase project status.',
          data: []
        };
      }
      
      return { 
        success: false, 
        error: error?.message || 'Failed to load contacts from database', 
        data: [] 
      };
    }
  },

  // FIXED: Get single contact by ID with proper validation
  async getContact(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('🔍 Fetching contact by ID:', contactId);

      const { data, error } = await supabase
        ?.from('contacts')
        ?.select(`
          *,
          account:accounts(id, name, company_type, address, city, state, website),
          property:properties(id, name, address, city, state, building_type, stage),
          activities(*)
        `)
        ?.eq('id', contactId)
        ?.single();

      if (error) {
        console.error('❌ Error fetching contact:', error);
        
        if (error?.code === 'PGRST116') {
          return { success: false, error: 'Contact not found' };
        }
        
        return { success: false, error: error?.message || 'Failed to load contact' };
      }

      console.log('✅ Contact loaded:', data?.first_name, data?.last_name);
      return { success: true, data };
    } catch (error) {
      console.error('❌ Get contact error:', error);
      return { success: false, error: 'Failed to load contact' };
    }
  },

  // FIXED: Create contact with comprehensive error handling
  async createContact(contactData) {
    try {
      console.log('🆕 Creating new contact...');
      
      // Validate required fields
      const requiredFields = ['first_name', 'last_name'];
      for (const field of requiredFields) {
        if (!contactData?.[field]) {
          return { success: false, error: `${field?.replace('_', ' ')} is required` };
        }
      }

      // Get current user for RLS compliance
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      if (userError || !user) {
        return { success: false, error: 'Authentication required to create contact' };
      }

      // Enhanced account validation if account_id is provided
      if (contactData?.account_id) {
        console.log('🔍 Validating account access for:', contactData?.account_id);
        const { data: accountCheck, error: accountError } = await supabase
          ?.from('accounts')
          ?.select('id, name')
          ?.eq('id', contactData?.account_id)
          ?.single();
        
        if (accountError || !accountCheck) {
          console.error('❌ Account validation failed:', accountError);
          return { 
            success: false, 
            error: 'Selected account not found or access denied. Please verify the account exists and you have permission.' 
          };
        }
        
        console.log('✅ Account validation successful:', accountCheck?.name);
      }

      // Handle primary contact logic
      if (contactData?.is_primary_contact && contactData?.account_id) {
        console.log('🔄 Setting as primary contact - clearing other primary contacts');
        const { error: updateError } = await supabase
          ?.from('contacts')
          ?.update({ is_primary_contact: false })
          ?.eq('account_id', contactData?.account_id)
          ?.eq('is_primary_contact', true);
          
        if (updateError) {
          console.warn('⚠️ Failed to update existing primary contacts:', updateError);
        }
      }

      const { data, error } = await supabase?.from('contacts')?.insert([{
        ...contactData,
        created_by: user?.id
      }])?.select(`
          *,
          account:accounts(id, name, company_type)
        `)?.single();

      if (error) {
        console.error('❌ Contact creation error:', error);
        
        // Handle specific constraint violations
        if (error?.code === '23505') {
          return { success: false, error: 'A contact with this email already exists in your organization' };
        }
        
        if (error?.code === '23503') {
          if (error?.message?.includes('account_id')) {
            return { success: false, error: 'Invalid account selected. The account may no longer exist.' };
          }
          return { success: false, error: 'Invalid data provided. Please check all fields.' };
        }

        return { 
          success: false, 
          error: `Contact creation failed: ${error?.message || 'Unknown error'}` 
        };
      }

      console.log('✅ Contact created successfully:', data?.first_name, data?.last_name);
      return { success: true, data };
    } catch (error) {
      console.error('❌ Create contact service error:', error);
      
      if (error?.message?.includes('Failed to fetch') || error?.message?.includes('NetworkError')) {
        return { 
          success: false, 
          error: 'Network connection error. Please check your internet connection.' 
        };
      }
      
      return { 
        success: false, 
        error: error?.message || 'Failed to create contact. Please try again.' 
      };
    }
  },

  // Update an existing contact
  async updateContact(contactId, updates) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('🔄 Updating contact:', contactId);

      // Handle primary contact logic
      if (updates?.is_primary_contact) {
        const { data: currentContact } = await supabase?.from('contacts')?.select('account_id')?.eq('id', contactId)?.single();

        if (currentContact?.account_id) {
          await supabase?.from('contacts')?.update({ is_primary_contact: false })?.eq('account_id', currentContact?.account_id)?.eq('is_primary_contact', true);
        }
      }

      const { data, error } = await supabase?.from('contacts')?.update({ 
        ...updates, 
        updated_at: new Date()?.toISOString() 
      })?.eq('id', contactId)?.select(`
          *,
          account:accounts(id, name, company_type)
        `)?.single();

      if (error) {
        console.error('❌ Update contact error:', error);
        return { success: false, error: error?.message };
      }

      console.log('✅ Contact updated successfully:', data?.first_name, data?.last_name);
      return { success: true, data };
    } catch (error) {
      console.error('❌ Update contact service error:', error);
      return { success: false, error: 'Failed to update contact' };
    }
  },

  // Delete a contact
  async deleteContact(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('🗑️ Deleting contact:', contactId);

      const { error } = await supabase?.from('contacts')?.delete()?.eq('id', contactId);

      if (error) {
        console.error('❌ Delete contact error:', error);
        return { success: false, error: error?.message };
      }

      console.log('✅ Contact deleted successfully');
      return { success: true };
    } catch (error) {
      console.error('❌ Delete contact service error:', error);
      return { success: false, error: 'Failed to delete contact' };
    }
  },

  // Get contacts by account ID
  async getContactsByAccount(accountId) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      console.log('🔍 Loading contacts for account:', accountId);

      // First verify the account exists and user has access
      const { data: account, error: accountError } = await supabase?.from('accounts')?.select('id, name')?.eq('id', accountId)?.single();
      
      if (accountError) {
        console.error('❌ Account verification error:', accountError);
        if (accountError?.code === 'PGRST116') {
          return { success: false, error: 'Account not found or access denied' };
        }
        return { success: false, error: 'Failed to verify account access' };
      }

      // Get contacts for this account
      const { data, error } = await supabase?.from('contacts')?.select('*')?.eq('account_id', accountId)?.order('is_primary_contact', { ascending: false })?.order('last_name');

      if (error) {
        console.error('❌ Get contacts by account error:', error);
        return { success: false, error: error?.message };
      }

      console.log(`✅ Account contacts loaded: ${data?.length} items`);
      return { success: true, data: data || [] };
    } catch (error) {
      console.error('❌ Get contacts by account service error:', error);
      return { success: false, error: 'Failed to load account contacts' };
    }
  },

  // FIXED: Get contact statistics with better data processing
  async getContactStats() {
    try {
      console.log('📊 Loading contact statistics...');

      const { data, error } = await supabase?.from('contacts')?.select('account_id, is_primary_contact, is_active');

      if (error) {
        console.error('❌ Contact stats error:', error);
        return { success: false, error: error?.message };
      }

      const stats = {
        total: data?.length || 0,
        primaryContacts: data?.filter(c => c?.is_primary_contact)?.length || 0,
        activeContacts: data?.filter(c => c?.is_active !== false)?.length || 0,
        accountsWithContacts: new Set(data?.map(c => c?.account_id))?.size || 0,
      };

      console.log('✅ Contact stats calculated:', stats);
      return { success: true, data: stats };
    } catch (error) {
      console.error('❌ Get contact stats service error:', error);
      return { success: false, error: 'Failed to load contact statistics' };
    }
  },

  // Get available properties (validated via RPC)
  async getAvailableProperties(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('🔍 Loading available properties for contact:', contactId);

      const { data, error } = await supabase
        ?.rpc('get_contact_available_properties', { contact_uuid: contactId });

      if (error) {
        console.error('❌ Get available properties error:', error);
        return { success: false, error: error?.message || 'Failed to load properties' };
      }

      console.log(`✅ Available properties loaded: ${data?.length} items`);
      return { success: true, data: data || [] };
    } catch (error) {
      console.error('❌ Get available properties service error:', error);
      return { success: false, error: 'Failed to load available properties' };
    }
  },

  // Get available accounts for dropdown selection
  async getAvailableAccounts() {
    try {
      console.log('🔍 Loading available accounts...');

      const { data, error } = await supabase
        ?.from('accounts')
        ?.select('id, name, company_type, city, state')
        ?.eq('is_active', true)
        ?.order('name');

      if (error) {
        console.error('❌ Error fetching accounts:', error);
        return { success: false, data: [], error: error?.message || 'Failed to fetch accounts' };
      }

      console.log(`✅ Available accounts loaded: ${data?.length} items`);
      return { success: true, data: data || [], error: null };
    } catch (error) {
      return { 
        success: false,
        data: [], 
        error: error?.message || 'Failed to fetch available accounts'
      };
    }
  },

  // Link contact to property (simplified approach)
  async linkToProperty(contactId, propertyId) {
    if (!contactId || !propertyId) {
      return { success: false, error: 'Contact ID and Property ID are required' };
    }

    try {
      console.log('🔗 Linking contact to property:', contactId, propertyId);

      const { data, error } = await supabase
        ?.rpc('link_contact_to_property', {
          contact_uuid: contactId,
          property_uuid: propertyId
        });

      if (error || data === false) {
        const message = error?.message || 'Failed to link contact to property';
        console.error('❌ Link to property error:', error || message);
        return { success: false, error: message };
      }

      console.log('✅ Contact linked to property successfully');
      return { success: true };
    } catch (error) {
      console.error('❌ Link to property service error:', error);
      return { success: false, error: 'Failed to link contact to property' };
    }
  },

  // Unlink contact from property
  async unlinkFromProperty(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('🔗 Unlinking contact from property:', contactId);

      const { data, error } = await supabase
        ?.rpc('unlink_contact_from_property', { contact_uuid: contactId });

      if (error || data === false) {
        const message = error?.message || 'Failed to unlink contact from property';
        console.error('❌ Unlink from property error:', error || message);
        return { success: false, error: message };
      }

      console.log('✅ Contact unlinked from property successfully');
      return { success: true };
    } catch (error) {
      console.error('❌ Unlink from property service error:', error);
      return { success: false, error: 'Failed to unlink contact from property' };
    }
  },

  // Set reminder for contact
  async setReminder(contactId, reminderData) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('⏰ Setting reminder for contact:', contactId);

      // Create an activity with reminder type
      const activityData = {
        activity_type: 'Follow-up',
        contact_id: contactId,
        description: reminderData?.notes || 'Follow-up reminder',
        outcome: 'Scheduled',
        activity_date: reminderData?.date,
        created_at: new Date()?.toISOString()
      };

      const { data, error } = await supabase
        ?.from('activities')
        ?.insert(activityData)
        ?.select()
        ?.single();

      if (error) {
        console.error('❌ Set reminder error:', error);
        return { success: false, error: error?.message };
      }

      console.log('✅ Reminder set successfully');
      return { success: true, data };
    } catch (error) {
      console.error('❌ Set reminder service error:', error);
      return { success: false, error: 'Failed to set reminder' };
    }
  },

  // Get linked properties for a contact
  async getLinkedProperties(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      console.log('dY"? Getting linked properties for contact:', contactId);

      const { data, error } = await supabase
        ?.rpc('get_contact_linked_properties', { contact_uuid: contactId });

      if (error) {
        console.error('Get linked properties error:', error);
        return { success: false, error: error?.message || 'Failed to load linked properties' };
      }

      console.log(`Linked properties loaded: ${data?.length || 0} items`);
      return { success: true, data: data || [] };
    } catch (error) {
      console.error('Get linked properties service error:', error);
      return { success: false, error: 'Failed to load linked properties' };
    }
  },

  // Get contact stages (static data based on enum)
  getContactStages() {
    return [
      { value: 'prospect', label: 'Prospect' },
      { value: 'lead', label: 'Lead' },
      { value: 'opportunity', label: 'Opportunity' },
      { value: 'customer', label: 'Customer' },
      { value: 'inactive', label: 'Inactive' }
    ];
  },

  // Utility methods
  formatContactName(contact) {
    if (!contact) return 'Unknown Contact';
    const name = `${contact?.first_name || ''} ${contact?.last_name || ''}`?.trim();
    return name || contact?.email || 'Unnamed Contact';
  },

  getContactInitials(contact) {
    if (!contact) return 'UC';
    const firstName = contact?.first_name?.charAt(0)?.toUpperCase() || '';
    const lastName = contact?.last_name?.charAt(0)?.toUpperCase() || '';
    return firstName && lastName ? `${firstName}${lastName}` : 
           firstName || lastName || 
           contact?.email?.charAt(0)?.toUpperCase() || 'UC';
  },

  validateContactData(contactData) {
    const errors = [];
    
    if (!contactData?.first_name?.trim()) {
      errors?.push('First name is required');
    }
    
    if (!contactData?.last_name?.trim()) {
      errors?.push('Last name is required');
    }
    
    if (contactData?.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/?.test(contactData?.email)) {
      errors?.push('Invalid email format');
    }
    
    return {
      isValid: errors?.length === 0,
      errors
    };
  }
};

export default contactsService;
