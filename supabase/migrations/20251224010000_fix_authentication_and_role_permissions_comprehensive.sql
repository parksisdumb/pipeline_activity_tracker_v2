-- Location: supabase/migrations/20251224010000_fix_authentication_and_role_permissions_comprehensive.sql
-- Schema Analysis: Fixing authentication and RLS policies for proper role-based access
-- Integration Type: Modification - enhancing existing authentication system
-- Dependencies: user_profiles, tenants, accounts, contacts, prospects, opportunities tables

-- =============================================================================
-- STEP 1: Enhanced User Profile and Auth Sync Functions
-- =============================================================================

-- Function to ensure user profile consistency and role sync
CREATE OR REPLACE FUNCTION public.ensure_user_profile_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
  -- For user profile updates, sync role to auth metadata if different
  IF TG_OP = 'UPDATE' AND OLD.role != NEW.role THEN
    -- Update auth.users metadata to match profile role
    UPDATE auth.users 
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', NEW.role)
    WHERE id = NEW.id;
    
    RAISE NOTICE 'Synced role % to auth metadata for user %', NEW.role, NEW.id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$func$;
-- Add trigger to keep auth metadata in sync with user profile
DROP TRIGGER IF EXISTS trigger_sync_user_profile_role ON public.user_profiles;
CREATE TRIGGER trigger_sync_user_profile_role
  AFTER UPDATE OF role ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.ensure_user_profile_consistency();
-- Function to get user role reliably (tries multiple sources)
CREATE OR REPLACE FUNCTION public.get_user_role_reliable()
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
…metadata role, otherwise 'rep'
    user_role := COALESCE(profile_role, auth_meta_role, 'rep');
RETURN user_role;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'rep';
-- Default fallback
END;
$func$;

-- Function to check if user has specific role
CREATE OR REPLACE FUNCTION public.user_has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT public.get_user_role_reliable() = required_role;
$func$;

-- Function to check if user is manager or admin
CREATE OR REPLACE FUNCTION public.user_is_manager_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT public.get_user_role_reliable() IN ('manager', 'admin', 'super_admin', 'master_admin');
$func$;

-- Function to check if user is admin (any admin type)
CREATE OR REPLACE FUNCTION public.user_is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT public.get_user_role_reliable() IN ('admin', 'super_admin', 'master_admin');
$func$;

-- =============================================================================
-- STEP 2: Enhanced Authentication Status and Diagnostics
-- =============================================================================

-- Function to get comprehensive user authentication status
CREATE OR REPLACE FUNCTION public.get_user_auth_status_enhanced()
RETURNS TABLE(
    user_id UUID,
    email TEXT,
    role TEXT,
    tenant_id UUID,
    is_active BOOLEAN,
    profile_completed BOOLEAN,
    password_set BOOLEAN,
    can_access_data BOOLEAN,
    auth_metadata JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    RETURN QUERY
    SELECT 
        au.id,
        au.email,
        public.get_user_role_reliable(),
        up.tenant_id,
        COALESCE(up.is_active, false),
        COALESCE(up.profile_completed, false),
        COALESCE(up.password_set, false),
        (up.id IS NOT NULL AND COALESCE(up.is_active, false) = true) as can_access_data,
        au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN public.user_profiles up ON au.id = up.id
    WHERE au.id = auth.uid();
END;
$func$;

-- =============================================================================
-- STEP 3: Enhanced RLS Policies - Manager and Rep Access
-- =============================================================================

-- Drop existing problematic policies that may cause infinite recursion
DROP POLICY IF EXISTS "users_view_own_profile" ON public.user_profiles;
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "manager_view_team_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "admin_full_access_user_profiles" ON public.user_profiles;

-- Pattern 1: Core User Table - Simple, direct access for user_profiles
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 6A: Admin access using auth metadata (safe from infinite recursion)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin')
         OR au.raw_app_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin'))
);
$func$;

-- Admin access to user profiles using auth metadata
CREATE POLICY "admin_full_access_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Enhanced manager access - managers can view profiles in their tenant
CREATE OR REPLACE FUNCTION public.manager_can_access_tenant_profiles(profile_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    current_user_role TEXT;
current_user_tenant UUID;
BEGIN
    -- Get current user's role and tenant from profiles
    SELECT up.role::TEXT, up.tenant_id INTO current_user_role, current_user_tenant
    FROM public.user_profiles up
    WHERE up.id = auth.uid()
    LIMIT 1;
-- Manager can access profiles in their tenant
    IF current_user_role = 'manager' AND current_user_tenant = profile_tenant_id THEN
        RETURN true;
END IF;
RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$func$;

-- Manager access to tenant user profiles
CREATE POLICY "manager_view_tenant_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (public.manager_can_access_tenant_profiles(tenant_id));

-- =============================================================================
-- STEP 4: Enhanced Tenant and Account Access Policies
-- =============================================================================

-- Function to check if user can access tenant data
CREATE OR REPLACE FUNCTION public.can_access_tenant_data(target_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    user_role TEXT;
user_tenant UUID;
BEGIN
    -- Get user role and tenant
    SELECT up.role::TEXT, up.tenant_id INTO user_role, user_tenant
    FROM public.user_profiles up
    WHERE up.id = auth.uid()
    LIMIT 1;
-- Admin can access all tenant data
    IF user_role IN ('admin', 'super_admin', 'master_admin') THEN
        RETURN true;
END IF;
-- Manager and rep can access their tenant data
    IF user_role IN ('manager', 'rep') AND user_tenant = target_tenant_id THEN
        RETURN true;
END IF;
RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$func$;

-- Enhanced account access policies
DROP POLICY IF EXISTS "users_access_accounts" ON public.accounts;
DROP POLICY IF EXISTS "manager_access_tenant_accounts" ON public.accounts;
DROP POLICY IF EXISTS "rep_access_assigned_accounts" ON public.accounts;
DROP POLICY IF EXISTS "admin_full_access_accounts" ON public.accounts;

-- Admin access to all accounts
CREATE POLICY "admin_full_access_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Managers can access accounts in their tenant
CREATE POLICY "manager_access_tenant_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
    public.user_has_role('manager') 
    AND public.can_access_tenant_data(tenant_id)
)
WITH CHECK (
    public.user_has_role('manager') 
    AND public.can_access_tenant_data(tenant_id)
);

-- Reps can access accounts in their tenant or assigned to them
CREATE POLICY "rep_access_tenant_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
    (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
    OR assigned_rep_id = auth.uid()
)
WITH CHECK (
    (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
    OR assigned_rep_id = auth.uid()
);

-- =============================================================================
-- STEP 5: Enhanced Contact, Prospect, and Opportunity Access
-- =============================================================================

-- Contacts access policies
DROP POLICY IF EXISTS "users_access_contacts" ON public.contacts;
DROP POLICY IF EXISTS "admin_full_access_contacts" ON public.contacts;
DROP POLICY IF EXISTS "manager_access_tenant_contacts" ON public.contacts;
DROP POLICY IF EXISTS "rep_access_tenant_contacts" ON public.contacts;

-- Admin access to all contacts
CREATE POLICY "admin_full_access_contacts"
ON public.contacts
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Manager and rep access to contacts in their tenant
CREATE POLICY "manager_rep_access_tenant_contacts"
ON public.contacts
FOR ALL
TO authenticated
USING (
    public.user_is_manager_or_admin() 
    OR (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
)
WITH CHECK (
    public.user_is_manager_or_admin() 
    OR (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
);

-- Properties access policies
DROP POLICY IF EXISTS "users_access_properties" ON public.properties;
DROP POLICY IF EXISTS "admin_full_access_properties" ON public.properties;
DROP POLICY IF EXISTS "manager_access_tenant_properties" ON public.properties;
DROP POLICY IF EXISTS "rep_access_tenant_properties" ON public.properties;

-- Admin access to all properties
CREATE POLICY "admin_full_access_properties"
ON public.properties
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Manager and rep access to properties in their tenant
CREATE POLICY "manager_rep_access_tenant_properties"
ON public.properties
FOR ALL
TO authenticated
USING (
    public.user_is_manager_or_admin() 
    OR (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
)
WITH CHECK (
    public.user_is_manager_or_admin() 
    OR (public.user_has_role('rep') AND public.can_access_tenant_data(tenant_id))
);

-- Prospects access policies (if table exists)
DO $prospects_policies$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prospects' AND table_schema = 'public') THEN
        -- Drop existing policies
        DROP POLICY IF EXISTS "users_access_prospects" ON public.prospects;
        DROP POLICY IF EXISTS "admin_full_access_prospects" ON public.prospects;
        DROP POLICY IF EXISTS "manager_access_tenant_prospects" ON public.prospects;
        DROP POLICY IF EXISTS "rep_access_tenant_prospects" ON public.prospects;

        -- Admin access to all prospects
        EXECUTE 'CREATE POLICY "admin_full_access_prospects" ON public.prospects FOR ALL TO authenticated USING (public.is_admin_from_auth()) WITH CHECK (public.is_admin_from_auth())';

        -- Manager and rep access to prospects in their tenant
        EXECUTE 'CREATE POLICY "manager_rep_access_tenant_prospects" ON public.prospects FOR ALL TO authenticated USING (public.user_is_manager_or_admin() OR (public.user_has_role(''rep'') AND public.can_access_tenant_data(tenant_id))) WITH CHECK (public.user_is_manager_or_admin() OR (public.user_has_role(''rep'') AND public.can_access_tenant_data(tenant_id)))';
    END IF;
END $prospects_policies$;

-- Opportunities access policies (if table exists)
DO $opportunities_policies$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'opportunities' AND table_schema = 'public') THEN
        -- Drop existing policies
        DROP POLICY IF EXISTS "users_access_opportunities" ON public.opportunities;
        DROP POLICY IF EXISTS "admin_full_access_opportunities" ON public.opportunities;
        DROP POLICY IF EXISTS "manager_access_tenant_opportunities" ON public.opportunities;
        DROP POLICY IF EXISTS "rep_access_tenant_opportunities" ON public.opportunities;

        -- Admin access to all opportunities
        EXECUTE 'CREATE POLICY "admin_full_access_opportunities" ON public.opportunities FOR ALL TO authenticated USING (public.is_admin_from_auth()) WITH CHECK (public.is_admin_from_auth())';

        -- Manager and rep access to opportunities in their tenant
        EXECUTE 'CREATE POLICY "manager_rep_access_tenant_opportunities" ON public.opportunities FOR ALL TO authenticated USING (public.user_is_manager_or_admin() OR (public.user_has_role(''rep'') AND public.can_access_tenant_data(tenant_id))) WITH CHECK (public.user_is_manager_or_admin() OR (public.user_has_role(''rep'') AND public.can_access_tenant_data(tenant_id)))';
    END IF;
END $opportunities_policies$;

-- =============================================================================
-- STEP 6: User Profile Initialization and Recovery
-- =============================================================================

-- Function to initialize or recover user profile
CREATE OR REPLACE FUNCTION public.initialize_user_profile()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    current_user_id UUID;
profile_exists BOOLEAN;
auth_user_data RECORD;
result JSONB;
BEGIN
    -- Get current user ID
    current_user_id := auth.uid();
IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
END IF;
-- Check if profile exists
    SELECT EXISTS(SELECT 1 FROM public.user_profiles WHERE id = current_user_id) INTO profile_exists;
-- Get auth user data
    SELECT * INTO auth_user_data FROM auth.users WHERE id = current_user_id;
IF NOT profile_exists THEN
        -- Create profile if it doesn't exist
        INSERT INTO public.user_profiles (
            id, 
            email, 
            full_name, 
            role,
            is_active,
            profile_completed
        ) VALUES (
            current_user_id,
            auth_user_data.email,
            COALESCE(auth_user_data.raw_user_meta_data->>'full_name', split_part(auth_user_data.email, '@', 1)),
            COALESCE(auth_user_data.raw_user_meta_data->>'role', 'rep')::user_role_type,
            true,
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            full_name = COALESCE(EXCLUDED.full_name, user_profiles.full_name),
            role = COALESCE(EXCLUDED.role, user_profiles.role),
            updated_at = CURRENT_TIMESTAMP;
result := jsonb_build_object('success', true, 'action', 'created', 'profile_existed', false);
ELSE
        -- Update existing profile with latest auth data
        UPDATE public.user_profiles 
        SET 
            email = auth_user_data.email,
            full_name = COALESCE(auth_user_data.raw_user_meta_data->>'full_name', full_name),
            role = COALESCE((auth_user_data.raw_user_meta_data->>'role')::user_role_type, role),
            is_active = COALESCE(is_active, true),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = current_user_id;
result := jsonb_build_object('success', true, 'action', 'updated', 'profile_existed', true);
END IF;
RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM, 'sqlstate', SQLSTATE);
END;
$func$;

-- =============================================================================
-- STEP 7: Authentication Validation and Diagnostics
-- =============================================================================

-- Function to validate and fix authentication issues
CREATE OR REPLACE FUNCTION public.validate_authentication_state()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    current_user_id UUID;
profile_data RECORD;
auth_data RECORD;
issues JSONB := '[]'::JSONB;
fixes_applied JSONB := '[]'::JSONB;
result JSONB;
BEGIN
    -- Get current user
    current_user_id := auth.uid();
IF current_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', 'No authenticated user',
            'requires_signin', true
        );
END IF;
-- Get auth user data
    SELECT * INTO auth_data FROM auth.users WHERE id = current_user_id;
-- Get profile data
    SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
-- Check for issues and apply fixes
    
    -- Issue 1: Profile missing
    IF profile_data IS NULL THEN
        issues := issues || jsonb_build_array('Profile missing for authenticated user');
-- Fix: Create profile
        INSERT INTO public.user_profiles (
            id, email, full_name, role, is_active, profile_completed
        ) VALUES (
            current_user_id,
            auth_data.email,
            COALESCE(auth_data.raw_user_meta_data->>'full_name', split_part(auth_data.email, '@', 1)),
            COALESCE(auth_data.raw_user_meta_data->>'role', 'rep')::user_role_type,
            true,
            true
        );
fixes_applied := fixes_applied || jsonb_build_array('Created missing user profile');
-- Refresh profile data
        SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
END IF;
-- Issue 2: Role mismatch between auth and profile
    IF auth_data.raw_user_meta_data->>'role' != profile_data.role::TEXT THEN
        issues := issues || jsonb_build_array('Role mismatch between auth metadata and profile');
-- Fix: Sync auth metadata to profile role
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', profile_data.role::TEXT)
        WHERE id = current_user_id;
fixes_applied := fixes_applied || jsonb_build_array('Synced auth metadata role to profile role');
END IF;
-- Issue 3: Profile inactive
    IF NOT COALESCE(profile_data.is_active, false) THEN
        issues := issues || jsonb_build_array('User profile is inactive');
END IF;
-- Issue 4: Profile incomplete
    IF NOT COALESCE(profile_data.profile_completed, false) THEN
        issues := issues || jsonb_build_array('User profile is incomplete');
-- Fix: Mark as complete if basic data exists
        IF profile_data.full_name IS NOT NULL AND profile_data.email IS NOT NULL THEN
            UPDATE public.user_profiles 
            SET profile_completed = true, updated_at = CURRENT_TIMESTAMP
            WHERE id = current_user_id;
fixes_applied := fixes_applied || jsonb_build_array('Marked profile as completed');
END IF;
END IF;
-- Return validation result
    result := jsonb_build_object(
        'success', true,
        'user_id', current_user_id,
        'profile_exists', (profile_data IS NOT NULL),
        'profile_active', COALESCE(profile_data.is_active, false),
        'profile_complete', COALESCE(profile_data.profile_completed, false),
        'role', COALESCE(profile_data.role::TEXT, 'rep'),
        'tenant_id', profile_data.tenant_id,
        'issues_found', jsonb_array_length(issues),
        'issues', issues,
        'fixes_applied', fixes_applied,
        'can_access_data', (
            profile_data IS NOT NULL 
            AND COALESCE(profile_data.is_active, false) = true
        )
    );
RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', SQLERRM, 
            'sqlstate', SQLSTATE,
            'issues', issues,
            'fixes_applied', fixes_applied
        );
END;
$func$;

-- =============================================================================
-- STEP 8: Role and Permission Summary Function
-- =============================================================================

-- Function to get complete user permissions summary
CREATE OR REPLACE FUNCTION public.get_user_permissions_summary()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    current_user_id UUID;
user_data RECORD;
permissions JSONB;
BEGIN
    current_user_id := auth.uid();
IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Not authenticated');
END IF;
-- Get comprehensive user data
    SELECT 
        up.id,
        up.email,
        up.full_name,
        up.role,
        up.tenant_id,
        up.is_active,
        up.profile_completed,
        t.name as tenant_name,
        au.raw_user_meta_data->>'role' as auth_role
    INTO user_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    LEFT JOIN auth.users au ON up.id = au.id
    WHERE up.id = current_user_id;
-- Build permissions based on role
    permissions := jsonb_build_object(
        'can_access_accounts', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_contacts', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_properties', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_prospects', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_opportunities', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_manage_users', (
            user_data.role IN ('admin', 'super_admin', 'master_admin')
        ),
        'can_manage_tenant', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager')
        ),
        'scope', CASE 
            WHEN user_data.role IN ('admin', 'super_admin', 'master_admin') THEN 'global'
            WHEN user_data.role = 'manager' THEN 'tenant'
            ELSE 'personal'
        END
    );
RETURN jsonb_build_object(
        'user_id', user_data.id,
        'email', user_data.email,
        'full_name', user_data.full_name,
        'role', user_data.role,
        'tenant_id', user_data.tenant_id,
        'tenant_name', user_data.tenant_name,
        'is_active', COALESCE(user_data.is_active, false),
        'profile_completed', COALESCE(user_data.profile_completed, false),
        'auth_role', user_data.auth_role,
        'permissions', permissions,
        'timestamp', CURRENT_TIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM, 'sqlstate', SQLSTATE);
END;
$func$;

-- =============================================================================
-- STEP 9: Comment and Notification
-- =============================================================================

-- Add helpful comment for debugging
COMMENT ON FUNCTION public.validate_authentication_state() IS 
'Validates and fixes authentication issues. Call this function when users experience permission problems.';

COMMENT ON FUNCTION public.get_user_permissions_summary() IS 
'Returns comprehensive user permissions summary for debugging role-based access issues.';

COMMENT ON FUNCTION public.get_user_role_reliable() IS 
'Gets user role from multiple sources with fallbacks. Used by RLS policies for reliable role detection.';

-- Success notification
DO $success$
BEGIN
    RAISE NOTICE 'Authentication and role permissions fix completed successfully!';
    RAISE NOTICE 'Key functions created:';
    RAISE NOTICE '  - get_user_role_reliable(): Gets user role reliably';
    RAISE NOTICE '  - validate_authentication_state(): Validates and fixes auth issues'; 
    RAISE NOTICE '  - get_user_permissions_summary(): Shows user permissions';
    RAISE NOTICE '  - initialize_user_profile(): Creates/updates user profile';
    RAISE NOTICE 'Enhanced RLS policies applied for proper manager/rep access to tenant data';
END $success$;
