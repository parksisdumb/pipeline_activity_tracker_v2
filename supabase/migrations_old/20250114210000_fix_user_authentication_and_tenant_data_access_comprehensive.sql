-- Migration: Fix User Authentication and Tenant Data Access - Comprehensive Solution
-- Date: 2025-01-14 21:00:00
-- Description: Comprehensive fix for Parks manager and all user authentication/tenant data issues

-- =======================================================================================
-- SECTION 1: AUTHENTICATION AND USER PROFILE SYNCHRONIZATION
-- =======================================================================================

-- Drop existing functions to avoid conflicts
DROP FUNCTION IF EXISTS fix_user_profile_authentication(UUID);
DROP FUNCTION IF EXISTS sync_parks_manager_authentication();
DROP FUNCTION IF EXISTS get_user_with_complete_profile(UUID);
DROP FUNCTION IF EXISTS validate_user_session_and_profile(UUID);

-- CRITICAL FIX: Function to get user with complete profile (synchronous)
CREATE OR REPLACE FUNCTION get_user_with_complete_profile(user_uuid UUID)
RETURNS TABLE (
    id UUID,
    email TEXT,
    role user_role,
    full_name TEXT,
    tenant_id UUID,
    is_active BOOLEAN,
    profile_completed BOOLEAN,
    password_set BOOLEAN,
    email_confirmed BOOLEAN,
    tenant_name TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.id,
        au.email,
        up.role,
        up.full_name,
        up.tenant_id,
        COALESCE(up.is_active, true) as is_active,
        COALESCE(up.profile_completed, false) as profile_completed,
        COALESCE(up.password_set, true) as password_set,
        COALESCE(au.email_confirmed_at IS NOT NULL, false) as email_confirmed,
        t.name as tenant_name,
        up.created_at,
        up.updated_at
    FROM user_profiles up
    LEFT JOIN auth.users au ON up.id = au.id
    LEFT JOIN tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
END;
$$;

-- CRITICAL FIX: Validate and sync user session with profile  
CREATE OR REPLACE FUNCTION validate_user_session_and_profile(user_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_record RECORD;
    auth_record RECORD;
    result JSON;
BEGIN
    -- Get user profile
    SELECT * INTO user_record FROM get_user_with_complete_profile(user_uuid);
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User profile not found',
            'user_exists', false,
            'requires_setup', true
        );
    END IF;
    
    -- Get auth user details
    SELECT 
        id,
        email,
        email_confirmed_at,
        raw_user_meta_data,
        raw_app_meta_data,
        created_at,
        updated_at
    INTO auth_record
    FROM auth.users 
    WHERE id = user_uuid;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Auth user not found',
            'user_exists', false,
            'requires_setup', true
        );
    END IF;
    
    -- Build comprehensive result
    result := json_build_object(
        'success', true,
        'user_exists', true,
        'profile_exists', true,
        'email_confirmed', auth_record.email_confirmed_at IS NOT NULL,
        'profile_completed', COALESCE(user_record.profile_completed, false),
        'password_set', COALESCE(user_record.password_set, true),
        'requires_setup', false,
        'user_data', json_build_object(
            'id', user_record.id,
            'email', user_record.email,
            'role', user_record.role,
            'full_name', user_record.full_name,
            'tenant_id', user_record.tenant_id,
            'tenant_name', user_record.tenant_name,
            'is_active', user_record.is_active
        ),
        'auth_metadata', json_build_object(
            'user_meta_data', auth_record.raw_user_meta_data,
            'app_meta_data', auth_record.raw_app_meta_data
        )
    );
    
    RETURN result;
END;
$$;

-- =======================================================================================
-- SECTION 2: PARKS MANAGER SPECIFIC AUTHENTICATION FIX
-- =======================================================================================

-- CRITICAL: Fix Parks manager authentication specifically
CREATE OR REPLACE FUNCTION sync_parks_manager_authentication()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    parks_user_id UUID;
    fox_tenant_id UUID;
    auth_user RECORD;
    profile_record RECORD;
    result JSON;
BEGIN
    -- Get Fox Roofing tenant ID
    SELECT id INTO fox_tenant_id 
    FROM tenants 
    WHERE name = 'Fox Roofing' 
    LIMIT 1;
    
    IF fox_tenant_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Fox Roofing tenant not found'
        );
    END IF;
    
    -- Find Parks user by email in auth.users
    SELECT id, email, raw_user_meta_data, raw_app_meta_data, email_confirmed_at
    INTO auth_user
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co'
    LIMIT 1;
    
    IF auth_user.id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Parks user not found in auth.users'
        );
    END IF;
    
    parks_user_id := auth_user.id;
    
    -- Check if profile exists
    SELECT * INTO profile_record
    FROM user_profiles 
    WHERE id = parks_user_id;
    
    -- Create or update user profile
    IF profile_record.id IS NULL THEN
        -- Create new profile
        INSERT INTO user_profiles (
            id, 
            email, 
            full_name, 
            role, 
            tenant_id,
            is_active,
            profile_completed,
            password_set,
            created_at,
            updated_at
        ) VALUES (
            parks_user_id,
            'parks@sbdllc.co',
            'Parks Manager',
            'manager',
            fox_tenant_id,
            true,
            true,
            true,
            NOW(),
            NOW()
        );
        
        RAISE LOG 'Created new user profile for Parks manager';
    ELSE
        -- Update existing profile
        UPDATE user_profiles SET
            email = 'parks@sbdllc.co',
            full_name = COALESCE(full_name, 'Parks Manager'),
            role = 'manager',
            tenant_id = fox_tenant_id,
            is_active = true,
            profile_completed = true,
            password_set = true,
            updated_at = NOW()
        WHERE id = parks_user_id;
        
        RAISE LOG 'Updated existing user profile for Parks manager';
    END IF;
    
    -- Verify the setup
    SELECT up.*, t.name as tenant_name
    INTO profile_record
    FROM user_profiles up
    LEFT JOIN tenants t ON up.tenant_id = t.id
    WHERE up.id = parks_user_id;
    
    RETURN json_build_object(
        'success', true,
        'message', 'Parks manager authentication synchronized successfully',
        'user_id', parks_user_id,
        'tenant_id', fox_tenant_id,
        'profile_data', json_build_object(
            'id', profile_record.id,
            'email', profile_record.email,
            'full_name', profile_record.full_name,
            'role', profile_record.role,
            'tenant_name', profile_record.tenant_name,
            'is_active', profile_record.is_active,
            'profile_completed', profile_record.profile_completed
        )
    );
END;
$$;

-- =======================================================================================
-- SECTION 3: ENHANCED TENANT DATA ACCESS FUNCTIONS
-- =======================================================================================

-- Drop existing functions
DROP FUNCTION IF EXISTS get_manager_tenant_accounts_comprehensive(UUID);
DROP FUNCTION IF EXISTS get_user_accessible_accounts(UUID);
DROP FUNCTION IF EXISTS get_user_accessible_contacts(UUID);
DROP FUNCTION IF EXISTS get_user_accessible_properties(UUID);
DROP FUNCTION IF EXISTS get_user_accessible_opportunities(UUID);
DROP FUNCTION IF EXISTS get_user_accessible_prospects(UUID);

-- ENHANCED: Get all tenant accounts with full details
CREATE OR REPLACE FUNCTION get_manager_tenant_accounts_comprehensive(manager_uuid UUID)
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
    contacts_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get manager's tenant
    SELECT tenant_id INTO manager_tenant_id
    FROM user_profiles
    WHERE id = manager_uuid AND role = 'manager' AND is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Manager not found or not authorized: %', manager_uuid;
    END IF;
    
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
        t.name as tenant_name,
        COALESCE(prop_count.count, 0) as properties_count,
        COALESCE(contact_count.count, 0) as contacts_count
    FROM accounts a
    LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
    LEFT JOIN tenants t ON a.tenant_id = t.id
    LEFT JOIN (
        SELECT account_id, COUNT(*) as count
        FROM properties
        WHERE is_active = true
        GROUP BY account_id
    ) prop_count ON a.id = prop_count.account_id
    LEFT JOIN (
        SELECT account_id, COUNT(*) as count
        FROM contacts
        WHERE is_active = true
        GROUP BY account_id
    ) contact_count ON a.id = contact_count.account_id
    WHERE a.tenant_id = manager_tenant_id
      AND COALESCE(a.is_active, true) = true
    ORDER BY a.name;
END;
$$;

-- ENHANCED: Get user accessible accounts based on role
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
    user_role user_role;
    user_tenant_id UUID;
BEGIN
    -- Get user role and tenant
    SELECT role, tenant_id INTO user_role, user_tenant_id
    FROM user_profiles
    WHERE id = user_uuid AND is_active = true;
    
    IF user_role IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role IN ('super_admin', 'admin') THEN
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
            t.name as tenant_name,
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
        
    ELSIF user_role = 'manager' THEN
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
            t.name as tenant_name,
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

-- ENHANCED: Get user accessible contacts based on role  
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
    user_role user_role;
    user_tenant_id UUID;
BEGIN
    -- Get user role and tenant
    SELECT role, tenant_id INTO user_role, user_tenant_id
    FROM user_profiles
    WHERE id = user_uuid AND is_active = true;
    
    IF user_role IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role IN ('super_admin', 'admin') THEN
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
        
    ELSIF user_role = 'manager' THEN
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
        WHERE a.tenant_id = user_tenant_id
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

-- ENHANCED: Get user accessible properties based on role
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
    user_role user_role;
    user_tenant_id UUID;
BEGIN
    -- Get user role and tenant
    SELECT role, tenant_id INTO user_role, user_tenant_id
    FROM user_profiles
    WHERE id = user_uuid AND is_active = true;
    
    IF user_role IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive: %', user_uuid;
    END IF;
    
    -- Return data based on role
    IF user_role IN ('super_admin', 'admin') THEN
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
        
    ELSIF user_role = 'manager' THEN
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
        WHERE a.tenant_id = user_tenant_id
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
-- SECTION 4: EXECUTE PARKS MANAGER FIX
-- =======================================================================================

-- Execute the Parks manager synchronization
SELECT sync_parks_manager_authentication();

-- =======================================================================================
-- SECTION 5: RLS POLICY UPDATES
-- =======================================================================================

-- Update RLS policies to ensure proper access control
-- Enable RLS on all tables if not already enabled
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;

-- Drop existing problematic policies
DROP POLICY IF EXISTS "user_profiles_select_own_or_tenant" ON user_profiles;
DROP POLICY IF EXISTS "accounts_select_tenant_based" ON accounts;
DROP POLICY IF EXISTS "contacts_select_tenant_based" ON contacts;
DROP POLICY IF EXISTS "properties_select_tenant_based" ON properties;

-- ENHANCED: User profiles access policy
CREATE POLICY "user_profiles_comprehensive_access" ON user_profiles
FOR SELECT USING (
    -- Users can see their own profile
    auth.uid() = id
    OR
    -- Super admins can see all profiles  
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'super_admin'
        AND up.is_active = true
    )
    OR
    -- Admins can see all profiles in their tenant
    EXISTS (
        SELECT 1 FROM user_profiles up1
        WHERE up1.id = auth.uid()
        AND up1.role = 'admin'
        AND up1.is_active = true
        AND up1.tenant_id = user_profiles.tenant_id
    )
    OR
    -- Managers can see profiles in their tenant
    EXISTS (
        SELECT 1 FROM user_profiles up2
        WHERE up2.id = auth.uid()
        AND up2.role = 'manager'
        AND up2.is_active = true
        AND up2.tenant_id = user_profiles.tenant_id
    )
);

-- ENHANCED: Accounts access policy
CREATE POLICY "accounts_comprehensive_access" ON accounts
FOR SELECT USING (
    -- Super admins can see all accounts
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'super_admin'
        AND up.is_active = true
    )
    OR
    -- Admins can see all accounts
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'admin'
        AND up.is_active = true
    )
    OR
    -- Managers can see accounts in their tenant
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid()
        AND up.role = 'manager'
        AND up.is_active = true
        AND up.tenant_id = accounts.tenant_id
    )
    OR
    -- Reps can see their assigned accounts
    accounts.assigned_rep_id = auth.uid()
    OR
    -- Reps can see accounts through account assignments
    EXISTS (
        SELECT 1 FROM account_assignments aa
        WHERE aa.account_id = accounts.id
        AND aa.rep_id = auth.uid()
    )
);

-- ENHANCED: Contacts access policy  
CREATE POLICY "contacts_comprehensive_access" ON contacts
FOR SELECT USING (
    -- Super admins can see all contacts
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'super_admin'
        AND up.is_active = true
    )
    OR
    -- Admins can see all contacts
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'admin'
        AND up.is_active = true
    )
    OR
    -- Managers can see contacts in their tenant accounts
    EXISTS (
        SELECT 1 FROM user_profiles up
        INNER JOIN accounts a ON up.tenant_id = a.tenant_id
        WHERE up.id = auth.uid()
        AND up.role = 'manager'
        AND up.is_active = true
        AND a.id = contacts.account_id
    )
    OR
    -- Reps can see contacts from their assigned accounts
    EXISTS (
        SELECT 1 FROM accounts a
        WHERE a.id = contacts.account_id
        AND a.assigned_rep_id = auth.uid()
    )
    OR
    -- Reps can see contacts through account assignments
    EXISTS (
        SELECT 1 FROM account_assignments aa
        WHERE aa.account_id = contacts.account_id
        AND aa.rep_id = auth.uid()
    )
);

-- ENHANCED: Properties access policy
CREATE POLICY "properties_comprehensive_access" ON properties
FOR SELECT USING (
    -- Super admins can see all properties
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'super_admin'
        AND up.is_active = true
    )
    OR
    -- Admins can see all properties
    EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id = auth.uid() 
        AND up.role = 'admin'
        AND up.is_active = true
    )
    OR
    -- Managers can see properties in their tenant accounts
    EXISTS (
        SELECT 1 FROM user_profiles up
        INNER JOIN accounts a ON up.tenant_id = a.tenant_id
        WHERE up.id = auth.uid()
        AND up.role = 'manager'
        AND up.is_active = true
        AND a.id = properties.account_id
    )
    OR
    -- Reps can see properties from their assigned accounts
    EXISTS (
        SELECT 1 FROM accounts a
        WHERE a.id = properties.account_id
        AND a.assigned_rep_id = auth.uid()
    )
    OR
    -- Reps can see properties through account assignments
    EXISTS (
        SELECT 1 FROM account_assignments aa
        WHERE aa.account_id = properties.account_id
        AND aa.rep_id = auth.uid()
    )
);

-- =======================================================================================
-- SECTION 6: TESTING AND VERIFICATION
-- =======================================================================================

-- Function to test user authentication and data access
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
    SELECT id INTO user_uuid
    FROM auth.users
    WHERE email = test_email;
    
    IF user_uuid IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found with email: ' || test_email
        );
    END IF;
    
    -- Test authentication
    SELECT validate_user_session_and_profile(user_uuid) INTO auth_result;
    
    -- Count accessible data
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

-- Test Parks manager access
SELECT test_user_data_access('parks@sbdllc.co');

-- =======================================================================================
-- SECTION 7: UTILITY FUNCTIONS FOR FRONTEND
-- =======================================================================================

-- Function for frontend to get current user's complete profile
CREATE OR REPLACE FUNCTION get_current_user_profile()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    current_user_id UUID;
    result JSON;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'No authenticated user found'
        );
    END IF;
    
    SELECT validate_user_session_and_profile(current_user_id) INTO result;
    RETURN result;
END;
$$;

-- Function to refresh user profile data
CREATE OR REPLACE FUNCTION refresh_user_profile(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_uuid UUID;
    result JSON;
BEGIN
    -- Get user ID from email
    SELECT au.id INTO user_uuid
    FROM auth.users au
    WHERE au.email = user_email;
    
    IF user_uuid IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User not found'
        );
    END IF;
    
    -- Validate and return updated profile
    SELECT validate_user_session_and_profile(user_uuid) INTO result;
    RETURN result;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION get_user_with_complete_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION validate_user_session_and_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_contacts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_properties(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION test_user_data_access(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_user_profile(TEXT) TO authenticated;

-- Final status message
SELECT json_build_object(
    'status', 'MIGRATION COMPLETED',
    'message', 'User authentication and tenant data access has been comprehensively fixed',
    'parks_manager_status', (SELECT sync_parks_manager_authentication()),
    'timestamp', NOW()
);