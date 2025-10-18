-- Migration: Create Missing test_user_data_access Function
-- Date: 2025-01-15 00:00:00
-- Description: Create the missing test_user_data_access function that was referenced in the migration but doesn't exist

-- =======================================================================================
-- SECTION 1: CREATE THE MISSING TEST USER DATA ACCESS FUNCTION
-- =======================================================================================

-- Create the missing test_user_data_access function
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
    
    -- Test authentication using validate_user_session_and_profile
    SELECT validate_user_session_and_profile(user_uuid) INTO auth_result;
    
    -- Count accessible data using existing functions
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
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Error testing user data access: ' || SQLERRM,
            'email', test_email
        );
END;
$$;

-- =======================================================================================
-- SECTION 2: GRANT PERMISSIONS
-- =======================================================================================

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION test_user_data_access(TEXT) TO authenticated;

-- =======================================================================================
-- SECTION 3: TEST THE FUNCTION (SAFE TESTING)
-- =======================================================================================

-- Test the function with Parks manager user (with error handling)
DO $$
DECLARE
    parks_test_result JSON;
    admin_test_result JSON;
BEGIN
    -- Test Parks manager data access
    BEGIN
        SELECT test_user_data_access('parks@sbdllc.co') INTO parks_test_result;
        RAISE NOTICE 'Parks manager test result: %', parks_test_result;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Parks manager test failed: %', SQLERRM;
    END;
    
    -- Test Admin data access  
    BEGIN
        SELECT test_user_data_access('admin@sbdllc.co') INTO admin_test_result;
        RAISE NOTICE 'Admin test result: %', admin_test_result;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Admin test failed: %', SQLERRM;
    END;
END;
$$;

-- Final status message
SELECT json_build_object(
    'status', 'MIGRATION COMPLETED SUCCESSFULLY',
    'message', 'Created missing test_user_data_access function',
    'created_functions', ARRAY['test_user_data_access'],
    'fixed_error', 'ERROR: 42883: function test_user_data_access(unknown) does not exist',
    'note', 'Function now safely tests user authentication and data access with proper error handling',
    'timestamp', NOW()
) as migration_result;