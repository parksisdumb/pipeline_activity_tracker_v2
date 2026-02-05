-- Location: supabase/migrations/20250114200000_fix_parks_manager_authentication_and_tenant_access_final.sql
-- Schema Analysis: Existing CRM system with user_profiles, tenants, accounts, contacts, properties, etc.
-- Integration Type: Authentication and permission fixes for existing schema
-- Dependencies: user_profiles, tenants, accounts, contacts, properties, opportunities

-- Step 1: Enhanced authentication and role synchronization functions
CREATE OR REPLACE FUNCTION public.sync_parks_manager_role()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    parks_user_id UUID;
    fox_roofing_tenant_id UUID := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7';
BEGIN
    -- Find Parks user by email
    SELECT au.id INTO parks_user_id
    FROM auth.users au
    WHERE au.email = 'parks@sbdllc.co';
    
    IF parks_user_id IS NULL THEN
        RAISE NOTICE 'Parks user not found in auth.users table';
        RETURN;
    END IF;
    
    -- Update auth.users metadata to ensure role synchronization
    UPDATE auth.users
    SET 
        raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role": "manager", "full_name": "Parks"}'::jsonb,
        raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "manager"}'::jsonb,
        updated_at = NOW()
    WHERE id = parks_user_id;
    
    -- Ensure user_profiles entry exists and is correct
    INSERT INTO public.user_profiles (
        id, email, full_name, role, tenant_id, 
        is_active, profile_completed, password_set,
        created_at, updated_at
    ) VALUES (
        parks_user_id, 
        'parks@sbdllc.co', 
        'Parks', 
        'manager'::public.user_role, 
        fox_roofing_tenant_id,
        true, 
        true, 
        true,
        NOW(), 
        NOW()
    )
    ON CONFLICT (id) 
    DO UPDATE SET
        full_name = 'Parks',
        role = 'manager'::public.user_role,
        tenant_id = fox_roofing_tenant_id,
        is_active = true,
        profile_completed = true,
        password_set = true,
        updated_at = NOW();
    
    -- Ensure tenant assignment is correct
    UPDATE public.user_profiles 
    SET tenant_id = fox_roofing_tenant_id
    WHERE id = parks_user_id;
    
    RAISE NOTICE 'Parks manager role and tenant assignment updated successfully';
END;
$func$;
-- Step 2: Enhanced tenant data visibility functions for managers
CREATE OR REPLACE FUNCTION public.get_manager_tenant_accounts(manager_user_id UUID)
RETURNS TABLE(
    id UUID,
    name TEXT,
    company_type public.company_type,
    stage public.account_stage,
    city TEXT,
    state TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    assigned_reps JSONB,
    primary_rep_name TEXT,
    tenant_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get the manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_user_id
    AND up.role = 'manager'
    AND up.is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RAISE NOTICE 'Manager tenant not found for user: %', manager_user_id;
        RETURN;
    END IF;
    
    -- Return all accounts within the manager's tenant
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
        a.is_active,
        COALESCE(
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep.full_name,
                        'is_primary', aa.is_primary,
                        'assigned_at', aa.assigned_at
                    )
                )
                FROM public.account_assignments aa
                LEFT JOIN public.user_profiles rep ON aa.rep_id = rep.id
                WHERE aa.account_id = a.id
            ), '[]'::jsonb
        ) as assigned_reps,
        assigned_rep.full_name as primary_rep_name,
        a.tenant_id
    FROM public.accounts a
    LEFT JOIN public.user_profiles assigned_rep ON a.assigned_rep_id = assigned_rep.id
    WHERE a.tenant_id = manager_tenant_id
    AND a.is_active = true
    ORDER BY a.name ASC;
END;
$func$;
-- Step 3: Enhanced tenant data visibility for contacts
CREATE OR REPLACE FUNCTION public.get_manager_tenant_contacts(manager_user_id UUID)
RETURNS TABLE(
    id UUID,
    account_id UUID,
    first_name TEXT,
    last_name TEXT,
    title TEXT,
    email TEXT,
    phone TEXT,
    mobile_phone TEXT,
    stage public.contact_stage,
    is_primary_contact BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    account_name TEXT,
    tenant_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get the manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_user_id
    AND up.role = 'manager'
    AND up.is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RAISE NOTICE 'Manager tenant not found for user: %', manager_user_id;
        RETURN;
    END IF;
    
    -- Return all contacts within the manager's tenant
    RETURN QUERY
    SELECT 
        c.id,
        c.account_id,
        c.first_name,
        c.last_name,
        c.title,
        c.email,
        c.phone,
        c.mobile_phone,
        c.stage,
        c.is_primary_contact,
        c.created_at,
        c.updated_at,
        c.notes,
        c.is_active,
        a.name as account_name,
        c.tenant_id
    FROM public.contacts c
    LEFT JOIN public.accounts a ON c.account_id = a.id
    WHERE c.tenant_id = manager_tenant_id
    AND c.is_active = true
    ORDER BY c.last_name ASC, c.first_name ASC;
END;
$func$;
-- Step 4: Enhanced tenant data visibility for properties
CREATE OR REPLACE FUNCTION public.get_manager_tenant_properties(manager_user_id UUID)
RETURNS TABLE(
    id UUID,
    account_id UUID,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    stage public.property_stage,
    building_type public.building_type,
    square_footage INTEGER,
    year_built INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    account_name TEXT,
    tenant_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get the manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_user_id
    AND up.role = 'manager'
    AND up.is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RAISE NOTICE 'Manager tenant not found for user: %', manager_user_id;
        RETURN;
    END IF;
    
    -- Return all properties within the manager's tenant
    RETURN QUERY
    SELECT 
        p.id,
        p.account_id,
        p.name,
        p.address,
        p.city,
        p.state,
        p.stage,
        p.building_type,
        p.square_footage,
        p.year_built,
        p.created_at,
        p.updated_at,
        p.notes,
        p.is_active,
        a.name as account_name,
        p.tenant_id
    FROM public.properties p
    LEFT JOIN public.accounts a ON p.account_id = a.id
    WHERE p.tenant_id = manager_tenant_id
    AND p.is_active = true
    ORDER BY p.name ASC;
END;
$func$;
-- Step 5: Enhanced tenant data visibility for opportunities
CREATE OR REPLACE FUNCTION public.get_manager_tenant_opportunities(manager_user_id UUID)
RETURNS TABLE(
    id UUID,
    account_id UUID,
    property_id UUID,
    name TEXT,
    stage public.opportunity_stage,
    opportunity_type public.opportunity_type,
    bid_value DECIMAL,
    probability INTEGER,
    expected_close_date DATE,
    actual_close_date DATE,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    notes TEXT,
    is_active BOOLEAN,
    account_name TEXT,
    property_name TEXT,
    tenant_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get the manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_user_id
    AND up.role = 'manager'
    AND up.is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RAISE NOTICE 'Manager tenant not found for user: %', manager_user_id;
        RETURN;
    END IF;
    
    -- Return all opportunities within the manager's tenant
    RETURN QUERY
    SELECT 
        o.id,
        o.account_id,
        o.property_id,
        o.name,
        o.stage,
        o.opportunity_type,
        o.bid_value,
        o.probability,
        o.expected_close_date,
        o.actual_close_date,
        o.created_at,
        o.updated_at,
        o.notes,
        o.is_active,
        a.name as account_name,
        p.name as property_name,
        o.tenant_id
    FROM public.opportunities o
    LEFT JOIN public.accounts a ON o.account_id = a.id
    LEFT JOIN public.properties p ON o.property_id = p.id
    WHERE o.tenant_id = manager_tenant_id
    AND o.is_active = true
    ORDER BY o.expected_close_date ASC NULLS LAST, o.name ASC;
END;
$func$;
-- Step 6: Enhanced authentication workflow function
CREATE OR REPLACE FUNCTION public.validate_manager_authentication(user_email TEXT)
RETURNS TABLE(
    success BOOLEAN,
    user_id UUID,
    tenant_id UUID,
    full_name TEXT,
    role TEXT,
    is_active BOOLEAN,
    setup_completed BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    auth_user_id UUID;
    profile_record RECORD;
BEGIN
    -- Find user in auth.users
    SELECT au.id INTO auth_user_id
    FROM auth.users au
    WHERE au.email = user_email
    AND au.email_confirmed_at IS NOT NULL;
    
    IF auth_user_id IS NULL THEN
        RETURN QUERY SELECT 
            false, 
            NULL::UUID, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::TEXT, 
            false, 
            false,
            'User not found or email not confirmed'::TEXT;
        RETURN;
    END IF;
    
    -- Get user profile
    SELECT up.* INTO profile_record
    FROM public.user_profiles up
    WHERE up.id = auth_user_id;
    
    IF profile_record IS NULL THEN
        RETURN QUERY SELECT 
            false, 
            auth_user_id, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::TEXT, 
            false, 
            false,
            'User profile not found'::TEXT;
        RETURN;
    END IF;
    
    -- Return successful authentication result
    RETURN QUERY SELECT 
        true, 
        auth_user_id, 
        profile_record.tenant_id, 
        profile_record.full_name, 
        profile_record.role::TEXT,
        profile_record.is_active, 
        profile_record.profile_completed,
        'Authentication successful'::TEXT;
END;
$func$;
-- Step 7: Execute the synchronization for Parks
SELECT public.sync_parks_manager_role();
-- Step 8: Verify Parks setup
DO $verify$
DECLARE
    parks_verification RECORD;
    fox_roofing_tenant_id UUID := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7';
BEGIN
    -- Verify Parks is properly set up
    SELECT * INTO parks_verification
    FROM public.validate_manager_authentication('parks@sbdllc.co');
    
    IF parks_verification.success THEN
        RAISE NOTICE 'Parks authentication verification successful:';
        RAISE NOTICE '  User ID: %', parks_verification.user_id;
        RAISE NOTICE '  Tenant ID: %', parks_verification.tenant_id;
        RAISE NOTICE '  Full Name: %', parks_verification.full_name;
        RAISE NOTICE '  Role: %', parks_verification.role;
        RAISE NOTICE '  Is Active: %', parks_verification.is_active;
        RAISE NOTICE '  Setup Completed: %', parks_verification.setup_completed;
        
        -- Verify tenant assignment
        IF parks_verification.tenant_id = fox_roofing_tenant_id THEN
            RAISE NOTICE '  ✅ Parks is correctly assigned to Fox Roofing tenant';
        ELSE
            RAISE NOTICE '  ❌ Parks tenant assignment incorrect. Expected: %, Got: %', 
                fox_roofing_tenant_id, parks_verification.tenant_id;
        END IF;
    ELSE
        RAISE NOTICE '❌ Parks authentication verification failed: %', parks_verification.message;
    END IF;
END;
$verify$;
-- Step 9: Test data access for Parks
DO $test_access$
DECLARE
    parks_user_id UUID;
    account_count INTEGER := 0;
    contact_count INTEGER := 0;
    property_count INTEGER := 0;
    opportunity_count INTEGER := 0;
BEGIN
    -- Get Parks user ID
    SELECT au.id INTO parks_user_id
    FROM auth.users au
    WHERE au.email = 'parks@sbdllc.co';
    
    IF parks_user_id IS NOT NULL THEN
        -- Test account access
        SELECT COUNT(*) INTO account_count
        FROM public.get_manager_tenant_accounts(parks_user_id);
        
        -- Test contact access
        SELECT COUNT(*) INTO contact_count
        FROM public.get_manager_tenant_contacts(parks_user_id);
        
        -- Test property access
        SELECT COUNT(*) INTO property_count
        FROM public.get_manager_tenant_properties(parks_user_id);
        
        -- Test opportunity access
        SELECT COUNT(*) INTO opportunity_count
        FROM public.get_manager_tenant_opportunities(parks_user_id);
        
        RAISE NOTICE 'Parks data access test results:';
        RAISE NOTICE '  Accounts accessible: %', account_count;
        RAISE NOTICE '  Contacts accessible: %', contact_count;
        RAISE NOTICE '  Properties accessible: %', property_count;
        RAISE NOTICE '  Opportunities accessible: %', opportunity_count;
        
        IF account_count > 0 OR contact_count > 0 OR property_count > 0 OR opportunity_count > 0 THEN
            RAISE NOTICE '  ✅ Parks has access to tenant data';
        ELSE
            RAISE NOTICE '  ❌ Parks has no access to tenant data - may need to populate tenant data';
        END IF;
    ELSE
        RAISE NOTICE '❌ Parks user not found for data access test';
    END IF;
END;
$test_access$;
