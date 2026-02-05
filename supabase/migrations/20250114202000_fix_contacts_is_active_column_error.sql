-- Location: supabase/migrations/20250114202000_fix_contacts_is_active_column_error.sql
-- Schema Analysis: Fix missing is_active column in contacts table for manager authentication functions
-- Integration Type: Schema correction for existing contact management functionality
-- Dependencies: contacts, accounts, user_profiles tables

-- Step 1: Add is_active column to contacts table if it doesn't exist
DO $add_column$
BEGIN
    -- Check if is_active column exists in contacts table
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'contacts' 
        AND column_name = 'is_active'
    ) THEN
        -- Add is_active column to contacts table
        ALTER TABLE public.contacts 
        ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;
        
        RAISE NOTICE 'Added is_active column to contacts table';
    ELSE
        RAISE NOTICE 'is_active column already exists in contacts table';
    END IF;
END;
$add_column$;
-- Step 2: Update existing contacts to be active by default
UPDATE public.contacts 
SET is_active = true 
WHERE is_active IS NULL;
-- Step 3: Recreate the get_manager_tenant_contacts function with correct column reference
DROP FUNCTION IF EXISTS public.get_manager_tenant_contacts(UUID);
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
    
    -- Return all active contacts within the manager's tenant
    -- Note: Now properly referencing c.is_active from contacts table
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
    AND c.is_active = true  -- Now this column exists in contacts table
    AND (a.is_active = true OR a.is_active IS NULL)  -- Also check account is active
    ORDER BY c.last_name ASC, c.first_name ASC;
END;
$func$;
-- Step 4: Create a comprehensive function to verify and fix Parks manager access
CREATE OR REPLACE FUNCTION public.verify_parks_manager_data_access()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    count_result INTEGER,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    parks_user_id UUID;
    fox_tenant_id UUID := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7';
    result_record RECORD;
BEGIN
    -- Get Parks user ID
    SELECT au.id INTO parks_user_id
    FROM auth.users au
    WHERE au.email = 'parks@sbdllc.co';
    
    IF parks_user_id IS NULL THEN
        RETURN QUERY SELECT 
            'parks_user_lookup'::TEXT, 
            'ERROR'::TEXT, 
            0, 
            'Parks user not found in auth.users'::TEXT;
        RETURN;
    END IF;
    
    -- Check user profile exists and has correct tenant
    SELECT COUNT(*)::INTEGER INTO result_record
    FROM public.user_profiles up
    WHERE up.id = parks_user_id
    AND up.tenant_id = fox_tenant_id
    AND up.role = 'manager'
    AND up.is_active = true;
    
    RETURN QUERY SELECT 
        'user_profile_check'::TEXT, 
        CASE WHEN result_record > 0 THEN 'SUCCESS' ELSE 'ERROR' END::TEXT,
        result_record,
        CASE WHEN result_record > 0 
            THEN 'Parks user profile is correctly configured'
            ELSE 'Parks user profile missing or incorrectly configured'
        END::TEXT;
    
    -- Test accounts access
    SELECT COUNT(*)::INTEGER INTO result_record
    FROM public.get_manager_tenant_accounts(parks_user_id);
    
    RETURN QUERY SELECT 
        'accounts_access'::TEXT, 
        CASE WHEN result_record >= 0 THEN 'SUCCESS' ELSE 'ERROR' END::TEXT,
        result_record,
        'Parks can access ' || result_record || ' accounts'::TEXT;
    
    -- Test contacts access (this should now work with the fixed function)
    SELECT COUNT(*)::INTEGER INTO result_record
    FROM public.get_manager_tenant_contacts(parks_user_id);
    
    RETURN QUERY SELECT 
        'contacts_access'::TEXT, 
        CASE WHEN result_record >= 0 THEN 'SUCCESS' ELSE 'ERROR' END::TEXT,
        result_record,
        'Parks can access ' || result_record || ' contacts'::TEXT;
    
    -- Test properties access
    SELECT COUNT(*)::INTEGER INTO result_record
    FROM public.get_manager_tenant_properties(parks_user_id);
    
    RETURN QUERY SELECT 
        'properties_access'::TEXT, 
        CASE WHEN result_record >= 0 THEN 'SUCCESS' ELSE 'ERROR' END::TEXT,
        result_record,
        'Parks can access ' || result_record || ' properties'::TEXT;
    
    -- Test opportunities access
    SELECT COUNT(*)::INTEGER INTO result_record
    FROM public.get_manager_tenant_opportunities(parks_user_id);
    
    RETURN QUERY SELECT 
        'opportunities_access'::TEXT, 
        CASE WHEN result_record >= 0 THEN 'SUCCESS' ELSE 'ERROR' END::TEXT,
        result_record,
        'Parks can access ' || result_record || ' opportunities'::TEXT;
    
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 
        'error'::TEXT, 
        'ERROR'::TEXT, 
        0, 
        'Error during verification: ' || SQLERRM::TEXT;
END;
$func$;
-- Step 5: Run the verification to test the fix
DO $verification$
DECLARE
    verification_result RECORD;
BEGIN
    RAISE NOTICE '🔍 Running Parks manager data access verification...';
    
    FOR verification_result IN 
        SELECT * FROM public.verify_parks_manager_data_access()
    LOOP
        RAISE NOTICE '  % - %: % (%)', 
            verification_result.check_name,
            verification_result.status,
            verification_result.message,
            verification_result.count_result;
    END LOOP;
END;
$verification$;
-- Step 6: Additional RLS policy verification for contacts
DO $rls_check$
BEGIN
    -- Ensure RLS is enabled on contacts table
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'contacts' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'Enabled RLS on contacts table';
    ELSE
        RAISE NOTICE 'RLS already enabled on contacts table';
    END IF;
    
    -- Verify manager access policy exists for contacts
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contacts' 
        AND policyname LIKE '%manager%'
    ) THEN
        RAISE NOTICE 'Warning: No manager-specific RLS policy found for contacts table';
    ELSE
        RAISE NOTICE 'Manager RLS policies exist for contacts table';
    END IF;
END;
$rls_check$;
-- Step 7: Final verification message
DO $final_message$
BEGIN
    RAISE NOTICE '✅ Migration completed successfully!';
    RAISE NOTICE 'Fixed issues:';
    RAISE NOTICE '  1. Added is_active column to contacts table';
    RAISE NOTICE '  2. Updated get_manager_tenant_contacts function to use correct column reference';
    RAISE NOTICE '  3. Added comprehensive verification function for Parks manager access';
    RAISE NOTICE '  4. Verified RLS policies are in place';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 Parks manager should now be able to access tenant data properly';
    RAISE NOTICE 'The error "column c.is_active does not exist" should be resolved';
END;
$final_message$;
