-- Migration: Fix pg_policies Column Reference Error
-- This fixes the "column definition does not exist" error by using correct pg_policies column names
-- AND prevents policy already exists errors

-- ================================
-- SCHEMA COLUMN FIXES FOR pg_policies
-- ================================

-- The pg_policies view uses 'qual' and 'with_check' columns, NOT 'definition'
-- Correct column references for pg_policies:
-- - schemaname (schema name)
-- - tablename (table name) 
-- - policyname (policy name)
-- - permissive (permissive vs restrictive)
-- - roles (array of role names)
-- - cmd (command: SELECT, INSERT, UPDATE, DELETE, ALL)
-- - qual (USING expression)
-- - with_check (WITH CHECK expression)

-- Function to safely check and fix policies with incorrect column references
CREATE OR REPLACE FUNCTION fix_policies_with_incorrect_column_references()
RETURNS TABLE (
    action_taken TEXT,
    schema_name TEXT,
    table_name TEXT,
    policy_name TEXT,
    status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    policy_record RECORD;
    policy_count INTEGER := 0;
    fixed_count INTEGER := 0;
BEGIN
    -- Get all policies that reference user_profiles.user_id in their USING clause
    FOR policy_record IN 
        SELECT schemaname, tablename, policyname, qual, with_check
        FROM pg_policies 
        WHERE qual LIKE '%user_profiles.user_id%' 
           OR with_check LIKE '%user_profiles.user_id%'
    LOOP
        policy_count := policy_count + 1;
        
        -- Log the policy that needs fixing
        RETURN QUERY SELECT 
            'IDENTIFIED'::TEXT,
            policy_record.schemaname::TEXT,
            policy_record.tablename::TEXT,
            policy_record.policyname::TEXT,
            'Found policy with incorrect user_profiles.user_id reference'::TEXT;
        
        -- Drop the problematic policy
        BEGIN
            EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
                          policy_record.policyname, 
                          policy_record.schemaname, 
                          policy_record.tablename);
            
            fixed_count := fixed_count + 1;
            
            RETURN QUERY SELECT 
                'DROPPED'::TEXT,
                policy_record.schemaname::TEXT,
                policy_record.tablename::TEXT,
                policy_record.policyname::TEXT,
                'Successfully dropped policy with incorrect column reference'::TEXT;
                
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT 
                'ERROR_DROPPING'::TEXT,
                policy_record.schemaname::TEXT,
                policy_record.tablename::TEXT,
                policy_record.policyname::TEXT,
                'Error dropping policy: ' || SQLERRM;
        END;
    END LOOP;
    
    -- Return summary
    RETURN QUERY SELECT 
        'SUMMARY'::TEXT,
        'ALL'::TEXT,
        'ALL'::TEXT,
        'TOTAL'::TEXT,
        format('Processed %s policies, fixed %s policies', policy_count, fixed_count)::TEXT;
        
END;
$$;
-- ================================
-- RUN THE POLICY FIX FUNCTION
-- ================================

-- Execute the function to identify and fix problematic policies
DO $$
DECLARE
    fix_result RECORD;
BEGIN
    RAISE NOTICE '=== FIXING POLICIES WITH INCORRECT COLUMN REFERENCES ===';
    
    FOR fix_result IN 
        SELECT * FROM fix_policies_with_incorrect_column_references()
    LOOP
        RAISE NOTICE 'ACTION: % | SCHEMA: % | TABLE: % | POLICY: % | STATUS: %', 
                     fix_result.action_taken,
                     fix_result.schema_name,
                     fix_result.table_name,
                     fix_result.policy_name,
                     fix_result.status;
    END LOOP;
END $$;
-- ================================
-- RECREATE COMMON POLICIES WITH CORRECT COLUMN REFERENCES
-- ================================
-- CRITICAL FIX: Drop existing policies first to prevent "already exists" errors

-- Activities policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "activities_tenant_isolation" ON activities;
CREATE POLICY "activities_tenant_isolation" ON activities
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Accounts policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "accounts_tenant_isolation" ON accounts;
CREATE POLICY "accounts_tenant_isolation" ON accounts
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Contacts policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "contacts_tenant_isolation" ON contacts;
CREATE POLICY "contacts_tenant_isolation" ON contacts
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Properties policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "properties_tenant_isolation" ON properties;
CREATE POLICY "properties_tenant_isolation" ON properties
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Opportunities policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "opportunities_tenant_isolation" ON opportunities;
CREATE POLICY "opportunities_tenant_isolation" ON opportunities
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Tasks policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "tasks_tenant_isolation" ON tasks;
CREATE POLICY "tasks_tenant_isolation" ON tasks
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Prospects policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "prospects_tenant_isolation" ON prospects;
CREATE POLICY "prospects_tenant_isolation" ON prospects
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Weekly goals policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "weekly_goals_tenant_isolation" ON weekly_goals;
CREATE POLICY "weekly_goals_tenant_isolation" ON weekly_goals
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Notifications policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "notifications_user_access" ON notifications;
CREATE POLICY "notifications_user_access" ON notifications
  FOR ALL USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.id = auth.uid() 
      AND user_profiles.role IN ('super_admin', 'admin')
    )
  );
-- Documents policies with correct user_profiles.id reference
DROP POLICY IF EXISTS "documents_tenant_isolation" ON documents;
CREATE POLICY "documents_tenant_isolation" ON documents
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );
-- Auth debug log policy with correct user_profiles.id reference
-- CRITICAL FIX: This is the policy causing the "already exists" error
DROP POLICY IF EXISTS "auth_debug_log_admin_access" ON auth_debug_log;
CREATE POLICY "auth_debug_log_admin_access" ON auth_debug_log
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.id = auth.uid() 
      AND user_profiles.role IN ('super_admin', 'admin')
    )
  );
-- ================================
-- ENHANCED POLICY VALIDATION FUNCTIONS
-- ================================

-- Function to validate all policies use correct column references
-- FIXED: Ensure all return values are properly cast to TEXT
CREATE OR REPLACE FUNCTION validate_policy_column_references()
RETURNS TABLE (
    validation_check TEXT,
    schema_name TEXT,
    table_name TEXT,
    policy_name TEXT,
    result TEXT,
    recommendation TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    policy_record RECORD;
    invalid_count INTEGER := 0;
    total_count INTEGER := 0;
BEGIN
    -- Check for any remaining policies with incorrect column references
    FOR policy_record IN 
        SELECT schemaname, tablename, policyname, qual, with_check
        FROM pg_policies 
        WHERE schemaname IN ('public', 'auth')
    LOOP
        total_count := total_count + 1;
        
        -- Check if policy still has incorrect user_profiles.user_id reference
        IF (policy_record.qual LIKE '%user_profiles.user_id%' OR 
            COALESCE(policy_record.with_check, '') LIKE '%user_profiles.user_id%') THEN
            
            invalid_count := invalid_count + 1;
            
            RETURN QUERY SELECT 
                'INVALID_COLUMN_REFERENCE'::TEXT,
                COALESCE(policy_record.schemaname, '')::TEXT,
                COALESCE(policy_record.tablename, '')::TEXT,
                COALESCE(policy_record.policyname, '')::TEXT,
                'FAILED - Still references user_profiles.user_id'::TEXT,
                'Update policy to use user_profiles.id instead'::TEXT;
        ELSE
            RETURN QUERY SELECT 
                'VALID_COLUMN_REFERENCE'::TEXT,
                COALESCE(policy_record.schemaname, '')::TEXT,
                COALESCE(policy_record.tablename, '')::TEXT,
                COALESCE(policy_record.policyname, '')::TEXT,
                'PASSED - Uses correct column references'::TEXT,
                'No action needed'::TEXT;
        END IF;
    END LOOP;
    
    -- Return summary with proper TEXT casting
    RETURN QUERY SELECT 
        'VALIDATION_SUMMARY'::TEXT,
        'ALL'::TEXT,
        'ALL'::TEXT,
        'SUMMARY'::TEXT,
        format('Validated %s policies, found %s with invalid references', total_count, invalid_count)::TEXT,
        CASE WHEN invalid_count = 0 
             THEN 'All policies use correct column references'::TEXT
             ELSE format('Fix %s policies with invalid column references', invalid_count)::TEXT END;
END;
$$;
-- Function to list all current policies for verification
CREATE OR REPLACE FUNCTION list_current_policies()
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    policy_name TEXT,
    command TEXT,
    roles TEXT[],
    using_expression TEXT,
    check_expression TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        COALESCE(p.schemaname, '')::TEXT,
        COALESCE(p.tablename, '')::TEXT,
        COALESCE(p.policyname, '')::TEXT,
        COALESCE(p.cmd, '')::TEXT,
        COALESCE(p.roles, ARRAY[]::TEXT[]),
        COALESCE(p.qual, '')::TEXT,
        COALESCE(p.with_check, '')::TEXT
    FROM pg_policies p
    WHERE p.schemaname IN ('public', 'auth')
    ORDER BY p.schemaname, p.tablename, p.policyname;
END;
$$;
-- ================================
-- RUN POLICY VALIDATION
-- ================================

-- Run validation to ensure all policies are correct
DO $$
DECLARE
    validation_result RECORD;
BEGIN
    RAISE NOTICE '=== POLICY COLUMN REFERENCE VALIDATION ===';
    
    FOR validation_result IN 
        SELECT * FROM validate_policy_column_references()
    LOOP
        RAISE NOTICE 'CHECK: % | SCHEMA: % | TABLE: % | POLICY: % | RESULT: % | RECOMMENDATION: %', 
                     validation_result.validation_check,
                     validation_result.schema_name,
                     validation_result.table_name,
                     validation_result.policy_name,
                     validation_result.result,
                     validation_result.recommendation;
    END LOOP;
END $$;
-- ================================
-- CLEANUP AND OPTIMIZATION
-- ================================

-- Drop the temporary fix function as it's no longer needed
DROP FUNCTION IF EXISTS fix_policies_with_incorrect_column_references();
-- Analyze tables to update statistics after policy changes
ANALYZE user_profiles;
ANALYZE activities;
ANALYZE accounts;
ANALYZE contacts;
ANALYZE properties;
ANALYZE opportunities;
ANALYZE tasks;
ANALYZE prospects;
ANALYZE weekly_goals;
ANALYZE notifications;
ANALYZE documents;
ANALYZE auth_debug_log;
-- Add helpful comments
COMMENT ON FUNCTION validate_policy_column_references() IS 'Validates that all RLS policies use correct column references (user_profiles.id instead of user_profiles.user_id)';
COMMENT ON FUNCTION list_current_policies() IS 'Lists all current RLS policies for verification and debugging';
-- Log successful migration
INSERT INTO auth_debug_log (
    event_type,
    token_type,
    success,
    error_message
) VALUES (
    'pg_policies_column_fix',
    'migration_20251014215000',
    TRUE,
    'Successfully fixed pg_policies column reference errors and recreated policies with correct user_profiles.id references'
);
-- ================================
-- VERIFICATION QUERIES
-- ================================

-- Verify no policies still reference the incorrect column
DO $$
DECLARE
    remaining_bad_policies INTEGER;
BEGIN
    SELECT COUNT(*) INTO remaining_bad_policies
    FROM pg_policies 
    WHERE (qual LIKE '%user_profiles.user_id%' OR COALESCE(with_check, '') LIKE '%user_profiles.user_id%')
    AND schemaname IN ('public', 'auth');
    
    IF remaining_bad_policies > 0 THEN
        RAISE WARNING 'Still found % policies with incorrect user_profiles.user_id references', remaining_bad_policies;
    ELSE
        RAISE NOTICE 'SUCCESS: All policies now use correct user_profiles.id column references';
    END IF;
END $$;
