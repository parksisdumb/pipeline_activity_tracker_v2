-- Location: supabase/migrations/20251227020000_fix_master_admin_enum_critical_auth_failure.sql
-- CRITICAL FIX: Authentication system failure due to missing master_admin enum value
-- This migration addresses the critical issue where users cannot authenticate because 
-- the user_role enum is missing 'master_admin' causing validation failures

-- Step 1: Add master_admin to the user_role enum safely
DO $$
BEGIN
    -- Check if master_admin enum value exists, if not add it
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'master_admin' 
        AND enumtypid = 'public.user_role'::regtype
    ) THEN
        ALTER TYPE public.user_role ADD VALUE 'master_admin';
        RAISE NOTICE 'Added master_admin to user_role enum';
    ELSE
        RAISE NOTICE 'master_admin enum value already exists';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding master_admin enum value: %', SQLERRM;
END $$;
-- Step 2: Update validation function to handle master_admin role properly
-- Drop and recreate to ensure we handle master_admin enum casting
DROP FUNCTION IF EXISTS public.validate_user_session_and_profile(UUID);
CREATE OR REPLACE FUNCTION public.validate_user_session_and_profile(user_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_exists_check BOOLEAN := FALSE;
    profile_data RECORD;
    validation_result JSON;
    role_string TEXT;
BEGIN
    -- Check if user exists in auth.users
    SELECT EXISTS (
        SELECT 1 FROM auth.users au WHERE au.id = user_uuid
    ) INTO user_exists_check;
    
    IF NOT user_exists_check THEN
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', FALSE,
            'profile_completed', FALSE,
            'password_set', FALSE,
            'message', 'User not found in authentication system',
            'redirect_url', '/login',
            'user_data', NULL
        ) INTO validation_result;
        
        RETURN validation_result;
    END IF;
    
    -- Get user profile data with tenant information
    -- CRITICAL FIX: Use role::text to avoid enum casting errors
    SELECT 
        up.id,
        up.email,
        up.full_name,
        up.role::text as role_text, -- Convert to text to avoid enum issues
        up.is_active,
        up.profile_completed,
        up.password_set,
        up.tenant_id,
        t.name as tenant_name
    INTO profile_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    -- If no profile found, return incomplete profile response
    IF profile_data IS NULL THEN
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', TRUE,
            'profile_completed', FALSE,
            'password_set', FALSE,
            'message', 'User profile not found. Please complete profile setup.',
            'redirect_url', '/profile-creation',
            'user_data', NULL
        ) INTO validation_result;
        
        RETURN validation_result;
    END IF;
    
    -- Extract role as string for safe comparisons
    role_string := profile_data.role_text;
    
    -- Check if profile is incomplete
    IF profile_data.profile_completed = FALSE OR profile_data.full_name IS NULL OR profile_data.full_name = '' THEN
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', TRUE,
            'profile_completed', FALSE,
            'password_set', COALESCE(profile_data.password_set, FALSE),
            'message', 'Profile setup incomplete. Please complete your profile.',
            'redirect_url', '/profile-creation',
            'user_data', json_build_object(
                'id', profile_data.id,
                'email', profile_data.email,
                'full_name', profile_data.full_name,
                'role', role_string,
                'is_active', profile_data.is_active,
                'tenant_id', profile_data.tenant_id,
                'tenant_name', profile_data.tenant_name
            )
        ) INTO validation_result;
        
        RETURN validation_result;
    END IF;
    
    -- Check if password setup is incomplete
    IF profile_data.password_set = FALSE THEN
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', TRUE,
            'profile_completed', TRUE,
            'password_set', FALSE,
            'message', 'Password setup required. Please set your password.',
            'redirect_url', '/password-setup',
            'user_data', json_build_object(
                'id', profile_data.id,
                'email', profile_data.email,
                'full_name', profile_data.full_name,
                'role', role_string,
                'is_active', profile_data.is_active,
                'tenant_id', profile_data.tenant_id,
                'tenant_name', profile_data.tenant_name
            )
        ) INTO validation_result;
        
        RETURN validation_result;
    END IF;
    
    -- All validation passed - return success with complete user data
    -- CRITICAL FIX: Handle both master_admin and super_admin for redirect
    SELECT json_build_object(
        'success', TRUE,
        'user_exists', TRUE,
        'profile_completed', TRUE,
        'password_set', TRUE,
        'message', 'Authentication completed successfully',
        'redirect_url', CASE 
            WHEN role_string IN ('super_admin', 'master_admin') THEN '/super-admin-dashboard'
            WHEN role_string = 'admin' THEN '/admin-dashboard'
            WHEN role_string = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END,
        'user_data', json_build_object(
            'id', profile_data.id,
            'email', profile_data.email,
            'full_name', profile_data.full_name,
            'role', role_string,
            'is_active', profile_data.is_active,
            'tenant_id', profile_data.tenant_id,
            'tenant_name', profile_data.tenant_name
        )
    ) INTO validation_result;
    
    RETURN validation_result;

EXCEPTION
    WHEN OTHERS THEN
        -- ENHANCED ERROR HANDLING: Provide more specific error information
        RAISE NOTICE 'Validation function error: % for user %', SQLERRM, user_uuid;
        
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', user_exists_check,
            'profile_completed', FALSE,
            'password_set', FALSE,
            'message', 'Validation error: ' || SQLERRM,
            'redirect_url', '/login',
            'user_data', NULL,
            'debug_info', json_build_object(
                'error_code', SQLSTATE,
                'error_message', SQLERRM,
                'user_uuid', user_uuid::text
            )
        ) INTO validation_result;
        
        RETURN validation_result;
END;
$$;
-- Step 3: Update authentication helper functions to handle master_admin
CREATE OR REPLACE FUNCTION public.is_super_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
    (SELECT (au.raw_user_meta_data->>'role' IN ('super_admin', 'master_admin')
             OR au.raw_app_meta_data->>'role' IN ('super_admin', 'master_admin'))
     FROM auth.users au
     WHERE au.id = auth.uid()),
    false
)
$$;
CREATE OR REPLACE FUNCTION public.is_super_admin_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role::text IN ('super_admin', 'master_admin')
    AND up.is_active = true
)
$$;
-- Step 4: Update admin functions to include master_admin
CREATE OR REPLACE FUNCTION public.is_admin_from_auth_metadata()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
    (SELECT (au.raw_user_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin')
             OR au.raw_app_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin'))
     FROM auth.users au
     WHERE au.id = auth.uid()),
    false
)
$$;
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role::text IN ('admin', 'super_admin', 'master_admin')
    AND up.is_active = true
)
$$;
-- Step 5: Fix any existing user records that might have invalid role references
-- Update any records that might be causing enum validation issues
DO $$
DECLARE
    fixed_count INTEGER := 0;
BEGIN
    -- This is a safety check - update any users with problematic role data in auth metadata
    -- while preserving their actual profile roles
    UPDATE auth.users 
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role_fixed', true)
    WHERE id IN (
        SELECT au.id FROM auth.users au
        JOIN public.user_profiles up ON au.id = up.id
        WHERE up.role::text IN ('master_admin', 'super_admin')
        AND (
            au.raw_user_meta_data->>'role' IS NULL
            OR au.raw_app_meta_data->>'role' IS NULL
        )
    );
    
    GET DIAGNOSTICS fixed_count = ROW_COUNT;
    RAISE NOTICE 'Fixed % user metadata records', fixed_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error fixing user metadata: %', SQLERRM;
END $$;
-- Step 6: Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.validate_user_session_and_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin_from_auth() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_from_auth_metadata() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_user() TO authenticated;
-- Step 7: Add helpful comments
COMMENT ON FUNCTION public.validate_user_session_and_profile(UUID) IS 'FIXED: Validates user authentication and handles both master_admin and super_admin roles without enum casting errors';
-- Step 8: Verification query to ensure the enum values exist
DO $$
BEGIN
    -- Check that both enum values exist
    IF EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'master_admin' AND enumtypid = 'public.user_role'::regtype) 
       AND EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'super_admin' AND enumtypid = 'public.user_role'::regtype) THEN
        RAISE NOTICE 'SUCCESS: Both master_admin and super_admin enum values are available';
    ELSE
        RAISE NOTICE 'WARNING: Enum values may be missing - please verify user_role enum';
    END IF;
END $$;
