import { supabase } from '../lib/supabaseClient';

const GROW_ACTIVITY_TYPES = [
  'Phone Call',
  'Email',
  'Decision Maker Conversation',
  'Pop-in'
];

const EARLY_OPPORTUNITY_STAGES = ['identified', 'qualified'];

const applyDateRange = (query, field, dateFrom, dateTo) => {
  let scoped = query;
  if (dateFrom) scoped = scoped?.gte(field, dateFrom);
  if (dateTo) scoped = scoped?.lte(field, dateTo);
  return scoped;
};

const countRows = async (query) => {
  const { count, error } = await query;
  if (error) {
    return { success: false, error: error?.message };
  }
  return { success: true, count: count || 0 };
};

export const growService = {
  async getGrowthCounts({ userId, dateFrom, dateTo }) {
    if (!userId) {
      return { success: false, error: 'User ID is required' };
    }

    const accountsQuery = applyDateRange(
      supabase
        ?.from('accounts')
        ?.select('id', { count: 'exact', head: true })
        ?.eq('created_from_grow', true)
        ?.eq('created_by', userId),
      'created_at',
      dateFrom,
      dateTo
    );

    const contactsQuery = applyDateRange(
      supabase
        ?.from('contacts')
        ?.select('id', { count: 'exact', head: true })
        ?.eq('created_from_grow', true)
        ?.eq('created_by', userId)
        ?.not('account_id', 'is', null),
      'created_at',
      dateFrom,
      dateTo
    );

    const propertiesQuery = applyDateRange(
      supabase
        ?.from('properties')
        ?.select('id', { count: 'exact', head: true })
        ?.eq('created_from_grow', true)
        ?.eq('created_by', userId)
        ?.not('account_id', 'is', null),
      'created_at',
      dateFrom,
      dateTo
    );

    const activitiesQuery = applyDateRange(
      supabase
        ?.from('activities')
        ?.select('id', { count: 'exact', head: true })
        ?.eq('created_from_grow', true)
        ?.eq('direction', 'outbound')
        ?.eq('user_id', userId)
        ?.in('activity_type', GROW_ACTIVITY_TYPES),
      'activity_date',
      dateFrom,
      dateTo
    );

    const opportunitiesQuery = applyDateRange(
      supabase
        ?.from('opportunities')
        ?.select('id', { count: 'exact', head: true })
        ?.eq('created_from_grow', true)
        ?.eq('created_by', userId)
        ?.not('account_id', 'is', null)
        ?.in('stage', EARLY_OPPORTUNITY_STAGES),
      'created_at',
      dateFrom,
      dateTo
    );

    const [accounts, contacts, properties, activities, opportunities] = await Promise.all([
      countRows(accountsQuery),
      countRows(contactsQuery),
      countRows(propertiesQuery),
      countRows(activitiesQuery),
      countRows(opportunitiesQuery)
    ]);

    const results = [accounts, contacts, properties, activities, opportunities];
    const failed = results?.find(result => !result?.success);
    if (failed) {
      return { success: false, error: failed?.error || 'Failed to load growth metrics' };
    }

    return {
      success: true,
      data: {
        accounts: accounts?.count || 0,
        contacts: contacts?.count || 0,
        properties: properties?.count || 0,
        touches: activities?.count || 0,
        opportunities: opportunities?.count || 0
      }
    };
  }
};
