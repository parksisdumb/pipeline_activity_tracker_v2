import { tasksService } from './tasksService';

const ACTIONS = new Set(['call', 'dm', 'email', 'pop_in', 'follow_up']);

const TASK_CATEGORY_ACTION_MAP = {
  follow_up_call: 'call',
  meeting_setup: 'call',
  assessment_scheduling: 'call',
  proposal_review: 'email',
  email: 'email',
  phone_call: 'call',
  pop_in: 'pop_in',
  dm_conversation: 'dm',
  follow_up: 'follow_up'
};

const normalizeAction = (value) => {
  if (!value) return 'follow_up';
  const normalized = String(value).toLowerCase();
  return ACTIONS.has(normalized) ? normalized : 'follow_up';
};

const actionLabel = (action) => {
  switch (action) {
    case 'call':
      return 'Call';
    case 'dm':
      return 'DM';
    case 'email':
      return 'Email';
    case 'pop_in':
      return 'Pop in';
    default:
      return 'Follow up with';
  }
};

const buildTitle = (action, name) => {
  const label = actionLabel(action);
  const target = name || 'task';
  return `${label} ${target}`;
};

const joinSubtitle = (...parts) => parts.filter(Boolean).join(' \u2022 ');

const toDate = (value) => {
  if (!value) return null;
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return date;
};

const buildQueueId = (sourceType, sourceId) => `${sourceType}:${sourceId}`;

const getTaskReason = (dueAt) => {
  const dueDate = toDate(dueAt);
  if (!dueDate) return 'Needs follow-up';
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (dueDate < today) return 'Overdue';
  if (dueDate.toDateString() === today.toDateString()) return 'Due today';
  return 'Up next';
};

const resolveTaskType = (task) => {
  if (task?.task_type) return task?.task_type;
  const category = String(task?.category || '').toLowerCase();
  if (category.includes('follow_up')) return 'follow_up';
  if (category.includes('system')) return 'system';
  return 'admin';
};

const taskTypeWeight = (taskType) => {
  switch (taskType) {
    case 'follow_up':
      return 1;
    case 'system':
      return 2;
    case 'admin':
      return 3;
    default:
      return 4;
  }
};

const bucketRank = (dueAt) => {
  const dueDate = toDate(dueAt);
  if (!dueDate) return 4;
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const upNextEnd = new Date(today);
  upNextEnd.setDate(today.getDate() + 2);
  upNextEnd.setHours(23, 59, 59, 999);

  if (dueDate < today) return 1;
  if (dueDate.toDateString() === today.toDateString()) return 2;
  if (dueDate <= upNextEnd) return 3;
  return 4;
};

const shouldInclude = (dueAt) => {
  const dueDate = toDate(dueAt);
  if (!dueDate) return false;
  return bucketRank(dueAt) <= 3;
};

const compareDueAt = (a, b) => {
  const aDate = toDate(a?.dueAt);
  const bDate = toDate(b?.dueAt);
  if (!aDate && !bDate) return 0;
  if (!aDate) return 1;
  if (!bDate) return -1;
  return aDate - bDate;
};

const resolveTaskAction = (task) => {
  const taskType = resolveTaskType(task);
  if (taskType === 'follow_up') return 'call';
  if (taskType === 'admin' || taskType === 'system') return 'follow_up';
  const mapped = TASK_CATEGORY_ACTION_MAP?.[String(task?.category || '').toLowerCase()];
  return normalizeAction(mapped || task?.category || task?.activity_type);
};

export const nbaService = {
  async getQueue(userId) {
    try {
      const now = new Date();
      const endOfUpNext = new Date(now);
      endOfUpNext.setDate(endOfUpNext.getDate() + 2);
      endOfUpNext.setHours(23, 59, 59, 999);

      const tasksResult = await tasksService?.getOpenTasksForUser(userId, {
        to: endOfUpNext.toISOString()
      });

      const taskItems = (tasksResult?.success ? tasksResult?.data : [])
        ?.filter(task => shouldInclude(task?.due_date))
        ?.map(task => {
        const resolvedTaskType = resolveTaskType(task);
        const action = resolveTaskAction(task);
        const contactName = task?.contact ? `${task?.contact?.first_name || ''} ${task?.contact?.last_name || ''}`?.trim() : null;
        const accountName = task?.account?.name || null;
        const propertyName = task?.property?.name || null;
        const opportunityName = task?.opportunity?.name || null;
        const titleTarget = contactName
          || propertyName
          || opportunityName
          || (accountName ? `${accountName} (Account)` : null)
          || task?.title;

        const dedupeKey = `task:${task?.id}`;

        return {
          id: buildQueueId('task', task?.id),
          sourceType: 'task',
          sourceId: task?.id,
          taskType: resolvedTaskType,
          dedupeKey,
          action,
          title: buildTitle(action, titleTarget || 'task'),
          subtitle: joinSubtitle(accountName, contactName || propertyName || opportunityName),
          dueAt: task?.due_date || null,
          reason: getTaskReason(task?.due_date),
          entity: {
            contactId: task?.contact_id || task?.contact?.id || null,
            accountId: task?.account_id || task?.account?.id || null,
            propertyId: task?.property_id || task?.property?.id || null,
            opportunityId: task?.opportunity_id || task?.opportunity?.id || null
          },
          suggestedOutcome: 'completed',
          task
        };
      }) || [];

      return taskItems.sort((a, b) => {
        const bucketDiff = bucketRank(a?.dueAt) - bucketRank(b?.dueAt);
        if (bucketDiff !== 0) return bucketDiff;
        const typeDiff = taskTypeWeight(a?.taskType) - taskTypeWeight(b?.taskType);
        if (typeDiff !== 0) return typeDiff;
        const dueDiff = compareDueAt(a, b);
        if (dueDiff !== 0) return dueDiff;
        const aCreated = toDate(a?.task?.created_at);
        const bCreated = toDate(b?.task?.created_at);
        if (!aCreated && !bCreated) return 0;
        if (!aCreated) return 1;
        if (!bCreated) return -1;
        return aCreated - bCreated;
      });
    } catch (error) {
      console.error('Failed to build activity queue:', error);
      return [];
    }
  }
};

export default nbaService;
