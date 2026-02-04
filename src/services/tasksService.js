import { supabase } from '../lib/supabaseClient';

const LINKED_ENTITY_FIELDS = {
  account: 'account_id',
  contact: 'contact_id',
  property: 'property_id',
  opportunity: 'opportunity_id',
  prospect: 'prospect_id'
};

const resolveLinkedEntity = (payload = {}) => {
  if (payload?.linked_entity_type && payload?.linked_entity_id) {
    return {
      linked_entity_type: payload?.linked_entity_type,
      linked_entity_id: payload?.linked_entity_id
    };
  }

  const orderedTypes = ['opportunity', 'property', 'contact', 'account', 'prospect'];
  const match = orderedTypes.find(type => payload?.[LINKED_ENTITY_FIELDS[type]]);
  if (!match) return { linked_entity_type: null, linked_entity_id: null };

  return {
    linked_entity_type: match,
    linked_entity_id: payload?.[LINKED_ENTITY_FIELDS[match]]
  };
};

const normalizeTaskStatus = (status) => {
  if (!status) return null;
  if (status === 'open') return 'pending';
  if (status === 'canceled') return 'completed';
  return status;
};

const resolveTaskType = (taskData = {}) => {
  if (taskData?.task_type) return taskData?.task_type;
  const category = String(taskData?.category || '').toLowerCase();
  if (category?.includes('follow_up')) return 'follow_up';
  return 'admin';
};

const deriveDirectionForTask = (taskType) => {
  if (taskType === 'follow_up') return 'outbound';
  if (taskType === 'admin' || taskType === 'system') return 'internal';
  return 'outbound';
};

const normalizeDueAt = (value) => {
  if (!value) return null;
  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) return null;
    return value.toISOString();
  }
  const raw = String(value);
  const hasTime = raw.includes('T') || raw.includes(':');
  const resolved = new Date(hasTime ? raw : `${raw}T09:00:00`);
  if (Number.isNaN(resolved.getTime())) return null;
  return resolved.toISOString();
};

const resolveTaskDueAt = (task) => {
  if (!task) return null;
  const value = task?.due_at || task?.due_date || task?.due_on || null;
  if (!value) return null;
  const resolved = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(resolved.getTime())) return null;
  return resolved;
};

const normalizeTaskDueFields = (task) => {
  if (!task || typeof task !== 'object') return task;
  const dueAt = task?.due_at || task?.due_date || task?.due_on || null;
  if (!dueAt) return task;
  return { ...task, due_at: dueAt, due_date: dueAt };
};

const normalizeTaskListDueFields = (tasks) => {
  if (!Array.isArray(tasks)) return tasks;
  return tasks.map(normalizeTaskDueFields);
};

const FOLLOW_UP_ENTITY_TABLES = {
  account: 'accounts',
  contact: 'contacts'
};

const resolveFollowUpIntervalDays = async ({ tenantId, entityType, entityId }) => {
  const table = FOLLOW_UP_ENTITY_TABLES?.[entityType];
  if (!table || !tenantId || !entityId) return null;

  try {
    const { data: entity, error } = await supabase
      ?.from(table)
      ?.select('temperature, stage, touch_interval_override_days')
      ?.eq('id', entityId)
      ?.eq('tenant_id', tenantId)
      ?.single();

    if (error || !entity) {
      return null;
    }

    const overrideDays = Number.parseInt(entity?.touch_interval_override_days, 10);
    if (Number.isFinite(overrideDays) && overrideDays > 0) {
      return overrideDays;
    }

    const { data: intervalDays, error: intervalError } = await supabase?.rpc('get_follow_up_interval_days', {
      p_tenant_id: tenantId,
      p_entity_type: entityType,
      p_temperature: entity?.temperature || 'cold',
      p_stage: entity?.stage || 'default'
    });

    if (intervalError) {
      return null;
    }

    const parsed = Number.parseInt(intervalDays, 10);
    return Number.isFinite(parsed) ? parsed : null;
  } catch (error) {
    console.warn('Failed to resolve follow-up interval:', error);
    return null;
  }
};

const buildFollowUpDueAt = (intervalDays) => {
  if (!Number.isFinite(intervalDays) || intervalDays <= 0) return null;
  const dueDate = new Date();
  dueDate.setDate(dueDate.getDate() + intervalDays);
  dueDate.setHours(9, 0, 0, 0);
  return dueDate.toISOString();
};

const TASK_INSERT_FIELDS = new Set([
  'id',
  'title',
  'description',
  'status',
  'priority',
  'category',
  'task_type',
  'due_at',
  'due_date',
  'reminder_date',
  'assigned_to',
  'assigned_by',
  'account_id',
  'property_id',
  'contact_id',
  'opportunity_id',
  'prospect_id',
  'tenant_id',
  'completed_at',
  'completion_notes',
  'source_activity_id',
  'linked_entity_type',
  'linked_entity_id'
]);

export const tasksService = {
  // Get tasks with details using the database function - UPDATED to remove mock data
  async getTasksWithDetails(userUuid = null, statusFilter = null, priorityFilter = null) {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      const { data, error } = await supabase?.rpc('get_tasks_with_details', {
        user_uuid: userUuid,
        status_filter: statusFilter,
        priority_filter: priorityFilter
      });

      if (error) {
        throw error;
      }

      return normalizeTaskListDueFields(data || []);
    } catch (error) {
      console.error('Failed to get tasks with details:', error);
      throw error;
    }
  },

  // New method to get prioritized tasks for Today view
  async getTodayTasks(userUuid = null, limit = 10) {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      // Get all active tasks
      const tasks = await this.getTasksWithDetails(userUuid, 'pending,in_progress', null);

      // Sort by: overdue → due today → due in 3 days, then by priority
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const threeDaysFromNow = new Date(today);
      threeDaysFromNow?.setDate(today?.getDate() + 3);

      const priorityWeight = { urgent: 4, high: 3, medium: 2, low: 1 };

      const sortedTasks = tasks?.sort((a, b) => {
        const aDue = resolveTaskDueAt(a);
        const bDue = resolveTaskDueAt(b);
        const aPriority = priorityWeight?.[a?.priority] || 2;
        const bPriority = priorityWeight?.[b?.priority] || 2;

        // Categorize tasks by due date
        const getDateCategory = (dueDate) => {
          if (!dueDate) return 4; // No due date = lowest priority
          if (dueDate < today) return 1; // Overdue
          if (dueDate?.toDateString() === today?.toDateString()) return 2; // Due today
          if (dueDate <= threeDaysFromNow) return 3; // Upcoming (3 days)
          return 4; // Future
        };

        const aCategory = getDateCategory(aDue);
        const bCategory = getDateCategory(bDue);

        // Sort by category first, then priority
        if (aCategory !== bCategory) {
          return aCategory - bCategory;
        }
        return bPriority - aPriority;
      });

      return normalizeTaskListDueFields(sortedTasks?.slice(0, limit));
    } catch (error) {
      console.error('Failed to get today tasks:', error);
      throw error;
    }
  },

  // New method to get task counts by urgency
  async getTaskCountsByUrgency(userUuid = null) {
    try {
      const tasks = await this.getTasksWithDetails(userUuid, 'pending,in_progress', null);
      
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const threeDaysFromNow = new Date(today);
      threeDaysFromNow?.setDate(today?.getDate() + 3);

      const counts = { overdue: 0, dueToday: 0, upcoming: 0, total: tasks?.length };

      tasks?.forEach(task => {
        const dueDate = resolveTaskDueAt(task);
        if (dueDate) {
          if (dueDate < today) {
            counts.overdue++;
          } else if (dueDate?.toDateString() === today?.toDateString()) {
            counts.dueToday++;
          } else if (dueDate <= threeDaysFromNow) {
            counts.upcoming++;
          }
        }
      });

      return counts;
    } catch (error) {
      console.error('Failed to get task counts:', error);
      return { overdue: 0, dueToday: 0, upcoming: 0, total: 0 };
    }
  },

  // Get tasks by contact ID
  async getTasksByContactId(contactId) {
    try {
      const { data, error } = await supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email),
          creator:assigned_by(id, full_name, email),
          account:account_id(id, name),
          property:property_id(id, name),
          contact:contact_id(id, first_name, last_name),
          opportunity:opportunity_id(id, name)
        `)?.eq('contact_id', contactId)?.order('created_at', { ascending: false });

      if (error) {
        throw error;
      }

      return { data: normalizeTaskListDueFields(data || []), error: null };
    } catch (error) {
      console.error('Failed to get tasks by contact ID:', error);
      return { data: [], error };
    }
  },

  // Get tasks by prospect ID - NEW METHOD
  async getTasksByProspectId(prospectId) {
    try {
      const { data, error } = await supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email),
          creator:assigned_by(id, full_name, email),
          account:account_id(id, name),
          property:property_id(id, name),
          contact:contact_id(id, first_name, last_name),
          opportunity:opportunity_id(id, name),
          prospect:prospect_id(id, name)
        `)?.eq('prospect_id', prospectId)?.order('created_at', { ascending: false });

      if (error) {
        throw error;
      }

      return { data: normalizeTaskListDueFields(data || []), error: null };
    } catch (error) {
      console.error('Failed to get tasks by prospect ID:', error);
      return { data: [], error };
    }
  },

  // Enhanced getTasks method with role-based filtering
  async getTasks(filters = {}) {
    try {
      let query = supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email, role),
          creator:assigned_by(id, full_name, email, role),
          account:account_id(id, name, company_type),
          contact:contact_id(id, first_name, last_name),
          property:property_id(id, name, address),
          opportunity:opportunity_id(id, name, stage),
          tenant:tenant_id(id, name)
        `);

      // Apply filters
      if (filters?.searchQuery) {
        query = query?.or(`title.ilike.%${filters?.searchQuery}%,description.ilike.%${filters?.searchQuery}%`);
      }

      if (filters?.status) {
        query = query?.eq('status', filters?.status);
      }

      if (filters?.priority) {
        query = query?.eq('priority', filters?.priority);
      }

      if (filters?.category) {
        query = query?.eq('category', filters?.category);
      }

      if (filters?.assignedTo) {
        query = query?.eq('assigned_to', filters?.assignedTo);
      }

      if (filters?.dueDateFrom) {
        query = query?.gte('due_at', filters?.dueDateFrom);
      }

      if (filters?.dueDateTo) {
        query = query?.lte('due_at', filters?.dueDateTo);
      }

      if (filters?.createdBy) {
        query = query?.eq('assigned_by', filters?.createdBy);
      }

      // Apply sorting
      const sortColumn = filters?.sortBy || 'due_at';
      const sortDirection = filters?.sortDirection === 'desc' ? false : true;
      query = query?.order(sortColumn, { ascending: sortDirection });

      const { data, error } = await query;

      if (error) {
        console.error('Tasks query error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load tasks' };
    }
  },

  async getOpenTasksForUser(userId, dateRange = {}) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      let query = supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email, role),
          creator:assigned_by(id, full_name, email, role),
          account:account_id(id, name, company_type),
          contact:contact_id(id, first_name, last_name),
          property:property_id(id, name, address),
          opportunity:opportunity_id(id, name, stage),
          prospect:prospect_id(id, name)
        `)
        ?.eq('assigned_to', userId)
        ?.in('status', ['pending', 'in_progress', 'overdue']);

      if (dateRange?.from) {
        query = query?.gte('due_at', dateRange?.from);
      }
      if (dateRange?.to) {
        query = query?.lte('due_at', dateRange?.to);
      }

      const { data, error } = await query?.order('due_at', { ascending: true });

      if (error) {
        console.error('Get open tasks error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load open tasks' };
    }
  },

  // Enhanced getTasksForUser - RLS policies will handle role-based filtering automatically
  async getTasksForUser(userId, filters = {}) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      const today = new Date();
      today?.setHours(0, 0, 0, 0);
      const threeDaysFromNow = new Date(today);
      threeDaysFromNow?.setDate(today?.getDate() + 3);

      let query = supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email, role),
          creator:assigned_by(id, full_name, email, role),
          account:account_id(id, name, company_type),
          contact:contact_id(id, first_name, last_name),
          property:property_id(id, name, address),
          opportunity:opportunity_id(id, name, stage)
        `);

      // Note: RLS policies will automatically filter based on user role
      // Managers will see all tasks in their tenant, reps will see only their tasks

      // Apply filters
      if (filters?.status) {
        query = query?.eq('status', filters?.status);
      }

      if (filters?.dueWithin) {
        query = query?.lte('due_at', threeDaysFromNow?.toISOString());
      }

      if (filters?.overdue) {
        query = query?.lt('due_at', today?.toISOString());
      }

      if (filters?.category) {
        query = query?.eq('category', filters?.category);
      }

      const { data, error } = await query?.order('due_at', { ascending: true });

      if (error) {
        console.error('Get tasks for user error:', error);
        return { success: false, error: error?.message };
      }

      // Sort tasks by urgency and priority
      const sortedTasks = (data || [])?.sort((a, b) => {
        const aDueDate = resolveTaskDueAt(a);
        const bDueDate = resolveTaskDueAt(b);

        // Define urgency categories
        const getUrgency = (dueDate) => {
          if (dueDate < today) return 3; // overdue (highest priority)
          if (dueDate?.toDateString() === today?.toDateString()) return 2; // due today
          if (dueDate <= threeDaysFromNow) return 1; // due within 3 days
          return 0; // future
        };

        const aUrgency = getUrgency(aDueDate);
        const bUrgency = getUrgency(bDueDate);

        // First sort by urgency
        if (aUrgency !== bUrgency) {
          return bUrgency - aUrgency; // higher urgency first
        }

        // Then by priority within same urgency
        const priorityOrder = { high: 3, medium: 2, low: 1 };
        const aPriority = priorityOrder?.[a?.priority] || 0;
        const bPriority = priorityOrder?.[b?.priority] || 0;

        if (aPriority !== bPriority) {
          return bPriority - aPriority;
        }

        // Finally by due date
        return aDueDate - bDueDate;
      });

      return { success: true, data: normalizeTaskListDueFields(sortedTasks) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load user tasks' };
    }
  },

  // Get task metrics using the database function
  async getTaskMetrics() {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      const { data, error } = await supabase?.rpc('get_task_metrics');

      if (error) {
        throw error;
      }

      return data?.[0] || {
        total_tasks: 0,
        pending_tasks: 0,
        in_progress_tasks: 0,
        completed_tasks: 0,
        overdue_tasks: 0,
        completion_rate: 0
      };
    } catch (error) {
      console.error('Failed to get task metrics:', error);
      throw error;
    }
  },

  // Enhanced getTaskStats with role-based filtering
  async getTaskStats(userId, filters = {}) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      // RLS policies will automatically filter tasks based on user role
      let query = supabase?.from('tasks')?.select('status, priority, due_at, category, assigned_to');

      if (filters?.dateFrom) {
        query = query?.gte('due_at', filters?.dateFrom);
      }

      if (filters?.dateTo) {
        query = query?.lte('due_at', filters?.dateTo);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Task stats error:', error);
        return { success: false, error: error?.message };
      }

      // Calculate enhanced statistics
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const threeDaysFromNow = new Date(today);
      threeDaysFromNow?.setDate(today?.getDate() + 3);

      const stats = {
        total: data?.length || 0,
        byStatus: {},
        byPriority: {},
        byCategory: {},
        urgency: {
          overdue: 0,
          dueToday: 0,
          dueWithin3Days: 0,
          future: 0
        },
        pending: 0,
        completed: 0,
        inProgress: 0
      };

      data?.forEach(task => {
        const dueDate = resolveTaskDueAt(task);
        
        // Count by status
        if (task?.status) {
          stats.byStatus[task.status] = (stats?.byStatus?.[task?.status] || 0) + 1;
          
          // Count main status categories
          if (task?.status === 'pending') stats.pending++;
          else if (task?.status === 'completed') stats.completed++;
          else if (task?.status === 'in_progress') stats.inProgress++;
        }

        // Count by priority
        if (task?.priority) {
          stats.byPriority[task.priority] = (stats?.byPriority?.[task?.priority] || 0) + 1;
        }

        // Count by category
        if (task?.category) {
          stats.byCategory[task.category] = (stats?.byCategory?.[task?.category] || 0) + 1;
        }

        // Count by urgency (only for pending/in-progress tasks)
        if (task?.status !== 'completed' && dueDate) {
          if (dueDate < today) {
            stats.urgency.overdue++;
          } else if (dueDate?.toDateString() === today?.toDateString()) {
            stats.urgency.dueToday++;
          } else if (dueDate <= threeDaysFromNow) {
            stats.urgency.dueWithin3Days++;
          } else {
            stats.urgency.future++;
          }
        }
      });

      return { success: true, data: stats };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load task statistics' };
    }
  },

  async getTask(taskId) {
    if (!taskId) return { success: false, error: 'Task ID is required' };

    try {
      const { data, error } = await supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email),
          creator:assigned_by(id, full_name, email),
          account:account_id(id, name, company_type),
          contact:contact_id(id, first_name, last_name),
          property:property_id(id, name, address),
          opportunity:opportunity_id(id, name, stage)
        `)?.eq('id', taskId)?.single();

      if (error) {
        if (error?.code === 'PGRST116') {
          return { success: false, error: 'Task not found' };
        }
        console.error('Get task error:', error);
        return { success: false, error: error?.message };
      }

      const normalizedTask = normalizeTaskDueFields(data);
      const resolvedTask = Array.isArray(normalizedTask) ? (normalizedTask[0] || null) : normalizedTask;
      return { success: true, data: resolvedTask };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load task' };
    }
  },

  // Enhanced createTask method with tenant-aware creation
  async createTask(taskData) {
      try {
        const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      // Get current user's tenant information
      const { data: userProfile, error: profileError } = await supabase
        ?.from('user_profiles')
        ?.select('tenant_id, role')
        ?.eq('id', user?.id)
        ?.single();

      if (profileError || !userProfile) {
        throw new Error('Unable to get user profile information');
      }

      const taskPayload = { ...taskData };
      const linkedEntity = resolveLinkedEntity(taskPayload);
      const normalizedStatus = normalizeTaskStatus(taskData?.status);
      const taskType = resolveTaskType(taskData);
      const dueAt = normalizeDueAt(taskData?.due_at || taskData?.due_date || taskData?.due_on || null);

      const entityField = LINKED_ENTITY_FIELDS?.[linkedEntity?.linked_entity_type];
      if (entityField && !taskPayload?.[entityField]) {
        taskPayload[entityField] = linkedEntity?.linked_entity_id;
      }

        const linkedEntityType = taskPayload?.linked_entity_type || linkedEntity?.linked_entity_type || null;
        const linkedEntityId = taskPayload?.linked_entity_id || linkedEntity?.linked_entity_id || null;
        let resolvedDueAt = dueAt;

        if (!resolvedDueAt && taskType === 'follow_up' && linkedEntityType && linkedEntityId) {
          const intervalDays = await resolveFollowUpIntervalDays({
            tenantId: userProfile?.tenant_id,
            entityType: linkedEntityType,
            entityId: linkedEntityId
          });
          resolvedDueAt = buildFollowUpDueAt(intervalDays);
        }

        // Set default assigned_to to current user if not specified
        const taskWithDefaults = {
        title: taskPayload?.title,
        description: taskPayload?.description || null,
        category: taskPayload?.category || 'other',
        priority: taskPayload?.priority || 'medium',
        status: normalizedStatus || taskPayload?.status || 'pending',
        task_type: taskType,
        due_at: dueAt,
        due_date: dueAt,
        reminder_date: taskPayload?.reminder_date || null,
        assigned_by: user?.id,
        assigned_to: taskPayload?.assigned_to || user?.id,
        tenant_id: userProfile?.tenant_id, // Ensure task is created in user's tenant
        account_id: taskPayload?.account_id || null,
        contact_id: taskPayload?.contact_id || null,
        property_id: taskPayload?.property_id || null,
        opportunity_id: taskPayload?.opportunity_id || null,
        prospect_id: taskPayload?.prospect_id || null,
        source_activity_id: taskPayload?.source_activity_id || null,
        linked_entity_type: linkedEntityType,
        linked_entity_id: linkedEntityId
      };

      const sanitizedTaskPayload = Object.keys(taskWithDefaults || {})
        ?.filter((key) => TASK_INSERT_FIELDS.has(key))
        ?.reduce((obj, key) => {
          obj[key] = taskWithDefaults?.[key];
          return obj;
        }, {});

      console.debug('createTask payload', sanitizedTaskPayload);

      const { data, error } = await supabase?.from('tasks')?.insert([sanitizedTaskPayload])?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email, role),
          creator:assigned_by(id, full_name, email, role),
          account:account_id(id, name),
          property:property_id(id, name),
          contact:contact_id(id, first_name, last_name),
          opportunity:opportunity_id(id, name),
          prospect:prospect_id(id, name)
        `)?.single();

      if (error) {
        console.error('Create task error:', error);
        console.log('Create task error details:', error);
        console.debug('createTask payload', sanitizedTaskPayload);
        if (typeof document !== 'undefined') {
          const containerId = 'task-error-toast-root';
          let container = document.getElementById(containerId);
          if (!container) {
            container = document.createElement('div');
            container.id = containerId;
            container.className = 'fixed top-4 right-4 z-[60] max-w-sm space-y-2';
            document.body.appendChild(container);
          }
          const toast = document.createElement('div');
          toast.className = 'flex items-start gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 shadow-lg';
          toast.textContent = error?.message || 'Failed to create task';
          container.appendChild(toast);
          window.setTimeout(() => {
            toast.remove();
            if (container?.childElementCount === 0) {
              container.remove();
            }
          }, 4500);
        }
        return { success: false, error: error?.message || 'Failed to create task' };
      }

      const normalizedTask = normalizeTaskDueFields(data);
      const resolvedTask = Array.isArray(normalizedTask) ? (normalizedTask[0] || null) : normalizedTask;
      return { success: true, data: resolvedTask };
    } catch (error) {
      console.error('Failed to create task:', error);
      return { success: false, error: error?.message || 'Failed to create task' };
    }
  },

  async completeTaskWithActivity(taskInput, activityPayload = {}, followUpPayload = null) {
    const taskId = typeof taskInput === 'string' ? taskInput : taskInput?.id;
    if (!taskId) return { success: false, error: 'Task ID is required' };

    try {
      let task = typeof taskInput === 'object' && taskInput?.id ? taskInput : null;
      if (!task) {
        const taskResult = await this.getTask(taskId);
        if (!taskResult?.success) {
          return { success: false, error: taskResult?.error || 'Task not found' };
        }
        task = taskResult?.data || {};
      }

      const taskType = task?.task_type || resolveTaskType(task);
      const linkedEntity = resolveLinkedEntity({
        linked_entity_type: task?.linked_entity_type,
        linked_entity_id: task?.linked_entity_id,
        account_id: task?.account_id,
        contact_id: task?.contact_id,
        property_id: task?.property_id,
        opportunity_id: task?.opportunity_id,
        prospect_id: task?.prospect_id
      });
      const shouldForceDirection = taskType === 'follow_up' || taskType === 'admin' || taskType === 'system';
      const resolvedDirection = shouldForceDirection
        ? deriveDirectionForTask(taskType)
        : (activityPayload?.direction || null);

      const { activitiesService } = await import('./activitiesService');
      const activityData = {
        ...activityPayload,
        account_id: activityPayload?.account_id || task?.account_id || null,
        contact_id: activityPayload?.contact_id || task?.contact_id || null,
        property_id: activityPayload?.property_id || task?.property_id || null,
        opportunity_id: activityPayload?.opportunity_id || task?.opportunity_id || null,
        source_task_id: taskId,
        direction: resolvedDirection,
        linked_entity_type: linkedEntity?.linked_entity_type || activityPayload?.linked_entity_type || null,
        linked_entity_id: linkedEntity?.linked_entity_id || activityPayload?.linked_entity_id || null
      };

      const activityResult = await activitiesService?.createActivity(activityData);
      if (!activityResult?.success) {
        return { success: false, error: activityResult?.error || 'Failed to create activity' };
      }

      const completedAt = new Date()?.toISOString();
      const { data: completedTask, error: completeError } = await this.updateTask(taskId, {
        status: 'completed',
        completed_at: completedAt
      });

      if (completeError || !completedTask) {
        return { success: false, error: completeError?.message || 'Failed to complete task' };
      }

        let createdFollowUpTask = null;
        if (followUpPayload) {
          const dueAt = normalizeDueAt(followUpPayload?.due_at || followUpPayload?.due_date);

          const followUpTask = {
            ...followUpPayload,
            title: followUpPayload?.title || task?.title || 'Follow up',
            task_type: 'follow_up',
            status: followUpPayload?.status || 'open',
            assigned_to: followUpPayload?.assigned_to || task?.assigned_to || null,
            due_at: dueAt || null,
            due_date: dueAt || null,
            account_id: followUpPayload?.account_id || task?.account_id || null,
            contact_id: followUpPayload?.contact_id || task?.contact_id || null,
            property_id: followUpPayload?.property_id || task?.property_id || null,
            opportunity_id: followUpPayload?.opportunity_id || task?.opportunity_id || null,
            prospect_id: followUpPayload?.prospect_id || task?.prospect_id || null,
            source_activity_id: activityResult?.data?.id || null,
            linked_entity_type: linkedEntity?.linked_entity_type || followUpPayload?.linked_entity_type || null,
            linked_entity_id: linkedEntity?.linked_entity_id || followUpPayload?.linked_entity_id || null
          };

        const followUpResult = await this.createTask(followUpTask);
        if (!followUpResult?.success) {
          return { success: false, error: followUpResult?.error || 'Failed to create follow-up task' };
        }
        createdFollowUpTask = followUpResult?.data;
      }

      return {
        success: true,
        data: {
          activity: activityResult?.data,
          completedTask,
          createdFollowUpTask
        }
      };
    } catch (error) {
      console.error('Failed to complete task with activity:', error);
      return { success: false, error: error?.message || 'Failed to complete task' };
    }
  },

  // Update task status using the database function
  async updateTaskStatus(taskId, newStatus, completionNotes = null) {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      const { data, error } = await supabase?.rpc('update_task_status', {
        task_uuid: taskId,
        new_status: newStatus,
        completion_notes_param: completionNotes
      });

      if (error) {
        throw error;
      }

      const result = data?.[0];
      if (!result?.success) {
        throw new Error(result?.message || 'Failed to update task status');
      }

      return result;
    } catch (error) {
      console.error('Failed to update task status:', error);
      throw error;
    }
  },

  // Update a task
  async updateTask(taskId, updates) {
    try {
      const resolvedUpdates = { ...updates };
      if (resolvedUpdates?.due_date && !resolvedUpdates?.due_at) {
        const normalized = normalizeDueAt(resolvedUpdates?.due_date);
        resolvedUpdates.due_at = normalized;
        resolvedUpdates.due_date = normalized;
      }
      if (resolvedUpdates?.due_at) {
        const normalized = normalizeDueAt(resolvedUpdates?.due_at);
        resolvedUpdates.due_at = normalized;
        resolvedUpdates.due_date = resolvedUpdates?.due_date || normalized;
      }

      const { data, error } = await supabase?.from('tasks')?.update({
          ...resolvedUpdates,
          updated_at: new Date()?.toISOString()
        })?.eq('id', taskId)?.select(`
          *,
          assigned_user:assigned_to(id, full_name, email),
          creator:assigned_by(id, full_name, email),
          account:account_id(id, name),
          property:property_id(id, name),
          contact:contact_id(id, first_name, last_name),
          opportunity:opportunity_id(id, name)
        `)?.single();

      if (error) {
        throw error;
      }

      return { data: normalizeTaskDueFields(data), error: null };
    } catch (error) {
      return { data: null, error };
    }
  },

  // Complete a task using the database function
  async completeTask(taskId) {
    try {
      const { data, error } = await supabase?.rpc('update_task_status', {
        task_uuid: taskId,
        new_status: 'completed',
        completion_notes_param: null
      });

      if (error) {
        throw error;
      }

      const result = data?.[0];
      if (!result?.success) {
        throw new Error(result?.message || 'Failed to complete task');
      }

      return { data: result, error: null };
    } catch (error) {
      return { data: null, error };
    }
  },

  // Delete a task
  async deleteTask(taskId) {
    try {
      const { error } = await supabase?.from('tasks')?.delete()?.eq('id', taskId);

      if (error) {
        throw error;
      }

      return { error: null };
    } catch (error) {
      return { error };
    }
  },

  // Get task comments
  async getTaskComments(taskId) {
    try {
      const { data, error } = await supabase?.from('task_comments')?.select(`
          *,
          author:author_id(id, full_name, email)
        `)?.eq('task_id', taskId)?.order('created_at', { ascending: true });

      if (error) {
        throw error;
      }

      return { data: data || [], error: null };
    } catch (error) {
      return { data: [], error };
    }
  },

  // Add a comment to a task
  async addTaskComment(taskId, content) {
    try {
      const { data: { user }, error: userError } = await supabase?.auth?.getUser();
      
      if (userError || !user) {
        throw new Error('User not authenticated');
      }

      const { data, error } = await supabase?.from('task_comments')?.insert([{
          task_id: taskId,
          author_id: user?.id,
          content
        }])?.select(`
          *,
          author:author_id(id, full_name, email)
        `)?.single();

      if (error) {
        throw error;
      }

      return { data, error: null };
    } catch (error) {
      return { data: null, error };
    }
  },

  // Get available entities for task assignment
  async getEntitiesForAssignment() {
    try {
      const [accountsResult, propertiesResult, contactsResult, opportunitiesResult, prospectsResult] = await Promise.all([
        supabase?.from('accounts')?.select('id, name')?.eq('is_active', true)?.order('name'),
        supabase?.from('properties')?.select('id, name')?.order('name'),
        supabase?.from('contacts')?.select('id, first_name, last_name')?.order('first_name'),
        supabase?.from('opportunities')?.select('id, name')?.order('name'),
        supabase?.from('prospects')?.select('id, name')?.order('name')
      ]);

      return {
        data: {
          accounts: accountsResult?.data || [],
          properties: propertiesResult?.data || [],
          contacts: (contactsResult?.data || [])?.map(contact => ({
            ...contact,
            name: `${contact?.first_name} ${contact?.last_name}`
          })),
          opportunities: opportunitiesResult?.data || [],
          prospects: prospectsResult?.data || []
        },
        error: null
      };
    } catch (error) {
      return { 
        data: { accounts: [], properties: [], contacts: [], opportunities: [], prospects: [] }, 
        error 
      };
    }
  },

  // Get team members for task assignment
  async getTeamMembers() {
    try {
      const { data, error } = await supabase?.from('user_profiles')?.select('id, full_name, email, role')?.eq('is_active', true)?.order('full_name');

      if (error) {
        throw error;
      }

      return { data: data || [], error: null };
    } catch (error) {
      return { data: [], error };
    }
  },

  // Get available assignees (team members for task assignment)
  async getAvailableAssignees() {
    try {
      const { data, error } = await supabase?.from('user_profiles')?.select('id, full_name, email, role')?.eq('is_active', true)?.order('full_name');

      if (error) {
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Failed to get available assignees:', error);
      throw error;
    }
  },

  async getTasksByAccount(accountId, limit) {
    if (!accountId) return { success: false, error: 'Account ID is required' };

    try {
      let query = supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name),
          contact:contact_id(id, first_name, last_name)
        `)?.eq('account_id', accountId)?.order('due_at', { ascending: true });

      if (limit) {
        query = query?.limit(limit);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Get tasks by account error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load account tasks' };
    }
  },

  async getTasksByContact(contactId, limit) {
    if (!contactId) return { success: false, error: 'Contact ID is required' };

    try {
      let query = supabase?.from('tasks')?.select(`
          *,
          assigned_user:assigned_to(id, full_name),
          account:account_id(id, name)
        `)?.eq('contact_id', contactId)?.order('due_at', { ascending: true });

      if (limit) {
        query = query?.limit(limit);
      }

      const { data, error } = await query;

      if (error) {
        console.error('Get tasks by contact error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load contact tasks' };
    }
  },

  // Get recent tasks for dashboard
  async getRecentTasks(userId, limit = 5) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      const { data, error } = await supabase?.from('tasks')?.select(`
          *,
          account:account_id(id, name),
          contact:contact_id(id, first_name, last_name)
        `)?.eq('assigned_to', userId)?.order('created_at', { ascending: false })?.limit(limit);

      if (error) {
        console.error('Get recent tasks error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load recent tasks' };
    }
  },

  // Get overdue tasks
  async getOverdueTasks(userId, limit = 10) {
    if (!userId) return { success: false, error: 'User ID is required' };

    try {
      const now = new Date()?.toISOString();

      const { data, error } = await supabase?.from('tasks')?.select(`
          *,
          account:account_id(id, name),
          contact:contact_id(id, first_name, last_name)
        `)?.eq('assigned_to', userId)?.neq('status', 'completed')?.lt('due_at', now)?.order('due_at', { ascending: true })?.limit(limit);

      if (error) {
        console.error('Get overdue tasks error:', error);
        return { success: false, error: error?.message };
      }

      return { success: true, data: normalizeTaskListDueFields(data || []) };
    } catch (error) {
      console.error('Service error:', error);
      return { success: false, error: 'Failed to load overdue tasks' };
    }
  },

  // Subscribe to task changes
  subscribeToTasks(callback) {
    const channel = supabase?.channel('tasks_changes')?.on('postgres_changes', 
          { event: '*', schema: 'public', table: 'tasks' }, 
          callback)?.subscribe();

    return () => supabase?.removeChannel(channel);
  },

  // Subscribe to task comment changes
  subscribeToTaskComments(taskId, callback) {
    const channel = supabase?.channel(`task_comments_${taskId}`)?.on('postgres_changes', 
          { 
            event: '*', 
            schema: 'public', 
            table: 'task_comments',
            filter: `task_id=eq.${taskId}`
          }, 
          callback)?.subscribe();

    return () => supabase?.removeChannel(channel);
  }
};

export default tasksService;
