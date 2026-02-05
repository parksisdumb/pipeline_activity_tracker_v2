-- Location: supabase/migrations/20251225140000_fix_authentication_signup_trigger_and_validation.sql
-- Schema Analysis: Fix authentication signup trigger and profile validation based on user analysis
-- Integration Type: Modificative - fixing existing authentication workflow
-- Dependencies: public.user_profiles, auth.users

-- 1. Relax tenant_id constraint during bootstrap to allow initial profile creation
ALTER TABLE public.user_profiles
  ALTER COLUMN tenant_id DROP NOT NULL;
-- 2. Create or replace signup trigger to bootstrap profiles automatically
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'rep',
    true,
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;
-- Drop existing trigger if it exists and create new one
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
-- 3. Backfill missing profiles for existing users
INSERT INTO public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at)
SELECT 
  u.id, 
  u.email, 
  COALESCE(u.raw_user_meta_data->>'full_name', ''), 
  'rep', 
  true, 
  now(), 
  now()
FROM auth.users u
LEFT JOIN public.user_profiles p ON p.id = u.id
WHERE p.id IS NULL;
-- 4. Fix the validation RPC to return a single JSON object (not array)
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
      'message', 'Profile missing',
      'redirect_url', '/onboarding'
    );
  END IF;

  -- Check if user is active
  IF v_profile.is_active = false THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'User inactive',
      'redirect_url', '/support'
    );
  END IF;

  -- If no tenant assigned, redirect to tenant selection
  IF v_profile.tenant_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', true,
      'user_exists', true,
      'profile_completed', v_profile.profile_completed,
      'password_set', v_profile.password_set,
      'message', 'Authenticated; tenant assignment required',
      'redirect_url', '/select-tenant',
      'user_data', jsonb_build_object(
        'id', v_profile.id,
        'role', v_profile.role,
        'email', v_profile.email,
        'full_name', v_profile.full_name,
        'is_active', v_profile.is_active
      )
    );
  END IF;

  -- Get tenant name
  SELECT t.name INTO v_tenant_name
  FROM public.tenants t
  WHERE t.id = v_profile.tenant_id;

  -- Return successful authentication with complete data
  v_payload := jsonb_build_object(
    'success', true,
    'user_exists', true,
    'profile_completed', v_profile.profile_completed,
    'password_set', v_profile.password_set,
    'message', 'Authentication completed successfully',
    'redirect_url', '/today',
    'user_data', jsonb_build_object(
      'id', v_profile.id,
      'role', v_profile.role,
      'email', v_profile.email,
      'full_name', v_profile.full_name,
      'is_active', v_profile.is_active,
      'tenant_id', v_profile.tenant_id,
      'tenant_name', COALESCE(v_tenant_name, null)
    )
  );

  RETURN v_payload;
END;
$$;
-- 5. Create tenant assignment helper function
CREATE OR REPLACE FUNCTION public.assign_user_tenant(user_uuid uuid, new_tenant_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Update user profile with tenant
  UPDATE public.user_profiles
  SET tenant_id = new_tenant_id, updated_at = now()
  WHERE id = user_uuid;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Tenant assigned successfully'
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'message', 'User profile not found'
    );
  END IF;
END;
$$;
-- 6. Create function to fill activity_logs tenant_id automatically
CREATE OR REPLACE FUNCTION public.fill_activity_log_tenant()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.tenant_id IS NULL AND NEW.user_id IS NOT NULL THEN
    SELECT up.tenant_id INTO NEW.tenant_id
    FROM public.user_profiles up
    WHERE up.id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$;
-- Apply trigger to activity_logs if table exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'activity_logs') THEN
    DROP TRIGGER IF EXISTS set_activity_log_tenant ON public.activity_logs;
    CREATE TRIGGER set_activity_log_tenant
      BEFORE INSERT ON public.activity_logs
      FOR EACH ROW EXECUTE FUNCTION public.fill_activity_log_tenant();
  END IF;
END $$;
-- 7. Enhanced tenant isolation with safe RLS policies
DO $$
BEGIN
  -- Only update RLS policies if they exist to avoid errors
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'user_profiles'
  ) THEN
    -- Drop and recreate user_profiles policies with safe patterns
    DROP POLICY IF EXISTS "users_read_own_profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "users_update_own_profile" ON public.user_profiles;
    
    CREATE POLICY "users_read_own_profile"
      ON public.user_profiles
      FOR SELECT
      USING (id = auth.uid());
      
    CREATE POLICY "users_update_own_profile"
      ON public.user_profiles
      FOR UPDATE
      USING (id = auth.uid());
  END IF;
END $$;
-- 8. Create debug functions for troubleshooting
CREATE OR REPLACE FUNCTION public.debug_user_profile_status(check_user_uuid uuid DEFAULT NULL)
RETURNS TABLE(
  user_id uuid,
  email text,
  has_profile boolean,
  tenant_assigned boolean,
  is_active boolean,
  profile_completed boolean,
  password_set boolean
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    au.id,
    au.email,
    (up.id IS NOT NULL) as has_profile,
    (up.tenant_id IS NOT NULL) as tenant_assigned,
    COALESCE(up.is_active, false) as is_active,
    COALESCE(up.profile_completed, false) as profile_completed,
    COALESCE(up.password_set, false) as password_set
  FROM auth.users au
  LEFT JOIN public.user_profiles up ON au.id = up.id
  WHERE check_user_uuid IS NULL OR au.id = check_user_uuid;
$$;
-- 9. Comment explaining the fixes
COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates user_profiles row on auth.users insert to prevent missing profile errors';
COMMENT ON FUNCTION public.get_session_context() IS 'Returns single JSON object (not array) for consistent client parsing';
COMMENT ON FUNCTION public.assign_user_tenant(uuid, uuid) IS 'Helper function to assign tenant to user after tenant selection';
COMMENT ON FUNCTION public.fill_activity_log_tenant() IS 'Auto-fills tenant_id in activity_logs based on user profile';
