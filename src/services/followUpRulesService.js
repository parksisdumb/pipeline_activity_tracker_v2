import { supabase } from '../lib/supabaseClient';

const sanitizeInteger = (value, fallback) => {
  const parsed = Number.parseInt(value, 10);
  if (Number.isFinite(parsed)) {
    return parsed;
  }
  return fallback;
};

const normalizeRule = (rule, tenantId) => ({
  id: rule?.id || undefined,
  tenant_id: tenantId,
  entity_type: rule?.entity_type || 'account',
  temperature: rule?.temperature || 'cold',
  stage: rule?.stage || 'default',
  interval_days: sanitizeInteger(rule?.interval_days, 30),
  priority: sanitizeInteger(rule?.priority, 100),
  is_active: rule?.is_active !== false
});

export const followUpRulesService = {
  async fetchRules(tenantId) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID is required', data: [] };
    }

    try {
      const { data, error } = await supabase
        ?.from('follow_up_rules')
        ?.select('id, tenant_id, entity_type, temperature, stage, interval_days, priority, is_active')
        ?.eq('tenant_id', tenantId)
        ?.order('entity_type', { ascending: true })
        ?.order('temperature', { ascending: true })
        ?.order('priority', { ascending: true })
        ?.order('stage', { ascending: true });

      if (error) {
        return { success: false, error: error?.message, data: [] };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      console.error('Failed to load follow-up rules:', error);
      return { success: false, error: error?.message || 'Failed to load rules', data: [] };
    }
  },

  async saveRules(tenantId, rules) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID is required' };
    }

    if (!Array.isArray(rules) || rules?.length === 0) {
      return { success: false, error: 'No rules provided' };
    }

    const normalized = rules
      ?.filter(rule => rule?.entity_type && rule?.temperature && rule?.stage)
      ?.map(rule => normalizeRule(rule, tenantId));

    const existingRules = normalized?.filter(rule => rule?.id);
    const newRules = normalized?.filter(rule => !rule?.id);

    try {
      const results = [];

      if (existingRules?.length) {
        const { data, error } = await supabase
          ?.from('follow_up_rules')
          ?.upsert(existingRules, { onConflict: 'id' })
          ?.select('id, tenant_id, entity_type, temperature, stage, interval_days, priority, is_active');

        if (error) {
          return { success: false, error: error?.message };
        }
        results.push(...(data || []));
      }

      if (newRules?.length) {
        const { data, error } = await supabase
          ?.from('follow_up_rules')
          ?.insert(newRules)
          ?.select('id, tenant_id, entity_type, temperature, stage, interval_days, priority, is_active');

        if (error) {
          return { success: false, error: error?.message };
        }
        results.push(...(data || []));
      }

      return { success: true, data: results };
    } catch (error) {
      console.error('Failed to save follow-up rules:', error);
      return { success: false, error: error?.message || 'Failed to save rules' };
    }
  },

  async deleteRule(ruleId) {
    if (!ruleId) {
      return { success: false, error: 'Rule ID is required' };
    }

    try {
      const { error } = await supabase
        ?.from('follow_up_rules')
        ?.delete()
        ?.eq('id', ruleId);

      if (error) {
        return { success: false, error: error?.message };
      }

      return { success: true };
    } catch (error) {
      console.error('Failed to delete follow-up rule:', error);
      return { success: false, error: error?.message || 'Failed to delete rule' };
    }
  }
};

export default followUpRulesService;
