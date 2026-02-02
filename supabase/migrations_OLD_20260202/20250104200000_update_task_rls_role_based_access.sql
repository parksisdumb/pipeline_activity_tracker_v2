-- Location: supabase/migrations/20250104200000_update_task_rls_role_based_access.sql
-- Schema Analysis: Existing task management system with user_profiles, tasks tables
-- Integration Type: Modification - Updating RLS policies for role-based task access
-- Dependencies: tasks, user_profiles, tenants tables

-- Step 1: Drop existing task RLS policies
DROP POLICY IF EXISTS "users_manage_own_tasks" ON public.tasks;
DROP POLICY IF EXISTS "users_can_view_own_tasks" ON public.tasks;
DROP POLICY IF EXISTS "users_can_create_own_tasks" ON public.tasks;
DROP POLICY IF EXISTS "users_can_update_own_tasks" ON public.tasks;
DROP POLICY IF EXISTS "users_can_delete_own_tasks" ON public.tasks;
DROP POLICY IF EXISTS "task_access_policy" ON public.tasks;
DROP POLICY IF EXISTS "manager_task_access" ON public.tasks;
DROP POLICY IF EXISTS "rep_task_access" ON public.tasks;

-- Step 2: Create helper function for role-based task access
-- This function checks if user is a manager or can access specific tasks
CREATE OR REPLACE FUNCTION public.can_access_task(task_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    JOIN public.tasks t ON t.id = task_uuid
    WHERE up.id = auth.uid()
    AND (
        -- Managers have access to all tasks in their tenant
        (up.role = 'manager' AND up.tenant_id = t.tenant_id)
        OR
        -- Reps can only access tasks assigned to them
        (up.role = 'rep' AND t.assigned_to = auth.uid())
        OR
        -- Super admin and admin have full access
        up.role IN ('super_admin', 'admin')
    )
)
$$;

-- Step 3: Create helper function for task creation/modification permission
CREATE OR REPLACE FUNCTION public.can_modify_task(task_tenant_id UUID, assigned_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND (
        -- Managers can modify all tasks in their tenant
        (up.role = 'manager' AND up.tenant_id = task_tenant_id)
        OR
        -- Reps can only modify tasks assigned to them
        (up.role = 'rep' AND assigned_user_id = auth.uid())
        OR
        -- Super admin and admin have full access
        up.role IN ('super_admin', 'admin')
    )
)
$$;

-- Step 4: Create new RLS policies for role-based task access

-- Policy for SELECT (viewing tasks)
CREATE POLICY "role_based_task_select"
ON public.tasks
FOR SELECT
TO authenticated
USING (public.can_access_task(id));

-- Policy for INSERT (creating tasks)
CREATE POLICY "role_based_task_insert"
ON public.tasks
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND (
            -- Managers can create tasks for anyone in their tenant
            (up.role = 'manager' AND up.tenant_id = tenant_id)
            OR
            -- Reps can create tasks for themselves
            (up.role = 'rep' AND assigned_to = auth.uid())
            OR
            -- Super admin and admin have full access
            up.role IN ('super_admin', 'admin')
        )
    )
);

-- Policy for UPDATE (modifying tasks)
CREATE POLICY "role_based_task_update"
ON public.tasks
FOR UPDATE
TO authenticated
USING (public.can_access_task(id))
WITH CHECK (public.can_modify_task(tenant_id, assigned_to));

-- Policy for DELETE (removing tasks)
CREATE POLICY "role_based_task_delete"
ON public.tasks
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND (
            -- Only managers and admins can delete tasks
            up.role IN ('manager', 'super_admin', 'admin')
            -- Managers can only delete tasks in their tenant
            AND (up.role != 'manager' OR up.tenant_id = tenant_id)
        )
    )
);

-- Step 5: Add index for better performance on tenant-based queries
CREATE INDEX IF NOT EXISTS idx_tasks_tenant_assigned 
ON public.tasks(tenant_id, assigned_to);

-- Step 6: Add comments for clarity
COMMENT ON FUNCTION public.can_access_task(UUID) IS 
'Determines if current user can access a specific task based on role and tenant';

COMMENT ON FUNCTION public.can_modify_task(UUID, UUID) IS 
'Determines if current user can modify a task based on role, tenant, and assignment';

COMMENT ON POLICY "role_based_task_select" ON public.tasks IS 
'Managers can view all tasks in tenant, reps can only view their own tasks';

COMMENT ON POLICY "role_based_task_insert" ON public.tasks IS 
'Managers can create tasks for anyone in tenant, reps can create tasks for themselves';

COMMENT ON POLICY "role_based_task_update" ON public.tasks IS 
'Managers can update all tasks in tenant, reps can only update their own tasks';

COMMENT ON POLICY "role_based_task_delete" ON public.tasks IS 
'Only managers and admins can delete tasks within their tenant scope';