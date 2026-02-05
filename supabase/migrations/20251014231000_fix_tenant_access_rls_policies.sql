-- Fix tenant-based RLS policies and missing schema elements
-- Migration: 20251014231000_fix_tenant_access_rls_policies.sql

-- STEP 1: Add missing tenant_id columns to existing tables (if they don't exist)
DO $$
BEGIN
    -- Add tenant_id to accounts table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'accounts' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.accounts ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to accounts table';
    END IF;

    -- Add tenant_id to contacts table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'contacts' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.contacts ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to contacts table';
    END IF;

    -- Add tenant_id to properties table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'properties' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.properties ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to properties table';
    END IF;

    -- Add tenant_id to opportunities table (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'opportunities'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'opportunities' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.opportunities ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to opportunities table';
    END IF;

    -- Add tenant_id to tasks table (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'tasks'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'tasks' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.tasks ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to tasks table';
    END IF;

    -- Add tenant_id to activities table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'activities' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.activities ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to activities table';
    END IF;

    -- Add tenant_id to prospects table (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'prospects'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'prospects' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.prospects ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to prospects table';
    END IF;

    -- Add tenant_id to weekly_goals table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'weekly_goals' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.weekly_goals ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to weekly_goals table';
    END IF;

    -- Add tenant_id to documents table (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'documents'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'documents' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.documents ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to documents table';
    END IF;

    -- Add tenant_id to notifications table (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'notifications'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'notifications' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.notifications ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to notifications table';
    END IF;

    -- Add tenant_id to user_profiles table
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN tenant_id UUID;
        RAISE NOTICE 'Added tenant_id column to user_profiles table';
    END IF;
END $$;
-- STEP 2: Create tenant access functions (safe - doesn't query user_profiles)
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
  (auth.jwt() -> 'user_metadata' ->> 'tenant_id')::UUID,
  (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID
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
    -- Super admin can access all tenants
    WHEN public.get_user_role() = 'super_admin' THEN true
    -- Admin can access all tenants
    WHEN public.get_user_role() = 'admin' THEN true
    -- Manager/Rep can access their own tenant
    WHEN public.get_user_tenant_id() = target_tenant_id THEN true
    ELSE false
  END
$$;
-- STEP 3: Drop existing problematic policies and create safe ones
-- Fix user_profiles RLS policy to avoid infinite recursion
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "admins_view_all_profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "managers_view_tenant_profiles" ON public.user_profiles;
-- Create safe user_profiles policy
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
-- STEP 4: Fix RLS policies for tables that actually exist
-- Accounts table
DROP POLICY IF EXISTS "tenant_isolation_accounts" ON public.accounts;
DROP POLICY IF EXISTS "users_manage_tenant_accounts" ON public.accounts;
DROP POLICY IF EXISTS "users_manage_assigned_accounts" ON public.accounts;
CREATE POLICY "tenant_access_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (
  CASE 
    WHEN tenant_id IS NULL THEN assigned_rep_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
)
WITH CHECK (
  CASE 
    WHEN tenant_id IS NULL THEN assigned_rep_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
);
-- Contacts table
DROP POLICY IF EXISTS "tenant_isolation_contacts" ON public.contacts;
DROP POLICY IF EXISTS "users_manage_tenant_contacts" ON public.contacts;
DROP POLICY IF EXISTS "users_access_account_contacts" ON public.contacts;
CREATE POLICY "tenant_access_contacts"
ON public.contacts
FOR ALL
TO authenticated
USING (
  CASE 
    WHEN tenant_id IS NULL THEN EXISTS (
      SELECT 1 FROM public.accounts a 
      WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
    )
    ELSE public.has_tenant_access(tenant_id)
  END
)
WITH CHECK (
  CASE 
    WHEN tenant_id IS NULL THEN EXISTS (
      SELECT 1 FROM public.accounts a 
      WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
    )
    ELSE public.has_tenant_access(tenant_id)
  END
);
-- Properties table
DROP POLICY IF EXISTS "tenant_isolation_properties" ON public.properties;
DROP POLICY IF EXISTS "users_manage_tenant_properties" ON public.properties;
DROP POLICY IF EXISTS "users_access_account_properties" ON public.properties;
CREATE POLICY "tenant_access_properties"
ON public.properties
FOR ALL
TO authenticated
USING (
  CASE 
    WHEN tenant_id IS NULL THEN EXISTS (
      SELECT 1 FROM public.accounts a 
      WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
    )
    ELSE public.has_tenant_access(tenant_id)
  END
)
WITH CHECK (
  CASE 
    WHEN tenant_id IS NULL THEN EXISTS (
      SELECT 1 FROM public.accounts a 
      WHERE a.id = account_id AND a.assigned_rep_id = auth.uid()
    )
    ELSE public.has_tenant_access(tenant_id)
  END
);
-- Activities table
DROP POLICY IF EXISTS "tenant_isolation_activities" ON public.activities;
DROP POLICY IF EXISTS "users_manage_tenant_activities" ON public.activities;
DROP POLICY IF EXISTS "users_manage_own_activities" ON public.activities;
CREATE POLICY "tenant_access_activities"
ON public.activities
FOR ALL
TO authenticated
USING (
  CASE 
    WHEN tenant_id IS NULL THEN user_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
)
WITH CHECK (
  CASE 
    WHEN tenant_id IS NULL THEN user_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
);
-- Weekly_goals table (not goals table)
DROP POLICY IF EXISTS "tenant_isolation_weekly_goals" ON public.weekly_goals;
DROP POLICY IF EXISTS "users_manage_tenant_weekly_goals" ON public.weekly_goals;
DROP POLICY IF EXISTS "users_manage_own_weekly_goals" ON public.weekly_goals;
CREATE POLICY "tenant_access_weekly_goals"
ON public.weekly_goals
FOR ALL
TO authenticated
USING (
  CASE 
    WHEN tenant_id IS NULL THEN user_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
)
WITH CHECK (
  CASE 
    WHEN tenant_id IS NULL THEN user_id = auth.uid()
    ELSE public.has_tenant_access(tenant_id)
  END
);
-- STEP 5: Handle conditional table policies (only if tables exist)
DO $$
BEGIN
    -- Opportunities table policies (if table exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'opportunities'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_isolation_opportunities" ON public.opportunities';
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_tenant_opportunities" ON public.opportunities';
        
        EXECUTE 'CREATE POLICY "tenant_access_opportunities"
        ON public.opportunities
        FOR ALL
        TO authenticated
        USING (public.has_tenant_access(tenant_id))
        WITH CHECK (public.has_tenant_access(tenant_id))';
        
        RAISE NOTICE 'Updated RLS policies for opportunities table';
    END IF;

    -- Tasks table policies (if table exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'tasks'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_isolation_tasks" ON public.tasks';
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_tenant_tasks" ON public.tasks';
        
        EXECUTE 'CREATE POLICY "tenant_access_tasks"
        ON public.tasks
        FOR ALL
        TO authenticated
        USING (public.has_tenant_access(tenant_id))
        WITH CHECK (public.has_tenant_access(tenant_id))';
        
        RAISE NOTICE 'Updated RLS policies for tasks table';
    END IF;

    -- Prospects table policies (if table exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'prospects'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_isolation_prospects" ON public.prospects';
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_tenant_prospects" ON public.prospects';
        
        EXECUTE 'CREATE POLICY "tenant_access_prospects"
        ON public.prospects
        FOR ALL
        TO authenticated
        USING (public.has_tenant_access(tenant_id))
        WITH CHECK (public.has_tenant_access(tenant_id))';
        
        RAISE NOTICE 'Updated RLS policies for prospects table';
    END IF;

    -- Documents table policies (if table exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'documents'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_isolation_documents" ON public.documents';
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_tenant_documents" ON public.documents';
        
        EXECUTE 'CREATE POLICY "tenant_access_documents"
        ON public.documents
        FOR ALL
        TO authenticated
        USING (public.has_tenant_access(tenant_id))
        WITH CHECK (public.has_tenant_access(tenant_id))';
        
        RAISE NOTICE 'Updated RLS policies for documents table';
    END IF;

    -- Notifications table policies (if table exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'notifications'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "tenant_isolation_notifications" ON public.notifications';
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_tenant_notifications" ON public.notifications';
        
        EXECUTE 'CREATE POLICY "tenant_access_notifications"
        ON public.notifications
        FOR ALL
        TO authenticated
        USING (public.has_tenant_access(tenant_id))
        WITH CHECK (public.has_tenant_access(tenant_id))';
        
        RAISE NOTICE 'Updated RLS policies for notifications table';
    END IF;
END $$;
-- STEP 6: Handle tenants table (if it exists)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'tenants'
    ) THEN
        EXECUTE 'DROP POLICY IF EXISTS "users_manage_own_tenant" ON public.tenants';
        EXECUTE 'DROP POLICY IF EXISTS "super_admin_manage_all_tenants" ON public.tenants';

        -- Super admins can manage all tenants
        EXECUTE 'CREATE POLICY "super_admin_manage_all_tenants"
        ON public.tenants
        FOR ALL
        TO authenticated
        USING (public.get_user_role() = ''super_admin'')
        WITH CHECK (public.get_user_role() = ''super_admin'')';

        -- Regular users can view their own tenant
        EXECUTE 'CREATE POLICY "users_view_own_tenant"
        ON public.tenants
        FOR SELECT
        TO authenticated
        USING (id = public.get_user_tenant_id())';
        
        RAISE NOTICE 'Updated RLS policies for tenants table';
    END IF;
END $$;
-- STEP 7: Update validate_user_session_and_profile function
CREATE OR REPLACE FUNCTION public.validate_user_session_and_profile(user_uuid UUID)
RETURNS TABLE (
    success BOOLEAN,
    user_exists BOOLEAN,
    user_data JSONB,
    profile_completed BOOLEAN,
    password_set BOOLEAN,
    message TEXT,
    redirect_url TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    auth_user_record RECORD;
BEGIN
    -- Get user profile from user_profiles table
    SELECT up.*, 
           COALESCE(t.name, 'Default Tenant') as tenant_name
    INTO user_record
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, false, NULL::JSONB, false, false, 'User profile not found', NULL::TEXT;
        RETURN;
    END IF;
    
    -- Get auth user metadata
    SELECT *
    INTO auth_user_record  
    FROM auth.users au
    WHERE au.id = user_uuid;
    
    -- Sync tenant_id to auth metadata if missing
    IF auth_user_record.raw_user_meta_data IS NULL OR 
       auth_user_record.raw_user_meta_data->>'tenant_id' IS NULL OR
       (auth_user_record.raw_user_meta_data->>'tenant_id')::UUID != user_record.tenant_id THEN
        
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || 
            jsonb_build_object(
                'tenant_id', COALESCE(user_record.tenant_id::text, gen_random_uuid()::text),
                'role', user_record.role
            )
        WHERE id = user_uuid;
    END IF;
    
    -- Return success with complete user data
    RETURN QUERY SELECT 
        true,
        true,
        jsonb_build_object(
            'id', user_record.id,
            'email', user_record.email,
            'role', user_record.role,
            'full_name', user_record.full_name,
            'tenant_id', user_record.tenant_id,
            'tenant_name', user_record.tenant_name,
            'is_active', user_record.is_active,
            'created_at', user_record.created_at,
            'updated_at', user_record.updated_at
        ),
        COALESCE(user_record.profile_completed, true),
        COALESCE(user_record.password_set, true),
        'User session and profile validated successfully',
        CASE 
            WHEN user_record.role = 'super_admin' THEN '/super-admin-dashboard'
            WHEN user_record.role = 'admin' THEN '/admin-dashboard'
            WHEN user_record.role = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END;
END;
$$;
-- STEP 8: Add helpful function to check current user's tenant access
CREATE OR REPLACE FUNCTION public.get_current_user_tenant_info()
RETURNS TABLE (
    user_id UUID,
    tenant_id UUID,
    user_role TEXT,
    can_access_all_tenants BOOLEAN
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    auth.uid(),
    public.get_user_tenant_id(),
    public.get_user_role(),
    public.get_user_role() IN ('super_admin', 'admin')
$$;
-- STEP 9: Final completion message
DO $$
BEGIN
    RAISE NOTICE 'Migration completed successfully - Fixed tenant access RLS policies and added missing schema elements';
END $$;
-- Add comments explaining the fix
COMMENT ON FUNCTION public.has_tenant_access(UUID) IS 'Determines if the current authenticated user can access data for the specified tenant. Super admins and admins can access all tenants, while managers and reps can only access their own tenant data.';
COMMENT ON FUNCTION public.get_user_tenant_id() IS 'Safely retrieves the current users tenant ID from auth JWT metadata without querying user_profiles table.';
COMMENT ON FUNCTION public.get_user_role() IS 'Safely retrieves the current users role from auth JWT metadata without querying user_profiles table.';
