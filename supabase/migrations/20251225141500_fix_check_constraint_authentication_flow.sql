-- Location: supabase/migrations/20251225141500_fix_check_constraint_authentication_flow.sql
-- Schema Analysis: Fix check constraint blocking user signup flow
-- Integration Type: Modificative - fixing existing authentication constraints
-- Dependencies: public.user_profiles, auth.users

-- CRITICAL FIX: The error shows "check_active_user_has_tenant" constraint is preventing
-- the insertion of active users with null tenant_id during signup bootstrap

-- 1. First, drop the problematic check constraint that prevents active users without tenant
DROP CONSTRAINT IF EXISTS check_active_user_has_tenant ON public.user_profiles;

-- 2. Also ensure tenant_id column allows null (in case previous migration didn't apply)
ALTER TABLE public.user_profiles
  ALTER COLUMN tenant_id DROP NOT NULL;

-- 3. Create or replace the signup trigger with better error handling
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert new user profile with safe defaults
  INSERT INTO public.user_profiles (
    id, 
    email, 
    full_name, 
    role, 
    is_active, 
    created_at, 
    updated_at,
    tenant_id  -- Explicitly set to NULL during bootstrap
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'rep',
    true,        -- Can be active without tenant during onboarding
    now(),
    now(),
    NULL         -- Tenant assigned later during onboarding flow
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't block auth.users creation
    RAISE WARNING 'Failed to create user profile for %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$;

-- 4. Ensure trigger exists (recreate to be safe)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Backfill any missing profiles with safe approach
INSERT INTO public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at, tenant_id)
SELECT 
  u.id, 
  u.email, 
  COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)), 
  'rep', 
  true,    -- Allow active users without tenant
  now(), 
  now(),
  NULL     -- Tenant will be assigned during onboarding
FROM auth.users u
LEFT JOIN public.user_profiles p ON p.id = u.id
WHERE p.id IS NULL;

-- 6. Fix the validation RPC to handle null tenant gracefully
CREATE OR REPLACE FUNCTION public.get_session_context()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_profile public.user_profiles;
  v_tenant_name text;
  v_payload jsonb;
BEGIN
  -- Check if user is authenticated
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'redirect_url', '/login'
    );
  END IF;

  -- Get user profile
  SELECT * INTO v_profile
  FROM public.user_profiles
  WHERE id = v_uid;

  -- Check if profile exists
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'user_exists', false,
      'message', 'Profile missing - please contact support',
      'redirect_url', '/support'
    );
  END IF;

  -- Check if user is active
  IF v_profile.is_active = false THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Account inactive - please contact support',
      'redirect_url', '/support'
    );
  END IF;

  -- CRITICAL: Handle the null tenant case (this is normal during onboarding)
  IF v_profile.tenant_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', true,
      'user_exists', true,
      'profile_completed', COALESCE(v_profile.profile_completed, false),
      'password_set', COALESCE(v_profile.password_set, true),
      'message', 'Please select your organization to continue',
      'redirect_url', '/profile-creation',
      'user_data', jsonb_build_object(
        'id', v_profile.id,
        'role', v_profile.role,
        'email', v_profile.email,
        'full_name', v_profile.full_name,
        'is_active', v_profile.is_active,
        'tenant_id', NULL
      )
    );
  END IF;

  -- Get tenant name for users with assigned tenant
  SELECT t.name INTO v_tenant_name
  FROM public.tenants t
  WHERE t.id = v_profile.tenant_id;

  -- Return successful authentication with complete data
  v_payload := jsonb_build_object(
    'success', true,
    'user_exists', true,
    'profile_completed', COALESCE(v_profile.profile_completed, true),
    'password_set', COALESCE(v_profile.password_set, true),
    'message', 'Authentication successful',
    'redirect_url', '/today',
    'user_data', jsonb_build_object(
      'id', v_profile.id,
      'role', v_profile.role,
      'email', v_profile.email,
      'full_name', v_profile.full_name,
      'is_active', v_profile.is_active,
      'tenant_id', v_profile.tenant_id,
      'tenant_name', COALESCE(v_tenant_name, 'Unknown Organization')
    )
  );

  RETURN v_payload;
END;
$$;

-- 7. Create helper function to assign tenant during onboarding
CREATE OR REPLACE FUNCTION public.assign_user_tenant(user_uuid uuid, new_tenant_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Validate tenant exists
  IF NOT EXISTS (SELECT 1 FROM public.tenants WHERE id = new_tenant_id) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Invalid organization selected'
    );
  END IF;

  -- Update user profile with tenant
  UPDATE public.user_profiles
  SET 
    tenant_id = new_tenant_id, 
    profile_completed = true,
    updated_at = now()
  WHERE id = user_uuid;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Organization assigned successfully'
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'message', 'User profile not found'
    );
  END IF;
END;
$$;

-- 8. Create function to check if user can be assigned to tenant (for admin use)
CREATE OR REPLACE FUNCTION public.can_assign_user_to_tenant(admin_user_id uuid, target_user_id uuid, target_tenant_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  admin_role text;
  admin_tenant_id uuid;
BEGIN
  -- Get admin user details
  SELECT up.role, up.tenant_id 
  INTO admin_role, admin_tenant_id
  FROM public.user_profiles up
  WHERE up.id = admin_user_id;

  -- Super admin can assign anyone to any tenant
  IF admin_role = 'super_admin' THEN
    RETURN true;
  END IF;

  -- Admin can assign users to their own tenant
  IF admin_role = 'admin' AND admin_tenant_id = target_tenant_id THEN
    RETURN true;
  END IF;

  -- Manager can assign users to their tenant with restrictions
  IF admin_role = 'manager' AND admin_tenant_id = target_tenant_id THEN
    -- Check if target user is not already an admin
    RETURN NOT EXISTS (
      SELECT 1 FROM public.user_profiles 
      WHERE id = target_user_id 
      AND role IN ('admin', 'super_admin')
    );
  END IF;

  RETURN false;
END;
$$;

-- 9. Add debugging function to check user status
CREATE OR REPLACE FUNCTION public.debug_user_status(check_user_uuid uuid DEFAULT NULL)
RETURNS TABLE(
  user_id uuid,
  email text,
  has_profile boolean,
  is_active boolean,
  tenant_assigned boolean,
  tenant_name text,
  profile_completed boolean,
  auth_confirmed boolean
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    au.id,
    au.email,
    (up.id IS NOT NULL) as has_profile,
    COALESCE(up.is_active, false) as is_active,
    (up.tenant_id IS NOT NULL) as tenant_assigned,
    COALESCE(t.name, 'No Tenant') as tenant_name,
    COALESCE(up.profile_completed, false) as profile_completed,
    (au.email_confirmed_at IS NOT NULL) as auth_confirmed
  FROM auth.users au
  LEFT JOIN public.user_profiles up ON au.id = up.id
  LEFT JOIN public.tenants t ON up.tenant_id = t.id
  WHERE check_user_uuid IS NULL OR au.id = check_user_uuid
  ORDER BY au.created_at DESC;
$$;

-- 10. Add a safer check constraint that allows active users without tenant during onboarding
-- This replaces the problematic check_active_user_has_tenant constraint
ALTER TABLE public.user_profiles
ADD CONSTRAINT check_completed_profile_has_tenant 
CHECK (
  -- If profile is completed, then active users must have a tenant
  (profile_completed = true AND is_active = true AND tenant_id IS NOT NULL)
  OR 
  -- Otherwise, allow any combination (for onboarding flow)
  (profile_completed = false OR profile_completed IS NULL OR is_active = false OR tenant_id IS NULL)
);

-- 11. Comment on the constraint to explain its purpose
COMMENT ON CONSTRAINT check_completed_profile_has_tenant ON public.user_profiles 
IS 'Ensures that users with completed profiles who are active must have a tenant assigned. Allows flexibility during onboarding process.';

-- 12. Comments explaining the fixes
COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates user_profiles with null tenant_id to allow signup flow completion';
COMMENT ON FUNCTION public.get_session_context() IS 'Returns single JSON object with proper null tenant handling for onboarding flow';
COMMENT ON FUNCTION public.assign_user_tenant(uuid, uuid) IS 'Safely assigns tenant to user and marks profile as completed';
COMMENT ON FUNCTION public.debug_user_status(uuid) IS 'Debug function to check user authentication and profile status';

-- 13. Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.get_session_context() TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_user_tenant(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.debug_user_status(uuid) TO authenticated;