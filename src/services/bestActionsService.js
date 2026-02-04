import { supabase } from '../lib/supabaseClient';

const TEMPERATURE_ORDER = {
  hot: 0,
  warm: 1,
  cold: 2
};

const toDate = (value) => {
  if (!value) return null;
  const resolved = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(resolved.getTime())) return null;
  return resolved;
};

const endOfTodayIso = () => {
  const now = new Date();
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
  return end.toISOString();
};

const startOfDayIso = (date = new Date()) => {
  const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  return start.toISOString();
};

const startOfWeekIso = (date = new Date()) => {
  const dayIndex = (date.getDay() + 6) % 7;
  const start = new Date(date.getFullYear(), date.getMonth(), date.getDate() - dayIndex);
  start.setHours(0, 0, 0, 0);
  return start.toISOString();
};

const resolveDisplayName = (contact) => {
  const name = [contact?.first_name, contact?.last_name].filter(Boolean).join(' ').trim();
  return name || contact?.email || 'Contact';
};

const buildFollowUpSortKey = (item) => {
  const dueDate = toDate(item?.next_touch_due_at);
  const isOverdue = dueDate ? dueDate < new Date() : false;
  const tempRank = TEMPERATURE_ORDER?.[String(item?.temperature || '').toLowerCase()] ?? 3;
  return {
    isOverdue: isOverdue ? 0 : 1,
    tempRank,
    dueDate: dueDate || new Date(8640000000000000)
  };
};

export const bestActionsService = {
  async getFollowUpsDue({ tenantId, userId, limit = 25 }) {
    if (!tenantId) {
      return { success: false, error: 'Tenant ID is required', data: [] };
    }

    try {
      const dueBy = endOfTodayIso();
      const [contactsResult, accountsResult, propertiesResult] = await Promise.all([
        supabase
          ?.from('contacts')
          ?.select('id, first_name, last_name, stage, temperature, next_touch_due_at, last_touch_at, account:accounts(id, name)')
          ?.eq('tenant_id', tenantId)
          ?.eq('is_active', true)
          ?.not('next_touch_due_at', 'is', null)
          ?.lte('next_touch_due_at', dueBy)
          ?.limit(limit),
        supabase
          ?.from('accounts')
          ?.select('id, name, stage, temperature, next_touch_due_at, last_touch_at')
          ?.eq('tenant_id', tenantId)
          ?.eq('is_active', true)
          ?.not('next_touch_due_at', 'is', null)
          ?.lte('next_touch_due_at', dueBy)
          ?.limit(limit),
        supabase
          ?.from('properties')
          ?.select('id, name, stage, temperature, next_touch_due_at, last_touch_at, account:accounts(id, name)')
          ?.eq('tenant_id', tenantId)
          ?.not('next_touch_due_at', 'is', null)
          ?.lte('next_touch_due_at', dueBy)
          ?.limit(limit)
      ]);

      if (contactsResult?.error) {
        return { success: false, error: contactsResult?.error?.message, data: [] };
      }
      if (accountsResult?.error) {
        return { success: false, error: accountsResult?.error?.message, data: [] };
      }
      if (propertiesResult?.error) {
        return { success: false, error: propertiesResult?.error?.message, data: [] };
      }

      const contactItems = (contactsResult?.data || []).map(contact => ({
        entity_type: 'contact',
        entity_id: contact?.id,
        display_name: resolveDisplayName(contact),
        stage: contact?.stage || null,
        temperature: contact?.temperature || 'cold',
        next_touch_due_at: contact?.next_touch_due_at || null,
        last_touch_at: contact?.last_touch_at || null,
        account_id: contact?.account?.id || null,
        account_name: contact?.account?.name || null,
        user_id: userId || null
      }));

      const accountItems = (accountsResult?.data || []).map(account => ({
        entity_type: 'account',
        entity_id: account?.id,
        display_name: account?.name || 'Account',
        stage: account?.stage || null,
        temperature: account?.temperature || 'cold',
        next_touch_due_at: account?.next_touch_due_at || null,
        last_touch_at: account?.last_touch_at || null,
        account_id: account?.id || null,
        account_name: account?.name || null,
        user_id: userId || null
      }));

      const propertyItems = (propertiesResult?.data || []).map(property => ({
        entity_type: 'property',
        entity_id: property?.id,
        display_name: property?.name || 'Property',
        stage: property?.stage || null,
        temperature: property?.temperature || 'cold',
        next_touch_due_at: property?.next_touch_due_at || null,
        last_touch_at: property?.last_touch_at || null,
        account_id: property?.account?.id || null,
        account_name: property?.account?.name || null,
        user_id: userId || null
      }));

      const combined = [...contactItems, ...accountItems, ...propertyItems];
      combined.sort((a, b) => {
        const aKey = buildFollowUpSortKey(a);
        const bKey = buildFollowUpSortKey(b);
        if (aKey.isOverdue !== bKey.isOverdue) return aKey.isOverdue - bKey.isOverdue;
        if (aKey.tempRank !== bKey.tempRank) return aKey.tempRank - bKey.tempRank;
        return aKey.dueDate - bKey.dueDate;
      });

      return { success: true, data: combined.slice(0, limit) };
    } catch (error) {
      console.error('Failed to load follow-ups due:', error);
      return { success: false, error: error?.message || 'Failed to load follow-ups', data: [] };
    }
  },

  async getQuotaTasks({ tenantId, userId }) {
    if (!tenantId || !userId) {
      return { success: false, error: 'Tenant ID and User ID are required', data: [] };
    }

    try {
      const now = new Date();
      const weekStart = startOfWeekIso(now);
      const todayStart = startOfDayIso(now);
      const todayEnd = endOfTodayIso();

      const { data: goals, error: goalsError } = await supabase
        ?.from('user_goals')
        ?.select('id, tenant_id, user_id, period, metric, target')
        ?.eq('tenant_id', tenantId)
        ?.eq('is_active', true)
        ?.eq('period', 'weekly')
        ?.or(`user_id.eq.${userId},user_id.is.null`);

      if (goalsError) {
        return { success: false, error: goalsError?.message, data: [] };
      }

      const goalByMetric = {};
      (goals || []).forEach(goal => {
        if (!goal?.metric) return;
        const existing = goalByMetric?.[goal.metric];
        if (!existing) {
          goalByMetric[goal.metric] = goal;
          return;
        }
        if (goal?.user_id && !existing?.user_id) {
          goalByMetric[goal.metric] = goal;
        }
      });

      const [
        weeklyCalls,
        todayCalls,
        weeklyTouches,
        todayTouches,
        weeklyContacts,
        todayContacts
      ] = await Promise.all([
        supabase
          ?.from('activities')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('user_id', userId)
          ?.eq('direction', 'outbound')
          ?.eq('activity_type', 'Phone Call')
          ?.gte('activity_date', weekStart),
        supabase
          ?.from('activities')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('user_id', userId)
          ?.eq('direction', 'outbound')
          ?.eq('activity_type', 'Phone Call')
          ?.gte('activity_date', todayStart)
          ?.lte('activity_date', todayEnd),
        supabase
          ?.from('activities')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('user_id', userId)
          ?.eq('direction', 'outbound')
          ?.gte('activity_date', weekStart),
        supabase
          ?.from('activities')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('user_id', userId)
          ?.eq('direction', 'outbound')
          ?.gte('activity_date', todayStart)
          ?.lte('activity_date', todayEnd),
        supabase
          ?.from('contacts')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('created_by', userId)
          ?.gte('created_at', weekStart),
        supabase
          ?.from('contacts')
          ?.select('id', { count: 'exact', head: true })
          ?.eq('created_by', userId)
          ?.gte('created_at', todayStart)
          ?.lte('created_at', todayEnd)
      ]);

      const countError = [
        weeklyCalls,
        todayCalls,
        weeklyTouches,
        todayTouches,
        weeklyContacts,
        todayContacts
      ].find(result => result?.error);

      if (countError?.error) {
        return { success: false, error: countError?.error?.message || 'Failed to load quota counts', data: [] };
      }

      const weekCounts = {
        calls: weeklyCalls?.count || 0,
        touches: weeklyTouches?.count || 0,
        new_contacts: weeklyContacts?.count || 0
      };

      const todayCounts = {
        calls: todayCalls?.count || 0,
        touches: todayTouches?.count || 0,
        new_contacts: todayContacts?.count || 0
      };

      const weekdayIndex = (now.getDay() + 6) % 7;
      const daysLeft = Math.max(1, 5 - weekdayIndex);

      const tasks = Object.keys(goalByMetric || {}).map(metric => {
        const goalWeek = goalByMetric?.[metric]?.target || 0;
        const doneWeek = weekCounts?.[metric] || 0;
        const doneToday = todayCounts?.[metric] || 0;
        const remainingWeek = Math.max(0, goalWeek - doneWeek);
        const targetToday = Math.max(0, Math.ceil(remainingWeek / daysLeft));

        return {
          type: 'quota',
          metric,
          targetToday,
          progress: doneToday,
          remainingWeek,
          goalWeek
        };
      });

      return { success: true, data: tasks };
    } catch (error) {
      console.error('Failed to load quota tasks:', error);
      return { success: false, error: error?.message || 'Failed to load quota tasks', data: [] };
    }
  }
};

export default bestActionsService;
