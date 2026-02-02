import { supabase } from '../lib/supabaseClient';

const OPEN_TASK_STATUSES = new Set(['pending', 'in_progress', 'overdue']);
const CLOSED_TASK_STATUSES = new Set(['completed', 'cancelled', 'canceled']);

const normalizeTimelineItems = (items = [], includeCompletedTasks = false) => {
  if (!Array.isArray(items)) return [];
  if (includeCompletedTasks) return items;

  return items.filter((item) => {
    if (item?.source_type !== 'task') return true;
    const status = String(item?.status || '').toLowerCase();
    if (OPEN_TASK_STATUSES.has(status)) return true;
    if (CLOSED_TASK_STATUSES.has(status)) return false;
    return true;
  });
};

export const timelineService = {
  async getTimelineForEntity(entityType, entityId, options = {}) {
    if (!entityType || !entityId) {
      return { success: false, error: 'Entity type and ID are required', data: [] };
    }

    const {
      includeCompletedTasks = false,
      limit = null,
      sortDirection = 'desc'
    } = options;

    try {
      let query = supabase
        ?.from('timeline_items')
        ?.select('*')
        ?.eq('entity_type', entityType)
        ?.eq('entity_id', entityId)
        ?.order('event_at', { ascending: sortDirection === 'asc' });

      if (limit) {
        query = query?.limit(limit);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Timeline query error:', error);
        return { success: false, error: error?.message || 'Failed to load timeline', data: [] };
      }

      const normalized = normalizeTimelineItems(data || [], includeCompletedTasks);
      return { success: true, data: normalized };
    } catch (error) {
      console.error('Timeline service error:', error);
      return { success: false, error: 'Failed to load timeline', data: [] };
    }
  }
};

export default timelineService;
