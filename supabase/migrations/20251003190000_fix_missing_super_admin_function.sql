-- Fix Missing is_super_admin_from_auth Function
-- This function is referenced by validate_tenant_consistency but was missing

-- Create the missing is_super_admin_from_auth function
CREATE OR REPLACE FUNCTION public.is_super_admin_from_auth()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role text;
BEGIN
  -- Get the current user's role from user_profiles
  SELECT up.role INTO user_role
  FROM user_profiles up
  WHERE up.id = auth.uid();
  
  -- Return true if user is super_admin, false otherwise
  RETURN COALESCE(user_role = 'super_admin', false);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_super_admin_from_auth() TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION public.is_super_admin_from_auth() IS 'Checks if the current authenticated user has super_admin role';

-- Also create a more comprehensive role checking function for future use
CREATE OR REPLACE FUNCTION public.check_user_role(required_role text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role text;
BEGIN
  -- Get the current user's role from user_profiles
  SELECT up.role INTO user_role
  FROM user_profiles up
  WHERE up.id = auth.uid();
  
  -- Return true if user has the required role or higher permissions
  RETURN CASE
    WHEN required_role = 'sales_rep' THEN 
      user_role IN ('sales_rep', 'manager', 'admin', 'super_admin')
    WHEN required_role = 'manager' THEN 
      user_role IN ('manager', 'admin', 'super_admin')
    WHEN required_role = 'admin' THEN 
      user_role IN ('admin', 'super_admin')
    WHEN required_role = 'super_admin' THEN 
      user_role = 'super_admin'
    ELSE false
  END;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.check_user_role(text) TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION public.check_user_role(text) IS 'Checks if the current authenticated user has the specified role or higher permissions';

-- Create helper functions for common role checks
CREATE OR REPLACE FUNCTION public.is_manager_or_above()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN check_user_role('manager');
END;
$$;

CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN check_user_role('admin');
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.is_manager_or_above() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_or_above() TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.is_manager_or_above() IS 'Checks if the current user has manager role or higher';
COMMENT ON FUNCTION public.is_admin_or_above() IS 'Checks if the current user has admin role or higher';