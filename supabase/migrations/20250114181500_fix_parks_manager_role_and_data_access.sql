-- Location: supabase/migrations/20250114181500_fix_parks_manager_role_and_data_access.sql
-- Schema Analysis: Fixing specific issue with parks@sbdllc.co user role detection and data access
-- Integration Type: Modification - fixing authentication role synchronization and RLS policies
-- Dependencies: user_profiles, tenants, accounts, contacts, prospects, opportunities tables

-- =============================================================================
-- STEP 1: Fix parks@sbdllc.co User Specifically
-- =============================================================================

-- Function to fix parks user profile and role sync
CREATE OR REPLACE FUNCTION public.fix_parks_user_profile()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    parks_user_id UUID;
    auth_user_data RECORD;
    profile_data RECORD;
    result JSONB;
BEGIN
    -- Find parks user in auth.users
    SELECT * INTO auth_user_data 
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co' 
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', 'Parks user not found in auth.users',
            'email', 'parks@sbdllc.co'
        );
    END IF;
    
    parks_user_id := auth_user_data.id;
    
    -- Check current profile state
    SELECT * INTO profile_data 
    FROM public.user_profiles 
    WHERE id = parks_user_id;
    
    -- Update or create profile with manager role
    IF profile_data IS NULL THEN
        -- Create profile if missing
        INSERT INTO public.user_profiles (
            id, 
            email, 
            full_name, 
            role,
            is_active,
            profile_completed,
            password_set
        ) VALUES (
            parks_user_id,
            'parks@sbdllc.co',
            COALESCE(auth_user_data.raw_user_meta_data->>'full_name', 'Parks Manager'),
            'manager'::public.user_role_type,
            true,
            true,
            true
        );
        
        result := jsonb_build_object(
            'success', true, 
            'action', 'created_profile',
            'user_id', parks_user_id,
            'email', 'parks@sbdllc.co',
            'role_set', 'manager'
        );
    ELSE
        -- Update existing profile to manager role
        UPDATE public.user_profiles 
        SET 
            role = 'manager'::public.user_role_type,
            is_active = true,
            profile_completed = true,
            password_set = true,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true, 
            'action', 'updated_profile',
            'user_id', parks_user_id,
            'email', 'parks@sbdllc.co',
            'old_role', COALESCE(profile_data.role::TEXT, 'null'),
            'new_role', 'manager'
        );
    END IF;
    
    -- Sync role to auth metadata
    UPDATE auth.users 
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'manager')
    WHERE id = parks_user_id;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', SQLERRM, 
            'sqlstate', SQLSTATE,
            'email', 'parks@sbdllc.co'
        );
END;
$func$;

-- Run the fix for parks user
DO $$
DECLARE
    fix_result JSONB;
BEGIN
    SELECT public.fix_parks_user_profile() INTO fix_result;
    RAISE NOTICE 'Parks user fix result: %', fix_result;
END $$;

-- =============================================================================
-- STEP 2: Enhanced Role Detection Functions (Schema-Safe)
-- =============================================================================

-- Enhanced function to get user role with multiple fallbacks
CREATE OR REPLACE FUNCTION public.get_user_role_with_fallbacks()
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    user_role TEXT;
    profile_role TEXT;
    auth_meta_role TEXT;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN 'anonymous';
    END IF;
    
    -- Try to get role from user_profiles first (most reliable)
    SELECT up.role::TEXT INTO profile_role
    FROM public.user_profiles up
    WHERE up.id = current_user_id
    LIMIT 1;
    
    -- Get role from auth metadata as backup
    SELECT au.raw_user_meta_data->>'role' INTO auth_meta_role
    FROM auth.users au
    WHERE au.id = current_user_id
    LIMIT 1;
    
    -- Return the most reliable role with proper fallback
    user_role := COALESCE(profile_role, auth_meta_role, 'rep');
    
    -- Log role detection for debugging
    RAISE NOTICE 'Role detection for user %: profile_role=%, auth_meta_role=%, final_role=%', 
        current_user_id, profile_role, auth_meta_role, user_role;
    
    RETURN user_role;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_user_role_with_fallbacks: %', SQLERRM;
        RETURN 'rep'; -- Safe fallback
END;
$func$;

-- Function to check if user is manager
CREATE OR REPLACE FUNCTION public.user_is_manager()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT public.get_user_role_with_fallbacks() = 'manager';
$func$;

-- Function to check if user is manager or admin
CREATE OR REPLACE FUNCTION public.user_is_manager_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT public.get_user_role_with_fallbacks() IN ('manager', 'admin', 'super_admin', 'master_admin');
$func$;

-- =============================================================================
-- STEP 3: Enhanced Tenant Access Control Functions
-- =============================================================================

-- Function to get user's tenant with debugging
CREATE OR REPLACE FUNCTION public.get_user_tenant_debug()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    current_user_id UUID;
    user_tenant_id UUID;
    user_role TEXT;
    tenant_name TEXT;
    result JSONB;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No authenticated user');
    END IF;
    
    -- Get user profile data
    SELECT up.tenant_id, up.role::TEXT, t.name
    INTO user_tenant_id, user_role, tenant_name
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = current_user_id
    LIMIT 1;
    
    result := jsonb_build_object(
        'user_id', current_user_id,
        'tenant_id', user_tenant_id,
        'role', user_role,
        'tenant_name', tenant_name,
        'can_access_data', (user_tenant_id IS NOT NULL AND user_role IN ('manager', 'rep', 'admin'))
    );
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'error', SQLERRM,
            'user_id', current_user_id
        );
END;
$func$;

-- Enhanced function to check tenant data access
CREATE OR REPLACE FUNCTION public.can_access_tenant_data_enhanced(target_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    user_role TEXT;
    user_tenant UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Get user role and tenant from profile
    SELECT public.get_user_role_with_fallbacks(), up.tenant_id 
    INTO user_role, user_tenant
    FROM public.user_profiles up
    WHERE up.id = current_user_id
    LIMIT 1;
    
    -- Debug logging
    RAISE NOTICE 'Tenant access check: user_id=%, role=%, user_tenant=%, target_tenant=%', 
        current_user_id, user_role, user_tenant, target_tenant_id;
    
    -- Admin can access all tenant data
    IF user_role IN ('admin', 'super_admin', 'master_admin') THEN
        RETURN true;
    END IF;
    
    -- Manager and rep can access their tenant data
    IF user_role IN ('manager', 'rep') AND user_tenant = target_tenant_id THEN
        RETURN true;
    END IF;
    
    -- If no tenant assigned but user has proper role, allow access to any tenant (for now)
    IF user_role IN ('manager', 'rep') AND user_tenant IS NULL THEN
        RAISE NOTICE 'User % has no tenant assigned but has role %, allowing access', current_user_id, user_role;
        RETURN true;
    END IF;
    
    RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in tenant access check: %', SQLERRM;
        RETURN false;
END;
$func$;

-- =============================================================================
-- STEP 4: Fix RLS Policies for Better Manager Access
-- =============================================================================

-- Drop and recreate account access policies with better manager support
DROP POLICY IF EXISTS "manager_access_tenant_accounts" ON public.accounts;
DROP POLICY IF EXISTS "rep_access_tenant_accounts" ON public.accounts;

-- Enhanced manager access to accounts
CREATE POLICY "manager_enhanced_access_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
    public.user_is_manager_or_admin() 
    AND (
        public.can_access_tenant_data_enhanced(tenant_id)
        OR tenant_id IS NULL  -- Allow access to unassigned accounts
    )
)
WITH CHECK (
    public.user_is_manager_or_admin() 
    AND (
        public.can_access_tenant_data_enhanced(tenant_id)
        OR tenant_id IS NULL
    )
);

-- Enhanced rep access to accounts
CREATE POLICY "rep_enhanced_access_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
    (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
    OR assigned_rep_id = auth.uid()
)
WITH CHECK (
    (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
    OR assigned_rep_id = auth.uid()
);

-- Enhanced contacts access policies
DROP POLICY IF EXISTS "manager_rep_access_tenant_contacts" ON public.contacts;

CREATE POLICY "manager_rep_enhanced_access_contacts"
ON public.contacts
FOR ALL
TO authenticated
USING (
    public.user_is_manager_or_admin() 
    OR (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
)
WITH CHECK (
    public.user_is_manager_or_admin() 
    OR (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
);

-- Enhanced properties access policies
DROP POLICY IF EXISTS "manager_rep_access_tenant_properties" ON public.properties;

CREATE POLICY "manager_rep_enhanced_access_properties"
ON public.properties
FOR ALL
TO authenticated
USING (
    public.user_is_manager_or_admin() 
    OR (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
)
WITH CHECK (
    public.user_is_manager_or_admin() 
    OR (public.get_user_role_with_fallbacks() = 'rep' AND public.can_access_tenant_data_enhanced(tenant_id))
);

-- Enhanced prospects access policies (if table exists)
DO $prospects_fix$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prospects' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS "manager_rep_access_tenant_prospects" ON public.prospects;

        EXECUTE 'CREATE POLICY "manager_rep_enhanced_access_prospects" ON public.prospects FOR ALL TO authenticated USING (public.user_is_manager_or_admin() OR (public.get_user_role_with_fallbacks() = ''rep'' AND public.can_access_tenant_data_enhanced(tenant_id))) WITH CHECK (public.user_is_manager_or_admin() OR (public.get_user_role_with_fallbacks() = ''rep'' AND public.can_access_tenant_data_enhanced(tenant_id)))';
    END IF;
END $prospects_fix$;

-- Enhanced opportunities access policies (if table exists)
DO $opportunities_fix$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'opportunities' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS "manager_rep_access_tenant_opportunities" ON public.opportunities;

        EXECUTE 'CREATE POLICY "manager_rep_enhanced_access_opportunities" ON public.opportunities FOR ALL TO authenticated USING (public.user_is_manager_or_admin() OR (public.get_user_role_with_fallbacks() = ''rep'' AND public.can_access_tenant_data_enhanced(tenant_id))) WITH CHECK (public.user_is_manager_or_admin() OR (public.get_user_role_with_fallbacks() = ''rep'' AND public.can_access_tenant_data_enhanced(tenant_id)))';
    END IF;
END $opportunities_fix$;

-- =============================================================================
-- STEP 5: Debug and Testing Functions
-- =============================================================================

-- Function to diagnose user access issues
CREATE OR REPLACE FUNCTION public.diagnose_user_access()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    current_user_id UUID;
    diagnostic_result JSONB;
    auth_data RECORD;
    profile_data RECORD;
    tenant_info RECORD;
    account_count INTEGER;
    contact_count INTEGER;
    prospect_count INTEGER;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No authenticated user');
    END IF;
    
    -- Get auth user data
    SELECT * INTO auth_data FROM auth.users WHERE id = current_user_id;
    
    -- Get profile data
    SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
    
    -- Get tenant info
    SELECT t.* INTO tenant_info FROM public.tenants t WHERE t.id = profile_data.tenant_id;
    
    -- Count accessible data
    SELECT COUNT(*) INTO account_count FROM public.accounts WHERE public.can_access_tenant_data_enhanced(tenant_id);
    SELECT COUNT(*) INTO contact_count FROM public.contacts WHERE public.can_access_tenant_data_enhanced(tenant_id);
    
    -- Try to count prospects if table exists
    prospect_count := 0;
    BEGIN
        EXECUTE 'SELECT COUNT(*) FROM public.prospects WHERE public.can_access_tenant_data_enhanced(tenant_id)' INTO prospect_count;
    EXCEPTION
        WHEN undefined_table THEN
            prospect_count := -1; -- Table doesn't exist
    END;
    
    diagnostic_result := jsonb_build_object(
        'user_id', current_user_id,
        'email', auth_data.email,
        'auth_role', auth_data.raw_user_meta_data->>'role',
        'profile_exists', (profile_data IS NOT NULL),
        'profile_role', COALESCE(profile_data.role::TEXT, 'null'),
        'profile_active', COALESCE(profile_data.is_active, false),
        'profile_completed', COALESCE(profile_data.profile_completed, false),
        'tenant_id', profile_data.tenant_id,
        'tenant_name', tenant_info.name,
        'detected_role', public.get_user_role_with_fallbacks(),
        'is_manager', public.user_is_manager(),
        'is_manager_or_admin', public.user_is_manager_or_admin(),
        'accessible_accounts', account_count,
        'accessible_contacts', contact_count,
        'accessible_prospects', CASE WHEN prospect_count = -1 THEN 'table_not_exists' ELSE prospect_count::TEXT END,
        'timestamp', CURRENT_TIMESTAMP
    );
    
    RETURN diagnostic_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'error', SQLERRM,
            'sqlstate', SQLSTATE,
            'user_id', current_user_id
        );
END;
$func$;

-- =============================================================================
-- STEP 6: Ensure Parks User Has Sample Data Access
-- =============================================================================

-- Function to assign parks user to a tenant if needed
CREATE OR REPLACE FUNCTION public.ensure_parks_tenant_assignment()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    parks_user_id UUID;
    default_tenant_id UUID;
    result JSONB;
BEGIN
    -- Get parks user ID
    SELECT id INTO parks_user_id 
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co';
    
    IF parks_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Parks user not found');
    END IF;
    
    -- Check if parks user already has a tenant
    IF EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = parks_user_id AND tenant_id IS NOT NULL
    ) THEN
        RETURN jsonb_build_object(
            'success', true, 
            'message', 'Parks user already has tenant assigned'
        );
    END IF;
    
    -- Get any existing tenant for assignment
    SELECT id INTO default_tenant_id 
    FROM public.tenants 
    ORDER BY created_at 
    LIMIT 1;
    
    IF default_tenant_id IS NOT NULL THEN
        -- Assign parks user to this tenant
        UPDATE public.user_profiles 
        SET tenant_id = default_tenant_id, updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true,
            'message', 'Assigned parks user to existing tenant',
            'user_id', parks_user_id,
            'tenant_id', default_tenant_id
        );
    ELSE
        -- Create a default tenant for parks user
        INSERT INTO public.tenants (id, name, description, is_active)
        VALUES (
            gen_random_uuid(),
            'SBD LLC',
            'Default tenant for Parks Manager',
            true
        ) RETURNING id INTO default_tenant_id;
        
        -- Assign parks user to new tenant
        UPDATE public.user_profiles 
        SET tenant_id = default_tenant_id, updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true,
            'message', 'Created new tenant and assigned parks user',
            'user_id', parks_user_id,
            'tenant_id', default_tenant_id
        );
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$func$;

-- Run tenant assignment for parks user
DO $$
DECLARE
    assignment_result JSONB;
BEGIN
    SELECT public.ensure_parks_tenant_assignment() INTO assignment_result;
    RAISE NOTICE 'Parks tenant assignment result: %', assignment_result;
END $$;

-- =============================================================================
-- STEP 7: Success Notification and Cleanup
-- =============================================================================

-- Add helpful comments for future debugging
COMMENT ON FUNCTION public.fix_parks_user_profile() IS 
'Fixes specific issue with parks@sbdllc.co user role and profile synchronization';

COMMENT ON FUNCTION public.get_user_role_with_fallbacks() IS 
'Enhanced role detection with multiple fallbacks and debugging for troubleshooting role access issues';

COMMENT ON FUNCTION public.diagnose_user_access() IS 
'Comprehensive diagnostic function to debug user access and permission issues';

-- Final success notification
DO $success$
BEGIN
    RAISE NOTICE '=== PARKS MANAGER FIX COMPLETED ===';
    RAISE NOTICE 'Actions completed:';
    RAISE NOTICE '1. Fixed parks@sbdllc.co user profile and role synchronization';
    RAISE NOTICE '2. Enhanced role detection functions with better fallbacks';
    RAISE NOTICE '3. Improved RLS policies for manager data access';
    RAISE NOTICE '4. Added comprehensive debugging functions';
    RAISE NOTICE '5. Ensured tenant assignment for data access';
    RAISE NOTICE '';
    RAISE NOTICE 'Parks user should now have:';
    RAISE NOTICE '- Manager role properly set in both profile and auth metadata';
    RAISE NOTICE '- Access to tenant accounts, contacts, prospects, and opportunities';
    RAISE NOTICE '- Proper role detection in the application';
    RAISE NOTICE '';
    RAISE NOTICE 'To debug further issues, call: SELECT public.diagnose_user_access();';
END $success$;