-- Location: supabase/migrations/20250115010000_create_missing_validate_user_session_and_profile_function.sql
-- Fix for Supabase error: "Could not find the function public.validate_user_session_and_profile(user_uuid) in the schema cache"
-- This migration creates the missing function that is being called by AuthContext.jsx

-- Create the missing validate_user_session_and_profile function
CREATE OR REPLACE FUNCTION public.validate_user_session_and_profile(user_uuid UUID)
RETURNS TABLE(
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
SET search_path = public
AS $$
DECLARE
    auth_user_record auth.users%ROWTYPE;
    profile_record public.user_profiles%ROWTYPE;
    result_data JSONB;
BEGIN
    -- Check if the provided UUID is valid and matches current auth user
    IF user_uuid IS NULL OR user_uuid != auth.uid() THEN
        RETURN QUERY SELECT 
            false::BOOLEAN,
            false::BOOLEAN,
            '{}'::JSONB,
            false::BOOLEAN,
            false::BOOLEAN,
            'Invalid or unauthorized user session'::TEXT,
            '/login'::TEXT;
        RETURN;
    END IF;

    -- Get auth user record
    SELECT * INTO auth_user_record
    FROM auth.users
    WHERE id = user_uuid;

    -- Check if auth user exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false::BOOLEAN,
            false::BOOLEAN,
            '{}'::JSONB,
            false::BOOLEAN,
            false::BOOLEAN,
            'User not found in authentication system'::TEXT,
            '/login'::TEXT;
        RETURN;
    END IF;

    -- Get user profile
    SELECT * INTO profile_record
    FROM public.user_profiles
    WHERE id = user_uuid;

    -- Build user data JSON
    IF profile_record.id IS NOT NULL THEN
        result_data := jsonb_build_object(
            'id', profile_record.id,
            'email', profile_record.email,
            'full_name', profile_record.full_name,
            'role', profile_record.role,
            'tenant_id', profile_record.tenant_id,
            'is_active', COALESCE(profile_record.is_active, true),
            'created_at', profile_record.created_at,
            'updated_at', profile_record.updated_at
        );
    ELSE
        -- Fallback to auth user data if no profile exists
        result_data := jsonb_build_object(
            'id', auth_user_record.id,
            'email', auth_user_record.email,
            'full_name', COALESCE(auth_user_record.raw_user_meta_data->>'full_name', ''),
            'role', COALESCE(auth_user_record.raw_user_meta_data->>'role', 'rep'),
            'tenant_id', null,
            'is_active', true,
            'created_at', auth_user_record.created_at,
            'updated_at', auth_user_record.updated_at
        );
    END IF;

    -- Determine profile completion status
    DECLARE
        is_profile_complete BOOLEAN := false;
        is_password_set BOOLEAN := false;
        redirect_path TEXT := '/today';
    BEGIN
        -- Check if profile is complete
        IF profile_record.id IS NOT NULL AND 
           profile_record.full_name IS NOT NULL AND 
           profile_record.full_name != '' THEN
            is_profile_complete := true;
        END IF;

        -- Check if password is set (auth user has encrypted password)
        IF auth_user_record.encrypted_password IS NOT NULL AND 
           auth_user_record.encrypted_password != '' THEN
            is_password_set := true;
        END IF;

        -- Determine redirect URL based on completion status
        IF NOT is_profile_complete THEN
            redirect_path := '/profile-creation';
        ELSIF NOT is_password_set THEN
            redirect_path := '/password-setup';
        ELSIF profile_record.role = 'super_admin' THEN
            redirect_path := '/super-admin-dashboard';
        ELSIF profile_record.role = 'admin' THEN
            redirect_path := '/admin-dashboard';
        ELSIF profile_record.role = 'manager' THEN
            redirect_path := '/manager-dashboard';
        ELSE
            redirect_path := '/today';
        END IF;

        -- Return successful validation result
        RETURN QUERY SELECT 
            true::BOOLEAN,
            true::BOOLEAN,
            result_data,
            is_profile_complete,
            is_password_set,
            'User session and profile validated successfully'::TEXT,
            redirect_path;
        RETURN;
    END;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle any unexpected errors
        RETURN QUERY SELECT 
            false::BOOLEAN,
            true::BOOLEAN,
            '{}'::JSONB,
            false::BOOLEAN,
            false::BOOLEAN,
            ('Error validating user session: ' || SQLERRM)::TEXT,
            '/login'::TEXT;
        RETURN;
END;
$$;
-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.validate_user_session_and_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_user_session_and_profile(UUID) TO anon;
-- Add function comment for documentation
COMMENT ON FUNCTION public.validate_user_session_and_profile(UUID) IS 
'Validates user session and returns comprehensive profile information including completion status and appropriate redirect URLs. Used by AuthContext.jsx for profile loading.';
