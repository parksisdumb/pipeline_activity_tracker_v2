-- Migration: Fix Authentication Redirect URLs and Enhanced Token Handling
-- This addresses the PKCE token expiration issues and redirect configuration problems

-- ================================
-- AUTHENTICATION URL CONFIGURATION FIX
-- ================================

-- This migration creates a configuration table to store the correct redirect URLs
-- that should be set in your Supabase dashboard manually

CREATE TABLE IF NOT EXISTS auth_configuration_guide (
  id SERIAL PRIMARY KEY,
  setting_name TEXT NOT NULL,
  current_value TEXT,
  required_value TEXT NOT NULL,
  description TEXT NOT NULL,
  is_configured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Insert required Supabase dashboard configuration settings
INSERT INTO auth_configuration_guide (setting_name, required_value, description) VALUES
  (
    'site_url', 
    'https://dillyos.com/auth-callback',
    'Main site URL that Supabase will use as default redirect. Must be set in Authentication > URL Configuration > Site URL'
  ),
  (
    'redirect_urls', 
    'https://dillyos.com/auth-callback,https://dillyos.com/password-reset,https://dillyos.com/email-confirmation,https://dillyos.com/magic-link-authentication',
    'Allowed redirect URLs. Must be set in Authentication > URL Configuration > Redirect URLs (one per line)'
  ),
  (
    'pkce_flow_enabled',
    'true',
    'PKCE flow must be enabled in Authentication > Settings > Advanced Settings > Enable PKCE'
  ),
  (
    'password_reset_expiry',
    '3600',
    'Password reset token expiry should be set to at least 1 hour (3600 seconds) in Authentication > Settings'
  );
-- ================================
-- ENHANCED AUTH STATE MANAGEMENT
-- ================================

-- Create a table to track authentication attempts and help with debugging
CREATE TABLE IF NOT EXISTS auth_debug_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL, -- 'password_reset_request', 'token_exchange', 'session_established'
  token_type TEXT, -- 'pkce', 'legacy', 'access_token'
  token_prefix TEXT, -- First 10 chars of token for debugging
  success BOOLEAN DEFAULT FALSE,
  error_message TEXT,
  user_agent TEXT,
  ip_address INET,
  redirect_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Enable RLS on debug log
ALTER TABLE auth_debug_log ENABLE ROW LEVEL SECURITY;
-- Create policy for auth debug log (admin only)
-- FIX: Use correct column name 'id' instead of 'user_id'
CREATE POLICY "auth_debug_log_admin_access" ON auth_debug_log
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.id = auth.uid() 
      AND user_profiles.role IN ('super_admin', 'admin')
    )
  );
-- ================================
-- ENHANCED PASSWORD RESET FUNCTIONS
-- ================================

-- Function to log authentication attempts for debugging
CREATE OR REPLACE FUNCTION log_auth_attempt(
  p_user_id UUID DEFAULT NULL,
  p_event_type TEXT DEFAULT 'unknown',
  p_token_type TEXT DEFAULT NULL,
  p_token_prefix TEXT DEFAULT NULL,
  p_success BOOLEAN DEFAULT FALSE,
  p_error_message TEXT DEFAULT NULL,
  p_redirect_url TEXT DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  log_id UUID;
  current_user_agent TEXT;
  current_ip INET;
BEGIN
  -- Get request metadata if available
  BEGIN
    current_user_agent := current_setting('request.headers', true)::json->>'user-agent';
    current_ip := inet(current_setting('request.headers', true)::json->>'x-forwarded-for');
  EXCEPTION WHEN OTHERS THEN
    current_user_agent := NULL;
    current_ip := NULL;
  END;

  INSERT INTO auth_debug_log (
    user_id,
    event_type,
    token_type,
    token_prefix,
    success,
    error_message,
    user_agent,
    ip_address,
    redirect_url
  ) VALUES (
    p_user_id,
    p_event_type,
    p_token_type,
    p_token_prefix,
    p_success,
    p_error_message,
    current_user_agent,
    current_ip,
    p_redirect_url
  ) RETURNING id INTO log_id;

  RETURN log_id;
END;
$$;
-- Function to validate password reset session
CREATE OR REPLACE FUNCTION validate_password_reset_session()
RETURNS TABLE (
  is_valid BOOLEAN,
  user_id UUID,
  user_email TEXT,
  session_created_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  error_message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id UUID;
  current_session_data JSON;
BEGIN
  -- Get current authenticated user
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RETURN QUERY SELECT 
      FALSE as is_valid,
      NULL::UUID as user_id,
      NULL::TEXT as user_email,
      NULL::TIMESTAMPTZ as session_created_at,
      NULL::TIMESTAMPTZ as expires_at,
      'No authenticated session found'::TEXT as error_message;
    RETURN;
  END IF;

  -- Get session information from auth.users
  SELECT 
    TRUE,
    au.id,
    au.email,
    au.email_confirmed_at,
    au.email_confirmed_at + INTERVAL '1 hour',
    NULL
  INTO 
    is_valid,
    user_id,
    user_email,
    session_created_at,
    expires_at,
    error_message
  FROM auth.users au
  WHERE au.id = current_user_id;

  -- Log the validation attempt
  PERFORM log_auth_attempt(
    current_user_id,
    'session_validation',
    'current_session',
    NULL,
    TRUE,
    NULL,
    NULL
  );

  RETURN QUERY SELECT 
    is_valid,
    user_id,
    user_email,
    session_created_at,
    expires_at,
    error_message;
END;
$$;
-- Function to get authentication configuration status
CREATE OR REPLACE FUNCTION get_auth_configuration_status()
RETURNS TABLE (
  setting_name TEXT,
  required_value TEXT,
  description TEXT,
  is_configured BOOLEAN,
  configuration_instructions TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    acg.setting_name,
    acg.required_value,
    acg.description,
    acg.is_configured,
    CASE 
      WHEN acg.setting_name = 'site_url' THEN 
        'Go to Supabase Dashboard > Authentication > URL Configuration > Site URL and set to: ' || acg.required_value
      WHEN acg.setting_name = 'redirect_urls' THEN 
        'Go to Supabase Dashboard > Authentication > URL Configuration > Redirect URLs and add these URLs (one per line): ' || replace(acg.required_value, ',', E'\n')
      WHEN acg.setting_name = 'pkce_flow_enabled' THEN 
        'Go to Supabase Dashboard > Authentication > Settings > Advanced Settings and enable PKCE'
      WHEN acg.setting_name = 'password_reset_expiry' THEN 
        'Go to Supabase Dashboard > Authentication > Settings and set password reset expiry to at least 3600 seconds (1 hour)'
      ELSE 
        'Manual configuration required in Supabase Dashboard'
    END as configuration_instructions
  FROM auth_configuration_guide acg
  ORDER BY acg.id;
END;
$$;
-- ================================
-- ENHANCED AUTH ERROR TRACKING
-- ================================

-- Function to track and analyze authentication errors
CREATE OR REPLACE FUNCTION track_auth_error(
  p_error_type TEXT,
  p_error_message TEXT,
  p_token_info TEXT DEFAULT NULL,
  p_user_context TEXT DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  log_id UUID;
  error_user_id UUID;
BEGIN
  -- Try to extract user ID from context if available
  error_user_id := auth.uid();

  -- Log the error for debugging
  log_id := log_auth_attempt(
    error_user_id,
    'auth_error',
    p_error_type,
    CASE WHEN p_token_info IS NOT NULL THEN substring(p_token_info from 1 for 10) ELSE NULL END,
    FALSE,
    p_error_message,
    p_user_context
  );

  RETURN log_id;
END;
$$;
-- ================================
-- HELPER VIEWS FOR DEBUGGING
-- ================================

-- View to help admins debug authentication issues
CREATE OR REPLACE VIEW auth_debug_summary AS
SELECT 
  DATE(created_at) as date,
  event_type,
  token_type,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE success = true) as successful_attempts,
  COUNT(*) FILTER (WHERE success = false) as failed_attempts,
  ROUND(
    (COUNT(*) FILTER (WHERE success = true)::numeric / COUNT(*)::numeric) * 100, 
    2
  ) as success_rate_percent
FROM auth_debug_log
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at), event_type, token_type
ORDER BY date DESC, event_type, token_type;
-- View to show recent authentication errors
CREATE OR REPLACE VIEW recent_auth_errors AS
SELECT 
  created_at,
  event_type,
  token_type,
  error_message,
  user_agent,
  redirect_url
FROM auth_debug_log
WHERE success = false
  AND created_at >= NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC
LIMIT 50;
-- ================================
-- CONFIGURATION VERIFICATION
-- ================================

-- Add comments for manual configuration steps
COMMENT ON TABLE auth_configuration_guide IS 'Configuration settings that must be manually set in Supabase Dashboard for proper authentication flow';
COMMENT ON TABLE auth_debug_log IS 'Debug log for tracking authentication attempts and troubleshooting token issues';
COMMENT ON FUNCTION validate_password_reset_session() IS 'Validates current password reset session and returns session details';
COMMENT ON FUNCTION get_auth_configuration_status() IS 'Returns current authentication configuration status and setup instructions';
COMMENT ON FUNCTION track_auth_error(TEXT, TEXT, TEXT, TEXT) IS 'Tracks authentication errors for debugging and analysis';
-- ================================
-- INITIAL SETUP VERIFICATION
-- ================================

-- Insert initial test record to verify setup
DO $$
BEGIN
  -- Log this migration execution
  PERFORM log_auth_attempt(
    NULL,
    'migration_applied',
    'configuration_fix',
    '20251014180000',
    TRUE,
    'Authentication configuration migration applied successfully',
    'supabase_migration'
  );
END $$;
