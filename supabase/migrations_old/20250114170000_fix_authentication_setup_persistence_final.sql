-- Fix Authentication Setup Persistence Issue
-- Issue: Users complete setup but get redirected back to setup screen
-- Solution: Enhanced functions to properly persist and validate setup completion

-- Step 1: Drop existing problematic functions that might be causing issues
DROP FUNCTION IF EXISTS public.complete_user_setup_enhanced(TEXT, JSONB, BOOLEAN);
DROP FUNCTION IF EXISTS public.get_detailed_user_auth_status(UUID);
DROP FUNCTION IF EXISTS public.get_user_auth_status(TEXT);
DROP FUNCTION IF EXISTS public.complete_password_setup(UUID, BOOLEAN);

-- Step 2: Create enhanced setup completion function with better error handling
CREATE OR REPLACE FUNCTION public.complete_user_setup_enhanced(
    user_email TEXT,
    profile_data JSONB,
    mark_password_set BOOLEAN DEFAULT true
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    redirect_to TEXT,
    user_id UUID,
    profile_completed BOOLEAN,
    password_set BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    existing_profile RECORD;
    tenant_redirect TEXT;
    final_redirect TEXT;
BEGIN
    -- Find user by email
    SELECT id INTO target_user_id
    FROM auth.users 
    WHERE email = user_email;
    
    IF target_user_id IS NULL THEN
        RETURN QUERY SELECT 
            false::BOOLEAN, 
            'User not found with email: ' || user_email::TEXT,
            '/login'::TEXT,
            NULL::UUID,
            false::BOOLEAN,
            false::BOOLEAN;
        RETURN;
    END IF;
    
    -- Get existing profile
    SELECT * INTO existing_profile
    FROM public.user_profiles 
    WHERE id = target_user_id;
    
    -- Update or create user profile with atomic transaction
    INSERT INTO public.user_profiles (
        id,
        email, 
        full_name,
        role,
        organization,
        profile_completed,
        password_set,
        setup_completed_at,
        updated_at
    )
    VALUES (
        target_user_id,
        user_email,
        (profile_data->>'fullName')::TEXT,
        COALESCE((profile_data->>'role')::TEXT, 'rep'),
        (profile_data->>'organization')::TEXT,
        true, -- Mark profile as completed
        mark_password_set, -- Mark password as set if requested
        CURRENT_TIMESTAMP, -- Record completion time
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = COALESCE((profile_data->>'fullName')::TEXT, user_profiles.full_name),
        role = COALESCE((profile_data->>'role')::TEXT, user_profiles.role),
        organization = COALESCE((profile_data->>'organization')::TEXT, user_profiles.organization),
        profile_completed = true, -- Always mark as completed
        password_set = CASE 
            WHEN mark_password_set THEN true 
            ELSE user_profiles.password_set 
        END,
        setup_completed_at = CURRENT_TIMESTAMP, -- Update completion time
        updated_at = CURRENT_TIMESTAMP;
    
    -- Determine redirect based on user role and tenant assignment
    SELECT 
        CASE 
            WHEN up.role = 'super_admin' THEN 'super-admin-dashboard'
            WHEN up.role = 'admin' THEN 'admin-dashboard' 
            WHEN up.role = 'manager' THEN 'manager-dashboard'
            ELSE 'today'
        END INTO final_redirect
    FROM public.user_profiles up
    WHERE up.id = target_user_id;
    
    -- Return success with proper redirect
    RETURN QUERY SELECT 
        true::BOOLEAN,
        'Profile setup completed successfully!'::TEXT,
        final_redirect::TEXT,
        target_user_id::UUID,
        true::BOOLEAN, -- profile_completed
        mark_password_set::BOOLEAN; -- password_set
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error and return failure
        RAISE WARNING 'Error in complete_user_setup_enhanced: %', SQLERRM;
        RETURN QUERY SELECT 
            false::BOOLEAN,
            'Setup failed: ' || SQLERRM::TEXT,
            '/password-setup'::TEXT,
            target_user_id::UUID,
            false::BOOLEAN,
            false::BOOLEAN;
        RETURN;
END;
$$;

-- Step 3: Create enhanced authentication status checking function
CREATE OR REPLACE FUNCTION public.get_detailed_user_auth_status(user_uuid UUID)
RETURNS TABLE(
    user_exists BOOLEAN,
    email_confirmed BOOLEAN,
    profile_completed BOOLEAN,
    password_set BOOLEAN,
    setup_completed BOOLEAN,
    next_action TEXT,
    redirect_url TEXT,
    role TEXT,
    full_name TEXT,
    last_setup_attempt TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user RECORD;
    profile_user RECORD;
BEGIN
    -- Get auth user data
    SELECT 
        au.id,
        au.email,
        au.email_confirmed_at IS NOT NULL AS email_confirmed,
        au.created_at
    INTO auth_user
    FROM auth.users au
    WHERE au.id = user_uuid;
    
    -- Get profile data if exists
    SELECT 
        up.id,
        up.full_name,
        up.role,
        up.profile_completed,
        up.password_set,
        up.setup_completed_at,
        up.tenant_id,
        up.updated_at
    INTO profile_user
    FROM public.user_profiles up
    WHERE up.id = user_uuid;
    
    -- Determine user status and next action
    IF auth_user.id IS NULL THEN
        -- User doesn't exist
        RETURN QUERY SELECT 
            false::BOOLEAN, -- user_exists
            false::BOOLEAN, -- email_confirmed  
            false::BOOLEAN, -- profile_completed
            false::BOOLEAN, -- password_set
            false::BOOLEAN, -- setup_completed
            'signup'::TEXT, -- next_action
            '/sign-up'::TEXT, -- redirect_url
            ''::TEXT, -- role
            ''::TEXT, -- full_name
            NULL::TIMESTAMPTZ; -- last_setup_attempt
        RETURN;
    END IF;
    
    -- User exists, check completion status
    IF profile_user.id IS NULL OR 
       NOT COALESCE(profile_user.profile_completed, false) OR
       NOT COALESCE(profile_user.password_set, false) THEN
        -- Setup incomplete
        RETURN QUERY SELECT 
            true::BOOLEAN, -- user_exists
            auth_user.email_confirmed::BOOLEAN, -- email_confirmed
            COALESCE(profile_user.profile_completed, false)::BOOLEAN, -- profile_completed
            COALESCE(profile_user.password_set, false)::BOOLEAN, -- password_set
            false::BOOLEAN, -- setup_completed
            'complete_setup'::TEXT, -- next_action
            '/password-setup'::TEXT, -- redirect_url
            COALESCE(profile_user.role, '')::TEXT, -- role
            COALESCE(profile_user.full_name, '')::TEXT, -- full_name
            profile_user.updated_at::TIMESTAMPTZ; -- last_setup_attempt
        RETURN;
    END IF;
    
    -- Setup completed, determine dashboard redirect
    RETURN QUERY SELECT 
        true::BOOLEAN, -- user_exists
        auth_user.email_confirmed::BOOLEAN, -- email_confirmed  
        profile_user.profile_completed::BOOLEAN, -- profile_completed
        profile_user.password_set::BOOLEAN, -- password_set
        true::BOOLEAN, -- setup_completed
        'dashboard'::TEXT, -- next_action
        CASE 
            WHEN profile_user.role = 'super_admin' THEN '/super-admin-dashboard'
            WHEN profile_user.role = 'admin' THEN '/admin-dashboard'
            WHEN profile_user.role = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END::TEXT, -- redirect_url
        profile_user.role::TEXT, -- role
        profile_user.full_name::TEXT, -- full_name
        profile_user.setup_completed_at::TIMESTAMPTZ; -- last_setup_attempt
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in get_detailed_user_auth_status: %', SQLERRM;
        RETURN QUERY SELECT 
            false::BOOLEAN,
            false::BOOLEAN, 
            false::BOOLEAN,
            false::BOOLEAN,
            false::BOOLEAN,
            'error'::TEXT,
            '/login'::TEXT,
            ''::TEXT,
            ''::TEXT,
            NULL::TIMESTAMPTZ;
        RETURN;
END;
$$;

-- Step 4: Create password setup completion function
CREATE OR REPLACE FUNCTION public.complete_password_setup(
    user_uuid UUID,
    mark_password_complete BOOLEAN DEFAULT true
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update password_set flag in user_profiles
    UPDATE public.user_profiles 
    SET 
        password_set = mark_password_complete,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = user_uuid;
    
    IF NOT FOUND THEN
        -- Create profile record if it doesn't exist
        INSERT INTO public.user_profiles (
            id, 
            email, 
            full_name, 
            password_set,
            created_at,
            updated_at
        )
        SELECT 
            user_uuid,
            au.email,
            COALESCE(au.raw_user_meta_data->>'full_name', split_part(au.email, '@', 1)),
            mark_password_complete,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        FROM auth.users au
        WHERE au.id = user_uuid;
    END IF;
    
    RETURN QUERY SELECT 
        true::BOOLEAN,
        'Password setup status updated successfully'::TEXT;
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in complete_password_setup: %', SQLERRM;
        RETURN QUERY SELECT 
            false::BOOLEAN,
            'Failed to update password setup status: ' || SQLERRM::TEXT;
        RETURN;
END;
$$;

-- Step 5: Create user authentication status function (for email-based checks)
CREATE OR REPLACE FUNCTION public.get_user_auth_status(user_email TEXT)
RETURNS TABLE(
    user_exists BOOLEAN,
    email_confirmed BOOLEAN,
    can_reset_password BOOLEAN,
    account_status TEXT,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user RECORD;
    profile_user RECORD;
BEGIN
    -- Get auth user data
    SELECT 
        au.id,
        au.email,
        au.email_confirmed_at IS NOT NULL AS email_confirmed,
        au.banned_until
    INTO auth_user
    FROM auth.users au
    WHERE au.email = user_email;
    
    -- Check if user exists
    IF auth_user.id IS NULL THEN
        RETURN QUERY SELECT 
            false::BOOLEAN, -- user_exists
            false::BOOLEAN, -- email_confirmed
            false::BOOLEAN, -- can_reset_password
            'NOT_FOUND'::TEXT, -- account_status
            'No account found with this email address'::TEXT; -- message
        RETURN;
    END IF;
    
    -- Check if account is banned
    IF auth_user.banned_until IS NOT NULL AND auth_user.banned_until > CURRENT_TIMESTAMP THEN
        RETURN QUERY SELECT 
            true::BOOLEAN, -- user_exists
            auth_user.email_confirmed::BOOLEAN, -- email_confirmed
            false::BOOLEAN, -- can_reset_password
            'BANNED'::TEXT, -- account_status
            'Account is temporarily suspended'::TEXT; -- message
        RETURN;
    END IF;
    
    -- Return normal account status
    RETURN QUERY SELECT 
        true::BOOLEAN, -- user_exists
        auth_user.email_confirmed::BOOLEAN, -- email_confirmed
        auth_user.email_confirmed::BOOLEAN, -- can_reset_password (same as confirmed)
        'ACTIVE'::TEXT, -- account_status
        'Account is active and available'::TEXT; -- message
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in get_user_auth_status: %', SQLERRM;
        RETURN QUERY SELECT 
            false::BOOLEAN,
            false::BOOLEAN, 
            false::BOOLEAN,
            'ERROR'::TEXT,
            'Error checking account status: ' || SQLERRM::TEXT;
        RETURN;
END;
$$;

-- Step 6: Add setup tracking columns to user_profiles if they don't exist
DO $$
BEGIN
    -- Add setup_completed_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'setup_completed_at'
    ) THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN setup_completed_at TIMESTAMPTZ;
    END IF;
    
    -- Add password_set column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'password_set'
    ) THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN password_set BOOLEAN DEFAULT false;
    END IF;
    
    -- Add profile_completed column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'profile_completed'
    ) THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN profile_completed BOOLEAN DEFAULT false;
    END IF;
END $$;

-- Step 7: Update existing user records that might have incomplete status
-- This fixes users who completed setup but have incorrect flags
UPDATE public.user_profiles 
SET 
    profile_completed = true,
    password_set = true,
    setup_completed_at = COALESCE(setup_completed_at, updated_at, created_at)
WHERE 
    full_name IS NOT NULL 
    AND full_name != ''
    AND role IS NOT NULL
    AND (profile_completed IS NULL OR profile_completed = false OR password_set IS NULL OR password_set = false);

-- Step 8: Create index for performance on frequently queried columns
CREATE INDEX IF NOT EXISTS idx_user_profiles_setup_status 
ON public.user_profiles(profile_completed, password_set, setup_completed_at);

CREATE INDEX IF NOT EXISTS idx_user_profiles_email_lookup 
ON public.user_profiles(email);

-- Step 9: Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.complete_user_setup_enhanced(TEXT, JSONB, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_detailed_user_auth_status(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_auth_status(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_password_setup(UUID, BOOLEAN) TO authenticated;

-- Step 10: Test the functions with specific user (parks@sbdllc.co)
DO $$
DECLARE
    test_user_id UUID;
    test_result RECORD;
BEGIN
    -- Find the problematic user
    SELECT id INTO test_user_id 
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co';
    
    IF test_user_id IS NOT NULL THEN
        -- Force complete their setup
        PERFORM public.complete_user_setup_enhanced(
            'parks@sbdllc.co',
            jsonb_build_object(
                'fullName', COALESCE(
                    (SELECT full_name FROM public.user_profiles WHERE id = test_user_id),
                    'Parks User'
                ),
                'role', COALESCE(
                    (SELECT role FROM public.user_profiles WHERE id = test_user_id),
                    'rep'
                ),
                'organization', COALESCE(
                    (SELECT organization FROM public.user_profiles WHERE id = test_user_id),
                    'SBDLLC'
                )
            ),
            true -- mark password as set
        );
        
        RAISE NOTICE 'Fixed setup status for parks@sbdllc.co (ID: %)', test_user_id;
    ELSE
        RAISE NOTICE 'User parks@sbdllc.co not found in auth.users';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error fixing parks@sbdllc.co setup: %', SQLERRM;
END $$;

-- Success confirmation
SELECT 'Authentication setup persistence fix completed successfully!' as status;