-- Fix critical "column p.is_active does not exist" error in get_user_accessible_accounts function
-- This addresses the critical database function error preventing app functionality

-- Drop the existing function first
DROP FUNCTION IF EXISTS get_user_accessible_accounts(uuid);
-- Recreate the function with corrected properties query (removing non-existent p.is_active)
CREATE OR REPLACE FUNCTION get_user_accessible_accounts(user_uuid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  company_type company_type,
  stage account_stages,
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
      a.stage,
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
      -- FIXED: Remove non-existent p.is_active condition
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
      a.stage,
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
      -- FIXED: Remove non-existent p.is_active condition
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
      a.stage,
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
      -- FIXED: Remove non-existent p.is_active condition
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
-- Add helpful comment
COMMENT ON FUNCTION get_user_accessible_accounts(uuid) IS 
'Returns accounts accessible to a user based on their role and tenant. FIXED: Removed non-existent p.is_active column reference from properties count query to resolve critical database error.';
