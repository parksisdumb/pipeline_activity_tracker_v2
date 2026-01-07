import { supabase } from '../lib/supabaseClient';

const resolveWorkspaceContext = async () => {
  const { data: { user }, error: userError } = await supabase?.auth?.getUser();
  if (userError || !user) {
    return { success: false, error: 'Authentication required' };
  }

  const { data: profileValidation, error: validationError } = await supabase
    ?.rpc('validate_user_session_and_profile', { user_uuid: user?.id });

  if (validationError) {
    console.error('Failed to validate user profile:', validationError);
    return { success: false, error: 'Failed to validate user permissions' };
  }

  const workspaceId = profileValidation?.user_data?.tenant_id || null;
  if (!workspaceId) {
    return { success: false, error: 'Unable to resolve workspace context for current user' };
  }

  return { success: true, workspaceId, user };
};

export const propertyContactsService = {
  async getContactsForProperty(propertyId) {
    if (!propertyId) return { success: false, error: 'Property ID is required' };

    try {
      const workspace = await resolveWorkspaceContext();
      if (!workspace?.success) return workspace;

      const { data, error } = await supabase
        ?.from('property_contacts')
        ?.select(`
          id,
          property_id,
          contact_id,
          relationship_type,
          is_primary,
          created_at,
          contact:contacts(
            id,
            first_name,
            last_name,
            email,
            phone,
            title,
            is_primary_contact
          )
        `)
        ?.eq('property_id', propertyId)
        ?.eq('workspace_id', workspace?.workspaceId)
        ?.order('created_at', { ascending: false });

      if (error) {
        console.error('Failed to load property contacts:', error);
        return { success: false, error: error?.message || 'Failed to load property contacts' };
      }

      const contacts = (data || [])
        ?.map((row) => ({
          ...(row?.contact || {}),
          property_contact_id: row?.id,
          property_id: row?.property_id,
          contact_id: row?.contact_id,
          relationship_type: row?.relationship_type || null,
          is_primary: row?.is_primary ?? false
        }))
        ?.filter((contact) => contact?.id);

      return { success: true, data: contacts };
    } catch (error) {
      console.error('Property contacts service error:', error);
      return { success: false, error: 'Failed to load property contacts' };
    }
  },

  async getPropertiesForContact(contactId) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      const workspace = await resolveWorkspaceContext();
      if (!workspace?.success) return workspace;

      const { data, error } = await supabase
        ?.from('property_contacts')
        ?.select(`
          id,
          property_id,
          contact_id,
          relationship_type,
          is_primary,
          created_at,
          property:properties(
            id,
            name,
            address,
            city,
            state,
            zip_code,
            building_type,
            stage,
            account_id
          )
        `)
        ?.eq('contact_id', contactId)
        ?.eq('workspace_id', workspace?.workspaceId)
        ?.order('created_at', { ascending: false });

      if (error) {
        console.error('Failed to load contact properties:', error);
        return { success: false, error: error?.message || 'Failed to load linked properties' };
      }

      const properties = (data || [])
        ?.map((row) => ({
          ...(row?.property || {}),
          property_contact_id: row?.id,
          property_id: row?.property_id,
          contact_id: row?.contact_id,
          relationship_type: row?.relationship_type || null,
          is_primary: row?.is_primary ?? false
        }))
        ?.filter((property) => property?.id);

      return { success: true, data: properties };
    } catch (error) {
      console.error('Contact properties service error:', error);
      return { success: false, error: 'Failed to load linked properties' };
    }
  },

  async addContactToProperty({
    propertyId,
    contactId,
    workspaceId,
    relationshipType = null,
    isPrimary = false
  }) {
    if (!propertyId || !contactId) {
      return { success: false, error: 'Property ID and Contact ID are required' };
    }

    try {
      let resolvedWorkspaceId = workspaceId;
      if (!resolvedWorkspaceId) {
        const workspace = await resolveWorkspaceContext();
        if (!workspace?.success) return workspace;
        resolvedWorkspaceId = workspace?.workspaceId;
      }

      const payload = {
        workspace_id: resolvedWorkspaceId,
        property_id: propertyId,
        contact_id: contactId,
        relationship_type: relationshipType || null,
        is_primary: Boolean(isPrimary)
      };

      const { data, error } = await supabase
        ?.from('property_contacts')
        ?.insert([payload])
        ?.select()
        ?.single();

      if (error) {
        console.error('Failed to link contact to property:', error);
        if (error?.code === '23505') {
          return { success: false, error: 'Contact is already linked to this property' };
        }
        return { success: false, error: error?.message || 'Failed to link contact to property' };
      }

      return { success: true, data };
    } catch (error) {
      console.error('Add property contact service error:', error);
      return { success: false, error: 'Failed to link contact to property' };
    }
  },

  async removeContactFromProperty({ propertyId, contactId }) {
    if (!propertyId || !contactId) {
      return { success: false, error: 'Property ID and Contact ID are required' };
    }

    try {
      const workspace = await resolveWorkspaceContext();
      if (!workspace?.success) return workspace;

      const { data, error } = await supabase
        ?.from('property_contacts')
        ?.delete()
        ?.eq('property_id', propertyId)
        ?.eq('contact_id', contactId)
        ?.eq('workspace_id', workspace?.workspaceId)
        ?.select();

      if (error) {
        console.error('Failed to unlink contact from property:', error);
        return { success: false, error: error?.message || 'Failed to unlink contact from property' };
      }

      return { success: true, data };
    } catch (error) {
      console.error('Remove property contact service error:', error);
      return { success: false, error: 'Failed to unlink contact from property' };
    }
  }
};

export default propertyContactsService;
