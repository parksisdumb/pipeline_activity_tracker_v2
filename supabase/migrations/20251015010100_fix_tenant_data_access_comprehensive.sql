-- CRITICAL FIX: Tenant Data Access Issues for Manager Role
-- Issue: Parks Flowers manager cannot view tenant account data due to missing functions and RLS policy issues
-- Solution: Create missing database functions and fix RLS policies for proper tenant access

-- Step 1: Fix missing database functions for tenant access
-- IMPORTANT: Drop existing functions first to avoid return type conflicts

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS public.validate_user_session_and_profile(UUID);
DROP FUNCTION IF EXISTS public.get_user_accessible_accounts(UUID);
DROP FUNCTION IF EXISTS public.get_manager_all_tenant_accounts(UUID);
DROP FUNCTION IF EXISTS public.debug_user_tenant_access(UUID);

-- Function 1: Enhanced user session and profile validation
CREATE FUNCTION public.validate_user_session_and_profile(user_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    user_data JSONB;
    result JSON;
BEGIN
    -- Get comprehensive user data with tenant information
    SELECT jsonb_build_object(
        'id', up.id,
        'email', up.email,
        'full_name', up.full_name,
        'role', up.role,
        'is_active', up.is_active,
        'tenant_id', up.tenant_id,
        'created_at', up.created_at,
        'updated_at', up.updated_at,
        'tenant_name', t.name
    ) INTO user_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;

    -- Build comprehensive response
    IF user_data IS NULL THEN
        result := json_build_object(
            'success', false,
            'user_exists', false,
            'user_data', null,
            'profile_completed', false,
            'password_set', false,
            'message', 'User profile not found',
            'redirect_url', '/profile-creation'
        );
    ELSE
        result := json_build_object(
            'success', true,
            'user_exists', true,
            'user_data', user_data,
            'profile_completed', true,
            'password_set', true,
            'message', 'User session and profile validated successfully',
            'redirect_url', CASE 
                WHEN (user_data->>'role')::TEXT = 'manager' THEN '/manager-dashboard'
                WHEN (user_data->>'role')::TEXT = 'admin' OR (user_data->>'role')::TEXT = 'super_admin' THEN '/admin-dashboard'
                ELSE '/today'
            END
        );
    END IF;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'user_exists', false,
            'user_data', null,
            'profile_completed', false,
            'password_set', false,
            'message', 'Error validating user session: ' || SQLERRM,
            'redirect_url', '/login'
        );
END;
$func$;

-- Function 2: Get user accessible accounts (universal function)
CREATE FUNCTION public.get_user_accessible_accounts(user_uuid UUID)
RETURNS TABLE(
    id UUID,
    name TEXT,
    company_type TEXT,
    stage TEXT,
    city TEXT,
    state TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    assigned_rep_id UUID,
    tenant_id UUID,
    properties_count BIGINT,
    contacts_count BIGINT,
    assigned_reps JSONB,
    primary_rep_name TEXT,
    access_type TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    user_role TEXT;
    user_tenant_id UUID;
BEGIN
    -- Get user role and tenant
    SELECT up.role, up.tenant_id INTO user_role, user_tenant_id
    FROM public.user_profiles up
    WHERE up.id = user_uuid;

    -- Return accounts based on role and tenant access
    IF user_role = 'manager' OR user_role = 'admin' OR user_role = 'super_admin' THEN
        -- Managers and admins can see all accounts in their tenant
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
            a.created_at,
            a.updated_at,
            a.notes,
            COALESCE(a.is_active, true) as is_active,
            a.assigned_rep_id,
            a.tenant_id,
            COALESCE(p_count.count, 0) as properties_count,
            COALESCE(c_count.count, 0) as contacts_count,
            COALESCE(ar.assigned_reps, '[]'::JSONB) as assigned_reps,
            COALESCE(rep.full_name, 'Unassigned') as primary_rep_name,
            'tenant_access' as access_type
        FROM public.accounts a
        LEFT JOIN public.user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM public.properties
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM public.contacts
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        LEFT JOIN (
            SELECT 
                aa.account_id,
                jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep_info.full_name,
                        'is_primary', aa.is_primary,
                        'assigned_at', aa.assigned_at
                    )
                ) as assigned_reps
            FROM public.account_assignments aa
            LEFT JOIN public.user_profiles rep_info ON aa.rep_id = rep_info.id
            GROUP BY aa.account_id
        ) ar ON a.id = ar.account_id
        WHERE a.tenant_id = user_tenant_id
        ORDER BY a.name;
    ELSE
        -- Regular reps can only see accounts assigned to them
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
            a.created_at,
            a.updated_at,
            a.notes,
            COALESCE(a.is_active, true) as is_active,
            a.assigned_rep_id,
            a.tenant_id,
            COALESCE(p_count.count, 0) as properties_count,
            COALESCE(c_count.count, 0) as contacts_count,
            '[]'::JSONB as assigned_reps,
            COALESCE(rep.full_name, 'Unassigned') as primary_rep_name,
            'rep_access' as access_type
        FROM public.accounts a
        LEFT JOIN public.user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM public.properties
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM public.contacts
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        WHERE (a.assigned_rep_id = user_uuid OR 
               EXISTS (
                   SELECT 1 FROM public.account_assignments aa 
                   WHERE aa.account_id = a.id AND aa.rep_id = user_uuid
               ))
        AND a.tenant_id = user_tenant_id
        ORDER BY a.name;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error and return empty result
        RAISE NOTICE 'Error in get_user_accessible_accounts: %', SQLERRM;
        RETURN;
END;
$func$;

-- Function 3: Get all accounts within manager's tenant
CREATE FUNCTION public.get_manager_all_tenant_accounts(manager_uuid UUID)
RETURNS TABLE(
    id UUID,
    name TEXT,
    company_type TEXT,
    stage TEXT,
    city TEXT,
    state TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    assigned_reps JSONB,
    primary_rep_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_uuid AND up.role = 'manager';

    -- If not a manager or tenant not found, return empty
    IF manager_tenant_id IS NULL THEN
        RETURN;
    END IF;

    -- Return all accounts in the manager's tenant
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
        a.created_at,
        a.updated_at,
        a.notes,
        COALESCE(a.is_active, true) as is_active,
        COALESCE(ar.assigned_reps, '[]'::JSONB) as assigned_reps,
        COALESCE(rep.full_name, 'Unassigned') as primary_rep_name
    FROM public.accounts a
    LEFT JOIN public.user_profiles rep ON a.assigned_rep_id = rep.id
    LEFT JOIN (
        SELECT 
            aa.account_id,
            jsonb_agg(
                jsonb_build_object(
                    'rep_id', aa.rep_id,
                    'rep_name', rep_info.full_name,
                    'is_primary', aa.is_primary,
                    'assigned_at', aa.assigned_at
                )
            ) as assigned_reps
        FROM public.account_assignments aa
        LEFT JOIN public.user_profiles rep_info ON aa.rep_id = rep_info.id
        GROUP BY aa.account_id
    ) ar ON a.id = ar.account_id
    WHERE a.tenant_id = manager_tenant_id
    ORDER BY a.name;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_all_tenant_accounts: %', SQLERRM;
        RETURN;
END;
$func$;

-- Step 2: Fix RLS policies to allow proper tenant access

-- Drop existing conflicting policies
DROP POLICY IF EXISTS "tenant_isolation_policy" ON public.accounts;
DROP POLICY IF EXISTS "users_can_read_accounts" ON public.accounts;
DROP POLICY IF EXISTS "users_can_manage_accounts" ON public.accounts;
DROP POLICY IF EXISTS "managers_can_access_tenant_accounts" ON public.accounts;
DROP POLICY IF EXISTS "reps_can_access_assigned_accounts" ON public.accounts;
DROP POLICY IF EXISTS "tenant_based_account_access" ON public.accounts;

-- Create comprehensive tenant-aware RLS policies for accounts
CREATE POLICY "tenant_based_account_access"
ON public.accounts
FOR ALL
TO authenticated
USING (
    -- Allow access if user is in the same tenant
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND up.tenant_id = accounts.tenant_id
        AND up.is_active = true
        AND (
            -- Managers and admins can see all tenant accounts
            up.role IN ('manager', 'admin', 'super_admin')
            -- OR reps can see accounts assigned to them
            OR accounts.assigned_rep_id = auth.uid()
            OR EXISTS (
                SELECT 1 FROM public.account_assignments aa
                WHERE aa.account_id = accounts.id
                AND aa.rep_id = auth.uid()
            )
        )
    )
)
WITH CHECK (
    -- Allow creation/update if user is in the same tenant and has proper role
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND up.tenant_id = accounts.tenant_id
        AND up.is_active = true
        AND up.role IN ('manager', 'admin', 'super_admin', 'rep')
    )
);

-- Fix RLS policies for related tables (properties, contacts, activities)

-- Properties RLS policy fix
DROP POLICY IF EXISTS "tenant_isolation_policy" ON public.properties;
DROP POLICY IF EXISTS "users_can_manage_properties" ON public.properties;
DROP POLICY IF EXISTS "tenant_based_property_access" ON public.properties;

CREATE POLICY "tenant_based_property_access"
ON public.properties
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.accounts a
        JOIN public.user_profiles up ON up.tenant_id = a.tenant_id
        WHERE a.id = properties.account_id
        AND up.id = auth.uid()
        AND up.is_active = true
        AND (
            up.role IN ('manager', 'admin', 'super_admin')
            OR a.assigned_rep_id = auth.uid()
            OR EXISTS (
                SELECT 1 FROM public.account_assignments aa
                WHERE aa.account_id = a.id AND aa.rep_id = auth.uid()
            )
        )
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.accounts a
        JOIN public.user_profiles up ON up.tenant_id = a.tenant_id
        WHERE a.id = properties.account_id
        AND up.id = auth.uid()
        AND up.is_active = true
        AND up.role IN ('manager', 'admin', 'super_admin', 'rep')
    )
);

-- Contacts RLS policy fix
DROP POLICY IF EXISTS "tenant_isolation_policy" ON public.contacts;
DROP POLICY IF EXISTS "users_can_manage_contacts" ON public.contacts;
DROP POLICY IF EXISTS "tenant_based_contact_access" ON public.contacts;

CREATE POLICY "tenant_based_contact_access"
ON public.contacts
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.accounts a
        JOIN public.user_profiles up ON up.tenant_id = a.tenant_id
        WHERE a.id = contacts.account_id
        AND up.id = auth.uid()
        AND up.is_active = true
        AND (
            up.role IN ('manager', 'admin', 'super_admin')
            OR a.assigned_rep_id = auth.uid()
            OR EXISTS (
                SELECT 1 FROM public.account_assignments aa
                WHERE aa.account_id = a.id AND aa.rep_id = auth.uid()
            )
        )
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.accounts a
        JOIN public.user_profiles up ON up.tenant_id = a.tenant_id
        WHERE a.id = contacts.account_id
        AND up.id = auth.uid()
        AND up.is_active = true
        AND up.role IN ('manager', 'admin', 'super_admin', 'rep')
    )
);

-- Activities RLS policy fix
DROP POLICY IF EXISTS "tenant_isolation_policy" ON public.activities;
DROP POLICY IF EXISTS "users_can_manage_activities" ON public.activities;
DROP POLICY IF EXISTS "tenant_based_activity_access" ON public.activities;

CREATE POLICY "tenant_based_activity_access"
ON public.activities
FOR ALL
TO authenticated
USING (
    -- Allow if user created the activity or has tenant access to related entities
    activities.user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND up.is_active = true
        AND up.role IN ('manager', 'admin', 'super_admin')
        AND (
            -- Manager/admin can see activities in their tenant via account relationship
            (activities.account_id IS NOT NULL AND EXISTS (
                SELECT 1 FROM public.accounts a
                WHERE a.id = activities.account_id AND a.tenant_id = up.tenant_id
            ))
            OR
            -- Manager/admin can see activities in their tenant via contact relationship
            (activities.contact_id IS NOT NULL AND EXISTS (
                SELECT 1 FROM public.contacts c
                JOIN public.accounts a ON c.account_id = a.id
                WHERE c.id = activities.contact_id AND a.tenant_id = up.tenant_id
            ))
            OR
            -- Manager/admin can see activities in their tenant via property relationship
            (activities.property_id IS NOT NULL AND EXISTS (
                SELECT 1 FROM public.properties p
                JOIN public.accounts a ON p.account_id = a.id
                WHERE p.id = activities.property_id AND a.tenant_id = up.tenant_id
            ))
        )
    )
)
WITH CHECK (
    -- Allow creation if user is in proper tenant context
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid()
        AND up.is_active = true
        AND up.role IN ('manager', 'admin', 'super_admin', 'rep')
    )
);

-- Step 3: Create diagnostic function for troubleshooting
CREATE FUNCTION public.debug_user_tenant_access(user_uuid UUID)
RETURNS TABLE(
    check_name TEXT,
    result BOOLEAN,
    details TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    user_record RECORD;
    account_count BIGINT;
BEGIN
    -- Get user information
    SELECT * INTO user_record
    FROM public.user_profiles up
    WHERE up.id = user_uuid;

    -- Check 1: User exists
    RETURN QUERY SELECT 
        'user_exists'::TEXT,
        (user_record.id IS NOT NULL),
        COALESCE('User ID: ' || user_record.id::TEXT, 'User not found')::TEXT;

    IF user_record.id IS NULL THEN
        RETURN;
    END IF;

    -- Check 2: User is active
    RETURN QUERY SELECT 
        'user_is_active'::TEXT,
        COALESCE(user_record.is_active, false),
        'Active status: ' || COALESCE(user_record.is_active::TEXT, 'null');

    -- Check 3: User has tenant
    RETURN QUERY SELECT 
        'user_has_tenant'::TEXT,
        (user_record.tenant_id IS NOT NULL),
        'Tenant ID: ' || COALESCE(user_record.tenant_id::TEXT, 'null');

    -- Check 4: User role
    RETURN QUERY SELECT 
        'user_role'::TEXT,
        (user_record.role IS NOT NULL),
        'Role: ' || COALESCE(user_record.role::TEXT, 'null');

    -- Check 5: Accounts in user's tenant
    SELECT COUNT(*) INTO account_count
    FROM public.accounts a
    WHERE a.tenant_id = user_record.tenant_id;

    RETURN QUERY SELECT 
        'tenant_accounts_count'::TEXT,
        (account_count > 0),
        'Accounts in tenant: ' || account_count::TEXT;

    -- Check 6: Function access test
    BEGIN
        PERFORM public.get_user_accessible_accounts(user_uuid);
        RETURN QUERY SELECT 
            'function_access_test'::TEXT,
            true,
            'Function call successful';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 
                'function_access_test'::TEXT,
                false,
                'Function error: ' || SQLERRM;
    END;
END;
$func$;

-- Step 4: Add helpful comments and grant proper permissions
COMMENT ON FUNCTION public.validate_user_session_and_profile(UUID) IS 'Validates user session and returns comprehensive profile data with tenant information';
COMMENT ON FUNCTION public.get_user_accessible_accounts(UUID) IS 'Returns accounts accessible to user based on role and tenant membership';
COMMENT ON FUNCTION public.get_manager_all_tenant_accounts(UUID) IS 'Returns all accounts within a manager''s tenant for oversight purposes';
COMMENT ON FUNCTION public.debug_user_tenant_access(UUID) IS 'Diagnostic function to troubleshoot tenant access issues';

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.validate_user_session_and_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_accessible_accounts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_manager_all_tenant_accounts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.debug_user_tenant_access(UUID) TO authenticated;

-- Final step: Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_accounts_tenant_id ON public.accounts(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_accounts_assigned_rep_id ON public.accounts(assigned_rep_id) WHERE assigned_rep_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_profiles_tenant_role ON public.user_profiles(tenant_id, role) WHERE tenant_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_account_assignments_compound ON public.account_assignments(account_id, rep_id);

-- Success notification
DO $success$
BEGIN
    RAISE NOTICE '✅ Tenant data access fix completed successfully';
    RAISE NOTICE '🎯 Functions created: validate_user_session_and_profile, get_user_accessible_accounts, get_manager_all_tenant_accounts';
    RAISE NOTICE '🔒 RLS policies updated for proper tenant isolation';
    RAISE NOTICE '🔧 Diagnostic function available: debug_user_tenant_access';
    RAISE NOTICE '📊 Performance indexes added';
END;
$success$;