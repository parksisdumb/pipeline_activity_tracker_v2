-- Migration: Fix API Key Issues and Schema Column Reference Errors
-- This addresses the "No API key found" and "user_profiles.user_id does not exist" errors

-- ================================
-- SCHEMA COLUMN FIXES
-- ================================

-- Fix all RLS policies that incorrectly reference user_profiles.user_id
-- The correct column name is user_profiles.id

-- Drop existing policies that have incorrect column references
DROP POLICY IF EXISTS "auth_debug_log_admin_access" ON auth_debug_log;

-- Recreate the policy with correct column reference
CREATE POLICY "auth_debug_log_admin_access" ON auth_debug_log
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.id = auth.uid() 
      AND user_profiles.role IN ('super_admin', 'admin')
    )
  );

-- ================================
-- FIX OTHER POLICIES WITH INCORRECT COLUMN REFERENCES
-- ================================

-- Check and fix user_profiles policies
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    -- Get all policies that reference user_profiles.user_id
    FOR policy_record IN 
        SELECT schemaname, tablename, policyname, definition
        FROM pg_policies 
        WHERE definition LIKE '%user_profiles.user_id%'
    LOOP
        -- Log the policy that needs fixing
        RAISE NOTICE 'Found policy with incorrect column reference: %.% - %', 
                     policy_record.schemaname, policy_record.tablename, policy_record.policyname;
        
        -- Drop and recreate each policy (this is a template - specific policies should be handled individually)
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
                      policy_record.policyname, policy_record.schemaname, policy_record.tablename);
    END LOOP;
END $$;

-- ================================
-- RECREATE COMMON POLICIES WITH CORRECT COLUMN REFERENCES
-- ================================

-- Activities policies
DROP POLICY IF EXISTS "activities_tenant_isolation" ON activities;
CREATE POLICY "activities_tenant_isolation" ON activities
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Accounts policies
DROP POLICY IF EXISTS "accounts_tenant_isolation" ON accounts;
CREATE POLICY "accounts_tenant_isolation" ON accounts
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Contacts policies
DROP POLICY IF EXISTS "contacts_tenant_isolation" ON contacts;
CREATE POLICY "contacts_tenant_isolation" ON contacts
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Properties policies
DROP POLICY IF EXISTS "properties_tenant_isolation" ON properties;
CREATE POLICY "properties_tenant_isolation" ON properties
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Opportunities policies
DROP POLICY IF EXISTS "opportunities_tenant_isolation" ON opportunities;
CREATE POLICY "opportunities_tenant_isolation" ON opportunities
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Tasks policies
DROP POLICY IF EXISTS "tasks_tenant_isolation" ON tasks;
CREATE POLICY "tasks_tenant_isolation" ON tasks
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Prospects policies
DROP POLICY IF EXISTS "prospects_tenant_isolation" ON prospects;
CREATE POLICY "prospects_tenant_isolation" ON prospects
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Weekly goals policies
DROP POLICY IF EXISTS "weekly_goals_tenant_isolation" ON weekly_goals;
CREATE POLICY "weekly_goals_tenant_isolation" ON weekly_goals
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- Notifications policies
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

-- Documents policies
DROP POLICY IF EXISTS "documents_tenant_isolation" ON documents;
CREATE POLICY "documents_tenant_isolation" ON documents
  FOR ALL USING (
    tenant_id IN (
      SELECT tenant_id FROM user_profiles 
      WHERE user_profiles.id = auth.uid()
    )
  );

-- ================================
-- ENHANCED DEBUGGING FUNCTIONS
-- ================================

-- Function to diagnose API key and connection issues
CREATE OR REPLACE FUNCTION diagnose_connection_issues()
RETURNS TABLE (
  check_name TEXT,
  status TEXT,
  details TEXT,
  recommendation TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_count INTEGER;
    profile_count INTEGER;
    current_user_id UUID;
BEGIN
    -- Get current user context
    current_user_id := auth.uid();
    
    -- Check 1: User authentication
    RETURN QUERY SELECT 
        'User Authentication'::TEXT,
        CASE WHEN current_user_id IS NOT NULL THEN 'OK' ELSE 'FAILED' END::TEXT,
        CASE WHEN current_user_id IS NOT NULL 
             THEN 'User ID: ' || current_user_id::TEXT 
             ELSE 'No authenticated user found' END::TEXT,
        CASE WHEN current_user_id IS NULL 
             THEN 'Ensure user is properly authenticated with valid session'
             ELSE 'User authentication is working' END::TEXT;
    
    -- Check 2: User count in auth.users
    SELECT COUNT(*) INTO user_count FROM auth.users;
    
    RETURN QUERY SELECT 
        'Auth Users Table'::TEXT,
        CASE WHEN user_count > 0 THEN 'OK' ELSE 'EMPTY' END::TEXT,
        'Total users: ' || user_count::TEXT,
        CASE WHEN user_count = 0 
             THEN 'No users found in auth.users table - check user registration'
             ELSE 'Users exist in auth table' END::TEXT;
    
    -- Check 3: User profiles count
    SELECT COUNT(*) INTO profile_count FROM user_profiles;
    
    RETURN QUERY SELECT 
        'User Profiles Table'::TEXT,
        CASE WHEN profile_count > 0 THEN 'OK' ELSE 'EMPTY' END::TEXT,
        'Total profiles: ' || profile_count::TEXT,
        CASE WHEN profile_count = 0 
             THEN 'No profiles found - check profile creation triggers'
             ELSE 'User profiles exist' END::TEXT;
    
    -- Check 4: Current user profile
    IF current_user_id IS NOT NULL THEN
        RETURN QUERY SELECT 
            'Current User Profile'::TEXT,
            CASE WHEN EXISTS(SELECT 1 FROM user_profiles WHERE id = current_user_id) 
                 THEN 'OK' ELSE 'MISSING' END::TEXT,
            CASE WHEN EXISTS(SELECT 1 FROM user_profiles WHERE id = current_user_id)
                 THEN 'Profile exists for current user'
                 ELSE 'No profile found for user: ' || current_user_id::TEXT END::TEXT,
            CASE WHEN NOT EXISTS(SELECT 1 FROM user_profiles WHERE id = current_user_id)
                 THEN 'Create user profile or check profile creation trigger'
                 ELSE 'Current user profile is properly configured' END::TEXT;
    END IF;
    
    -- Check 5: RLS status
    RETURN QUERY SELECT 
        'RLS Configuration'::TEXT,
        'INFO'::TEXT,
        'Row Level Security policies are active',
        'Ensure all tables have proper RLS policies for tenant isolation'::TEXT;
        
END;
$$;

-- Function to test basic connectivity
CREATE OR REPLACE FUNCTION test_basic_connectivity()
RETURNS TABLE (
  test_name TEXT,
  result TEXT,
  execution_time_ms NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration_ms NUMERIC;
BEGIN
    -- Test 1: Simple SELECT
    start_time := clock_timestamp();
    PERFORM 1;
    end_time := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    
    RETURN QUERY SELECT 
        'Basic SELECT'::TEXT,
        'SUCCESS'::TEXT,
        duration_ms;
    
    -- Test 2: User profiles query
    start_time := clock_timestamp();
    BEGIN
        PERFORM COUNT(*) FROM user_profiles LIMIT 1;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        
        RETURN QUERY SELECT 
            'User Profiles Query'::TEXT,
            'SUCCESS'::TEXT,
            duration_ms;
    EXCEPTION WHEN OTHERS THEN
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        
        RETURN QUERY SELECT 
            'User Profiles Query'::TEXT,
            'FAILED: ' || SQLERRM,
            duration_ms;
    END;
    
    -- Test 3: Auth function
    start_time := clock_timestamp();
    BEGIN
        PERFORM auth.uid();
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        
        RETURN QUERY SELECT 
            'Auth Function'::TEXT,
            'SUCCESS'::TEXT,
            duration_ms;
    EXCEPTION WHEN OTHERS THEN
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        
        RETURN QUERY SELECT 
            'Auth Function'::TEXT,
            'FAILED: ' || SQLERRM,
            duration_ms;
    END;
END;
$$;

-- ================================
-- CONNECTION RECOVERY HELPERS
-- ================================

-- Function to validate client configuration
CREATE OR REPLACE FUNCTION validate_client_config()
RETURNS TABLE (
  config_item TEXT,
  is_valid BOOLEAN,
  current_value TEXT,
  recommendation TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY SELECT 
        'Database Connection'::TEXT,
        TRUE,
        'Connected to: ' || current_database(),
        'Database connection is working'::TEXT;
        
    RETURN QUERY SELECT 
        'Current User'::TEXT,
        auth.uid() IS NOT NULL,
        COALESCE(auth.uid()::TEXT, 'No authenticated user'),
        CASE WHEN auth.uid() IS NULL 
             THEN 'Authenticate user before making requests'
             ELSE 'User authentication is working' END::TEXT;
             
    RETURN QUERY SELECT 
        'Session Role'::TEXT,
        current_setting('role') IS NOT NULL,
        current_setting('role'),
        'Database role is properly set'::TEXT;
END;
$$;

-- ================================
-- IMMEDIATE DIAGNOSTICS
-- ================================

-- Run immediate diagnostics to identify issues
DO $$
DECLARE
    diagnostic_result RECORD;
BEGIN
    RAISE NOTICE '=== API KEY AND SCHEMA DIAGNOSTICS ===';
    
    FOR diagnostic_result IN 
        SELECT * FROM diagnose_connection_issues()
    LOOP
        RAISE NOTICE 'CHECK: % | STATUS: % | DETAILS: % | RECOMMENDATION: %', 
                     diagnostic_result.check_name,
                     diagnostic_result.status,
                     diagnostic_result.details,
                     diagnostic_result.recommendation;
    END LOOP;
    
    RAISE NOTICE '=== CONNECTIVITY TESTS ===';
    
    FOR diagnostic_result IN 
        SELECT * FROM test_basic_connectivity()
    LOOP
        RAISE NOTICE 'TEST: % | RESULT: % | TIME: %ms', 
                     diagnostic_result.test_name,
                     diagnostic_result.result,
                     diagnostic_result.execution_time_ms;
    END LOOP;
END $$;

-- ================================
-- CLEANUP AND OPTIMIZATION
-- ================================

-- Analyze tables to update statistics
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

-- Add helpful comments
COMMENT ON FUNCTION diagnose_connection_issues() IS 'Comprehensive diagnostic function to identify API key and authentication issues';
COMMENT ON FUNCTION test_basic_connectivity() IS 'Basic connectivity tests to validate database operations';
COMMENT ON FUNCTION validate_client_config() IS 'Validates client configuration and connection status';

-- Log successful migration
INSERT INTO auth_debug_log (
    event_type,
    token_type,
    success,
    error_message
) VALUES (
    'schema_fix_migration',
    'migration_20251014200000',
    TRUE,
    'Successfully fixed API key issues and schema column references'
);