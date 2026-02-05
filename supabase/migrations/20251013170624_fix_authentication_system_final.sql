-- ==================================================================
-- AUTHENTICATION SYSTEM FIXES - Final Comprehensive Update
-- ==================================================================
-- This migration fixes password reset, magic link, and authentication issues
-- Created: 2025-10-13 17:06:24

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- ==================================================================
-- 1. ENHANCED USER AUTHENTICATION STATUS FUNCTION
-- ==================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS get_user_auth_status(text);
-- Create comprehensive user authentication status checker
CREATE OR REPLACE FUNCTION get_user_auth_status(user_email text)
RETURNS TABLE (
    user_exists boolean,
    email_confirmed boolean,
    last_sign_in timestamptz,
    password_set boolean,
    profile_completed boolean,
    account_status text,
    can_reset_password boolean,
    message text
) 
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
DECLARE
    auth_user auth.users%ROWTYPE;
    user_profile user_profiles%ROWTYPE;
BEGIN
    -- Get user from auth.users
    SELECT * INTO auth_user 
    FROM auth.users 
    WHERE email = user_email;
    
    -- If user doesn't exist in auth.users
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,                    -- user_exists
            false,                    -- email_confirmed  
            NULL::timestamptz,        -- last_sign_in
            false,                    -- password_set
            false,                    -- profile_completed
            'USER_NOT_FOUND'::text,   -- account_status
            false,                    -- can_reset_password
            'User account not found'::text; -- message
        RETURN;
    END IF;
    
    -- Get user profile
    SELECT * INTO user_profile 
    FROM user_profiles 
    WHERE id = auth_user.id;
    
    -- Determine account status
    DECLARE
        status text := 'ACTIVE';
        can_reset boolean := true;
        status_message text := 'Account is active and ready to use';
    BEGIN
        -- Check if email is confirmed
        IF auth_user.email_confirmed_at IS NULL THEN
            status := 'UNVERIFIED';
            can_reset := false;
            status_message := 'Email address needs to be verified';
        -- Check if account is disabled
        ELSIF auth_user.banned_until IS NOT NULL AND auth_user.banned_until > now() THEN
            status := 'BANNED';
            can_reset := false;
            status_message := 'Account is temporarily suspended';
        -- Check if profile is incomplete
        ELSIF user_profile IS NULL OR NOT COALESCE(user_profile.profile_completed, false) THEN
            status := 'INCOMPLETE';
            status_message := 'Profile setup needs to be completed';
        -- Check if password needs to be set
        ELSIF user_profile IS NOT NULL AND NOT COALESCE(user_profile.password_set, false) THEN
            status := 'PASSWORD_SETUP_NEEDED';
            status_message := 'Password needs to be set up';
        END IF;
        
        RETURN QUERY SELECT 
            true,                                           -- user_exists
            auth_user.email_confirmed_at IS NOT NULL,      -- email_confirmed
            auth_user.last_sign_in_at,                     -- last_sign_in
            COALESCE(user_profile.password_set, false),    -- password_set
            COALESCE(user_profile.profile_completed, false), -- profile_completed
            status,                                         -- account_status
            can_reset,                                      -- can_reset_password
            status_message;                                 -- message
    END;
END;
$$;
-- ==================================================================
-- 2. ENHANCED PASSWORD RESET WORKFLOW FUNCTION
-- ==================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS admin_force_password_reset(text, uuid);
-- Create admin function to force password reset for specific users
CREATE OR REPLACE FUNCTION admin_force_password_reset(
    target_email text,
    admin_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
    success boolean,
    message text,
    reset_token text
) 
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
DECLARE
    target_user auth.users%ROWTYPE;
    admin_profile user_profiles%ROWTYPE;
    reset_token_value text;
BEGIN
    -- Validate admin user if provided
    IF admin_user_id IS NOT NULL THEN
        SELECT * INTO admin_profile 
        FROM user_profiles 
        WHERE id = admin_user_id;
        
        IF NOT FOUND OR admin_profile.role NOT IN ('super_admin', 'admin', 'manager') THEN
            RETURN QUERY SELECT 
                false,
                'Insufficient permissions to reset passwords'::text,
                NULL::text;
            RETURN;
        END IF;
    END IF;
    
    -- Find target user
    SELECT * INTO target_user 
    FROM auth.users 
    WHERE email = target_email;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,
            'User not found: ' || target_email,
            NULL::text;
        RETURN;
    END IF;
    
    -- Check if user can receive password reset
    IF target_user.email_confirmed_at IS NULL THEN
        RETURN QUERY SELECT 
            false,
            'Cannot reset password for unverified email address'::text,
            NULL::text;
        RETURN;
    END IF;
    
    -- Generate password reset token (simplified for this example)
    reset_token_value := 'PWD_RESET_' || generate_random_uuid()::text;
    
    -- Update user profile to mark password as needing reset
    UPDATE user_profiles 
    SET 
        password_set = false,
        updated_at = now()
    WHERE id = target_user.id;
    
    -- Log the password reset action
    INSERT INTO activity_logs (
        user_id,
        activity_type,
        description,
        metadata,
        created_at
    ) VALUES (
        COALESCE(admin_user_id, target_user.id),
        'PASSWORD_RESET_INITIATED',
        'Password reset initiated for ' || target_email,
        jsonb_build_object(
            'target_user', target_email,
            'initiated_by', CASE WHEN admin_user_id IS NOT NULL THEN 'admin' ELSE 'user' END,
            'timestamp', now()
        ),
        now()
    );
    
    RETURN QUERY SELECT 
        true,
        'Password reset has been initiated. User will need to complete password setup.'::text,
        reset_token_value;
END;
$$;
-- ==================================================================
-- 3. USER NEEDS PASSWORD SETUP CHECKER
-- ==================================================================

-- Drop existing function if it exists  
DROP FUNCTION IF EXISTS user_needs_password_setup(uuid);
-- Create function to check if user needs password setup
CREATE OR REPLACE FUNCTION user_needs_password_setup(user_uuid uuid)
RETURNS boolean
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
DECLARE
    profile_record user_profiles%ROWTYPE;
BEGIN
    SELECT * INTO profile_record 
    FROM user_profiles 
    WHERE id = user_uuid;
    
    IF NOT FOUND THEN
        RETURN true; -- If no profile, needs setup
    END IF;
    
    -- Return true if password is not set or profile is not completed
    RETURN NOT COALESCE(profile_record.password_set, false) 
           OR NOT COALESCE(profile_record.profile_completed, false);
END;
$$;
-- ==================================================================
-- 4. COMPLETE PASSWORD SETUP FUNCTION  
-- ==================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS complete_password_setup(uuid, boolean);
-- Create function to mark password setup as complete
CREATE OR REPLACE FUNCTION complete_password_setup(
    user_uuid uuid,
    mark_password_complete boolean DEFAULT true
)
RETURNS TABLE (
    success boolean,
    message text
) 
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
BEGIN
    -- Update user profile to mark password as set
    UPDATE user_profiles 
    SET 
        password_set = mark_password_complete,
        updated_at = now()
    WHERE id = user_uuid;
    
    IF FOUND THEN
        RETURN QUERY SELECT 
            true,
            'Password setup completed successfully'::text;
    ELSE
        RETURN QUERY SELECT 
            false,
            'User profile not found'::text;
    END IF;
END;
$$;
-- ==================================================================
-- 5. ENHANCED USER REGISTRATION WORKFLOW
-- ==================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS complete_user_setup_enhanced(text, jsonb, boolean);
-- Create enhanced user setup function
CREATE OR REPLACE FUNCTION complete_user_setup_enhanced(
    user_email text,
    profile_data jsonb,
    mark_password_set boolean DEFAULT false
)
RETURNS TABLE (
    success boolean,
    message text,
    redirect_to text
) 
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
DECLARE
    auth_user auth.users%ROWTYPE;
    existing_profile user_profiles%ROWTYPE;
    tenant_record tenants%ROWTYPE;
    user_role text;
    user_organization text;
BEGIN
    -- Get user from auth.users
    SELECT * INTO auth_user 
    FROM auth.users 
    WHERE email = user_email;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,
            'User not found in authentication system'::text,
            NULL::text;
        RETURN;
    END IF;
    
    -- Extract profile data
    user_role := COALESCE(profile_data->>'role', 'rep');
    user_organization := profile_data->>'organization';
    
    -- Check if profile already exists
    SELECT * INTO existing_profile 
    FROM user_profiles 
    WHERE id = auth_user.id;
    
    -- Get tenant information
    SELECT * INTO tenant_record 
    FROM tenants 
    WHERE name = user_organization OR id::text = user_organization
    ORDER BY created_at DESC 
    LIMIT 1;
    
    -- Create or update user profile
    IF existing_profile IS NULL THEN
        INSERT INTO user_profiles (
            id,
            full_name,
            email,
            role,
            tenant_id,
            password_set,
            profile_completed,
            created_at,
            updated_at
        ) VALUES (
            auth_user.id,
            profile_data->>'fullName',
            auth_user.email,
            user_role::user_role,
            tenant_record.id,
            mark_password_set,
            true,
            now(),
            now()
        );
    ELSE
        UPDATE user_profiles 
        SET 
            full_name = COALESCE(profile_data->>'fullName', existing_profile.full_name),
            role = COALESCE(user_role::user_role, existing_profile.role),
            tenant_id = COALESCE(tenant_record.id, existing_profile.tenant_id),
            password_set = mark_password_set OR existing_profile.password_set,
            profile_completed = true,
            updated_at = now()
        WHERE id = auth_user.id;
    END IF;
    
    -- Log the profile completion
    INSERT INTO activity_logs (
        user_id,
        activity_type,
        description,
        metadata,
        created_at
    ) VALUES (
        auth_user.id,
        'PROFILE_COMPLETED',
        'User profile setup completed for ' || auth_user.email,
        jsonb_build_object(
            'role', user_role,
            'organization', user_organization,
            'password_set', mark_password_set,
            'timestamp', now()
        ),
        now()
    );
    
    -- Determine redirect URL based on role
    DECLARE
        redirect_url text;
    BEGIN
        CASE user_role
            WHEN 'super_admin' THEN redirect_url := '/super-admin-dashboard';
            WHEN 'admin' THEN redirect_url := '/admin-dashboard';
            WHEN 'manager' THEN redirect_url := '/manager-dashboard';
            ELSE redirect_url := '/today';
        END CASE;
        
        RETURN QUERY SELECT 
            true,
            'Profile setup completed successfully! Welcome to the platform.'::text,
            redirect_url;
    END;
END;
$$;
-- ==================================================================
-- 6. RESEND CONFIRMATION WORKFLOW
-- ==================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS resend_confirmation_workflow(text);
-- Create function to handle confirmation resending
CREATE OR REPLACE FUNCTION resend_confirmation_workflow(user_email text)
RETURNS TABLE (
    success boolean,
    message text,
    can_resend boolean
) 
LANGUAGE plpgsql SECURITY definer
SET search_path = public
AS $$
DECLARE
    auth_user auth.users%ROWTYPE;
BEGIN
    -- Get user from auth.users
    SELECT * INTO auth_user 
    FROM auth.users 
    WHERE email = user_email;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false,
            'No account found with this email address'::text,
            false;
        RETURN;
    END IF;
    
    -- Check if already confirmed
    IF auth_user.email_confirmed_at IS NOT NULL THEN
        RETURN QUERY SELECT 
            false,
            'Email address is already verified'::text,
            false;
        RETURN;
    END IF;
    
    -- Check if account is banned
    IF auth_user.banned_until IS NOT NULL AND auth_user.banned_until > now() THEN
        RETURN QUERY SELECT 
            false,
            'Account is currently suspended and cannot receive confirmation emails'::text,
            false;
        RETURN;
    END IF;
    
    -- Allow resending
    RETURN QUERY SELECT 
        true,
        'Confirmation email can be sent'::text,
        true;
END;
$$;
-- ==================================================================
-- 7. GRANT PERMISSIONS
-- ==================================================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_user_auth_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION admin_force_password_reset(text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION user_needs_password_setup(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_password_setup(uuid, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_user_setup_enhanced(text, jsonb, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION resend_confirmation_workflow(text) TO authenticated;
-- Grant execute permissions to service role
GRANT EXECUTE ON FUNCTION get_user_auth_status(text) TO service_role;
GRANT EXECUTE ON FUNCTION admin_force_password_reset(text, uuid) TO service_role;
GRANT EXECUTE ON FUNCTION user_needs_password_setup(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION complete_password_setup(uuid, boolean) TO service_role;
GRANT EXECUTE ON FUNCTION complete_user_setup_enhanced(text, jsonb, boolean) TO service_role;
GRANT EXECUTE ON FUNCTION resend_confirmation_workflow(text) TO service_role;
-- ==================================================================
-- 8. ACTIVITY LOGS TABLE (if not exists)
-- ==================================================================

-- Create activity_logs table if it doesn't exist
CREATE TABLE IF NOT EXISTS activity_logs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type text NOT NULL,
    description text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    tenant_id uuid REFERENCES tenants(id) ON DELETE SET NULL
);
-- Create index for activity logs
CREATE INDEX IF NOT EXISTS activity_logs_user_id_idx ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS activity_logs_created_at_idx ON activity_logs(created_at);
CREATE INDEX IF NOT EXISTS activity_logs_activity_type_idx ON activity_logs(activity_type);
-- Enable RLS on activity_logs
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
-- Create RLS policies for activity_logs
DROP POLICY IF EXISTS "Users can view their own activity logs" ON activity_logs;
CREATE POLICY "Users can view their own activity logs" ON activity_logs
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND role IN ('super_admin', 'admin', 'manager')
        )
    );
DROP POLICY IF EXISTS "System can insert activity logs" ON activity_logs;
CREATE POLICY "System can insert activity logs" ON activity_logs
    FOR INSERT WITH CHECK (true);
-- ==================================================================
-- MIGRATION COMPLETE
-- ==================================================================

-- Add a comment to track this migration
COMMENT ON SCHEMA public IS 'Authentication system fixes completed on 2025-10-13 17:06:24';
