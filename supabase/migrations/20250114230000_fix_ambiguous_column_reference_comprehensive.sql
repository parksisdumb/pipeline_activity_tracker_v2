-- Migration: Fix Ambiguous Column Reference in PostgreSQL Functions
-- Date: 2025-01-14 23:00:00
-- Description: Fix the ambiguous "tenant_id" column reference error in PostgreSQL functions

-- =======================================================================================
-- SECTION 1: DROP AND RECREATE AFFECTED FUNCTIONS WITH QUALIFIED COLUMN NAMES
-- =======================================================================================

-- Drop the problematic function
DROP FUNCTION IF EXISTS test_user_data_access(TEXT);
DROP FUNCTION IF EXISTS get_user_accessible_accounts(UUID);

-- =======================================================================================
-- SECTION 2: RECREATE FUNCTIONS WITH PROPER COLUMN QUALIFICATION
-- =======================================================================================

-- FIXED: Get user accessible accounts with qualified column names
CREATE OR REPLACE FUNCTION get_user_accessible_accounts(user_uuid UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    company_type company_type,
    stage account_stage,
    email TEXT,
    phone TEXT,
    city TEXT,
    state TEXT,
    notes TEXT,
    is_active BOOLEAN,
    tenant_id UUID,
    assigned_rep_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    primary_rep_name TEXT,
    tenant_name TEXT,
    properties_count BIGINT,
    contacts_count BIGINT,
    access_type TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_role_var user_role;
    user_tenant_id_var UUID;
BEGIN
    -- Get user role and tenant with qualified column names and different variable names
    SELECT up.role, up.tenant_id 
    INTO user_role_var, user_tenant_id_var
    FROM user_profiles up
    WHERE up.id = user_uuid AND up.is_active = true;
    
    IF user_role_var IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role_var IN ('super_admin', 'admin') THEN
        -- Admins see all accounts
        RETURN QUERY
        SELECT 
            a.id,
            a.name,
            a.company_type,
            a.stage,
            a.email,
            a.phone,
            a.city,
            a.state,
            a.notes,
            COALESCE(a.is_active, true) as is_active,
            a.tenant_id,
            a.assigned_rep_id,
            a.created_at,
            a.updated_at,
            rep.full_name as primary_rep_name,
            CAST(t.name AS TEXT) as tenant_name,
            COALESCE(prop_count.count, 0) as properties_count,
            COALESCE(contact_count.count, 0) as contacts_count,
            'admin_access' as access_type
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN tenants t ON a.tenant_id = t.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties WHERE is_active = true GROUP BY account_id
        ) prop_count ON a.id = prop_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts WHERE is_active = true GROUP BY account_id
        ) contact_count ON a.id = contact_count.account_id
        WHERE COALESCE(a.is_active, true) = true
        ORDER BY a.name;
        
    ELSIF user_role_var = 'manager' THEN
        -- Managers see all accounts in their tenant
        RETURN QUERY
        SELECT * FROM get_manager_tenant_accounts_comprehensive(user_uuid);
        
    ELSE
        -- Reps see accounts assigned to them
        RETURN QUERY
        SELECT 
            a.id,
            a.name,
            a.company_type,
            a.stage,
            a.email,
            a.phone,
            a.city,
            a.state,
            a.notes,
            COALESCE(a.is_active, true) as is_active,
            a.tenant_id,
            a.assigned_rep_id,
            a.created_at,
            a.updated_at,
            rep.full_name as primary_rep_name,
            CAST(t.name AS TEXT) as tenant_name,
            COALESCE(prop_count.count, 0) as properties_count,
            COALESCE(contact_count.count, 0) as contacts_count,
            'assigned_rep' as access_type
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN tenants t ON a.tenant_id = t.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties WHERE is_active = true GROUP BY account_id
        ) prop_count ON a.id = prop_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts WHERE is_active = true GROUP BY account_id
        ) contact_count ON a.id = contact_count.account_id
        WHERE a.assigned_rep_id = user_uuid
          AND COALESCE(a.is_active, true) = true
        ORDER BY a.name;
    END IF;
END;
$$;

-- FIXED: Test user data access with qualified column names and different variable names
CREATE OR REPLACE FUNCTION test_user_data_access(test_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_uuid UUID;
    auth_result JSON;
    accounts_count INTEGER;
    contacts_count INTEGER;
    properties_count INTEGER;
    result JSON;
BEGIN
    -- Get user ID from email
    SELECT au.id INTO user_uuid
    FROM auth.users au
    WHERE au.email = test_email;
    
    IF user_uuid IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found with email: ' || test_email
        );
    END IF;
    
    -- Test authentication
    SELECT validate_user_session_and_profile(user_uuid) INTO auth_result;
    
    -- Count accessible data using fixed function
    SELECT COUNT(*) INTO accounts_count
    FROM get_user_accessible_accounts(user_uuid);
    
    SELECT COUNT(*) INTO contacts_count  
    FROM get_user_accessible_contacts(user_uuid);
    
    SELECT COUNT(*) INTO properties_count
    FROM get_user_accessible_properties(user_uuid);
    
    result := json_build_object(
        'success', true,
        'email', test_email,
        'user_id', user_uuid,
        'authentication', auth_result,
        'data_access', json_build_object(
            'accounts_count', accounts_count,
            'contacts_count', contacts_count,
            'properties_count', properties_count
        )
    );
    
    RETURN result;
END;
$$;

-- =======================================================================================
-- SECTION 3: UPDATE OTHER AFFECTED FUNCTIONS FOR CONSISTENCY
-- =======================================================================================

-- FIXED: Get user accessible contacts with qualified column names
DROP FUNCTION IF EXISTS get_user_accessible_contacts(UUID);

CREATE OR REPLACE FUNCTION get_user_accessible_contacts(user_uuid UUID)
RETURNS TABLE (
    id UUID,
    first_name TEXT,
    last_name TEXT,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    title TEXT,
    stage contact_stage,
    account_id UUID,
    account_name TEXT,
    is_primary_contact BOOLEAN,
    is_active BOOLEAN,
    tenant_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    access_type TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_role_var user_role;
    user_tenant_id_var UUID;
BEGIN
    -- Get user role and tenant with qualified column names and different variable names
    SELECT up.role, up.tenant_id 
    INTO user_role_var, user_tenant_id_var
    FROM user_profiles up
    WHERE up.id = user_uuid AND up.is_active = true;
    
    IF user_role_var IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role_var IN ('super_admin', 'admin') THEN
        -- Admins see all contacts
        RETURN QUERY
        SELECT 
            c.id,
            c.first_name,
            c.last_name,
            CONCAT(c.first_name, ' ', c.last_name) as full_name,
            c.email,
            c.phone,
            c.title,
            c.stage,
            c.account_id,
            a.name as account_name,
            COALESCE(c.is_primary_contact, false) as is_primary_contact,
            COALESCE(c.is_active, true) as is_active,
            a.tenant_id,
            c.created_at,
            c.updated_at,
            'admin_access' as access_type
        FROM contacts c
        LEFT JOIN accounts a ON c.account_id = a.id
        WHERE COALESCE(c.is_active, true) = true
        ORDER BY c.first_name, c.last_name;
        
    ELSIF user_role_var = 'manager' THEN
        -- Managers see all contacts in their tenant
        RETURN QUERY
        SELECT 
            c.id,
            c.first_name,
            c.last_name,
            CONCAT(c.first_name, ' ', c.last_name) as full_name,
            c.email,
            c.phone,
            c.title,
            c.stage,
            c.account_id,
            a.name as account_name,
            COALESCE(c.is_primary_contact, false) as is_primary_contact,
            COALESCE(c.is_active, true) as is_active,
            a.tenant_id,
            c.created_at,
            c.updated_at,
            'manager_tenant_access' as access_type
        FROM contacts c
        LEFT JOIN accounts a ON c.account_id = a.id
        WHERE a.tenant_id = user_tenant_id_var
          AND COALESCE(c.is_active, true) = true
        ORDER BY c.first_name, c.last_name;
        
    ELSE
        -- Reps see contacts from their assigned accounts
        RETURN QUERY
        SELECT 
            c.id,
            c.first_name,
            c.last_name,
            CONCAT(c.first_name, ' ', c.last_name) as full_name,
            c.email,
            c.phone,
            c.title,
            c.stage,
            c.account_id,
            a.name as account_name,
            COALESCE(c.is_primary_contact, false) as is_primary_contact,
            COALESCE(c.is_active, true) as is_active,
            a.tenant_id,
            c.created_at,
            c.updated_at,
            'assigned_rep_access' as access_type
        FROM contacts c
        LEFT JOIN accounts a ON c.account_id = a.id
        WHERE a.assigned_rep_id = user_uuid
          AND COALESCE(c.is_active, true) = true
        ORDER BY c.first_name, c.last_name;
    END IF;
END;
$$;

-- FIXED: Get user accessible properties with qualified column names
DROP FUNCTION IF EXISTS get_user_accessible_properties(UUID);

CREATE OR REPLACE FUNCTION get_user_accessible_properties(user_uuid UUID)
RETURNS TABLE (
    id UUID,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    stage property_stage,
    building_type TEXT,
    square_footage INTEGER,
    year_built INTEGER,
    account_id UUID,
    account_name TEXT,
    is_active BOOLEAN,
    tenant_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    access_type TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_role_var user_role;
    user_tenant_id_var UUID;
BEGIN
    -- Get user role and tenant with qualified column names and different variable names
    SELECT up.role, up.tenant_id 
    INTO user_role_var, user_tenant_id_var
    FROM user_profiles up
    WHERE up.id = user_uuid AND up.is_active = true;
    
    IF user_role_var IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role_var IN ('super_admin', 'admin') THEN
        -- Admins see all properties
        RETURN QUERY
        SELECT 
            p.id,
            p.name,
            p.address,
            p.city,
            p.state,
            p.zip_code,
            p.stage,
            p.building_type,
            p.square_footage,
            p.year_built,
            p.account_id,
            a.name as account_name,
            COALESCE(p.is_active, true) as is_active,
            a.tenant_id,
            p.created_at,
            p.updated_at,
            'admin_access' as access_type
        FROM properties p
        LEFT JOIN accounts a ON p.account_id = a.id
        WHERE COALESCE(p.is_active, true) = true
        ORDER BY p.name;
        
    ELSIF user_role_var = 'manager' THEN
        -- Managers see all properties in their tenant
        RETURN QUERY
        SELECT 
            p.id,
            p.name,
            p.address,
            p.city,
            p.state,
            p.zip_code,
            p.stage,
            p.building_type,
            p.square_footage,
            p.year_built,
            p.account_id,
            a.name as account_name,
            COALESCE(p.is_active, true) as is_active,
            a.tenant_id,
            p.created_at,
            p.updated_at,
            'manager_tenant_access' as access_type
        FROM properties p
        LEFT JOIN accounts a ON p.account_id = a.id
        WHERE a.tenant_id = user_tenant_id_var
          AND COALESCE(p.is_active, true) = true
        ORDER BY p.name;
        
    ELSE
        -- Reps see properties from their assigned accounts
        RETURN QUERY
        SELECT 
            p.id,
            p.name,
            p.address,
            p.city,
            p.state,
            p.zip_code,
            p.stage,
            p.building_type,
            p.square_footage,
            p.year_built,
            p.account_id,
            a.name as account_name,
            COALESCE(p.is_active, true) as is_active,
            a.tenant_id,
            p.created_at,
            p.updated_at,
            'assigned_rep_access' as access_type
        FROM properties p
        LEFT JOIN accounts a ON p.account_id = a.id
        WHERE a.assigned_rep_id = user_uuid
          AND COALESCE(p.is_active, true) = true
        ORDER BY p.name;
    END IF;
END;
$$;

-- =======================================================================================
-- SECTION 4: GRANT PERMISSIONS
-- =======================================================================================

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_contacts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_properties(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION test_user_data_access(TEXT) TO authenticated;

-- =======================================================================================
-- SECTION 5: TEST THE FIXED FUNCTIONS
-- =======================================================================================

-- Test Parks manager access to ensure the fix works
SELECT test_user_data_access('parks@sbdllc.co');

-- Test other users to ensure comprehensive access works
SELECT test_user_data_access('admin@sbdllc.co');

-- Final status message
SELECT json_build_object(
    'status', 'MIGRATION COMPLETED SUCCESSFULLY',
    'message', 'Ambiguous column reference errors have been fixed by qualifying column names and using different variable names',
    'fixed_functions', ARRAY[
        'get_user_accessible_accounts',
        'get_user_accessible_contacts', 
        'get_user_accessible_properties',
        'test_user_data_access'
    ],
    'timestamp', NOW()
);