-- Fix critical enum type mismatch and RLS policy violations
-- This addresses the critical errors preventing app functionality
-- Error: "Returned type account_stage does not match expected type account_stages"
-- Error: "new row violates row-level security policy for table weekly_goals"

-- Step 1: Fix the get_user_accessible_accounts function to use correct enum type
DROP FUNCTION IF EXISTS get_user_accessible_accounts(uuid);
CREATE OR REPLACE FUNCTION get_user_accessible_accounts(user_uuid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  company_type company_type,
  stage account_stage,  -- FIXED: Use singular form (account_stage)
  city text,
  state text,
  email text,
  phone text,
  notes text,
  is_active boolean,
  created_at timestamptz,
  updated_at timestamptz,
  assigned_rep_id uuid,
  primary_rep_name text,
  assigned_reps jsonb,
  properties_count bigint,
  contacts_count bigint,
  tenant_id uuid
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role text;
  user_tenant_id uuid;
  is_manager boolean := false;
  is_super_admin boolean := false;
  is_master_admin boolean := false;
BEGIN
  -- Get user profile information
  SELECT up.role, up.tenant_id
  INTO user_role, user_tenant_id
  FROM user_profiles up
  WHERE up.id = user_uuid;

  -- Handle case where user profile doesn't exist
  IF user_role IS NULL THEN
    RETURN;
  END IF;

  -- Set role flags
  is_manager := (user_role = 'manager');
  is_super_admin := (user_role = 'super_admin');
  is_master_admin := (user_role = 'master_admin');

  -- CASE 1: Super Admin or Master Admin - can see all accounts across all tenants
  IF is_super_admin OR is_master_admin THEN
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
    ORDER BY a.name;

  -- CASE 2: Manager - can see accounts within their tenant and assigned accounts
  ELSIF is_manager THEN
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
      AND (
        a.tenant_id = user_tenant_id 
        OR 
        EXISTS (
          SELECT 1 FROM account_assignments aa
          LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
          WHERE aa.account_id = a.id 
            AND rep.tenant_id = user_tenant_id
            AND rep.is_active = true
        )
      )
    ORDER BY a.name;

  -- CASE 3: Regular rep - can only see accounts assigned to them
  ELSE
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
      AND (
        a.assigned_rep_id = user_uuid
        OR
        EXISTS (
          SELECT 1 FROM account_assignments aa
          WHERE aa.account_id = a.id AND aa.rep_id = user_uuid
        )
      )
    ORDER BY a.name;

  END IF;
END;
$$;
-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(uuid) TO service_role;
-- Step 2: Fix weekly_goals RLS policies to allow proper access
-- Drop existing policies that may be too restrictive
DROP POLICY IF EXISTS "users_manage_own_weekly_goals" ON public.weekly_goals;
DROP POLICY IF EXISTS "manager_can_manage_team_weekly_goals" ON public.weekly_goals;
DROP POLICY IF EXISTS "weekly_goals_rls_policy" ON public.weekly_goals;
DROP POLICY IF EXISTS "managers_can_access_team_weekly_goals" ON public.weekly_goals;
-- Create helper function for manager access that queries DIFFERENT tables
CREATE OR REPLACE FUNCTION public.can_manage_weekly_goals(goal_user_id uuid, goal_tenant_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND up.tenant_id = goal_tenant_id
    AND up.role IN ('manager', 'super_admin', 'master_admin')
    AND up.is_active = true
) OR (auth.uid() = goal_user_id)
$$;
-- Create comprehensive RLS policy for weekly_goals using Pattern 2 + Role-based access
CREATE POLICY "weekly_goals_comprehensive_access"
ON public.weekly_goals
FOR ALL
TO authenticated
USING (public.can_manage_weekly_goals(user_id, tenant_id))
WITH CHECK (public.can_manage_weekly_goals(user_id, tenant_id));
-- Step 3: Add validation function to ensure tenant consistency
CREATE OR REPLACE FUNCTION public.validate_weekly_goals_tenant_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_tenant_id uuid;
BEGIN
    -- Get the user's tenant_id
    SELECT tenant_id INTO user_tenant_id
    FROM public.user_profiles 
    WHERE id = NEW.user_id;
    
    -- Ensure the goal's tenant_id matches the user's tenant_id
    IF user_tenant_id IS NOT NULL AND NEW.tenant_id != user_tenant_id THEN
        RAISE EXCEPTION 'Weekly goal tenant_id must match user tenant_id';
    END IF;
    
    -- If user doesn't exist in user_profiles, prevent the operation
    IF user_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User must have a valid profile to create weekly goals';
    END IF;
    
    RETURN NEW;
END;
$$;
-- Add trigger to validate tenant consistency
DROP TRIGGER IF EXISTS weekly_goals_tenant_consistency_trigger ON public.weekly_goals;
CREATE TRIGGER weekly_goals_tenant_consistency_trigger
    BEFORE INSERT OR UPDATE ON public.weekly_goals
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_weekly_goals_tenant_consistency();
-- Step 4: Refresh all function grants to ensure proper access
GRANT EXECUTE ON FUNCTION public.can_manage_weekly_goals(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_manage_weekly_goals(uuid, uuid) TO service_role;
GRANT EXECUTE ON FUNCTION public.validate_weekly_goals_tenant_consistency() TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_weekly_goals_tenant_consistency() TO service_role;
-- Step 5: Add comment documenting the fixes
COMMENT ON FUNCTION get_user_accessible_accounts(uuid) IS 
'Fixed enum type mismatch: Returns account_stage (singular) instead of account_stages (plural) to match database schema. Resolves "structure of query does not match function result type" error.';
COMMENT ON FUNCTION public.can_manage_weekly_goals(uuid, uuid) IS 
'Helper function for weekly_goals RLS policy. Allows users to manage their own goals and managers to manage team member goals within the same tenant. Prevents circular dependencies by querying user_profiles table.';
-- Step 6: Log successful completion
DO $$
BEGIN
    RAISE NOTICE 'Critical fixes applied successfully:';
    RAISE NOTICE '1. Fixed get_user_accessible_accounts enum type mismatch (account_stage vs account_stages)';
    RAISE NOTICE '2. Fixed weekly_goals RLS policy violations with comprehensive access control';
    RAISE NOTICE '3. Added tenant consistency validation for weekly goals';
    RAISE NOTICE '4. Granted all necessary permissions for authenticated users';
END $$;
