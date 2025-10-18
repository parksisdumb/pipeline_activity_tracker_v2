-- Location: supabase/migrations/20251227010000_fix_validation_rpc_return_single_object.sql
-- Fix validate_user_session_and_profile RPC function to return single JSON object instead of array
-- This addresses the "user profile validation failed" error that occurs even with successful authentication

-- CRITICAL FIX: Drop the existing function first to avoid "cannot change return type" error
DROP FUNCTION IF EXISTS public.validate_user_session_and_profile(UUID);

-- Create new function that returns a single JSON object instead of SETOF/array
CREATE OR REPLACE FUNCTION public.validate_user_session_and_profile(user_uuid UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_exists_check BOOLEAN := FALSE;
    profile_data RECORD;
    validation_result JSON;
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
    SELECT 
        up.id,
        up.email,
        up.full_name,
        up.role,
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
                'role', profile_data.role,
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
                'role', profile_data.role,
                'is_active', profile_data.is_active,
                'tenant_id', profile_data.tenant_id,
                'tenant_name', profile_data.tenant_name
            )
        ) INTO validation_result;
        
        RETURN validation_result;
    END IF;
    
    -- All validation passed - return success with complete user data
    SELECT json_build_object(
        'success', TRUE,
        'user_exists', TRUE,
        'profile_completed', TRUE,
        'password_set', TRUE,
        'message', 'Authentication completed successfully',
        'redirect_url', CASE 
            WHEN profile_data.role = 'super_admin' OR profile_data.role = 'master_admin' THEN '/super-admin-dashboard'
            WHEN profile_data.role = 'admin' THEN '/admin-dashboard'
            WHEN profile_data.role = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END,
        'user_data', json_build_object(
            'id', profile_data.id,
            'email', profile_data.email,
            'full_name', profile_data.full_name,
            'role', profile_data.role,
            'is_active', profile_data.is_active,
            'tenant_id', profile_data.tenant_id,
            'tenant_name', profile_data.tenant_name
        )
    ) INTO validation_result;
    
    RETURN validation_result;

EXCEPTION
    WHEN OTHERS THEN
        -- Return error response as single JSON object
        SELECT json_build_object(
            'success', FALSE,
            'user_exists', user_exists_check,
            'profile_completed', FALSE,
            'password_set', FALSE,
            'message', 'Validation error: ' || SQLERRM,
            'redirect_url', '/login',
            'user_data', NULL
        ) INTO validation_result;
        
        RETURN validation_result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.validate_user_session_and_profile(UUID) TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION public.validate_user_session_and_profile(UUID) IS 'Validates user session and profile completeness, returns single JSON object instead of array to prevent parsing errors in client applications';