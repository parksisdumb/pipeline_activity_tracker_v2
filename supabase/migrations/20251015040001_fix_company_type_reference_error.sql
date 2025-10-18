-- CRITICAL FIX: company_types type does not exist error
-- The migration 20251015040000_fix_tenant_data_access_comprehensive_final.sql references 'company_types' (plural)
-- but the actual enum type is 'company_type' (singular) as defined in the original schema
-- This migration fixes all references to use the correct type name

-- Drop the problematic functions that reference the wrong type name
DROP FUNCTION IF EXISTS get_user_accessible_accounts(uuid);
DROP FUNCTION IF EXISTS validate_user_session_and_profile(uuid);

-- 1. CREATE ENHANCED USER VALIDATION FUNCTION (with correct type references)
CREATE OR REPLACE FUNCTION validate_user_session_and_profile(user_uuid uuid)
RETURNS TABLE (
    success boolean,
    user_exists boolean,
    profile_completed boolean,
    password_set boolean,
    message text,
    redirect_url text,
    user_data jsonb
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_profile RECORD;
    tenant_info RECORD;
BEGIN
    -- Check if user exists in user_profiles
    SELECT up.*, t.name as tenant_name
    INTO user_profile
    FROM user_profiles up
    LEFT JOIN tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,
            false,
            false,
            false,
            'User profile not found'::text,
            '/profile-creation'::text,
            '{}'::jsonb;
        RETURN;
    END IF;

    -- Return successful validation with comprehensive user data
    RETURN QUERY SELECT 
        true,
        true,
        COALESCE(user_profile.profile_completed, true),
        COALESCE(user_profile.password_set, true),
        'Authentication completed successfully'::text,
        CASE 
            WHEN user_profile.role = 'super_admin' THEN '/super-admin-dashboard'
            WHEN user_profile.role = 'manager' THEN '/manager-dashboard'
            WHEN user_profile.role = 'admin' THEN '/admin-dashboard'
            ELSE '/today'
        END::text,
        jsonb_build_object(
            'id', user_profile.id,
            'email', user_profile.email,
            'role', user_profile.role,
            'full_name', user_profile.full_name,
            'tenant_id', user_profile.tenant_id,
            'tenant_name', COALESCE(user_profile.tenant_name, 'No Organization'),
            'is_active', COALESCE(user_profile.is_active, true)
        );
END;
$$;

-- 2. CREATE COMPREHENSIVE ACCOUNT ACCESS FUNCTION (with correct type reference)
CREATE OR REPLACE FUNCTION get_user_accessible_accounts(user_uuid uuid)
RETURNS TABLE (
    id uuid,
    name text,
    company_type company_type,  -- ✅ FIXED: Changed from company_types to company_type
    stage account_stages,
    city text,
    state text,
    email text,
    phone text,
    created_at timestamptz,
    updated_at timestamptz,
    notes text,
    is_active boolean,
    assigned_rep_id uuid,
    tenant_id uuid,
    properties_count bigint,
    contacts_count bigint,
    opportunities_count bigint,
    primary_rep_name text,
    assigned_reps jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_profile RECORD;
    user_role text;
    user_tenant_id uuid;
BEGIN
    -- Get user profile information
    SELECT up.role, up.tenant_id, up.full_name, up.is_active
    INTO user_profile
    FROM user_profiles up
    WHERE up.id = user_uuid;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User profile not found for UUID: %', user_uuid;
    END IF;

    user_role := user_profile.role;
    user_tenant_id := user_profile.tenant_id;

    -- Log for debugging
    RAISE LOG 'User % with role % accessing accounts for tenant %', user_uuid, user_role, user_tenant_id;

    -- Return accounts based on role with enhanced data
    IF user_role IN ('super_admin', 'master_admin') THEN
        -- Super admins see all accounts across all tenants
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
            COALESCE(o_count.count, 0) as opportunities_count,
            rep.full_name as primary_rep_name,
            COALESCE(rep_assignments.assigned_reps, '[]'::jsonb) as assigned_reps
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties 
            WHERE is_active = true
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts 
            WHERE is_active = true
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM opportunities 
            WHERE is_active = true
            GROUP BY account_id
        ) o_count ON a.id = o_count.account_id
        LEFT JOIN (
            SELECT 
                aa.account_id,
                jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep.full_name,
                        'is_primary', aa.is_primary
                    )
                ) as assigned_reps
            FROM account_assignments aa
            JOIN user_profiles rep ON aa.rep_id = rep.id
            GROUP BY aa.account_id
        ) rep_assignments ON a.id = rep_assignments.account_id
        WHERE COALESCE(a.is_active, true) = true
        ORDER BY a.name;

    ELSIF user_role = 'admin' THEN
        -- Admins see all accounts in their tenant
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
            COALESCE(o_count.count, 0) as opportunities_count,
            rep.full_name as primary_rep_name,
            COALESCE(rep_assignments.assigned_reps, '[]'::jsonb) as assigned_reps
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties 
            WHERE is_active = true
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts 
            WHERE is_active = true
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM opportunities 
            WHERE is_active = true
            GROUP BY account_id
        ) o_count ON a.id = o_count.account_id
        LEFT JOIN (
            SELECT 
                aa.account_id,
                jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep.full_name,
                        'is_primary', aa.is_primary
                    )
                ) as assigned_reps
            FROM account_assignments aa
            JOIN user_profiles rep ON aa.rep_id = rep.id
            GROUP BY aa.account_id
        ) rep_assignments ON a.id = rep_assignments.account_id
        WHERE a.tenant_id = user_tenant_id 
        AND COALESCE(a.is_active, true) = true
        ORDER BY a.name;

    ELSIF user_role = 'manager' THEN
        -- Managers see accounts in their tenant or assigned to their team
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
            COALESCE(o_count.count, 0) as opportunities_count,
            rep.full_name as primary_rep_name,
            COALESCE(rep_assignments.assigned_reps, '[]'::jsonb) as assigned_reps
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties 
            WHERE is_active = true
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts 
            WHERE is_active = true
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM opportunities 
            WHERE is_active = true
            GROUP BY account_id
        ) o_count ON a.id = o_count.account_id
        LEFT JOIN (
            SELECT 
                aa.account_id,
                jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep.full_name,
                        'is_primary', aa.is_primary
                    )
                ) as assigned_reps
            FROM account_assignments aa
            JOIN user_profiles rep ON aa.rep_id = rep.id
            GROUP BY aa.account_id
        ) rep_assignments ON a.id = rep_assignments.account_id
        WHERE (
            a.tenant_id = user_tenant_id 
            OR a.assigned_rep_id IN (
                SELECT id FROM user_profiles 
                WHERE tenant_id = user_tenant_id
            )
            OR EXISTS (
                SELECT 1 FROM account_assignments aa 
                JOIN user_profiles team_rep ON aa.rep_id = team_rep.id
                WHERE aa.account_id = a.id 
                AND team_rep.tenant_id = user_tenant_id
            )
        )
        AND COALESCE(a.is_active, true) = true
        ORDER BY a.name;

    ELSE
        -- Reps see only their assigned accounts
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
            COALESCE(o_count.count, 0) as opportunities_count,
            rep.full_name as primary_rep_name,
            COALESCE(rep_assignments.assigned_reps, '[]'::jsonb) as assigned_reps
        FROM accounts a
        LEFT JOIN user_profiles rep ON a.assigned_rep_id = rep.id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM properties 
            WHERE is_active = true
            GROUP BY account_id
        ) p_count ON a.id = p_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM contacts 
            WHERE is_active = true
            GROUP BY account_id
        ) c_count ON a.id = c_count.account_id
        LEFT JOIN (
            SELECT account_id, COUNT(*) as count
            FROM opportunities 
            WHERE is_active = true
            GROUP BY account_id
        ) o_count ON a.id = o_count.account_id
        LEFT JOIN (
            SELECT 
                aa.account_id,
                jsonb_agg(
                    jsonb_build_object(
                        'rep_id', aa.rep_id,
                        'rep_name', rep.full_name,
                        'is_primary', aa.is_primary
                    )
                ) as assigned_reps
            FROM account_assignments aa
            JOIN user_profiles rep ON aa.rep_id = rep.id
            GROUP BY aa.account_id
        ) rep_assignments ON a.id = rep_assignments.account_id
        WHERE (
            a.assigned_rep_id = user_uuid
            OR EXISTS (
                SELECT 1 FROM account_assignments aa 
                WHERE aa.account_id = a.id 
                AND aa.rep_id = user_uuid
            )
        )
        AND COALESCE(a.is_active, true) = true
        ORDER BY a.name;

    END IF;
END;
$$;

-- 3. CREATE SAMPLE DATA TO TEST (if none exists) - with correct enum casting
DO $$
DECLARE
    sample_tenant_id uuid;
    sample_user_id uuid;
    sample_account_id uuid;
BEGIN
    -- Check if we have any tenants, if not create sample data
    SELECT id INTO sample_tenant_id FROM tenants LIMIT 1;
    
    IF sample_tenant_id IS NULL THEN
        -- Create sample tenant
        INSERT INTO tenants (name, is_active) 
        VALUES ('Sample Organization', true)
        RETURNING id INTO sample_tenant_id;
        
        RAISE LOG 'Created sample tenant: %', sample_tenant_id;
    END IF;
    
    -- Check if we have any active accounts, if not create some
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE is_active = true) THEN
        -- Create sample accounts with correct enum casting
        FOR i IN 1..5 LOOP
            INSERT INTO accounts (
                name, 
                company_type, 
                stage, 
                tenant_id, 
                city, 
                state, 
                email,
                is_active
            ) VALUES (
                'Sample Company ' || i,
                'Property Management'::company_type,  -- ✅ FIXED: Using correct enum name
                'Prospect'::account_stages,  -- Using existing account_stages enum
                sample_tenant_id,
                'Sample City',
                'CA',
                'contact' || i || '@samplecompany.com',
                true
            );
        END LOOP;
        
        RAISE LOG 'Created sample accounts for tenant: %', sample_tenant_id;
    END IF;
END;
$$;

-- 4. GRANT NECESSARY PERMISSIONS
GRANT EXECUTE ON FUNCTION validate_user_session_and_profile(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(uuid) TO authenticated;

-- Log completion
SELECT 'Migration completed: Fixed company_type reference error and created corrected functions' as status;