-- Fix Weekly Goals Persistence After Page Refresh
-- Migration to resolve RLS policies and missing functions for weekly goals

-- Create enhanced RLS policies for weekly_goals that work for both managers and reps
DROP POLICY IF EXISTS "weekly_goals_select_policy" ON weekly_goals;
DROP POLICY IF EXISTS "weekly_goals_insert_policy" ON weekly_goals;
DROP POLICY IF EXISTS "weekly_goals_update_policy" ON weekly_goals;
DROP POLICY IF EXISTS "weekly_goals_delete_policy" ON weekly_goals;
-- Create comprehensive SELECT policy that allows both self-access and manager access
CREATE POLICY "weekly_goals_select_comprehensive" ON weekly_goals
FOR SELECT
USING (
  -- User can see their own goals
  auth.uid() = user_id
  OR
  -- Managers can see goals for their team members in the same tenant
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_manager
      WHERE up_manager.id = auth.uid()
      AND up_manager.role IN ('manager', 'admin', 'super_admin')
      AND up_manager.tenant_id IN (
        SELECT up_target.tenant_id FROM user_profiles up_target
        WHERE up_target.id = weekly_goals.user_id
      )
    )
  )
  OR
  -- Super admins can see all goals
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_super
      WHERE up_super.id = auth.uid()
      AND up_super.role = 'super_admin'
    )
  )
);
-- Create comprehensive INSERT policy
CREATE POLICY "weekly_goals_insert_comprehensive" ON weekly_goals
FOR INSERT
WITH CHECK (
  -- User can create goals for themselves
  auth.uid() = user_id
  OR
  -- Managers can create goals for their team members in the same tenant
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_manager
      WHERE up_manager.id = auth.uid()
      AND up_manager.role IN ('manager', 'admin', 'super_admin')
      AND up_manager.tenant_id IN (
        SELECT up_target.tenant_id FROM user_profiles up_target
        WHERE up_target.id = weekly_goals.user_id
      )
    )
  )
  OR
  -- Super admins can create goals for anyone
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_super
      WHERE up_super.id = auth.uid()
      AND up_super.role = 'super_admin'
    )
  )
);
-- Create comprehensive UPDATE policy
CREATE POLICY "weekly_goals_update_comprehensive" ON weekly_goals
FOR UPDATE
USING (
  -- User can update their own goals
  auth.uid() = user_id
  OR
  -- Managers can update goals for their team members in the same tenant
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_manager
      WHERE up_manager.id = auth.uid()
      AND up_manager.role IN ('manager', 'admin', 'super_admin')
      AND up_manager.tenant_id IN (
        SELECT up_target.tenant_id FROM user_profiles up_target
        WHERE up_target.id = weekly_goals.user_id
      )
    )
  )
  OR
  -- Super admins can update all goals
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_super
      WHERE up_super.id = auth.uid()
      AND up_super.role = 'super_admin'
    )
  )
);
-- Create comprehensive DELETE policy
CREATE POLICY "weekly_goals_delete_comprehensive" ON weekly_goals
FOR DELETE
USING (
  -- Managers can delete goals for their team members in the same tenant
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_manager
      WHERE up_manager.id = auth.uid()
      AND up_manager.role IN ('manager', 'admin', 'super_admin')
      AND up_manager.tenant_id IN (
        SELECT up_target.tenant_id FROM user_profiles up_target
        WHERE up_target.id = weekly_goals.user_id
      )
    )
  )
  OR
  -- Super admins can delete all goals
  (
    EXISTS (
      SELECT 1 FROM user_profiles up_super
      WHERE up_super.id = auth.uid()
      AND up_super.role = 'super_admin'
    )
  )
);
-- Create the missing verify_manager_assigned_goals function
CREATE OR REPLACE FUNCTION verify_manager_assigned_goals(
  manager_uuid UUID,
  target_user_ids UUID[],
  target_week_start DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  manager_profile user_profiles%ROWTYPE;
  goal_count INTEGER := 0;
  result JSON;
BEGIN
  -- Get manager profile
  SELECT * INTO manager_profile
  FROM user_profiles
  WHERE id = manager_uuid;

  -- Check if user exists and has manager permissions
  IF NOT FOUND OR manager_profile.role NOT IN ('manager', 'admin', 'super_admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Unauthorized: User does not have manager permissions',
      'goal_count', 0
    );
  END IF;

  -- Count goals for the specified users and week
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals wg
  JOIN user_profiles up ON wg.user_id = up.id
  WHERE wg.user_id = ANY(target_user_ids)
  AND wg.week_start_date = target_week_start
  AND (
    -- Manager can verify goals for users in their tenant
    up.tenant_id = manager_profile.tenant_id
    OR 
    -- Super admin can verify all goals
    manager_profile.role = 'super_admin'
  );

  -- Return result
  result := json_build_object(
    'success', true,
    'goal_count', goal_count,
    'manager_id', manager_uuid,
    'users_checked', array_length(target_user_ids, 1),
    'week_start', target_week_start
  );

  RETURN result;
END;
$$;
-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION verify_manager_assigned_goals TO authenticated;
-- Create a simplified function to help with goal persistence verification
CREATE OR REPLACE FUNCTION check_weekly_goals_exist(
  user_ids UUID[],
  week_start_date DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  goal_count INTEGER := 0;
  current_user_profile user_profiles%ROWTYPE;
BEGIN
  -- Get current user profile
  SELECT * INTO current_user_profile
  FROM user_profiles
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User not found',
      'goal_count', 0
    );
  END IF;

  -- Count goals with appropriate tenant filtering
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals wg
  JOIN user_profiles up ON wg.user_id = up.id
  WHERE wg.user_id = ANY(user_ids)
  AND wg.week_start_date = week_start_date
  AND (
    -- Users can check their own goals
    wg.user_id = auth.uid()
    OR
    -- Managers can check goals for users in their tenant
    (
      current_user_profile.role IN ('manager', 'admin', 'super_admin')
      AND up.tenant_id = current_user_profile.tenant_id
    )
    OR
    -- Super admin can check all goals
    current_user_profile.role = 'super_admin'
  );

  RETURN json_build_object(
    'success', true,
    'goal_count', goal_count,
    'user_count', array_length(user_ids, 1),
    'week_start', week_start_date
  );
END;
$$;
-- Grant execute permission on the helper function
GRANT EXECUTE ON FUNCTION check_weekly_goals_exist TO authenticated;
-- Update existing indexes to improve performance
CREATE INDEX IF NOT EXISTS idx_weekly_goals_user_week_goal_type 
ON weekly_goals(user_id, week_start_date, goal_type);
CREATE INDEX IF NOT EXISTS idx_weekly_goals_tenant_week 
ON weekly_goals(tenant_id, week_start_date);
-- Add helpful comments
COMMENT ON FUNCTION verify_manager_assigned_goals IS 'Verifies that goals have been assigned by checking goal count for specific users and week';
COMMENT ON FUNCTION check_weekly_goals_exist IS 'Simple function to check if weekly goals exist for given users and week';
-- Create a debug function to help troubleshoot goal persistence issues
CREATE OR REPLACE FUNCTION debug_weekly_goals_access(
  target_user_id UUID,
  target_week_start DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_profile user_profiles%ROWTYPE;
  target_user_profile user_profiles%ROWTYPE;
  goal_count INTEGER := 0;
  debug_info JSON;
BEGIN
  -- Get current user profile
  SELECT * INTO current_user_profile
  FROM user_profiles
  WHERE id = auth.uid();

  -- Get target user profile
  SELECT * INTO target_user_profile
  FROM user_profiles
  WHERE id = target_user_id;

  -- Count goals for the target user and week
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals
  WHERE user_id = target_user_id
  AND week_start_date = target_week_start;

  -- Build debug information
  debug_info := json_build_object(
    'current_user_id', auth.uid(),
    'current_user_role', current_user_profile.role,
    'current_user_tenant', current_user_profile.tenant_id,
    'target_user_id', target_user_id,
    'target_user_role', target_user_profile.role,
    'target_user_tenant', target_user_profile.tenant_id,
    'same_tenant', (current_user_profile.tenant_id = target_user_profile.tenant_id),
    'goal_count_found', goal_count,
    'week_start', target_week_start,
    'can_access_as_manager', (
      current_user_profile.role IN ('manager', 'admin', 'super_admin')
      AND current_user_profile.tenant_id = target_user_profile.tenant_id
    ),
    'is_super_admin', (current_user_profile.role = 'super_admin')
  );

  RETURN debug_info;
END;
$$;
-- Grant execute permission on debug function
GRANT EXECUTE ON FUNCTION debug_weekly_goals_access TO authenticated;
COMMENT ON FUNCTION debug_weekly_goals_access IS 'Debug function to help troubleshoot weekly goals access issues';
