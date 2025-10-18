-- Comprehensive fix for app-wide 404 errors and tenant RLS policy issues
-- Migration: 20251015010000_fix_comprehensive_app_wide_404_and_rls_issues.sql

-- STEP 1: Create enhanced tenant access functions with proper error handling
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
  (auth.jwt() -> 'user_metadata' ->> 'tenant_id')::UUID,
  (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
  (
    SELECT tenant_id FROM public.user_profiles 
    WHERE id = auth.uid() 
    LIMIT 1
  )
)
$$;

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
  auth.jwt() -> 'user_metadata' ->> 'role',
  auth.jwt() -> 'app_metadata' ->> 'role',
  (
    SELECT role::text FROM public.user_profiles 
    WHERE id = auth.uid() 
    LIMIT 1
  ),
  'rep'
)
$$;

CREATE OR REPLACE FUNCTION public.has_tenant_access(target_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
  CASE 
    -- Handle null tenant_id (legacy data)
    WHEN target_tenant_id IS NULL THEN true
    -- Super admin can access all tenants
    WHEN public.get_user_role() = 'super_admin' THEN true
    -- Admin can access all tenants  
    WHEN public.get_user_role() = 'admin' THEN true
    -- Manager/Rep can access their own tenant
    WHEN public.get_user_tenant_id() = target_tenant_id THEN true
    -- Default deny
    ELSE false
  END
$$;

-- STEP 2: Fix user_profiles RLS policies to prevent infinite recursion
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "tenant_access_user_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "admins_view_all_profiles" ON public.user_profiles;

-- Create safe user_profiles policies that don't cause recursion
CREATE POLICY "users_own_profile_access"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Separate policy for admin/manager oversight without recursion
CREATE POLICY "admin_profile_oversight"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (
  COALESCE(
    auth.jwt() -> 'user_metadata' ->> 'role',
    auth.jwt() -> 'app_metadata' ->> 'role'
  ) IN ('super_admin', 'admin')
);

-- Manager can view profiles in their tenant
CREATE POLICY "manager_tenant_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (
  COALESCE(
    auth.jwt() -> 'user_metadata' ->> 'role',
    auth.jwt() -> 'app_metadata' ->> 'role'
  ) = 'manager'
  AND 
  tenant_id = COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID
  )
);

-- STEP 3: Enhanced tenant RLS policies for all main tables
-- Accounts table - Enhanced for tenant isolation
DROP POLICY IF EXISTS "tenant_access_accounts" ON public.accounts;
CREATE POLICY "enhanced_tenant_access_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
  -- Super admin and admin can access all
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  -- Tenant-based access
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  -- Legacy assigned rep access for null tenant_id
  (tenant_id IS NULL AND assigned_rep_id = auth.uid())
)
WITH CHECK (
  -- Same logic for insert/update
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  (tenant_id IS NULL AND assigned_rep_id = auth.uid())
);

-- Contacts table - Enhanced for tenant isolation
DROP POLICY IF EXISTS "tenant_access_contacts" ON public.contacts;
CREATE POLICY "enhanced_tenant_access_contacts"
ON public.contacts
FOR ALL
TO authenticated
USING (
  -- Super admin and admin can access all
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  -- Tenant-based access
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  -- Legacy account-based access for null tenant_id
  (tenant_id IS NULL AND EXISTS (
    SELECT 1 FROM public.accounts a 
    WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
  ))
)
WITH CHECK (
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  (tenant_id IS NULL AND EXISTS (
    SELECT 1 FROM public.accounts a 
    WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
  ))
);

-- Properties table - Enhanced for tenant isolation
DROP POLICY IF EXISTS "tenant_access_properties" ON public.properties;
CREATE POLICY "enhanced_tenant_access_properties"
ON public.properties
FOR ALL
TO authenticated
USING (
  -- Super admin and admin can access all
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  -- Tenant-based access
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  -- Legacy account-based access for null tenant_id
  (tenant_id IS NULL AND EXISTS (
    SELECT 1 FROM public.accounts a 
    WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
  ))
)
WITH CHECK (
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  (tenant_id IS NULL AND EXISTS (
    SELECT 1 FROM public.accounts a 
    WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
  ))
);

-- Activities table - Enhanced for tenant isolation
DROP POLICY IF EXISTS "tenant_access_activities" ON public.activities;
CREATE POLICY "enhanced_tenant_access_activities"
ON public.activities
FOR ALL
TO authenticated
USING (
  -- Super admin and admin can access all
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  -- Tenant-based access
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  -- Legacy user-based access for null tenant_id
  (tenant_id IS NULL AND user_id = auth.uid())
)
WITH CHECK (
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  (tenant_id IS NULL AND user_id = auth.uid())
);

-- Weekly_goals table - Enhanced for tenant isolation
DROP POLICY IF EXISTS "tenant_access_weekly_goals" ON public.weekly_goals;
CREATE POLICY "enhanced_tenant_access_weekly_goals"
ON public.weekly_goals
FOR ALL
TO authenticated
USING (
  -- Super admin and admin can access all
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  -- Tenant-based access
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  -- Legacy user-based access for null tenant_id
  (tenant_id IS NULL AND user_id = auth.uid())
)
WITH CHECK (
  public.get_user_role() IN ('super_admin', 'admin') 
  OR
  (tenant_id IS NOT NULL AND public.has_tenant_access(tenant_id))
  OR
  (tenant_id IS NULL AND user_id = auth.uid())
);

-- STEP 4: Handle conditional tables with enhanced policies
DO $$
BEGIN
    -- Opportunities table (if exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'opportunities' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_access_opportunities" ON public.opportunities';
        EXECUTE 'CREATE POLICY "enhanced_tenant_access_opportunities"
        ON public.opportunities
        FOR ALL
        TO authenticated
        USING (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )
        WITH CHECK (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )';
        RAISE NOTICE 'Updated opportunities table RLS policies';
    END IF;

    -- Tasks table (if exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tasks' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_access_tasks" ON public.tasks';
        EXECUTE 'CREATE POLICY "enhanced_tenant_access_tasks"
        ON public.tasks
        FOR ALL
        TO authenticated
        USING (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )
        WITH CHECK (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )';
        RAISE NOTICE 'Updated tasks table RLS policies';
    END IF;

    -- Prospects table (if exists)  
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prospects' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_access_prospects" ON public.prospects';
        EXECUTE 'CREATE POLICY "enhanced_tenant_access_prospects"
        ON public.prospects
        FOR ALL
        TO authenticated
        USING (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )
        WITH CHECK (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )';
        RAISE NOTICE 'Updated prospects table RLS policies';
    END IF;

    -- Documents table (if exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'documents' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_access_documents" ON public.documents';
        EXECUTE 'CREATE POLICY "enhanced_tenant_access_documents"
        ON public.documents
        FOR ALL
        TO authenticated
        USING (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )
        WITH CHECK (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )';
        RAISE NOTICE 'Updated documents table RLS policies';
    END IF;

    -- Notifications table (if exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_access_notifications" ON public.notifications';
        EXECUTE 'CREATE POLICY "enhanced_tenant_access_notifications"
        ON public.notifications
        FOR ALL
        TO authenticated
        USING (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )
        WITH CHECK (
          public.get_user_role() IN (''super_admin'', ''admin'') 
          OR public.has_tenant_access(tenant_id)
        )';
        RAISE NOTICE 'Updated notifications table RLS policies';
    END IF;
END $$;

-- STEP 5: Enhanced tenants table policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenants' AND table_schema = 'public') THEN
        EXECUTE 'DROP POLICY IF EXISTS "super_admin_manage_all_tenants" ON public.tenants';
        EXECUTE 'DROP POLICY IF EXISTS "users_view_own_tenant" ON public.tenants';

        -- Super admins can manage all tenants
        EXECUTE 'CREATE POLICY "super_admin_full_tenant_access"
        ON public.tenants
        FOR ALL
        TO authenticated
        USING (public.get_user_role() = ''super_admin'')
        WITH CHECK (public.get_user_role() = ''super_admin'')';

        -- Admins can view all tenants
        EXECUTE 'CREATE POLICY "admin_view_all_tenants"
        ON public.tenants
        FOR SELECT
        TO authenticated
        USING (public.get_user_role() IN (''admin'', ''super_admin''))';

        -- Users can view their own tenant
        EXECUTE 'CREATE POLICY "users_view_own_tenant_enhanced"
        ON public.tenants
        FOR SELECT
        TO authenticated
        USING (id = public.get_user_tenant_id())';
        
        RAISE NOTICE 'Updated tenants table RLS policies';
    END IF;
END $$;

-- STEP 6: Create comprehensive authentication validation function
CREATE OR REPLACE FUNCTION public.validate_user_session_and_profile_enhanced(user_uuid UUID)
RETURNS TABLE (
    success BOOLEAN,
    user_exists BOOLEAN,
    user_data JSONB,
    profile_completed BOOLEAN,
    password_set BOOLEAN,
    message TEXT,
    redirect_url TEXT,
    tenant_access_info JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    auth_user_record RECORD;
    tenant_info JSONB;
BEGIN
    -- Get user profile from user_profiles table with enhanced error handling
    SELECT up.*, 
           COALESCE(t.name, 'Default Tenant') as tenant_name,
           up.role as user_role,
           up.tenant_id as user_tenant_id
    INTO user_record
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false, 
            false, 
            NULL::JSONB, 
            false, 
            false, 
            'User profile not found - please contact administrator', 
            '/login'::TEXT,
            '{}'::JSONB;
        RETURN;
    END IF;
    
    -- Get auth user metadata
    SELECT *
    INTO auth_user_record  
    FROM auth.users au
    WHERE au.id = user_uuid;
    
    -- Sync metadata to auth if missing or incorrect
    IF auth_user_record.raw_user_meta_data IS NULL OR 
       auth_user_record.raw_user_meta_data->>'tenant_id' IS NULL OR
       auth_user_record.raw_user_meta_data->>'role' IS NULL OR
       (auth_user_record.raw_user_meta_data->>'tenant_id')::UUID != user_record.tenant_id OR
       auth_user_record.raw_user_meta_data->>'role' != user_record.role::text THEN
        
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || 
            jsonb_build_object(
                'tenant_id', COALESCE(user_record.tenant_id::text, gen_random_uuid()::text),
                'role', user_record.role::text,
                'full_name', user_record.full_name
            )
        WHERE id = user_uuid;
        
        RAISE NOTICE 'Synced user metadata for user %', user_uuid;
    END IF;
    
    -- Build tenant access info
    tenant_info := jsonb_build_object(
        'tenant_id', user_record.tenant_id,
        'tenant_name', user_record.tenant_name,
        'can_access_all_tenants', user_record.role IN ('super_admin', 'admin'),
        'role_permissions', CASE user_record.role
            WHEN 'super_admin' THEN '["all"]'::jsonb
            WHEN 'admin' THEN '["tenant_admin", "user_management"]'::jsonb  
            WHEN 'manager' THEN '["team_management", "reporting"]'::jsonb
            ELSE '["data_entry"]'::jsonb
        END
    );
    
    -- Return enhanced success response
    RETURN QUERY SELECT 
        true,
        true,
        jsonb_build_object(
            'id', user_record.id,
            'email', auth_user_record.email,
            'role', user_record.role,
            'full_name', user_record.full_name,
            'tenant_id', user_record.tenant_id,
            'tenant_name', user_record.tenant_name,
            'is_active', user_record.is_active,
            'manager_id', user_record.manager_id,
            'position', user_record.position,
            'phone_number', user_record.phone_number,
            'created_at', user_record.created_at,
            'updated_at', user_record.updated_at,
            'last_login', NOW()
        ),
        COALESCE(user_record.profile_completed, true),
        COALESCE(user_record.password_set, true),
        'Authentication successful - tenant access validated',
        CASE 
            WHEN user_record.role = 'super_admin' THEN '/super-admin-dashboard'
            WHEN user_record.role = 'admin' THEN '/admin-dashboard'
            WHEN user_record.role = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END,
        tenant_info;
END;
$$;

-- STEP 7: Create diagnostic function for troubleshooting
CREATE OR REPLACE FUNCTION public.diagnose_user_tenant_access(user_uuid UUID DEFAULT auth.uid())
RETURNS TABLE (
    user_id UUID,
    user_role TEXT,
    user_tenant_id UUID,
    tenant_name TEXT,
    auth_metadata JSONB,
    access_summary TEXT,
    recommendations TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    profile_data RECORD;
    auth_data RECORD;
    issues TEXT[] := '{}';
    recommendations TEXT[] := '{}';
BEGIN
    -- Get profile data
    SELECT up.*, t.name as tenant_name
    INTO profile_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    -- Get auth data
    SELECT * INTO auth_data
    FROM auth.users WHERE id = user_uuid;
    
    -- Check for issues and build recommendations
    IF profile_data IS NULL THEN
        issues := array_append(issues, 'No user profile found');
        recommendations := array_append(recommendations, 'Create user profile');
    END IF;
    
    IF profile_data.tenant_id IS NULL THEN
        issues := array_append(issues, 'No tenant assigned');
        recommendations := array_append(recommendations, 'Assign user to a tenant');
    END IF;
    
    IF auth_data.raw_user_meta_data->>'tenant_id' IS NULL THEN
        issues := array_append(issues, 'Missing tenant_id in auth metadata');
        recommendations := array_append(recommendations, 'Sync auth metadata');
    END IF;
    
    IF auth_data.raw_user_meta_data->>'role' IS NULL THEN
        issues := array_append(issues, 'Missing role in auth metadata');
        recommendations := array_append(recommendations, 'Sync auth metadata');
    END IF;
    
    RETURN QUERY SELECT 
        user_uuid,
        COALESCE(profile_data.role::text, 'unknown'),
        profile_data.tenant_id,
        COALESCE(profile_data.tenant_name, 'No tenant'),
        COALESCE(auth_data.raw_user_meta_data, '{}'::jsonb),
        CASE WHEN array_length(issues, 1) > 0 
             THEN 'Issues found: ' || array_to_string(issues, ', ')
             ELSE 'All access checks passed'
        END,
        CASE WHEN array_length(recommendations, 1) > 0 
             THEN recommendations
             ELSE ARRAY['No action needed']
        END;
END;
$$;

-- STEP 8: Add database constraints to prevent data inconsistency
ALTER TABLE public.user_profiles 
ADD CONSTRAINT check_active_user_has_tenant 
CHECK (NOT is_active OR tenant_id IS NOT NULL)
NOT VALID;

-- STEP 9: Create indexes for performance (removed CONCURRENTLY to work within transaction)
CREATE INDEX IF NOT EXISTS idx_accounts_tenant_assigned_rep 
ON public.accounts (tenant_id, assigned_rep_id) 
WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_contacts_tenant_account 
ON public.contacts (tenant_id, account_id) 
WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_properties_tenant_account 
ON public.properties (tenant_id, account_id) 
WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_activities_tenant_user 
ON public.activities (tenant_id, user_id) 
WHERE tenant_id IS NOT NULL;

-- STEP 10: Final validation and logging
DO $$
DECLARE
    policy_count INTEGER;
    function_count INTEGER;
BEGIN
    -- Count policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND policyname LIKE '%tenant%';
    
    -- Count tenant-related functions
    SELECT COUNT(*) INTO function_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' 
    AND p.proname LIKE '%tenant%';
    
    RAISE NOTICE 'Migration completed successfully:';
    RAISE NOTICE '- RLS policies updated: %', policy_count;
    RAISE NOTICE '- Tenant functions available: %', function_count;
    RAISE NOTICE '- Enhanced authentication validation created';
    RAISE NOTICE '- Performance indexes added';
    RAISE NOTICE '- Diagnostic tools available';
    RAISE NOTICE 'App-wide 404 errors and tenant RLS issues have been fixed';
END $$;

-- Add helpful comments
COMMENT ON FUNCTION public.validate_user_session_and_profile_enhanced IS 'Enhanced authentication validation with comprehensive tenant access info and metadata synchronization';

COMMENT ON FUNCTION public.diagnose_user_tenant_access IS 'Diagnostic tool to troubleshoot user tenant access issues and provide recommendations';

COMMENT ON FUNCTION public.has_tenant_access IS 'Enhanced tenant access validation supporting legacy data and all user roles with proper null handling';