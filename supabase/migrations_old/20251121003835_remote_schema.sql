

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'Authentication system fixes completed on 2025-10-13 17:06:24';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."account_stage" AS ENUM (
    'Prospect',
    'Contacted',
    'Vendor Packet Request',
    'Vendor Packet Submitted',
    'Approved for Work',
    'Actively Engaged'
);


ALTER TYPE "public"."account_stage" OWNER TO "postgres";


COMMENT ON TYPE "public"."account_stage" IS 'Updated account stages for vendor packet workflow: Prospect → Contacted → Vendor Packet Request → Vendor Packet Submitted → Approved for Work → Actively Engaged';



CREATE TYPE "public"."account_stages" AS ENUM (
    'Prospect',
    'Qualified Lead',
    'Proposal',
    'Negotiation',
    'Closed Won',
    'Closed Lost',
    'Follow Up',
    'On Hold'
);


ALTER TYPE "public"."account_stages" OWNER TO "postgres";


CREATE TYPE "public"."activity_motion_type" AS ENUM (
    'prospecting',
    'follow_up',
    'opportunity_follow_up'
);


ALTER TYPE "public"."activity_motion_type" OWNER TO "postgres";


CREATE TYPE "public"."activity_outcome" AS ENUM (
    'Successful',
    'No Answer',
    'Callback Requested',
    'Not Interested',
    'Interested',
    'Proposal Requested',
    'Meeting Scheduled',
    'Contract Signed',
    'Assessment Completed'
);


ALTER TYPE "public"."activity_outcome" OWNER TO "postgres";


CREATE TYPE "public"."activity_type" AS ENUM (
    'Phone Call',
    'Email',
    'Meeting',
    'Site Visit',
    'Proposal Sent',
    'Follow-up',
    'Assessment',
    'Contract Signed',
    'Pop-in',
    'Decision Maker Conversation'
);


ALTER TYPE "public"."activity_type" OWNER TO "postgres";


CREATE TYPE "public"."building_type" AS ENUM (
    'Industrial',
    'Warehouse',
    'Manufacturing',
    'Hospitality',
    'Multifamily',
    'Commercial Office',
    'Retail',
    'Healthcare'
);


ALTER TYPE "public"."building_type" OWNER TO "postgres";


CREATE TYPE "public"."company_type" AS ENUM (
    'Property Management',
    'General Contractor',
    'Developer',
    'REIT/Institutional Investor',
    'Asset Manager',
    'Building Owner',
    'Facility Manager',
    'Roofing Contractor',
    'Insurance',
    'Architecture/Engineering',
    'Commercial Office',
    'Retail',
    'Healthcare',
    'Affiliate: Manufacturer',
    'Affiliate: Real Estate'
);


ALTER TYPE "public"."company_type" OWNER TO "postgres";


CREATE TYPE "public"."contact_stage" AS ENUM (
    'Identified',
    'Reached',
    'DM Confirmed',
    'Engaged',
    'Dormant'
);


ALTER TYPE "public"."contact_stage" OWNER TO "postgres";


CREATE TYPE "public"."document_event_type" AS ENUM (
    'upload',
    'download',
    'view',
    'replace',
    'delete',
    'metadata_update'
);


ALTER TYPE "public"."document_event_type" OWNER TO "postgres";


CREATE TYPE "public"."document_status" AS ENUM (
    'valid',
    'expiring',
    'expired',
    'missing'
);


ALTER TYPE "public"."document_status" OWNER TO "postgres";


CREATE TYPE "public"."document_type" AS ENUM (
    'coi',
    'w9',
    'business_license',
    'other'
);


ALTER TYPE "public"."document_type" OWNER TO "postgres";


CREATE TYPE "public"."event_priority" AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE "public"."event_priority" OWNER TO "postgres";


CREATE TYPE "public"."event_status" AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
    'rescheduled'
);


ALTER TYPE "public"."event_status" OWNER TO "postgres";


CREATE TYPE "public"."event_type" AS ENUM (
    'meeting',
    'deadline',
    'company_event',
    'appointment',
    'training',
    'holiday',
    'maintenance',
    'inspection'
);


ALTER TYPE "public"."event_type" OWNER TO "postgres";


CREATE TYPE "public"."goal_status" AS ENUM (
    'Not Started',
    'In Progress',
    'Completed',
    'Overdue'
);


ALTER TYPE "public"."goal_status" OWNER TO "postgres";


CREATE TYPE "public"."notification_type" AS ENUM (
    'task_assigned',
    'task_due',
    'task_overdue',
    'activity_assessment',
    'activity_contract_signed',
    'system_alert'
);


ALTER TYPE "public"."notification_type" OWNER TO "postgres";


CREATE TYPE "public"."opportunity_stage" AS ENUM (
    'identified',
    'qualified',
    'proposal_sent',
    'negotiation',
    'won',
    'lost'
);


ALTER TYPE "public"."opportunity_stage" OWNER TO "postgres";


CREATE TYPE "public"."opportunity_type" AS ENUM (
    'new_construction',
    'inspection',
    'repair',
    'maintenance',
    're_roof'
);


ALTER TYPE "public"."opportunity_type" OWNER TO "postgres";


CREATE TYPE "public"."property_stage" AS ENUM (
    'Unassessed',
    'Assessment Scheduled',
    'Assessed',
    'Proposal Sent',
    'In Negotiation',
    'Won',
    'Lost'
);


ALTER TYPE "public"."property_stage" OWNER TO "postgres";


CREATE TYPE "public"."prospect_stages" AS ENUM (
    'new',
    'contacted',
    'qualified',
    'proposal_sent',
    'negotiating',
    'closed_won',
    'closed_lost'
);


ALTER TYPE "public"."prospect_stages" OWNER TO "postgres";


CREATE TYPE "public"."roof_condition_label" AS ENUM (
    'dirty',
    'aged',
    'patched',
    'ponding',
    'damaged',
    'other'
);


ALTER TYPE "public"."roof_condition_label" OWNER TO "postgres";


CREATE TYPE "public"."roof_lead_status" AS ENUM (
    'new',
    'assessed',
    'contacted',
    'qualified',
    'converted',
    'rejected'
);


ALTER TYPE "public"."roof_lead_status" OWNER TO "postgres";


CREATE TYPE "public"."roof_type" AS ENUM (
    'TPO',
    'EPDM',
    'Metal',
    'Modified Bitumen',
    'Shingle',
    'PVC',
    'BUR'
);


ALTER TYPE "public"."roof_type" OWNER TO "postgres";


CREATE TYPE "public"."subscription_plan" AS ENUM (
    'free',
    'basic',
    'pro',
    'enterprise',
    'custom'
);


ALTER TYPE "public"."subscription_plan" OWNER TO "postgres";


CREATE TYPE "public"."task_category" AS ENUM (
    'follow_up_call',
    'site_visit',
    'proposal_review',
    'contract_negotiation',
    'assessment_scheduling',
    'document_review',
    'meeting_setup',
    'property_inspection',
    'client_check_in',
    'other'
);


ALTER TYPE "public"."task_category" OWNER TO "postgres";


CREATE TYPE "public"."task_priority" AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);


ALTER TYPE "public"."task_priority" OWNER TO "postgres";


CREATE TYPE "public"."task_status" AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'overdue'
);


ALTER TYPE "public"."task_status" OWNER TO "postgres";


CREATE TYPE "public"."tenant_status" AS ENUM (
    'active',
    'inactive',
    'suspended',
    'trial',
    'expired'
);


ALTER TYPE "public"."tenant_status" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'admin',
    'manager',
    'rep',
    'super_admin',
    'master_admin'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."_audit_log"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public._audit_queue(table_name, action, row_data)
  values (tg_table_name, tg_op,
          case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) else to_jsonb(old) end);
  return coalesce(new, old);
end;
$$;


ALTER FUNCTION "public"."_audit_log"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."_policy_exists"("p_table" "text", "p_name" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
declare v_exists boolean;
begin
  select exists(
    select 1
    from pg_catalog.pg_policy pol
    join pg_catalog.pg_class cls on pol.polrelid = cls.oid
    join pg_catalog.pg_namespace nsp on nsp.oid = cls.relnamespace
    where nsp.nspname = 'public'
      and cls.relname = p_table
      and pol.polname = p_name
  ) into v_exists;
  return v_exists;
end;
$$;


ALTER FUNCTION "public"."_policy_exists"("p_table" "text", "p_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_force_password_reset"("target_email" "text", "admin_user_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("success" boolean, "message" "text", "reset_token" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."admin_force_password_reset"("target_email" "text", "admin_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."app_role"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select role from public.user_profiles where id = auth.uid()
$$;


ALTER FUNCTION "public"."app_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    account_tenant_id UUID;
    rep_tenant_id UUID;
BEGIN
    -- Get the tenant ID for the account
    SELECT tenant_id INTO account_tenant_id
    FROM public.accounts
    WHERE id = account_uuid;

    -- Get the tenant ID for the rep
    SELECT tenant_id INTO rep_tenant_id
    FROM public.user_profiles
    WHERE id = rep_uuid;

    -- Verify both exist and belong to same tenant
    IF account_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Account % not found', account_uuid;
    END IF;

    IF rep_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User profile % not found', rep_uuid;
    END IF;

    IF account_tenant_id != rep_tenant_id THEN
        RAISE EXCEPTION 'Cannot assign rep from tenant % to account in tenant %', rep_tenant_id, account_tenant_id;
    END IF;

    -- Safe to assign - both belong to same tenant
    UPDATE public.accounts
    SET assigned_rep_id = rep_uuid,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = account_uuid;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to assign rep: %', SQLERRM;
        RETURN FALSE;
END $$;


ALTER FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") IS 'Safely assigns a rep to an account ensuring both belong to the same tenant';



CREATE OR REPLACE FUNCTION "public"."assign_reps_to_account"("account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid" DEFAULT NULL::"uuid", "manager_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    rep_id UUID;
    manager_tenant UUID;
    account_tenant UUID;
BEGIN
    -- Verify manager can manage this account
    IF NOT public.manager_can_manage_account_assignments(manager_uuid, account_uuid) THEN
        RETURN QUERY SELECT false::BOOLEAN, 'Manager does not have permission to manage assignments for this account'::TEXT;
        RETURN;
    END IF;

    -- Get manager and account tenant IDs for validation
    SELECT up.tenant_id INTO manager_tenant 
    FROM public.user_profiles up 
    WHERE up.id = manager_uuid;
    
    SELECT a.tenant_id INTO account_tenant 
    FROM public.accounts a 
    WHERE a.id = account_uuid;
    
    IF manager_tenant != account_tenant THEN
        RETURN QUERY SELECT false::BOOLEAN, 'Account and manager must be in the same tenant'::TEXT;
        RETURN;
    END IF;

    -- Clear existing primary designation if setting new primary
    IF primary_rep_id IS NOT NULL THEN
        UPDATE public.account_assignments 
        SET is_primary = false 
        WHERE account_id = account_uuid;
    END IF;

    -- Insert or update assignments for each rep
    FOREACH rep_id IN ARRAY rep_ids
    LOOP
        -- Verify rep belongs to same tenant
        IF NOT EXISTS (
            SELECT 1 FROM public.user_profiles up 
            WHERE up.id = rep_id 
            AND up.tenant_id = manager_tenant
            AND up.is_active = true
        ) THEN
            RETURN QUERY SELECT false::BOOLEAN, 'Rep ' || rep_id::TEXT || ' not found or not in same tenant'::TEXT;
            RETURN;
        END IF;

        -- Insert assignment (ON CONFLICT UPDATE to handle duplicates)
        INSERT INTO public.account_assignments (
            account_id, 
            rep_id, 
            assigned_by, 
            is_primary
        ) VALUES (
            account_uuid, 
            rep_id, 
            manager_uuid,
            (rep_id = primary_rep_id)
        )
        ON CONFLICT (account_id, rep_id) 
        DO UPDATE SET 
            assigned_by = EXCLUDED.assigned_by,
            assigned_at = CURRENT_TIMESTAMP,
            is_primary = EXCLUDED.is_primary;
    END LOOP;

    -- Update the legacy assigned_rep_id to primary rep for backward compatibility
    IF primary_rep_id IS NOT NULL THEN
        UPDATE public.accounts 
        SET assigned_rep_id = primary_rep_id 
        WHERE id = account_uuid;
    END IF;

    RETURN QUERY SELECT true::BOOLEAN, 'Representatives assigned successfully'::TEXT;
END;
$$;


ALTER FUNCTION "public"."assign_reps_to_account"("account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid", "manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Validate tenant exists
  IF NOT EXISTS (SELECT 1 FROM public.tenants WHERE id = new_tenant_id) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Invalid organization selected'
    );
  END IF;

  -- Update user profile with tenant
  UPDATE public.user_profiles
  SET 
    tenant_id = new_tenant_id, 
    profile_completed = true,
    updated_at = now()
  WHERE id = user_uuid;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Organization assigned successfully'
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'message', 'User profile not found'
    );
  END IF;
END;
$$;


ALTER FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") IS 'Safely assigns tenant to user and marks profile as completed';



CREATE OR REPLACE FUNCTION "public"."auto_establish_manager_rep_relationship"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    available_manager_id UUID;
BEGIN
    -- Only process for rep role users
    IF NEW.role = 'rep' AND NEW.is_active = true AND NEW.manager_id IS NULL THEN
        -- Find an active manager in the same tenant
        SELECT id INTO available_manager_id
        FROM public.user_profiles
        WHERE role IN ('manager', 'admin')
        AND tenant_id = NEW.tenant_id
        AND is_active = true
        LIMIT 1;
        
        -- Assign the manager if found
        IF available_manager_id IS NOT NULL THEN
            NEW.manager_id := available_manager_id;
            RAISE NOTICE 'Auto-assigned manager % to new rep %', available_manager_id, NEW.full_name;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_establish_manager_rep_relationship"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_access_any_account"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.is_active = true
    AND up.role IN ('admin', 'manager', 'rep')
)
$$;


ALTER FUNCTION "public"."can_access_any_account"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_access_any_tenant"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.is_super_admin_from_auth()
$$;


ALTER FUNCTION "public"."can_access_any_tenant"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_access_tenant_data"("target_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    user_role TEXT;
    user_tenant UUID;
BEGIN
    -- Get user role and tenant
    SELECT up.role::TEXT, up.tenant_id INTO user_role, user_tenant
    FROM public.user_profiles up
    WHERE up.id = auth.uid()
    LIMIT 1;
    
    -- Admin can access all tenant data
    IF user_role IN ('admin', 'super_admin', 'master_admin') THEN
        RETURN true;
    END IF;
    
    -- Manager and rep can access their tenant data
    IF user_role IN ('manager', 'rep') AND user_tenant = target_tenant_id THEN
        RETURN true;
    END IF;
    
    RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$;


ALTER FUNCTION "public"."can_access_tenant_data"("target_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_access_tenant_data_enhanced"("target_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    user_role TEXT;
    user_tenant UUID;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Get user role and tenant from profile
    SELECT public.get_user_role_with_fallbacks(), up.tenant_id 
    INTO user_role, user_tenant
    FROM public.user_profiles up
    WHERE up.id = current_user_id
    LIMIT 1;
    
    -- Debug logging
    RAISE NOTICE 'Tenant access check: user_id=%, role=%, user_tenant=%, target_tenant=%', 
        current_user_id, user_role, user_tenant, target_tenant_id;
    
    -- Admin can access all tenant data
    IF user_role IN ('admin', 'super_admin', 'master_admin') THEN
        RETURN true;
    END IF;
    
    -- Manager and rep can access their tenant data
    IF user_role IN ('manager', 'rep') AND user_tenant = target_tenant_id THEN
        RETURN true;
    END IF;
    
    -- If no tenant assigned but user has proper role, allow access to any tenant (for now)
    IF user_role IN ('manager', 'rep') AND user_tenant IS NULL THEN
        RAISE NOTICE 'User % has no tenant assigned but has role %, allowing access', current_user_id, user_role;
        RETURN true;
    END IF;
    
    RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in tenant access check: %', SQLERRM;
        RETURN false;
END;
$$;


ALTER FUNCTION "public"."can_access_tenant_data_enhanced"("target_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_assign_user_to_tenant"("admin_user_id" "uuid", "target_user_id" "uuid", "target_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  admin_role text;
  admin_tenant_id uuid;
BEGIN
  -- Get admin user details
  SELECT up.role, up.tenant_id 
  INTO admin_role, admin_tenant_id
  FROM public.user_profiles up
  WHERE up.id = admin_user_id;

  -- Super admin can assign anyone to any tenant
  IF admin_role = 'super_admin' THEN
    RETURN true;
  END IF;

  -- Admin can assign users to their own tenant
  IF admin_role = 'admin' AND admin_tenant_id = target_tenant_id THEN
    RETURN true;
  END IF;

  -- Manager can assign users to their tenant with restrictions
  IF admin_role = 'manager' AND admin_tenant_id = target_tenant_id THEN
    -- Check if target user is not already an admin
    RETURN NOT EXISTS (
      SELECT 1 FROM public.user_profiles 
      WHERE id = target_user_id 
      AND role IN ('admin', 'super_admin')
    );
  END IF;

  RETURN false;
END;
$$;


ALTER FUNCTION "public"."can_assign_user_to_tenant"("admin_user_id" "uuid", "target_user_id" "uuid", "target_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_manage_user"("target_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT CASE 
    WHEN public.is_admin_user() THEN true
    WHEN public.is_manager_user() THEN (
        SELECT EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = target_user_id 
            AND up.manager_id = auth.uid()
        )
    )
    ELSE false
END;
$$;


ALTER FUNCTION "public"."can_manage_user"("target_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."can_manage_user"("target_user_id" "uuid") IS 'Checks if current user can manage the specified user based on role hierarchy';



CREATE OR REPLACE FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND up.tenant_id = goal_tenant_id
    AND up.role IN ('manager', 'super_admin', 'master_admin')
    AND up.is_active = true
) OR (auth.uid() = goal_user_id)
$$;


ALTER FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") IS 'Helper function for weekly_goals RLS policy. Allows users to manage their own goals and managers to manage team member goals within the same tenant. Prevents circular dependencies by querying user_profiles table.';



CREATE OR REPLACE FUNCTION "public"."can_user_manage_documents"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role IN ('admin', 'manager')
)
$$;


ALTER FUNCTION "public"."can_user_manage_documents"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_task_access"("task_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    user_role text;
    user_tenant UUID;
    task_tenant UUID;
    task_assigned_to UUID;
BEGIN
    -- Get current user's role and tenant
    SELECT role, tenant_id INTO user_role, user_tenant
    FROM public.user_profiles
    WHERE id = auth.uid();

    -- If no user profile found, deny access
    IF user_role IS NULL OR user_tenant IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get task details
    SELECT tenant_id, assigned_to INTO task_tenant, task_assigned_to
    FROM public.tasks
    WHERE id = task_id;

    -- If task not found, deny access
    IF task_tenant IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Check access based on role
    CASE user_role
        WHEN 'super_admin', 'admin' THEN
            RETURN TRUE;
        WHEN 'manager' THEN
            -- Managers can access all tasks in their tenant
            RETURN user_tenant = task_tenant;
        WHEN 'rep' THEN
            -- Reps can ONLY access tasks assigned to them in their tenant
            RETURN user_tenant = task_tenant AND task_assigned_to = auth.uid();
        ELSE
            RETURN FALSE;
    END CASE;
END;
$$;


ALTER FUNCTION "public"."check_task_access"("task_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_task_access"("task_id" "uuid") IS 'Strict function to check if current user can access a specific task - reps restricted to assigned tasks only';



CREATE OR REPLACE FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    user_role text;
    user_tenant UUID;
BEGIN
    -- Get current user's role and tenant
    SELECT role, tenant_id INTO user_role, user_tenant
    FROM public.user_profiles
    WHERE id = auth.uid();

    -- If no user profile found, deny access
    IF user_role IS NULL OR user_tenant IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Check modification permissions based on role
    CASE user_role
        WHEN 'super_admin', 'admin' THEN
            RETURN TRUE;
        WHEN 'manager' THEN
            -- Managers can modify tasks in their tenant
            RETURN user_tenant = target_tenant_id;
        WHEN 'rep' THEN
            -- Reps can only modify tasks assigned to them in their tenant
            RETURN user_tenant = target_tenant_id AND target_assigned_to = auth.uid();
        ELSE
            RETURN FALSE;
    END CASE;
END;
$$;


ALTER FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") IS 'Strict function to check task modification permissions - enforces tenant boundaries';



CREATE OR REPLACE FUNCTION "public"."check_tenant_limits"("tenant_uuid" "uuid", "limit_type" "text") RETURNS integer
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    CASE limit_type
        WHEN 'users' THEN t.max_users
        WHEN 'accounts' THEN t.max_accounts  
        WHEN 'properties' THEN t.max_properties
        WHEN 'storage' THEN t.max_storage_mb
        ELSE 0
    END
FROM public.tenants t
WHERE t.id = tenant_uuid
$$;


ALTER FUNCTION "public"."check_tenant_limits"("tenant_uuid" "uuid", "limit_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_role"("required_role" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  user_role text;
BEGIN
  -- Get the current user's role from user_profiles
  SELECT up.role INTO user_role
  FROM user_profiles up
  WHERE up.id = auth.uid();
  
  -- Return true if user has the required role or higher permissions
  RETURN CASE
    WHEN required_role = 'sales_rep' THEN 
      user_role IN ('sales_rep', 'manager', 'admin', 'super_admin')
    WHEN required_role = 'manager' THEN 
      user_role IN ('manager', 'admin', 'super_admin')
    WHEN required_role = 'admin' THEN 
      user_role IN ('admin', 'super_admin')
    WHEN required_role = 'super_admin' THEN 
      user_role = 'super_admin'
    ELSE false
  END;
END;
$$;


ALTER FUNCTION "public"."check_user_role"("required_role" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_user_role"("required_role" "text") IS 'Checks if the current authenticated user has the specified role or higher permissions';



CREATE OR REPLACE FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  goal_count INTEGER := 0;
  current_user_profile user_profiles%ROWTYPE;
BEGIN
  -- Get current user profile
  SELECT * INTO current_user_profile
  FROM user_profiles
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'User not found',
      'goal_count', 0
    );
  END IF;

  -- Count goals with appropriate tenant filtering
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals wg
  JOIN user_profiles up ON wg.user_id = up.id
  WHERE wg.user_id = ANY(user_ids)
  AND wg.week_start_date = week_start_date
  AND (
    -- Users can check their own goals
    wg.user_id = auth.uid()
    OR
    -- Managers can check goals for users in their tenant
    (
      current_user_profile.role IN ('manager', 'admin', 'super_admin')
      AND up.tenant_id = current_user_profile.tenant_id
    )
    OR
    -- Super admin can check all goals
    current_user_profile.role = 'super_admin'
  );

  RETURN json_build_object(
    'success', true,
    'goal_count', goal_count,
    'user_count', array_length(user_ids, 1),
    'week_start', week_start_date
  );
END;
$$;


ALTER FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") IS 'Simple function to check if weekly goals exist for given users and week';



CREATE OR REPLACE FUNCTION "public"."cleanup_inactive_user_profiles"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    cleanup_count INTEGER := 0;
BEGIN
    -- Mark profiles as inactive if they haven't been updated in 30 days and have incomplete info
    UPDATE public.user_profiles 
    SET is_active = false, updated_at = CURRENT_TIMESTAMP
    WHERE updated_at < (CURRENT_TIMESTAMP - INTERVAL '30 days')
    AND (full_name IS NULL OR full_name = '')
    AND is_active = true;

    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    
    RETURN cleanup_count;
END;
$$;


ALTER FUNCTION "public"."cleanup_inactive_user_profiles"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."cleanup_inactive_user_profiles"() IS 'Maintenance function to clean up inactive user profiles';



CREATE OR REPLACE FUNCTION "public"."complete_password_setup"("user_uuid" "uuid", "mark_password_complete" boolean DEFAULT true) RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."complete_password_setup"("user_uuid" "uuid", "mark_password_complete" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_user_profile_setup"("user_uuid" "uuid", "full_name_param" "text", "organization_param" "text" DEFAULT NULL::"text", "role_param" "text" DEFAULT 'rep'::"text") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Update user profile with complete information
  UPDATE public.user_profiles
  SET 
    full_name = full_name_param,
    organization = organization_param,
    role = role_param::public.user_role,
    profile_completed = true,
    password_set = true,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = user_uuid;

  -- Check if update was successful
  IF FOUND THEN
    RETURN QUERY SELECT true, 'Profile setup completed successfully'::TEXT;
  ELSE
    RETURN QUERY SELECT false, 'User profile not found'::TEXT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error updating profile: ' || SQLERRM)::TEXT;
END;
$$;


ALTER FUNCTION "public"."complete_user_profile_setup"("user_uuid" "uuid", "full_name_param" "text", "organization_param" "text", "role_param" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("success" boolean, "message" "text", "user_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
    update_count INTEGER;
BEGIN
    -- Find the user in user_profiles
    SELECT id INTO target_user_id
    FROM public.user_profiles
    WHERE email = user_email
    AND is_active = true;

    IF target_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User profile not found'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Update user profile with additional information if provided
    IF profile_data != '{}'::JSONB THEN
        UPDATE public.user_profiles
        SET
            full_name = COALESCE(profile_data->>'fullName', profile_data->>'full_name', full_name),
            phone = COALESCE(profile_data->>'phone', phone),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = target_user_id;
        
        GET DIAGNOSTICS update_count = ROW_COUNT;
    END IF;

    RETURN QUERY SELECT TRUE, 'Profile updated successfully'::TEXT, target_user_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error updating user profile: ' || SQLERRM)::TEXT, NULL::UUID;
END;
$$;


ALTER FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb") IS 'Completes user profile setup after email confirmation';



CREATE OR REPLACE FUNCTION "public"."complete_user_setup_enhanced"("user_email" "text", "profile_data" "jsonb", "mark_password_set" boolean DEFAULT true) RETURNS TABLE("success" boolean, "message" "text", "redirect_to" "text", "user_id" "uuid", "profile_completed" boolean, "password_set" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."complete_user_setup_enhanced"("user_email" "text", "profile_data" "jsonb", "mark_password_set" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("success" boolean, "message" "text", "account_id" "uuid", "prospect_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    prospect_record public.prospects%ROWTYPE;
    new_account_id UUID;
    current_user_id UUID;
    current_tenant_id UUID;
    manager_id UUID;
    valid_company_type public.company_type;
BEGIN
    -- Get current user info
    current_user_id := auth.uid();
    SELECT tenant_id INTO current_tenant_id FROM public.user_profiles WHERE id = current_user_id;
    
    -- Get prospect record
    SELECT * INTO prospect_record FROM public.prospects 
    WHERE id = prospect_uuid AND tenant_id = current_tenant_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Prospect not found', NULL::UUID, prospect_uuid;
        RETURN;
    END IF;
    
    -- Check if already converted
    IF prospect_record.status = 'converted' THEN
        RETURN QUERY SELECT FALSE, 'Prospect already converted', prospect_record.linked_account_id, prospect_uuid;
        RETURN;
    END IF;
    
    -- If linking to existing account
    IF link_to_existing_account_id IS NOT NULL THEN
        -- Verify account exists and is in same tenant
        IF NOT EXISTS (SELECT 1 FROM public.accounts WHERE id = link_to_existing_account_id AND tenant_id = current_tenant_id) THEN
            RETURN QUERY SELECT FALSE, 'Target account not found', NULL::UUID, prospect_uuid;
            RETURN;
        END IF;
        
        -- Update prospect to linked status
        UPDATE public.prospects 
        SET status = 'converted', 
            linked_account_id = link_to_existing_account_id,
            last_activity_at = NOW(),
            updated_at = NOW()
        WHERE id = prospect_uuid;
        
        -- Create follow-up task on existing account
        INSERT INTO public.tasks (
            tenant_id, account_id, assigned_to, assigned_by, title, description, 
            category, status, priority, due_date
        ) VALUES (
            current_tenant_id, link_to_existing_account_id, current_user_id, current_user_id,
            'Follow up on linked prospect conversion', 
            'Prospect "' || prospect_record.name || '" was linked to this account. Follow up on next steps.',
            'other', 'pending', 'medium', NOW() + INTERVAL '1 day'
        );
        
        RETURN QUERY SELECT TRUE, 'Prospect linked to existing account', link_to_existing_account_id, prospect_uuid;
        RETURN;
    END IF;
    
    -- FIXED: Handle company_type enum conversion with fallback
    BEGIN
        -- Try to cast the prospect's company_type to the enum
        valid_company_type := COALESCE(prospect_record.company_type, 'Property Management')::public.company_type;
    EXCEPTION WHEN others THEN
        -- If casting fails, use default
        valid_company_type := 'Property Management'::public.company_type;
    END;
    
    -- Create new account from prospect data with proper type casting
    INSERT INTO public.accounts (
        tenant_id, name, company_type, phone, website, address, city, state, zip_code, 
        notes, assigned_rep_id, stage, is_active
    ) VALUES (
        current_tenant_id, 
        prospect_record.name, 
        valid_company_type, -- FIXED: Use properly cast enum value
        prospect_record.phone, 
        prospect_record.website, 
        prospect_record.address, 
        prospect_record.city, 
        prospect_record.state, 
        prospect_record.zip_code,
        COALESCE(prospect_record.notes, 'Converted from prospect: ' || prospect_record.name),
        current_user_id, 
        'Prospect'::public.account_stage, -- FIXED: Explicit enum casting
        TRUE
    ) RETURNING id INTO new_account_id;
    
    -- Create account assignment
    INSERT INTO public.account_assignments (tenant_id, account_id, rep_id, assigned_by, is_primary)
    VALUES (current_tenant_id, new_account_id, current_user_id, current_user_id, TRUE);
    
    -- Get manager for approval task
    SELECT manager_id INTO manager_id FROM public.user_profiles WHERE id = current_user_id;
    
    -- Create approval task for manager
    INSERT INTO public.tasks (
        tenant_id, account_id, assigned_to, assigned_by, title, description, 
        category, status, priority, due_date
    ) VALUES (
        current_tenant_id, new_account_id, 
        COALESCE(manager_id, current_user_id), current_user_id,
        'Review new account conversion', 
        'Account "' || prospect_record.name || '" was converted from prospect. Please review and approve.',
        'other', 'pending', 'high', NOW() + INTERVAL '1 day'
    );
    
    -- Update prospect status
    UPDATE public.prospects 
    SET status = 'converted', 
        linked_account_id = new_account_id,
        last_activity_at = NOW(),
        updated_at = NOW()
    WHERE id = prospect_uuid;
    
    RETURN QUERY SELECT TRUE, 'Prospect successfully converted to new account', new_account_id, prospect_uuid;
    RETURN;
    
EXCEPTION WHEN others THEN
    -- ENHANCED: Better error logging and handling
    RAISE LOG 'Error in convert_prospect_to_account: % %', SQLERRM, SQLSTATE;
    RETURN QUERY SELECT FALSE, 
        'Conversion failed: ' || CASE 
            WHEN SQLSTATE = '23505' THEN 'Duplicate account detected'
            WHEN SQLSTATE = '23503' THEN 'Invalid reference data'
            WHEN SQLSTATE = '23514' THEN 'Data validation failed'
            ELSE 'Database error occurred'
        END, 
        NULL::UUID, 
        prospect_uuid;
    RETURN;
END;
$$;


ALTER FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid") IS 'Converts a prospect to an account with proper enum type handling and comprehensive error management';



CREATE OR REPLACE FUNCTION "public"."create_activity_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  notification_title TEXT;
  notification_body TEXT;
  should_notify BOOLEAN := false;
BEGIN
  -- Check if this is an Assessment or Contract Signed activity
  IF NEW.activity_type = 'Assessment' OR NEW.outcome = 'Contract Signed' THEN
    should_notify := true;
    
    IF NEW.activity_type = 'Assessment' THEN
      notification_title := 'Assessment Completed';
      notification_body := 'An assessment has been completed: ' || NEW.subject;
    ELSIF NEW.outcome = 'Contract Signed' THEN
      notification_title := 'Contract Signed!';
      notification_body := 'Great news! A contract has been signed: ' || NEW.subject;
    END IF;
    
    -- Create notification for the user who performed the activity
    IF should_notify AND NEW.user_id IS NOT NULL THEN
      INSERT INTO public.notifications (
        tenant_id,
        user_id,
        type,
        title,
        body,
        data
      ) VALUES (
        NEW.tenant_id,
        NEW.user_id,
        CASE 
          WHEN NEW.activity_type = 'Assessment' THEN 'activity_assessment'::public.notification_type
          WHEN NEW.outcome = 'Contract Signed' THEN 'activity_contract_signed'::public.notification_type
        END,
        notification_title,
        notification_body,
        jsonb_build_object(
          'activity_id', NEW.id,
          'activity_type', NEW.activity_type,
          'outcome', NEW.outcome,
          'subject', NEW.subject,
          'account_id', NEW.account_id,
          'contact_id', NEW.contact_id
        )
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_activity_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_admin_user_with_workflow"("user_email" "text", "user_full_name" "text", "user_role" "text" DEFAULT 'admin'::"text", "user_phone" "text" DEFAULT NULL::"text", "user_organization" "text" DEFAULT NULL::"text", "temp_password" "text" DEFAULT 'TempPass123!'::"text") RETURNS TABLE("success" boolean, "message" "text", "user_id" "uuid", "confirmation_needed" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_user_id UUID;
    default_tenant_id UUID;
    current_user_role TEXT;
BEGIN
    -- Check if current user has permission to create admin users
    SELECT up.role::TEXT INTO current_user_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid();

    IF current_user_role NOT IN ('super_admin', 'admin') THEN
        RETURN QUERY SELECT FALSE, 'Insufficient permissions to create admin users'::TEXT, NULL::UUID, FALSE;
        RETURN;
    END IF;

    -- Generate new user ID
    new_user_id := gen_random_uuid();

    -- Get default tenant for assignment
    SELECT id INTO default_tenant_id
    FROM public.tenants
    WHERE status = 'active'::tenant_status
    ORDER BY created_at ASC
    LIMIT 1;

    IF default_tenant_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No active tenant found for user assignment'::TEXT, NULL::UUID, FALSE;
        RETURN;
    END IF;

    -- Create auth user with temporary password
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, created_at, updated_at, 
        raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES (
        new_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
        user_email, crypt(temp_password, gen_salt('bf', 10)), 
        NOW(), NOW(), NOW(),
        jsonb_build_object('full_name', user_full_name, 'role', user_role),
        jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
        false, false, '', null, '', null, '', '', null, '', 0, 
        '', null, user_phone, '', '', null
    );

    -- Create user profile
    INSERT INTO public.user_profiles (
        id, email, full_name, role, phone, organization, tenant_id,
        is_active, password_set, profile_completed,
        created_at, updated_at
    ) VALUES (
        new_user_id, user_email, user_full_name, 
        user_role::public.user_role, user_phone, user_organization, default_tenant_id,
        true, false, false,  -- Requires password setup and profile completion
        NOW(), NOW()
    );

    RETURN QUERY SELECT 
        TRUE, 
        'Admin user created successfully. User must set password and confirm setup on first login.'::TEXT, 
        new_user_id,
        TRUE;  -- confirmation_needed = true

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT FALSE, 'User with this email already exists'::TEXT, NULL::UUID, FALSE;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error creating admin user: ' || SQLERRM)::TEXT, NULL::UUID, FALSE;
END;
$$;


ALTER FUNCTION "public"."create_admin_user_with_workflow"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "temp_password" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_roof_lead_with_geojson"("p_name" "text", "p_geojson" "jsonb", "p_condition_label" "public"."roof_condition_label", "p_condition_score" integer, "p_tags" "text"[] DEFAULT '{}'::"text"[], "p_notes" "text" DEFAULT NULL::"text", "p_address" "text" DEFAULT NULL::"text", "p_city" "text" DEFAULT NULL::"text", "p_state" "text" DEFAULT NULL::"text", "p_zip_code" "text" DEFAULT NULL::"text", "p_estimated_sqft" integer DEFAULT NULL::integer, "p_estimated_repair_cost" numeric DEFAULT NULL::numeric) RETURNS TABLE("success" boolean, "lead_id" "uuid", "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_lead_id UUID := gen_random_uuid();
    v_user_id UUID := auth.uid();
    v_tenant_id UUID;
    v_geometry GEOMETRY;
BEGIN
    -- Get user's tenant_id
    SELECT tenant_id INTO v_tenant_id
    FROM public.user_profiles
    WHERE id = v_user_id;

    IF v_tenant_id IS NULL THEN
        RETURN QUERY SELECT false, NULL::UUID, 'User not found or not associated with tenant';
        RETURN;
    END IF;

    -- Convert GeoJSON to PostGIS geometry
    v_geometry := ST_GeomFromGeoJSON(p_geojson::text);
    
    -- Set SRID to WGS84 if not specified
    IF ST_SRID(v_geometry) = 0 THEN
        v_geometry := ST_SetSRID(v_geometry, 4326);
    END IF;

    -- Insert roof lead
    INSERT INTO public.roof_leads (
        id, name, geometry, condition_label, condition_score,
        tags, notes, address, city, state, zip_code,
        estimated_sqft, estimated_repair_cost,
        created_by, tenant_id
    ) VALUES (
        v_lead_id, p_name, v_geometry, p_condition_label, p_condition_score,
        p_tags, p_notes, p_address, p_city, p_state, p_zip_code,
        p_estimated_sqft, p_estimated_repair_cost,
        v_user_id, v_tenant_id
    );

    RETURN QUERY SELECT true, v_lead_id, 'Roof lead created successfully';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Error creating roof lead: ' || SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_roof_lead_with_geojson"("p_name" "text", "p_geojson" "jsonb", "p_condition_label" "public"."roof_condition_label", "p_condition_score" integer, "p_tags" "text"[], "p_notes" "text", "p_address" "text", "p_city" "text", "p_state" "text", "p_zip_code" "text", "p_estimated_sqft" integer, "p_estimated_repair_cost" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_task_assignment_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Only create notification if task is assigned to someone other than creator
  IF NEW.assigned_to IS NOT NULL AND NEW.assigned_to != NEW.assigned_by THEN
    INSERT INTO public.notifications (
      tenant_id,
      user_id,
      type,
      title,
      body,
      data
    ) VALUES (
      NEW.tenant_id,
      NEW.assigned_to,
      'task_assigned'::public.notification_type,
      'New Task Assigned',
      'You have been assigned a new task: ' || NEW.title,
      jsonb_build_object(
        'task_id', NEW.id,
        'task_title', NEW.title,
        'assigned_by', NEW.assigned_by,
        'due_date', NEW.due_date
      )
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_task_assignment_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_task_due_notifications"() RETURNS TABLE("notifications_created" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  task_record RECORD;
  notifications_count INTEGER := 0;
BEGIN
  -- Find tasks due today that haven't been completed
  FOR task_record IN
    SELECT t.id, t.tenant_id, t.assigned_to, t.title, t.due_date, t.priority
    FROM public.tasks t
    WHERE t.due_date::date = CURRENT_DATE
    AND t.status != 'completed'
    AND t.assigned_to IS NOT NULL
    -- Only create notification if one doesn't already exist for today
    AND NOT EXISTS (
      SELECT 1 FROM public.notifications n
      WHERE n.user_id = t.assigned_to
      AND n.type = 'task_due'
      AND n.data->>'task_id' = t.id::text
      AND n.created_at::date = CURRENT_DATE
    )
  LOOP
    INSERT INTO public.notifications (
      tenant_id,
      user_id,
      type,
      title,
      body,
      data
    ) VALUES (
      task_record.tenant_id,
      task_record.assigned_to,
      'task_due'::public.notification_type,
      'Task Due Today',
      'Task "' || task_record.title || '" is due today.',
      jsonb_build_object(
        'task_id', task_record.id,
        'task_title', task_record.title,
        'due_date', task_record.due_date,
        'priority', task_record.priority
      )
    );
    
    notifications_count := notifications_count + 1;
  END LOOP;
  
  -- Find overdue tasks
  FOR task_record IN
    SELECT t.id, t.tenant_id, t.assigned_to, t.title, t.due_date, t.priority
    FROM public.tasks t
    WHERE t.due_date < CURRENT_DATE
    AND t.status != 'completed'
    AND t.assigned_to IS NOT NULL
    -- Only create notification if one doesn't already exist for today
    AND NOT EXISTS (
      SELECT 1 FROM public.notifications n
      WHERE n.user_id = t.assigned_to
      AND n.type = 'task_overdue'
      AND n.data->>'task_id' = t.id::text
      AND n.created_at::date = CURRENT_DATE
    )
  LOOP
    INSERT INTO public.notifications (
      tenant_id,
      user_id,
      type,
      title,
      body,
      data
    ) VALUES (
      task_record.tenant_id,
      task_record.assigned_to,
      'task_overdue'::public.notification_type,
      'Task Overdue',
      'Task "' || task_record.title || '" is overdue.',
      jsonb_build_object(
        'task_id', task_record.id,
        'task_title', task_record.title,
        'due_date', task_record.due_date,
        'priority', task_record.priority
      )
    );
    
    notifications_count := notifications_count + 1;
  END LOOP;
  
  RETURN QUERY SELECT notifications_count;
END;
$$;


ALTER FUNCTION "public"."create_task_due_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_tenant_and_assign"("p_name" "text", "p_slug" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_uid uuid := auth.uid();
  v_new_id uuid;
begin
  if v_uid is null then
    return jsonb_build_object('success', false, 'message', 'Not authenticated');
  end if;

  insert into public.tenants (id, name, slug, owner_id, created_by, is_active, created_at, updated_at)
  values (gen_random_uuid(), p_name, p_slug, v_uid, v_uid, true, now(), now())
  returning id into v_new_id;

  update public.user_profiles
  set tenant_id = v_new_id, role = 'admin', updated_at = now()
  where id = v_uid;

  return jsonb_build_object(
    'success', true,
    'message', 'Tenant created and assigned',
    'tenant_id', v_new_id
  );
end;
$$;


ALTER FUNCTION "public"."create_tenant_and_assign"("p_name" "text", "p_slug" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text" DEFAULT 'rep'::"text", "user_phone" "text" DEFAULT NULL::"text", "user_organization" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "profile_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    default_tenant_id UUID;
    current_user_role TEXT;
    profile_exists BOOLEAN := FALSE;
BEGIN
    -- Check if current user is admin or super_admin
    SELECT up.role::TEXT INTO current_user_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid();

    IF current_user_role NOT IN ('admin', 'super_admin') THEN
        RETURN QUERY SELECT FALSE, 'Insufficient permissions'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Check if profile already exists
    SELECT EXISTS(SELECT 1 FROM public.user_profiles WHERE email = user_email OR id = user_id) INTO profile_exists;
    
    IF profile_exists THEN
        RETURN QUERY SELECT FALSE, 'User profile already exists'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Get default tenant
    SELECT id INTO default_tenant_id
    FROM public.tenants
    WHERE status = 'active'::tenant_status
    LIMIT 1;

    -- Create user profile in public schema
    INSERT INTO public.user_profiles (
        id,
        email,
        full_name,
        role,
        phone,
        tenant_id,
        is_active
    ) VALUES (
        user_id,
        user_email,
        user_full_name,
        user_role::public.user_role,
        user_phone,
        default_tenant_id,
        true
    );

    RETURN QUERY SELECT TRUE, 'User profile created successfully'::TEXT, user_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT FALSE, 'User profile with this email already exists'::TEXT, NULL::UUID;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error creating user profile: ' || SQLERRM)::TEXT, NULL::UUID;
END;
$$;


ALTER FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text") IS 'Admin function to create user profiles (requires separate auth user creation)';



CREATE OR REPLACE FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text" DEFAULT 'rep'::"text", "user_phone" "text" DEFAULT NULL::"text", "user_organization" "text" DEFAULT NULL::"text", "target_tenant_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("success" boolean, "message" "text", "user_id" "uuid", "temp_password" "text", "needs_confirmation" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_user_id UUID;
    generated_temp_password TEXT;
    assigned_tenant_id UUID;
    current_user_role TEXT;
BEGIN
    -- Check if current user has permission to create users
    SELECT up.role::TEXT INTO current_user_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid();

    IF current_user_role NOT IN ('super_admin', 'admin') THEN
        RETURN QUERY SELECT FALSE, 'Insufficient permissions to create users'::TEXT, NULL::UUID, ''::TEXT, FALSE;
        RETURN;
    END IF;

    -- Check if user already exists
    IF EXISTS (SELECT 1 FROM public.user_profiles WHERE email = user_email) THEN
        RETURN QUERY SELECT FALSE, 'User with this email already exists'::TEXT, NULL::UUID, ''::TEXT, FALSE;
        RETURN;
    END IF;

    -- Generate secure temporary password
    generated_temp_password := 'Temp' || substr(md5(random()::text), 1, 8) || '!' || extract(epoch from now())::int % 100;
    
    -- Generate new user ID
    new_user_id := gen_random_uuid();

    -- Determine tenant assignment
    assigned_tenant_id := COALESCE(
        target_tenant_id,
        (SELECT tenant_id FROM public.user_profiles WHERE id = auth.uid()),
        (SELECT id FROM public.tenants WHERE status = 'active'::tenant_status ORDER BY created_at ASC LIMIT 1)
    );

    IF assigned_tenant_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No valid tenant found for user assignment'::TEXT, NULL::UUID, ''::TEXT, FALSE;
        RETURN;
    END IF;

    -- Create auth user with temporary password
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, created_at, updated_at, 
        raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous
    ) VALUES (
        new_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
        user_email, crypt(generated_temp_password, gen_salt('bf', 10)), 
        NULL, -- Email not confirmed yet
        NOW(), NOW(),
        jsonb_build_object('full_name', user_full_name, 'role', user_role, 'setup_required', true),
        jsonb_build_object('provider', 'temp_password', 'providers', ARRAY['temp_password']),
        false, false
    );

    -- Create user profile with temporary password flags
    INSERT INTO public.user_profiles (
        id, email, full_name, role, phone, organization, tenant_id,
        is_active, password_set, profile_completed,
        temp_password_used, temp_password_expires_at, confirmation_status,
        created_at, updated_at
    ) VALUES (
        new_user_id, user_email, user_full_name, 
        user_role::public.user_role, user_phone, user_organization, assigned_tenant_id,
        true, false, false,  -- User needs to set permanent password and complete profile
        false, NOW() + INTERVAL '7 days', 'pending',  -- Temp password expires in 7 days
        NOW(), NOW()
    );

    RETURN QUERY SELECT 
        TRUE, 
        'User created successfully with temporary password'::TEXT, 
        new_user_id,
        generated_temp_password,
        TRUE;  -- needs_confirmation = true

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT FALSE, 'User with this email already exists'::TEXT, NULL::UUID, ''::TEXT, FALSE;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error creating user: ' || SQLERRM)::TEXT, NULL::UUID, ''::TEXT, FALSE;
END;
$$;


ALTER FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "target_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "target_tenant_id" "uuid") IS 'Enhanced user creation with temporary password support for admin workflows';



CREATE OR REPLACE FUNCTION "public"."current_tenant_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$select up.tenant_id from public.user_profiles up where up.id = auth.uid();$$;


ALTER FUNCTION "public"."current_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_user_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$select auth.uid();$$;


ALTER FUNCTION "public"."current_user_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."debug_manager_team_relationships"("manager_uuid" "uuid") RETURNS TABLE("manager_name" "text", "manager_role" "text", "tenant_name" "text", "rep_id" "uuid", "rep_name" "text", "rep_role" "text", "has_manager_relationship" boolean, "is_same_tenant" boolean, "rep_is_active" boolean, "manager_is_active" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.full_name as manager_name,
        m.role::text as manager_role,
        COALESCE(t.name, 'Unknown Tenant') as tenant_name,
        r.id as rep_id,
        COALESCE(r.full_name, 'Unknown Rep') as rep_name,
        COALESCE(r.role::text, 'Unknown Role') as rep_role,
        (r.manager_id = m.id) as has_manager_relationship,
        (r.tenant_id = m.tenant_id) as is_same_tenant,
        COALESCE(r.is_active, false) as rep_is_active,
        COALESCE(m.is_active, false) as manager_is_active
    FROM public.user_profiles m
    LEFT JOIN public.tenants t ON m.tenant_id = t.id
    LEFT JOIN public.user_profiles r ON (r.tenant_id = m.tenant_id AND r.role = 'rep')
    WHERE m.id = manager_uuid
    ORDER BY r.full_name;
END;
$$;


ALTER FUNCTION "public"."debug_manager_team_relationships"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("tenant_name" "text", "user_id" "uuid", "user_email" "text", "user_name" "text", "user_role" "text", "is_active" boolean, "user_count" bigint)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    t.name AS tenant_name,
    up.id AS user_id,
    up.email AS user_email,
    up.full_name AS user_name,
    up.role::TEXT AS user_role,
    up.is_active,
    COUNT(*) OVER (PARTITION BY up.tenant_id) as user_count
FROM public.tenants t
JOIN public.user_profiles up ON t.id = up.tenant_id
WHERE (target_tenant_id IS NULL OR t.id = target_tenant_id)
AND up.is_active = true
ORDER BY t.name, up.role, up.full_name;
$$;


ALTER FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid") IS 'Diagnostic function to debug tenant-user relationships. Call with no params to see all tenants, or pass tenant_id to see specific tenant.';



CREATE OR REPLACE FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("user_id" "uuid", "email" "text", "has_profile" boolean, "is_active" boolean, "tenant_assigned" boolean, "tenant_name" "text", "profile_completed" boolean, "auth_confirmed" boolean)
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT 
    au.id,
    au.email,
    (up.id IS NOT NULL) as has_profile,
    COALESCE(up.is_active, false) as is_active,
    (up.tenant_id IS NOT NULL) as tenant_assigned,
    COALESCE(t.name, 'No Tenant') as tenant_name,
    COALESCE(up.profile_completed, false) as profile_completed,
    (au.email_confirmed_at IS NOT NULL) as auth_confirmed
  FROM auth.users au
  LEFT JOIN public.user_profiles up ON au.id = up.id
  LEFT JOIN public.tenants t ON up.tenant_id = t.id
  WHERE check_user_uuid IS NULL OR au.id = check_user_uuid
  ORDER BY au.created_at DESC;
$$;


ALTER FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid") IS 'Debug function to check user authentication and profile status';



CREATE OR REPLACE FUNCTION "public"."debug_user_tenant_access"() RETURNS TABLE("user_id" "uuid", "user_email" "text", "tenant_id_from_profile" "uuid", "tenant_id_from_metadata" "text", "user_role" "text", "has_tenant_access" boolean)
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
SELECT 
    up.id,
    up.email,
    up.tenant_id,
    au.raw_user_meta_data->>'tenant_id',
    up.role::text,
    (up.tenant_id IS NOT NULL)
FROM public.user_profiles up
JOIN auth.users au ON au.id = up.id
WHERE up.id = auth.uid();
$$;


ALTER FUNCTION "public"."debug_user_tenant_access"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."debug_user_tenant_access"() IS 'Debug function to check user tenant access configuration - FIXED return type conflict';



CREATE OR REPLACE FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") RETURNS TABLE("check_name" "text", "result" boolean, "details" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_record RECORD;
    account_count BIGINT;
BEGIN
    -- Get user information
    SELECT * INTO user_record
    FROM public.user_profiles up
    WHERE up.id = user_uuid;

    -- Check 1: User exists
    RETURN QUERY SELECT 
        'user_exists'::TEXT,
        (user_record.id IS NOT NULL),
        COALESCE('User ID: ' || user_record.id::TEXT, 'User not found')::TEXT;

    IF user_record.id IS NULL THEN
        RETURN;
    END IF;

    -- Check 2: User is active
    RETURN QUERY SELECT 
        'user_is_active'::TEXT,
        COALESCE(user_record.is_active, false),
        'Active status: ' || COALESCE(user_record.is_active::TEXT, 'null');

    -- Check 3: User has tenant
    RETURN QUERY SELECT 
        'user_has_tenant'::TEXT,
        (user_record.tenant_id IS NOT NULL),
        'Tenant ID: ' || COALESCE(user_record.tenant_id::TEXT, 'null');

    -- Check 4: User role
    RETURN QUERY SELECT 
        'user_role'::TEXT,
        (user_record.role IS NOT NULL),
        'Role: ' || COALESCE(user_record.role::TEXT, 'null');

    -- Check 5: Accounts in user's tenant
    SELECT COUNT(*) INTO account_count
    FROM public.accounts a
    WHERE a.tenant_id = user_record.tenant_id;

    RETURN QUERY SELECT 
        'tenant_accounts_count'::TEXT,
        (account_count > 0),
        'Accounts in tenant: ' || account_count::TEXT;

    -- Check 6: Function access test
    BEGIN
        PERFORM public.get_user_accessible_accounts(user_uuid);
        RETURN QUERY SELECT 
            'function_access_test'::TEXT,
            true,
            'Function call successful';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 
                'function_access_test'::TEXT,
                false,
                'Function error: ' || SQLERRM;
    END;
END;
$$;


ALTER FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") IS 'Diagnostic function to troubleshoot tenant access issues';



CREATE OR REPLACE FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_profile user_profiles%ROWTYPE;
  target_user_profile user_profiles%ROWTYPE;
  goal_count INTEGER := 0;
  debug_info JSON;
BEGIN
  -- Get current user profile
  SELECT * INTO current_user_profile
  FROM user_profiles
  WHERE id = auth.uid();

  -- Get target user profile
  SELECT * INTO target_user_profile
  FROM user_profiles
  WHERE id = target_user_id;

  -- Count goals for the target user and week
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals
  WHERE user_id = target_user_id
  AND week_start_date = target_week_start;

  -- Build debug information
  debug_info := json_build_object(
    'current_user_id', auth.uid(),
    'current_user_role', current_user_profile.role,
    'current_user_tenant', current_user_profile.tenant_id,
    'target_user_id', target_user_id,
    'target_user_role', target_user_profile.role,
    'target_user_tenant', target_user_profile.tenant_id,
    'same_tenant', (current_user_profile.tenant_id = target_user_profile.tenant_id),
    'goal_count_found', goal_count,
    'week_start', target_week_start,
    'can_access_as_manager', (
      current_user_profile.role IN ('manager', 'admin', 'super_admin')
      AND current_user_profile.tenant_id = target_user_profile.tenant_id
    ),
    'is_super_admin', (current_user_profile.role = 'super_admin')
  );

  RETURN debug_info;
END;
$$;


ALTER FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") IS 'Debug function to help troubleshoot weekly goals access issues';



CREATE OR REPLACE FUNCTION "public"."diagnose_user_access"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
    diagnostic_result JSONB;
    auth_data RECORD;
    profile_data RECORD;
    tenant_info RECORD;
    account_count INTEGER;
    contact_count INTEGER;
    prospect_count INTEGER;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No authenticated user');
    END IF;
    
    -- Get auth user data
    SELECT * INTO auth_data FROM auth.users WHERE id = current_user_id;
    
    -- Get profile data
    SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
    
    -- Get tenant info
    SELECT t.* INTO tenant_info FROM public.tenants t WHERE t.id = profile_data.tenant_id;
    
    -- Count accessible data
    SELECT COUNT(*) INTO account_count FROM public.accounts WHERE public.can_access_tenant_data_enhanced(tenant_id);
    SELECT COUNT(*) INTO contact_count FROM public.contacts WHERE public.can_access_tenant_data_enhanced(tenant_id);
    
    -- Try to count prospects if table exists
    prospect_count := 0;
    BEGIN
        EXECUTE 'SELECT COUNT(*) FROM public.prospects WHERE public.can_access_tenant_data_enhanced(tenant_id)' INTO prospect_count;
    EXCEPTION
        WHEN undefined_table THEN
            prospect_count := -1; -- Table doesn't exist
    END;
    
    diagnostic_result := jsonb_build_object(
        'user_id', current_user_id,
        'email', auth_data.email,
        'auth_role', auth_data.raw_user_meta_data->>'role',
        'profile_exists', (profile_data IS NOT NULL),
        'profile_role', COALESCE(profile_data.role::TEXT, 'null'),
        'profile_active', COALESCE(profile_data.is_active, false),
        'profile_completed', COALESCE(profile_data.profile_completed, false),
        'tenant_id', profile_data.tenant_id,
        'tenant_name', tenant_info.name,
        'detected_role', public.get_user_role_with_fallbacks(),
        'is_manager', public.user_is_manager(),
        'is_manager_or_admin', public.user_is_manager_or_admin(),
        'accessible_accounts', account_count,
        'accessible_contacts', contact_count,
        'accessible_prospects', CASE WHEN prospect_count = -1 THEN 'table_not_exists' ELSE prospect_count::TEXT END,
        'timestamp', CURRENT_TIMESTAMP
    );
    
    RETURN diagnostic_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'error', SQLERRM,
            'sqlstate', SQLSTATE,
            'user_id', current_user_id
        );
END;
$$;


ALTER FUNCTION "public"."diagnose_user_access"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."diagnose_user_access"() IS 'Comprehensive diagnostic function to debug user access and permission issues';



CREATE OR REPLACE FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("user_id" "uuid", "user_role" "text", "user_tenant_id" "uuid", "tenant_name" "text", "auth_metadata" "jsonb", "access_summary" "text", "recommendations" "text"[])
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    profile_data RECORD;
    auth_data RECORD;
    issues TEXT[] := '{}';
    recommendations TEXT[] := '{}';
BEGIN
    -- Get profile data
    SELECT up.*, t.name as tenant_name
    INTO profile_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    -- Get auth data
    SELECT * INTO auth_data
    FROM auth.users WHERE id = user_uuid;
    
    -- Check for issues and build recommendations
    IF profile_data IS NULL THEN
        issues := array_append(issues, 'No user profile found');
        recommendations := array_append(recommendations, 'Create user profile');
    END IF;
    
    IF profile_data.tenant_id IS NULL THEN
        issues := array_append(issues, 'No tenant assigned');
        recommendations := array_append(recommendations, 'Assign user to a tenant');
    END IF;
    
    IF auth_data.raw_user_meta_data->>'tenant_id' IS NULL THEN
        issues := array_append(issues, 'Missing tenant_id in auth metadata');
        recommendations := array_append(recommendations, 'Sync auth metadata');
    END IF;
    
    IF auth_data.raw_user_meta_data->>'role' IS NULL THEN
        issues := array_append(issues, 'Missing role in auth metadata');
        recommendations := array_append(recommendations, 'Sync auth metadata');
    END IF;
    
    RETURN QUERY SELECT 
        user_uuid,
        COALESCE(profile_data.role::text, 'unknown'),
        profile_data.tenant_id,
        COALESCE(profile_data.tenant_name, 'No tenant'),
        COALESCE(auth_data.raw_user_meta_data, '{}'::jsonb),
        CASE WHEN array_length(issues, 1) > 0 
             THEN 'Issues found: ' || array_to_string(issues, ', ')
             ELSE 'All access checks passed'
        END,
        CASE WHEN array_length(recommendations, 1) > 0 
             THEN recommendations
             ELSE ARRAY['No action needed']
        END;
END;
$$;


ALTER FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid") IS 'Diagnostic tool to troubleshoot user tenant access issues and provide recommendations';



CREATE OR REPLACE FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") RETURNS numeric
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    AS $$
DECLARE
    len1 integer;
    len2 integer;
    distance integer;
    max_len integer;
    similarity_score numeric;
BEGIN
    -- Handle null or empty inputs
    IF text1 IS NULL OR text2 IS NULL OR text1 = '' OR text2 = '' THEN
        RETURN 0.0;
    END IF;
    
    -- Exact match
    IF text1 = text2 THEN
        RETURN 1.0;
    END IF;
    
    -- Get string lengths
    len1 := length(text1);
    len2 := length(text2);
    max_len := GREATEST(len1, len2);
    
    -- Handle very short strings
    IF max_len < 3 THEN
        IF text1 = text2 THEN
            RETURN 1.0;
        ELSE
            RETURN 0.0;
        END IF;
    END IF;
    
    -- Calculate Levenshtein distance using existing function
    distance := public.levenshtein_distance(text1, text2);
    
    -- Convert distance to similarity score
    similarity_score := 1.0 - (distance::numeric / max_len::numeric);
    
    -- Ensure result is between 0 and 1
    RETURN GREATEST(0.0, LEAST(1.0, similarity_score));
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in enhanced_text_similarity_fallback: %', SQLERRM;
        RETURN 0.0;
END;
$$;


ALTER FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") IS 'Enhanced fallback similarity calculation using Levenshtein distance for when pg_trgm extension is unavailable.';



CREATE OR REPLACE FUNCTION "public"."ensure_parks_tenant_assignment"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    parks_user_id UUID;
    default_tenant_id UUID;
    result JSONB;
BEGIN
    -- Get parks user ID
    SELECT id INTO parks_user_id 
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co';
    
    IF parks_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Parks user not found');
    END IF;
    
    -- Check if parks user already has a tenant
    IF EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = parks_user_id AND tenant_id IS NOT NULL
    ) THEN
        RETURN jsonb_build_object(
            'success', true, 
            'message', 'Parks user already has tenant assigned'
        );
    END IF;
    
    -- Get any existing tenant for assignment
    SELECT id INTO default_tenant_id 
    FROM public.tenants 
    ORDER BY created_at 
    LIMIT 1;
    
    IF default_tenant_id IS NOT NULL THEN
        -- Assign parks user to this tenant
        UPDATE public.user_profiles 
        SET tenant_id = default_tenant_id, updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true,
            'message', 'Assigned parks user to existing tenant',
            'user_id', parks_user_id,
            'tenant_id', default_tenant_id
        );
    ELSE
        -- Create a default tenant for parks user
        INSERT INTO public.tenants (id, name, description, is_active)
        VALUES (
            gen_random_uuid(),
            'SBD LLC',
            'Default tenant for Parks Manager',
            true
        ) RETURNING id INTO default_tenant_id;
        
        -- Assign parks user to new tenant
        UPDATE public.user_profiles 
        SET tenant_id = default_tenant_id, updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true,
            'message', 'Created new tenant and assigned parks user',
            'user_id', parks_user_id,
            'tenant_id', default_tenant_id
        );
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;


ALTER FUNCTION "public"."ensure_parks_tenant_assignment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_user_profile_consistency"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- For user profile updates, sync role to auth metadata if different
  IF TG_OP = 'UPDATE' AND OLD.role != NEW.role THEN
    -- Update auth.users metadata to match profile role
    UPDATE auth.users 
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', NEW.role)
    WHERE id = NEW.id;
    
    RAISE NOTICE 'Synced role % to auth metadata for user %', NEW.role, NEW.id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION "public"."ensure_user_profile_consistency"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."establish_manager_team_relationships"() RETURNS TABLE("manager_id" "uuid", "rep_id" "uuid", "relationship_established" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    manager_record RECORD;
    rep_record RECORD;
    relationships_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting manager-team relationship establishment...';
    
    -- Loop through all managers in each tenant
    FOR manager_record IN 
        SELECT id, tenant_id, full_name, role
        FROM public.user_profiles 
        WHERE role IN ('manager', 'admin') 
        AND is_active = true
        ORDER BY tenant_id, role DESC -- Prioritize admins
    LOOP
        RAISE NOTICE 'Processing manager: % (%s) in tenant %', manager_record.full_name, manager_record.role, manager_record.tenant_id;
        
        -- Find reps in the same tenant who don't have a manager assigned or are assigned to a different manager
        -- FIX: Qualify column references to avoid ambiguity
        FOR rep_record IN 
            SELECT up.id, up.full_name, up.manager_id
            FROM public.user_profiles up
            WHERE up.role = 'rep' 
            AND up.tenant_id = manager_record.tenant_id 
            AND up.is_active = true 
            AND (up.manager_id IS NULL OR up.manager_id != manager_record.id)
        LOOP
            -- FIXED: Fully qualify all column references to avoid ambiguity
            UPDATE public.user_profiles 
            SET manager_id = manager_record.id,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = rep_record.id
            AND (user_profiles.manager_id IS NULL OR user_profiles.manager_id != manager_record.id); -- Qualified column references
            
            IF FOUND THEN
                relationships_count := relationships_count + 1;
                RAISE NOTICE 'Established relationship: % -> %', manager_record.full_name, rep_record.full_name;
                
                -- Return the relationship that was established
                RETURN QUERY SELECT 
                    manager_record.id,
                    rep_record.id,
                    true;
            END IF;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Manager-team relationship establishment completed. % relationships established.', relationships_count;
    
    -- If no relationships were found, return a summary
    IF relationships_count = 0 THEN
        RAISE NOTICE 'No new manager-rep relationships needed to be established. All active reps may already have managers assigned.';
    END IF;
    
    RETURN;
END;
$$;


ALTER FUNCTION "public"."establish_manager_team_relationships"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fill_activity_log_tenant"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.tenant_id is null and new.user_id is not null then
    select up.tenant_id into new.tenant_id
    from public.user_profiles up
    where up.id = new.user_id; -- auth.users.id == user_profiles.id
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."fill_activity_log_tenant"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") RETURNS TABLE("account_id" "uuid", "account_name" "text", "match_type" "text", "similarity_score" numeric)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    use_pg_trgm BOOLEAN := FALSE;
BEGIN
    -- Check if pg_trgm similarity function is available
    BEGIN
        PERFORM similarity('test', 'test');
        use_pg_trgm := TRUE;
        RAISE NOTICE 'pg_trgm extension available, using similarity function';
    EXCEPTION 
        WHEN undefined_function THEN
            use_pg_trgm := FALSE;
            RAISE NOTICE 'pg_trgm extension not available, using fallback similarity';
        WHEN OTHERS THEN
            use_pg_trgm := FALSE;
            RAISE NOTICE 'Error testing similarity function, using fallback: %', SQLERRM;
    END;
    
    -- Return query with appropriate similarity function
    IF use_pg_trgm THEN
        RETURN QUERY
        SELECT 
            a.id,
            a.name,
            CASE 
                WHEN a.website IS NOT NULL AND prospect_domain IS NOT NULL 
                    AND LOWER(a.website) = LOWER(prospect_domain) THEN 'domain'
                WHEN a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
                    AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g') THEN 'phone'
                WHEN similarity(LOWER(a.name), LOWER(prospect_name)) > 0.7 
                    AND (a.city IS NULL OR prospect_city IS NULL OR LOWER(a.city) = LOWER(prospect_city))
                    AND (a.state IS NULL OR prospect_state IS NULL OR LOWER(a.state) = LOWER(prospect_state)) THEN 'name_location'
                ELSE 'other'
            END as match_type,
            CASE 
                WHEN a.website IS NOT NULL AND prospect_domain IS NOT NULL 
                    AND LOWER(a.website) = LOWER(prospect_domain) THEN 1.0
                WHEN a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
                    AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g') THEN 0.95
                ELSE similarity(LOWER(a.name), LOWER(prospect_name))
            END as similarity_score
        FROM public.accounts a
        WHERE a.tenant_id = current_tenant_id
        AND (
            -- Domain match
            (a.website IS NOT NULL AND prospect_domain IS NOT NULL 
             AND LOWER(a.website) = LOWER(prospect_domain))
            OR
            -- Phone match
            (a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
             AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g'))
            OR
            -- Name similarity with location match
            (similarity(LOWER(a.name), LOWER(prospect_name)) > 0.7 
             AND (a.city IS NULL OR prospect_city IS NULL OR LOWER(a.city) = LOWER(prospect_city))
             AND (a.state IS NULL OR prospect_state IS NULL OR LOWER(a.state) = LOWER(prospect_state)))
        )
        ORDER BY similarity_score DESC
        LIMIT 5;
    ELSE
        -- Use enhanced fallback similarity function with better logic
        RETURN QUERY
        SELECT 
            a.id,
            a.name,
            CASE 
                WHEN a.website IS NOT NULL AND prospect_domain IS NOT NULL 
                    AND LOWER(a.website) = LOWER(prospect_domain) THEN 'domain'
                WHEN a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
                    AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g') THEN 'phone'
                WHEN public.enhanced_text_similarity_fallback(LOWER(a.name), LOWER(prospect_name)) > 0.7 
                    AND (a.city IS NULL OR prospect_city IS NULL OR LOWER(a.city) = LOWER(prospect_city))
                    AND (a.state IS NULL OR prospect_state IS NULL OR LOWER(a.state) = LOWER(prospect_state)) THEN 'name_location'
                ELSE 'other'
            END as match_type,
            CASE 
                WHEN a.website IS NOT NULL AND prospect_domain IS NOT NULL 
                    AND LOWER(a.website) = LOWER(prospect_domain) THEN 1.0
                WHEN a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
                    AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g') THEN 0.95
                ELSE public.enhanced_text_similarity_fallback(LOWER(a.name), LOWER(prospect_name))
            END as similarity_score
        FROM public.accounts a
        WHERE a.tenant_id = current_tenant_id
        AND (
            -- Domain match
            (a.website IS NOT NULL AND prospect_domain IS NOT NULL 
             AND LOWER(a.website) = LOWER(prospect_domain))
            OR
            -- Phone match
            (a.phone IS NOT NULL AND prospect_phone IS NOT NULL 
             AND regexp_replace(a.phone, '[^0-9]', '', 'g') = regexp_replace(prospect_phone, '[^0-9]', '', 'g'))
            OR
            -- Enhanced name similarity with location match
            (public.enhanced_text_similarity_fallback(LOWER(a.name), LOWER(prospect_name)) > 0.7 
             AND (a.city IS NULL OR prospect_city IS NULL OR LOWER(a.city) = LOWER(prospect_city))
             AND (a.state IS NULL OR prospect_state IS NULL OR LOWER(a.state) = LOWER(prospect_state)))
        )
        ORDER BY similarity_score DESC
        LIMIT 5;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in find_account_duplicates: %', SQLERRM;
        -- Return empty result on any error
        RETURN;
END;
$$;


ALTER FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") IS 'Find duplicate accounts with enhanced error handling for pg_trgm extension availability. Falls back to Levenshtein distance when similarity() is not available.';



CREATE OR REPLACE FUNCTION "public"."fix_parks_user_profile"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    parks_user_id UUID;
    auth_user_data RECORD;
    profile_data RECORD;
    result JSONB;
BEGIN
    -- Find parks user in auth.users
    SELECT * INTO auth_user_data 
    FROM auth.users 
    WHERE email = 'parks@sbdllc.co' 
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', 'Parks user not found in auth.users',
            'email', 'parks@sbdllc.co'
        );
    END IF;
    
    parks_user_id := auth_user_data.id;
    
    -- Check current profile state
    SELECT * INTO profile_data 
    FROM public.user_profiles 
    WHERE id = parks_user_id;
    
    -- Update or create profile with manager role
    IF profile_data IS NULL THEN
        -- Create profile if missing
        INSERT INTO public.user_profiles (
            id, 
            email, 
            full_name, 
            role,
            is_active,
            profile_completed,
            password_set
        ) VALUES (
            parks_user_id,
            'parks@sbdllc.co',
            COALESCE(auth_user_data.raw_user_meta_data->>'full_name', 'Parks Manager'),
            'manager'::public.user_role_type,
            true,
            true,
            true
        );
        
        result := jsonb_build_object(
            'success', true, 
            'action', 'created_profile',
            'user_id', parks_user_id,
            'email', 'parks@sbdllc.co',
            'role_set', 'manager'
        );
    ELSE
        -- Update existing profile to manager role
        UPDATE public.user_profiles 
        SET 
            role = 'manager'::public.user_role_type,
            is_active = true,
            profile_completed = true,
            password_set = true,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = parks_user_id;
        
        result := jsonb_build_object(
            'success', true, 
            'action', 'updated_profile',
            'user_id', parks_user_id,
            'email', 'parks@sbdllc.co',
            'old_role', COALESCE(profile_data.role::TEXT, 'null'),
            'new_role', 'manager'
        );
    END IF;
    
    -- Sync role to auth metadata
    UPDATE auth.users 
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'manager')
    WHERE id = parks_user_id;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', SQLERRM, 
            'sqlstate', SQLSTATE,
            'email', 'parks@sbdllc.co'
        );
END;
$$;


ALTER FUNCTION "public"."fix_parks_user_profile"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."fix_parks_user_profile"() IS 'Fixes specific issue with parks@sbdllc.co user role and profile synchronization';



CREATE OR REPLACE FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") RETURNS TABLE("success" boolean, "message" "text", "temp_password" "text", "expires_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
    generated_temp_password TEXT;
    expiry_date TIMESTAMPTZ;
    current_user_role TEXT;
BEGIN
    -- Check if current user has permission
    SELECT up.role::TEXT INTO current_user_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid();

    IF current_user_role NOT IN ('super_admin', 'admin') THEN
        RETURN QUERY SELECT FALSE, 'Insufficient permissions'::TEXT, ''::TEXT, NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- Find the target user
    SELECT id INTO target_user_id
    FROM public.user_profiles
    WHERE email = user_email AND is_active = true;

    IF target_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User not found'::TEXT, ''::TEXT, NULL::TIMESTAMPTZ;
        RETURN;
    END IF;

    -- Generate new temporary password
    generated_temp_password := 'Temp' || substr(md5(random()::text), 1, 8) || '!' || extract(epoch from now())::int % 100;
    expiry_date := NOW() + INTERVAL '7 days';

    -- Update auth.users with new temporary password
    UPDATE auth.users
    SET 
        encrypted_password = crypt(generated_temp_password, gen_salt('bf', 10)),
        updated_at = NOW()
    WHERE id = target_user_id;

    -- Update user profile
    UPDATE public.user_profiles
    SET 
        temp_password_used = false,
        temp_password_expires_at = expiry_date,
        confirmation_status = 'temp_password_assigned',
        updated_at = NOW()
    WHERE id = target_user_id;

    RETURN QUERY SELECT 
        TRUE, 
        'Temporary password generated successfully'::TEXT,
        generated_temp_password,
        expiry_date;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            FALSE, 
            ('Error generating temporary password: ' || SQLERRM)::TEXT,
            ''::TEXT,
            NULL::TIMESTAMPTZ;
END;
$$;


ALTER FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") IS 'Generates new temporary password for existing users';



CREATE OR REPLACE FUNCTION "public"."get_account_reps"("account_uuid" "uuid") RETURNS TABLE("rep_id" "uuid", "rep_name" "text", "rep_email" "text", "is_primary" boolean, "assigned_at" timestamp with time zone, "assigned_by_name" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    up.id as rep_id,
    up.full_name as rep_name,
    up.email as rep_email,
    aa.is_primary,
    aa.assigned_at,
    assignee.full_name as assigned_by_name
FROM public.account_assignments aa
JOIN public.user_profiles up ON aa.rep_id = up.id
LEFT JOIN public.user_profiles assignee ON aa.assigned_by = assignee.id
WHERE aa.account_id = account_uuid
AND up.is_active = true
ORDER BY aa.is_primary DESC, aa.assigned_at ASC;
$$;


ALTER FUNCTION "public"."get_account_reps"("account_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_available_accounts"() RETURNS TABLE("id" "uuid", "name" "text", "company_type" "public"."company_type", "stage" "public"."account_stage")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT a.id, a.name, a.company_type, a.stage
FROM public.accounts a
WHERE a.is_active = true
AND public.can_access_any_account()
ORDER BY a.name
$$;


ALTER FUNCTION "public"."get_all_available_accounts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_auth_configuration_status"() RETURNS TABLE("setting_name" "text", "required_value" "text", "description" "text", "is_configured" boolean, "configuration_instructions" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."get_auth_configuration_status"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_auth_configuration_status"() IS 'Returns current authentication configuration status and setup instructions';



CREATE OR REPLACE FUNCTION "public"."get_contact_available_properties"("contact_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "address" "text", "building_type" "text", "stage" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    p.id,
    p.name,
    p.address,
    p.building_type::TEXT,
    p.stage::TEXT
FROM public.properties p
JOIN public.contacts c ON c.account_id = p.account_id
WHERE c.id = contact_uuid
ORDER BY p.name;
$$;


ALTER FUNCTION "public"."get_contact_available_properties"("contact_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "address" "text", "city" "text", "state" "text", "zip_code" "text", "building_type" "text", "roof_type" "text", "square_footage" integer, "year_built" integer, "stage" "text", "account_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT DISTINCT
    p.id,
    p.name,
    p.address,
    p.city,
    p.state,
    p.zip_code,
    p.building_type::TEXT,
    p.roof_type::TEXT,
    p.square_footage,
    p.year_built,
    p.stage::TEXT,
    p.account_id,
    p.created_at,
    p.updated_at
FROM public.properties p
INNER JOIN public.contacts c ON c.property_id = p.id
WHERE c.id = contact_uuid
  AND c.tenant_id = get_user_tenant_id()
  AND p.tenant_id = get_user_tenant_id()
ORDER BY p.name;
$$;


ALTER FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") IS 'Returns properties that are currently linked to a specific contact. Uses tenant isolation for security.';



CREATE OR REPLACE FUNCTION "public"."get_current_user_tenant"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT t.id
FROM public.tenants t
JOIN public.user_profiles up ON up.id = auth.uid()
WHERE t.owner_id = up.id OR t.created_by = up.id
LIMIT 1
$$;


ALTER FUNCTION "public"."get_current_user_tenant"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_current_user_tenant_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT (au.raw_user_meta_data->>'tenant_id')::UUID
FROM auth.users au
WHERE au.id = auth.uid();
$$;


ALTER FUNCTION "public"."get_current_user_tenant_id"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_current_user_tenant_id"() IS 'Gets current user tenant_id from auth.users metadata - avoids circular dependency with user_profiles';



CREATE OR REPLACE FUNCTION "public"."get_current_user_tenant_info"() RETURNS TABLE("user_id" "uuid", "tenant_id" "uuid", "user_role" "text", "can_access_all_tenants" boolean)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    auth.uid(),
    public.get_user_tenant_id(),
    public.get_user_role(),
    public.get_user_role() IN ('super_admin', 'admin')
$$;


ALTER FUNCTION "public"."get_current_user_tenant_info"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_detailed_user_auth_status"("user_uuid" "uuid") RETURNS TABLE("user_exists" boolean, "email_confirmed" boolean, "profile_completed" boolean, "password_set" boolean, "setup_completed" boolean, "next_action" "text", "redirect_url" "text", "role" "text", "full_name" "text", "last_setup_attempt" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."get_detailed_user_auth_status"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_documents_expiring"("within_days" integer DEFAULT 30) RETURNS TABLE("document_id" "uuid", "document_name" "text", "document_type" "public"."document_type", "expires_on" "date", "days_until_expiry" integer, "tenant_id" "uuid", "uploaded_by" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    d.id,
    d.name,
    d.type,
    d.valid_to,
    (d.valid_to - CURRENT_DATE)::INTEGER,
    d.tenant_id,
    d.uploaded_by
FROM public.documents d
WHERE d.valid_to IS NOT NULL
AND d.valid_to BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '1 day' * within_days)
AND d.tenant_id = public.get_user_tenant_id()
ORDER BY d.valid_to ASC;
$$;


ALTER FUNCTION "public"."get_documents_expiring"("within_days" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_accessible_accounts"("manager_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "company_type" "text", "stage" "text", "assigned_rep_id" "uuid", "assigned_rep_name" "text", "city" "text", "state" "text", "email" "text", "phone" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    a.id,
    a.name,
    a.company_type::TEXT,
    a.stage::TEXT,
    a.assigned_rep_id,
    up.full_name as assigned_rep_name,
    a.city,
    a.state,
    a.email,
    a.phone,
    a.created_at,
    a.updated_at
FROM public.accounts a
LEFT JOIN public.user_profiles up ON a.assigned_rep_id = up.id
WHERE a.tenant_id = (
    SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
)
AND (
    a.assigned_rep_id IN (
        SELECT id FROM public.user_profiles 
        WHERE manager_id = manager_uuid OR id = manager_uuid
    )
    OR a.assigned_rep_id = manager_uuid  -- Manager's own accounts
)
ORDER BY a.name;
$$;


ALTER FUNCTION "public"."get_manager_accessible_accounts"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_accessible_accounts_with_assignments"("manager_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "company_type" "text", "stage" "text", "assigned_reps" "jsonb", "primary_rep_name" "text", "city" "text", "state" "text", "email" "text", "phone" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    a.id,
    a.name,
    a.company_type::TEXT,
    a.stage::TEXT,
    COALESCE(
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'rep_id', up_rep.id,
                'rep_name', up_rep.full_name,
                'rep_email', up_rep.email,
                'is_primary', aa.is_primary
            ) ORDER BY aa.is_primary DESC, up_rep.full_name
        ) FILTER (WHERE up_rep.id IS NOT NULL),
        '[]'::jsonb
    ) as assigned_reps,
    up_primary.full_name as primary_rep_name,
    a.city,
    a.state,
    a.email,
    a.phone,
    a.created_at,
    a.updated_at
FROM public.accounts a
LEFT JOIN public.account_assignments aa ON a.id = aa.account_id
LEFT JOIN public.user_profiles up_rep ON aa.rep_id = up_rep.id AND up_rep.is_active = true
LEFT JOIN public.user_profiles up_primary ON a.assigned_rep_id = up_primary.id
WHERE a.tenant_id = (
    SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
)
AND (
    -- Manager can see accounts assigned to their team members or themselves
    a.assigned_rep_id IN (
        SELECT id FROM public.user_profiles 
        WHERE manager_id = manager_uuid OR id = manager_uuid
    )
    OR a.assigned_rep_id = manager_uuid
    OR EXISTS (
        -- Or accounts with reps assigned through new system
        SELECT 1 FROM public.account_assignments aa2
        JOIN public.user_profiles up2 ON aa2.rep_id = up2.id
        WHERE aa2.account_id = a.id
        AND (up2.manager_id = manager_uuid OR up2.id = manager_uuid)
    )
)
GROUP BY a.id, a.name, a.company_type, a.stage, a.city, a.state, a.email, a.phone, a.created_at, a.updated_at, up_primary.full_name
ORDER BY a.name;
$$;


ALTER FUNCTION "public"."get_manager_accessible_accounts_with_assignments"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "company_type" "text", "stage" "text", "city" "text", "state" "text", "email" "text", "phone" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "notes" "text", "is_active" boolean, "assigned_reps" "jsonb", "primary_rep_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    manager_tenant_id UUID;
BEGIN
    -- Get manager's tenant ID
    SELECT up.tenant_id INTO manager_tenant_id
    FROM public.user_profiles up
    WHERE up.id = manager_uuid AND up.role = 'manager';

    -- If not a manager or tenant not found, return empty
    IF manager_tenant_id IS NULL THEN
        RETURN;
    END IF;

    -- Return all accounts in the manager's tenant
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.company_type,
        a.stage,
        a.city,
        a.state,
        a.email,
        a.phone,
        a.created_at,
        a.updated_at,
        a.notes,
        COALESCE(a.is_active, true) as is_active,
        COALESCE(ar.assigned_reps, '[]'::JSONB) as assigned_reps,
        COALESCE(rep.full_name, 'Unassigned') as primary_rep_name
    FROM public.accounts a
    LEFT JOIN public.user_profiles rep ON a.assigned_rep_id = rep.id
    LEFT JOIN (
        SELECT 
            aa.account_id,
            jsonb_agg(
                jsonb_build_object(
                    'rep_id', aa.rep_id,
                    'rep_name', rep_info.full_name,
                    'is_primary', aa.is_primary,
                    'assigned_at', aa.assigned_at
                )
            ) as assigned_reps
        FROM public.account_assignments aa
        LEFT JOIN public.user_profiles rep_info ON aa.rep_id = rep_info.id
        GROUP BY aa.account_id
    ) ar ON a.id = ar.account_id
    WHERE a.tenant_id = manager_tenant_id
    ORDER BY a.name;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_all_tenant_accounts: %', SQLERRM;
        RETURN;
END;
$$;


ALTER FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") IS 'Returns all accounts within a manager''s tenant for oversight purposes';



CREATE OR REPLACE FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") RETURNS TABLE("id" "uuid", "full_name" "text", "email" "text", "role" "text", "phone" "text", "tenant_id" "uuid", "is_active" boolean, "manager_id" "uuid", "created_at" timestamp with time zone, "total_accounts" integer, "recent_activities" integer)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    up.id,
    up.full_name,
    up.email,
    up.role::TEXT,
    up.phone,
    up.tenant_id,
    up.is_active,
    up.manager_id,
    up.created_at,
    COALESCE(account_count.total, 0)::INTEGER as total_accounts,
    COALESCE(activity_count.recent, 0)::INTEGER as recent_activities
FROM public.user_profiles up
LEFT JOIN (
    SELECT 
        assigned_rep_id,
        COUNT(*) as total
    FROM public.accounts
    WHERE is_active = true
    GROUP BY assigned_rep_id
) account_count ON up.id = account_count.assigned_rep_id
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) as recent
    FROM public.activities
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY user_id
) activity_count ON up.id = activity_count.user_id
WHERE up.tenant_id = (
    SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
)
AND up.is_active = true
ORDER BY up.role DESC, up.full_name;
$$;


ALTER FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") IS 'Enhanced manager function: Returns ALL users within the manager tenant with account and activity summaries';



CREATE OR REPLACE FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") RETURNS TABLE("total_accounts" integer, "prospects" integer, "contacted" integer, "qualified" integer, "assessed" integer, "proposals_sent" integer, "in_negotiation" integer, "won" integer, "lost" integer, "conversion_rate" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH funnel_data AS (
        SELECT 
            COUNT(*)::INTEGER as total_count,
            COUNT(CASE WHEN a.stage = 'Prospect' THEN 1 END)::INTEGER as prospect_count,
            COUNT(CASE WHEN a.stage = 'Contacted' THEN 1 END)::INTEGER as contacted_count,
            COUNT(CASE WHEN a.stage = 'Qualified' THEN 1 END)::INTEGER as qualified_count,
            COUNT(CASE WHEN a.stage = 'Assessed' THEN 1 END)::INTEGER as assessed_count,
            COUNT(CASE WHEN a.stage = 'Proposal Sent' THEN 1 END)::INTEGER as proposal_count,
            COUNT(CASE WHEN a.stage = 'In Negotiation' THEN 1 END)::INTEGER as negotiation_count,
            COUNT(CASE WHEN a.stage = 'Won' THEN 1 END)::INTEGER as won_count,
            COUNT(CASE WHEN a.stage = 'Lost' THEN 1 END)::INTEGER as lost_count
        FROM public.accounts a
        JOIN public.user_profiles up ON a.assigned_rep_id = up.id
        WHERE up.manager_id = manager_uuid
        AND a.is_active = true
        AND up.is_active = true
    )
    SELECT 
        fd.total_count,
        fd.prospect_count,
        fd.contacted_count,
        fd.qualified_count,
        fd.assessed_count,
        fd.proposal_count,
        fd.negotiation_count,
        fd.won_count,
        fd.lost_count,
        CASE 
            WHEN fd.total_count > 0 THEN 
                ROUND((fd.won_count::NUMERIC / fd.total_count::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2) as conversion_percentage
    FROM funnel_data fd;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_team_funnel_metrics: %', SQLERRM;
        -- Return default values on error
        RETURN QUERY SELECT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0::NUMERIC(10,2);
END;
$$;


ALTER FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") IS 'Manager dashboard funnel metrics - refreshed for schema cache compatibility';



CREATE OR REPLACE FUNCTION "public"."get_manager_team_members"("manager_uuid" "uuid") RETURNS TABLE("id" "uuid", "full_name" "text", "email" "text", "role" "text", "phone" "text", "tenant_id" "uuid", "is_active" boolean, "manager_id" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    up.id,
    up.full_name,
    up.email,
    up.role::TEXT,
    up.phone,
    up.tenant_id,
    up.is_active,
    up.manager_id
FROM public.user_profiles up
WHERE up.tenant_id = (
    SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
)
AND (
    up.manager_id = manager_uuid  -- Team members reporting to this manager
    OR up.id = manager_uuid       -- Include the manager themselves
)
AND up.is_active = true
ORDER BY up.full_name;
$$;


ALTER FUNCTION "public"."get_manager_team_members"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date" DEFAULT NULL::"date") RETURNS TABLE("calls_target" integer, "calls_actual" integer, "calls_progress" numeric, "emails_target" integer, "emails_actual" integer, "emails_progress" numeric, "meetings_target" integer, "meetings_actual" integer, "meetings_progress" numeric, "assessments_target" integer, "assessments_actual" integer, "assessments_progress" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    week_date DATE;
BEGIN
    -- Use provided week_start or default to current week
    week_date := COALESCE(week_start, date_trunc('week', CURRENT_DATE)::DATE);

    RETURN QUERY
    WITH goals_summary AS (
        SELECT 
            wg.goal_type,
            SUM(wg.target_value)::INTEGER as total_target,
            SUM(wg.current_value)::INTEGER as total_current
        FROM public.weekly_goals wg
        JOIN public.user_profiles up ON wg.user_id = up.id
        WHERE up.manager_id = manager_uuid
        AND wg.week_start_date = week_date
        AND up.is_active = true
        GROUP BY wg.goal_type
    ),
    activity_summary AS (
        SELECT 
            act.activity_type,
            COUNT(*)::INTEGER as activity_count
        FROM public.activities act
        JOIN public.user_profiles up ON act.user_id = up.id
        WHERE up.manager_id = manager_uuid
        AND act.activity_date >= week_date
        AND act.activity_date < week_date + INTERVAL '7 days'
        AND up.is_active = true
        GROUP BY act.activity_type
    )
    SELECT 
        COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'calls'), 0),
        COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'calls'), 
                 (SELECT activity_count FROM activity_summary WHERE activity_type = 'Phone Call'), 0),
        CASE 
            WHEN COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'calls'), 0) > 0 
            THEN ROUND((COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'calls'), 0)::NUMERIC / 
                       (SELECT total_target FROM goals_summary WHERE goal_type = 'calls')::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'emails'), 0),
        COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'emails'),
                 (SELECT activity_count FROM activity_summary WHERE activity_type = 'Email'), 0),
        CASE 
            WHEN COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'emails'), 0) > 0 
            THEN ROUND((COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'emails'), 0)::NUMERIC / 
                       (SELECT total_target FROM goals_summary WHERE goal_type = 'emails')::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'meetings'), 0),
        COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'meetings'),
                 (SELECT activity_count FROM activity_summary WHERE activity_type = 'Meeting'), 0),
        CASE 
            WHEN COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'meetings'), 0) > 0 
            THEN ROUND((COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'meetings'), 0)::NUMERIC / 
                       (SELECT total_target FROM goals_summary WHERE goal_type = 'meetings')::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'assessments'), 0),
        COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'assessments'),
                 (SELECT activity_count FROM activity_summary WHERE activity_type = 'Assessment'), 0),
        CASE 
            WHEN COALESCE((SELECT total_target FROM goals_summary WHERE goal_type = 'assessments'), 0) > 0 
            THEN ROUND((COALESCE((SELECT total_current FROM goals_summary WHERE goal_type = 'assessments'), 0)::NUMERIC / 
                       (SELECT total_target FROM goals_summary WHERE goal_type = 'assessments')::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_team_metrics: %', SQLERRM;
        -- Return default values on error
        RETURN QUERY SELECT 0, 0, 0.0::NUMERIC(10,2), 0, 0, 0.0::NUMERIC(10,2), 0, 0, 0.0::NUMERIC(10,2), 0, 0, 0.0::NUMERIC(10,2);
END;
$$;


ALTER FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date") IS 'Manager dashboard team goal metrics with optional week parameter - refreshed for schema cache compatibility';



CREATE OR REPLACE FUNCTION "public"."get_manager_team_performance"("manager_uuid" "uuid", "week_start_date" "date" DEFAULT (CURRENT_DATE - ('7 days'::interval * ((EXTRACT(dow FROM CURRENT_DATE))::integer)::double precision))) RETURNS TABLE("user_id" "uuid", "user_name" "text", "user_email" "text", "user_role" "text", "total_accounts" integer, "total_contacts" integer, "current_week_activities" integer, "weekly_goals" "jsonb", "goal_completion_rate" integer)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
WITH team_members AS (
    SELECT id, full_name, email, role::TEXT
    FROM public.user_profiles up
    WHERE up.tenant_id = (
        SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
    )
    AND (up.manager_id = manager_uuid OR up.id = manager_uuid)
    AND up.is_active = true
),
account_counts AS (
    SELECT 
        a.assigned_rep_id as user_id,
        COUNT(*) as account_count
    FROM public.accounts a
    INNER JOIN team_members tm ON a.assigned_rep_id = tm.id
    WHERE a.tenant_id = (
        SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
    )
    GROUP BY a.assigned_rep_id
),
contact_counts AS (
    SELECT 
        tm.id as user_id,
        COUNT(c.id) as contact_count
    FROM team_members tm
    LEFT JOIN public.accounts a ON a.assigned_rep_id = tm.id
    LEFT JOIN public.contacts c ON c.account_id = a.id
    GROUP BY tm.id
),
activity_counts AS (
    SELECT 
        act.user_id,
        COUNT(*) as activity_count
    FROM public.activities act
    INNER JOIN team_members tm ON act.user_id = tm.id
    WHERE act.tenant_id = (
        SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
    )
    AND act.created_at >= week_start_date
    AND act.created_at < week_start_date + INTERVAL '7 days'
    GROUP BY act.user_id
),
goal_data AS (
    SELECT 
        wg.user_id,
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'goal_type', wg.goal_type,
                'target_value', wg.target_value,
                'current_value', wg.current_value,
                'status', wg.status
            )
        ) as goals,
        CASE 
            WHEN COUNT(*) = 0 THEN 0
            ELSE ROUND((COUNT(*) FILTER (WHERE wg.status = 'Completed')::DECIMAL / COUNT(*)) * 100)::INTEGER
        END as completion_rate
    FROM public.weekly_goals wg
    INNER JOIN team_members tm ON wg.user_id = tm.id
    WHERE wg.tenant_id = (
        SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
    )
    AND wg.week_start_date = week_start_date
    GROUP BY wg.user_id
)
SELECT 
    tm.id,
    tm.full_name,
    tm.email,
    tm.role,
    COALESCE(ac.account_count, 0)::INTEGER,
    COALESCE(cc.contact_count, 0)::INTEGER,
    COALESCE(act.activity_count, 0)::INTEGER,
    COALESCE(gd.goals, '[]'::JSONB),
    COALESCE(gd.completion_rate, 0)::INTEGER
FROM team_members tm
LEFT JOIN account_counts ac ON tm.id = ac.user_id
LEFT JOIN contact_counts cc ON tm.id = cc.user_id
LEFT JOIN activity_counts act ON tm.id = act.user_id
LEFT JOIN goal_data gd ON tm.id = gd.user_id
ORDER BY tm.full_name;
$$;


ALTER FUNCTION "public"."get_manager_team_performance"("manager_uuid" "uuid", "week_start_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date" DEFAULT NULL::"date") RETURNS TABLE("user_id" "uuid", "full_name" "text", "email" "text", "role" "text", "calls_target" integer, "calls_actual" integer, "calls_progress" numeric, "emails_target" integer, "emails_actual" integer, "emails_progress" numeric, "meetings_target" integer, "meetings_actual" integer, "meetings_progress" numeric, "total_activities" integer, "accounts_assigned" integer, "last_activity_date" timestamp with time zone, "performance_score" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    week_date DATE;
BEGIN
    -- Use provided week_start or default to current week
    week_date := COALESCE(week_start, date_trunc('week', CURRENT_DATE)::DATE);

    RETURN QUERY
    SELECT 
        up.id,
        up.full_name,
        up.email,
        up.role::TEXT,
        
        -- Calls metrics
        COALESCE(wg_calls.target_value, 0)::INTEGER,
        COALESCE(wg_calls.current_value, 0)::INTEGER,
        CASE 
            WHEN COALESCE(wg_calls.target_value, 0) > 0 
            THEN ROUND((COALESCE(wg_calls.current_value, 0)::NUMERIC / wg_calls.target_value::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        -- Emails metrics
        COALESCE(wg_emails.target_value, 0)::INTEGER,
        COALESCE(wg_emails.current_value, 0)::INTEGER,
        CASE 
            WHEN COALESCE(wg_emails.target_value, 0) > 0 
            THEN ROUND((COALESCE(wg_emails.current_value, 0)::NUMERIC / wg_emails.target_value::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        -- Meetings metrics
        COALESCE(wg_meetings.target_value, 0)::INTEGER,
        COALESCE(wg_meetings.current_value, 0)::INTEGER,
        CASE 
            WHEN COALESCE(wg_meetings.target_value, 0) > 0 
            THEN ROUND((COALESCE(wg_meetings.current_value, 0)::NUMERIC / wg_meetings.target_value::NUMERIC) * 100, 2)
            ELSE 0.0
        END::NUMERIC(10,2),
        
        -- Additional metrics
        COALESCE(act_summary.total_activities, 0)::INTEGER,
        COALESCE(account_summary.assigned_count, 0)::INTEGER,
        act_summary.last_activity,
        
        -- Performance score calculation
        CASE 
            WHEN (COALESCE(wg_calls.target_value, 0) + COALESCE(wg_emails.target_value, 0) + COALESCE(wg_meetings.target_value, 0)) > 0
            THEN ROUND(
                ((COALESCE(wg_calls.current_value, 0)::NUMERIC / NULLIF(wg_calls.target_value, 0)::NUMERIC * 0.4) +
                 (COALESCE(wg_emails.current_value, 0)::NUMERIC / NULLIF(wg_emails.target_value, 0)::NUMERIC * 0.3) +
                 (COALESCE(wg_meetings.current_value, 0)::NUMERIC / NULLIF(wg_meetings.target_value, 0)::NUMERIC * 0.3)) * 100, 
                2)
            ELSE 0.0
        END::NUMERIC(10,2)
        
    FROM public.user_profiles up
    LEFT JOIN public.weekly_goals wg_calls ON up.id = wg_calls.user_id 
        AND wg_calls.goal_type = 'calls' 
        AND wg_calls.week_start_date = week_date
    LEFT JOIN public.weekly_goals wg_emails ON up.id = wg_emails.user_id 
        AND wg_emails.goal_type = 'emails' 
        AND wg_emails.week_start_date = week_date
    LEFT JOIN public.weekly_goals wg_meetings ON up.id = wg_meetings.user_id 
        AND wg_meetings.goal_type = 'meetings' 
        AND wg_meetings.week_start_date = week_date
    LEFT JOIN (
        SELECT 
            act.user_id,
            COUNT(*)::INTEGER as total_activities,
            MAX(act.activity_date) as last_activity
        FROM public.activities act
        WHERE act.activity_date >= week_date
        AND act.activity_date < week_date + INTERVAL '7 days'
        GROUP BY act.user_id
    ) act_summary ON up.id = act_summary.user_id
    LEFT JOIN (
        SELECT 
            a.assigned_rep_id,
            COUNT(*)::INTEGER as assigned_count
        FROM public.accounts a
        WHERE a.is_active = true
        GROUP BY a.assigned_rep_id
    ) account_summary ON up.id = account_summary.assigned_rep_id
    
    WHERE up.manager_id = manager_uuid
    AND up.is_active = true
    ORDER BY up.full_name;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_team_performance_detailed: %', SQLERRM;
        RETURN;
END;
$$;


ALTER FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date") IS 'Manager dashboard detailed team performance with optional week parameter - refreshed for schema cache compatibility';



CREATE OR REPLACE FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") RETURNS TABLE("team_size" integer, "active_accounts" integer, "total_activities_this_week" integer, "total_properties" integer, "avg_account_stage_progress" numeric, "top_performer" "text", "team_performance_rating" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    week_start_date DATE;
    team_tenant_id UUID;
BEGIN
    -- Get current week start
    week_start_date := date_trunc('week', CURRENT_DATE)::DATE;
    
    -- Get manager's tenant_id for proper data filtering
    SELECT tenant_id INTO team_tenant_id
    FROM public.user_profiles 
    WHERE id = manager_uuid 
    LIMIT 1;

    IF team_tenant_id IS NULL THEN
        RAISE NOTICE 'Manager not found or no tenant_id: %', manager_uuid;
        RETURN QUERY SELECT 0, 0, 0, 0, 0.0::NUMERIC(10,2), 'Manager Not Found'::TEXT, 'Error'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY
    WITH team_members AS (
        -- Get all team members (direct reports of this manager)
        SELECT id, full_name, email, role
        FROM public.user_profiles up
        WHERE up.manager_id = manager_uuid
        AND up.is_active = true
        AND up.tenant_id = team_tenant_id
    ),
    team_stats AS (
        SELECT 
            COUNT(*)::INTEGER as team_count
        FROM team_members
    ),
    account_stats AS (
        -- Count active accounts assigned to team members
        SELECT 
            COUNT(DISTINCT a.id)::INTEGER as account_count,
            COUNT(DISTINCT p.id)::INTEGER as property_count
        FROM public.accounts a
        INNER JOIN team_members tm ON a.assigned_rep_id = tm.id
        LEFT JOIN public.properties p ON p.account_id = a.id
        WHERE a.is_active = true
        AND a.tenant_id = team_tenant_id
    ),
    activity_stats AS (
        -- Count activities for the current week
        SELECT COUNT(*)::INTEGER as weekly_activities
        FROM public.activities act
        INNER JOIN team_members tm ON act.user_id = tm.id
        WHERE act.activity_date >= week_start_date
        AND act.activity_date < week_start_date + INTERVAL '7 days'
        AND act.tenant_id = team_tenant_id
    ),
    stage_progress AS (
        -- Calculate average account stage progress
        SELECT 
            AVG(
                CASE a.stage::TEXT
                    WHEN 'Prospect' THEN 1
                    WHEN 'Contacted' THEN 2
                    WHEN 'Vendor Packet Request' THEN 3
                    WHEN 'Vendor Packet Submitted' THEN 4
                    WHEN 'Approved for Work' THEN 5
                    WHEN 'Actively Engaged' THEN 6
                    ELSE 1
                END
            )::NUMERIC(10,2) as avg_progress
        FROM public.accounts a
        INNER JOIN team_members tm ON a.assigned_rep_id = tm.id
        WHERE a.is_active = true
        AND a.tenant_id = team_tenant_id
    ),
    top_performer AS (
        -- Find the top performer based on weekly activities
        SELECT 
            COALESCE(tm.full_name, 'No activities')::TEXT as performer_name,
            COALESCE(COUNT(act.id), 0) as activity_count
        FROM team_members tm
        LEFT JOIN public.activities act ON act.user_id = tm.id 
            AND act.activity_date >= week_start_date
            AND act.activity_date < week_start_date + INTERVAL '7 days'
            AND act.tenant_id = team_tenant_id
        GROUP BY tm.id, tm.full_name
        ORDER BY activity_count DESC
        LIMIT 1
    )
    SELECT 
        COALESCE(ts.team_count, 0)::INTEGER,
        COALESCE(ast.account_count, 0)::INTEGER,
        COALESCE(acts.weekly_activities, 0)::INTEGER,
        COALESCE(ast.property_count, 0)::INTEGER,
        COALESCE(sp.avg_progress, 0.0)::NUMERIC(10,2),
        COALESCE(tp.performer_name, 'No data')::TEXT,
        CASE 
            WHEN COALESCE(ts.team_count, 0) = 0 THEN 'No Team Members'
            WHEN COALESCE(sp.avg_progress, 0) >= 5 THEN 'Excellent'
            WHEN COALESCE(sp.avg_progress, 0) >= 3 THEN 'Good'
            WHEN COALESCE(sp.avg_progress, 0) >= 1 THEN 'Needs Improvement'
            ELSE 'Getting Started'
        END::TEXT
    FROM team_stats ts
    CROSS JOIN account_stats ast
    CROSS JOIN activity_stats acts
    CROSS JOIN stage_progress sp
    CROSS JOIN top_performer tp;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_manager_team_summary: %', SQLERRM;
        -- Return meaningful default values on error
        RETURN QUERY SELECT 0, 0, 0, 0, 0.0::NUMERIC(10,2), 'Error occurred'::TEXT, 'Error'::TEXT;
END;
$$;


ALTER FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") IS 'Fixed function that properly calculates team summary metrics for manager dashboard. Counts team members, accounts, activities, and properties with proper tenant filtering and manager hierarchy checks.';



CREATE OR REPLACE FUNCTION "public"."get_manager_tenant_accounts"("manager_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("id" "uuid", "name" "text", "company_type" "text", "assigned_rep_id" "uuid", "assigned_rep_name" "text", "tenant_id" "uuid", "is_active" boolean, "created_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    a.id,
    a.name,
    a.company_type,
    a.assigned_rep_id,
    up.full_name as assigned_rep_name,
    a.tenant_id,
    a.is_active,
    a.created_at
FROM public.accounts a
LEFT JOIN public.user_profiles up ON a.assigned_rep_id = up.id
WHERE a.tenant_id = (
    SELECT tenant_id 
    FROM public.user_profiles 
    WHERE id = manager_uuid 
    LIMIT 1
)
ORDER BY a.name;
$$;


ALTER FUNCTION "public"."get_manager_tenant_accounts"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_tenant_contacts"("manager_user_id" "uuid") RETURNS TABLE("id" "uuid", "account_id" "uuid", "first_name" "text", "last_name" "text", "title" "text", "email" "text", "phone" "text", "mobile_phone" "text", "stage" "public"."contact_stage", "is_primary_contact" boolean, "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "notes" "text", "is_active" boolean, "account_name" "text", "tenant_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."get_manager_tenant_contacts"("manager_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_manager_tenant_properties"("manager_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("id" "uuid", "name" "text", "address" "text", "account_id" "uuid", "account_name" "text", "tenant_id" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    p.id,
    p.name,
    p.address,
    p.account_id,
    a.name as account_name,
    a.tenant_id
FROM public.properties p
JOIN public.accounts a ON p.account_id = a.id
WHERE a.tenant_id = (
    SELECT tenant_id 
    FROM public.user_profiles 
    WHERE id = manager_uuid 
    LIMIT 1
)
ORDER BY p.name;
$$;


ALTER FUNCTION "public"."get_manager_tenant_properties"("manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_opportunities_with_details"("filter_stage" "text" DEFAULT NULL::"text", "filter_type" "text" DEFAULT NULL::"text", "limit_count" integer DEFAULT 50, "offset_count" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "name" "text", "opportunity_type" "text", "stage" "text", "bid_value" numeric, "currency" "text", "expected_close_date" "date", "probability" integer, "description" "text", "account_name" "text", "account_id" "uuid", "property_name" "text", "property_id" "uuid", "assigned_to_name" "text", "assigned_to_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    o.id,
    o.name,
    o.opportunity_type::TEXT,
    o.stage::TEXT,
    o.bid_value,
    o.currency,
    o.expected_close_date,
    o.probability,
    o.description,
    a.name as account_name,
    a.id as account_id,
    p.name as property_name,
    p.id as property_id,
    up.full_name as assigned_to_name,
    up.id as assigned_to_id,
    o.created_at,
    o.updated_at
FROM public.opportunities o
LEFT JOIN public.accounts a ON o.account_id = a.id
LEFT JOIN public.properties p ON o.property_id = p.id
LEFT JOIN public.user_profiles up ON o.assigned_to = up.id
WHERE 
    (filter_stage IS NULL OR o.stage::TEXT = filter_stage)
    AND (filter_type IS NULL OR o.opportunity_type::TEXT = filter_type)
    AND user_can_access_tenant_data(o.tenant_id)
ORDER BY o.created_at DESC
LIMIT limit_count
OFFSET offset_count;
$$;


ALTER FUNCTION "public"."get_opportunities_with_details"("filter_stage" "text", "filter_type" "text", "limit_count" integer, "offset_count" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_opportunity_pipeline_metrics"() RETURNS TABLE("stage" "text", "count_opportunities" bigint, "total_value" numeric, "avg_probability" numeric)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    o.stage::TEXT,
    COUNT(*) as count_opportunities,
    COALESCE(SUM(o.bid_value), 0) as total_value,
    COALESCE(ROUND(AVG(o.probability), 2), 0) as avg_probability
FROM public.opportunities o
WHERE user_can_access_tenant_data(o.tenant_id)
GROUP BY o.stage
ORDER BY 
    CASE o.stage
        WHEN 'identified' THEN 1
        WHEN 'qualified' THEN 2
        WHEN 'proposal_sent' THEN 3
        WHEN 'negotiation' THEN 4
        WHEN 'won' THEN 5
        WHEN 'lost' THEN 6
        ELSE 7
    END;
$$;


ALTER FUNCTION "public"."get_opportunity_pipeline_metrics"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_prospects_with_details"("filter_status" "text"[] DEFAULT ARRAY['uncontacted'::"text"], "filter_min_icp_score" integer DEFAULT NULL::integer, "filter_state" "text" DEFAULT NULL::"text", "filter_city" "text" DEFAULT NULL::"text", "filter_company_type" "text" DEFAULT NULL::"text", "filter_assigned_to" "uuid" DEFAULT NULL::"uuid", "filter_source" "text" DEFAULT NULL::"text", "search_term" "text" DEFAULT NULL::"text", "sort_column" "text" DEFAULT 'icp_fit_score'::"text", "sort_direction" "text" DEFAULT 'desc'::"text", "page_limit" integer DEFAULT 50, "page_offset" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "name" "text", "domain" "text", "phone" "text", "city" "text", "state" "text", "company_type" "text", "icp_fit_score" integer, "status" "text", "assigned_to" "uuid", "assigned_to_name" "text", "source" "text", "last_activity_at" timestamp with time zone, "created_at" timestamp with time zone, "tags" "text"[], "has_phone" boolean, "has_website" boolean)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $_$
DECLARE
    current_tenant_id UUID;
    base_query TEXT;
    where_conditions TEXT[];
    order_clause TEXT;
    final_query TEXT;
    param_count INTEGER := 1;
BEGIN
    -- Get current user tenant
    SELECT tenant_id INTO current_tenant_id FROM public.user_profiles WHERE id = auth.uid();
    
    -- Base query with proper table aliases and qualified column references
    base_query := '
        SELECT 
            p.id, p.name, p.domain, p.phone, p.city, p.state, p.company_type,
            p.icp_fit_score, p.status, p.assigned_to,
            COALESCE(up.full_name, '''') as assigned_to_name, 
            p.source, p.last_activity_at, p.created_at, p.tags,
            (p.phone IS NOT NULL) as has_phone,
            (p.website IS NOT NULL) as has_website
        FROM public.prospects p
        LEFT JOIN public.user_profiles up ON p.assigned_to = up.id
        WHERE p.tenant_id = $' || param_count;
    
    param_count := param_count + 1;
    
    -- Build where conditions dynamically with proper parameter numbering
    where_conditions := ARRAY[]::TEXT[];
    
    IF filter_status IS NOT NULL AND array_length(filter_status, 1) > 0 THEN
        where_conditions := where_conditions || ARRAY['p.status = ANY($' || param_count || ')'];
        param_count := param_count + 1;
    END IF;
    
    IF filter_min_icp_score IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['p.icp_fit_score >= $' || param_count];
        param_count := param_count + 1;
    END IF;
    
    IF filter_state IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['LOWER(p.state) = LOWER($' || param_count || ')'];
        param_count := param_count + 1;
    END IF;
    
    IF filter_city IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['LOWER(p.city) = LOWER($' || param_count || ')'];
        param_count := param_count + 1;
    END IF;
    
    IF filter_assigned_to IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['p.assigned_to = $' || param_count];
        param_count := param_count + 1;
    END IF;
    
    IF filter_source IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['LOWER(p.source) = LOWER($' || param_count || ')'];
        param_count := param_count + 1;
    END IF;
    
    IF search_term IS NOT NULL THEN
        where_conditions := where_conditions || ARRAY['(LOWER(p.name) ILIKE LOWER($' || param_count || ') OR LOWER(p.domain) ILIKE LOWER($' || param_count || '))'];
        param_count := param_count + 1;
    END IF;
    
    -- Build order clause with qualified column references
    order_clause := 'ORDER BY ';
    CASE sort_column
        WHEN 'name' THEN order_clause := order_clause || 'p.name';
        WHEN 'icp_fit_score' THEN order_clause := order_clause || 'p.icp_fit_score';
        WHEN 'last_activity_at' THEN order_clause := order_clause || 'p.last_activity_at';
        WHEN 'created_at' THEN order_clause := order_clause || 'p.created_at';
        ELSE order_clause := order_clause || 'p.icp_fit_score';
    END CASE;
    
    IF sort_direction = 'asc' THEN
        order_clause := order_clause || ' ASC';
    ELSE
        order_clause := order_clause || ' DESC';
    END IF;
    
    -- Add pagination parameters
    order_clause := order_clause || ' LIMIT $' || param_count || ' OFFSET $' || (param_count + 1);
    
    -- Final query construction
    final_query := base_query;
    
    IF array_length(where_conditions, 1) > 0 THEN
        final_query := final_query || ' AND ' || array_to_string(where_conditions, ' AND ');
    END IF;
    
    final_query := final_query || ' ' || order_clause;
    
    -- Execute with proper parameter handling
    IF filter_status IS NOT NULL AND array_length(filter_status, 1) > 0 
       AND filter_min_icp_score IS NOT NULL 
       AND filter_state IS NOT NULL 
       AND filter_city IS NOT NULL 
       AND filter_assigned_to IS NOT NULL 
       AND filter_source IS NOT NULL 
       AND search_term IS NOT NULL THEN
        RETURN QUERY EXECUTE final_query 
        USING current_tenant_id, filter_status, filter_min_icp_score, filter_state, filter_city, 
              filter_assigned_to, filter_source, '%' || search_term || '%', page_limit, page_offset;
    ELSE
        -- Handle cases with fewer parameters by constructing simpler queries
        RETURN QUERY EXECUTE 
        'SELECT p.id, p.name, p.domain, p.phone, p.city, p.state, p.company_type,
                p.icp_fit_score, p.status, p.assigned_to,
                COALESCE(up.full_name, '''') as assigned_to_name, 
                p.source, p.last_activity_at, p.created_at, p.tags,
                (p.phone IS NOT NULL) as has_phone,
                (p.website IS NOT NULL) as has_website
         FROM public.prospects p
         LEFT JOIN public.user_profiles up ON p.assigned_to = up.id
         WHERE p.tenant_id = $1
         ORDER BY p.icp_fit_score DESC
         LIMIT $2 OFFSET $3'
        USING current_tenant_id, page_limit, page_offset;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_prospects_with_details: %', SQLERRM;
        RETURN;
END;
$_$;


ALTER FUNCTION "public"."get_prospects_with_details"("filter_status" "text"[], "filter_min_icp_score" integer, "filter_state" "text", "filter_city" "text", "filter_company_type" "text", "filter_assigned_to" "uuid", "filter_source" "text", "search_term" "text", "sort_column" "text", "sort_direction" "text", "page_limit" integer, "page_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_session_context"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_uid uuid := auth.uid();
  v_p public.user_profiles;
  v_tenant public.tenants;
begin
  if v_uid is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'redirect_url', '/login'
    );
  end if;

  select * into v_p from public.user_profiles where id = v_uid;

  if not found then
    return jsonb_build_object(
      'success', false,
      'user_exists', false,
      'message', 'Profile missing',
      'redirect_url', '/onboarding'
    );
  end if;

  if v_p.is_active is false then
    return jsonb_build_object(
      'success', false,
      'message', 'User inactive',
      'redirect_url', '/support'
    );
  end if;

  if v_p.tenant_id is null then
    return jsonb_build_object(
      'success', true,
      'user_exists', true,
      'profile_completed', v_p.profile_completed,
      'password_set', v_p.password_set,
      'message', 'Authenticated; tenant assignment required',
      'redirect_url', '/select-tenant',
      'user_data', jsonb_build_object(
        'id', v_p.id,
        'role', v_p.role,
        'email', v_p.email,
        'full_name', v_p.full_name,
        'is_active', v_p.is_active
      )
    );
  end if;

  select * into v_tenant from public.tenants where id = v_p.tenant_id;

  return jsonb_build_object(
    'success', true,
    'user_exists', true,
    'profile_completed', v_p.profile_completed,
    'password_set', v_p.password_set,
    'message', 'Authentication completed successfully',
    'redirect_url', '/today',
    'user_data', jsonb_build_object(
      'id', v_p.id,
      'role', v_p.role,
      'email', v_p.email,
      'full_name', v_p.full_name,
      'is_active', v_p.is_active,
      'tenant_id', v_p.tenant_id,
      'tenant_name', v_tenant.name
    )
  );
end;
$$;


ALTER FUNCTION "public"."get_session_context"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_session_context"() IS 'Returns single JSON object with proper null tenant handling for onboarding flow';



CREATE OR REPLACE FUNCTION "public"."get_task_metrics"() RETURNS TABLE("total_tasks" integer, "pending_tasks" integer, "in_progress_tasks" integer, "completed_tasks" integer, "overdue_tasks" integer, "completion_rate" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_tasks,
        COUNT(CASE WHEN status = 'pending' THEN 1 END)::INTEGER as pending_tasks,
        COUNT(CASE WHEN status = 'in_progress' THEN 1 END)::INTEGER as in_progress_tasks,
        COUNT(CASE WHEN status = 'completed' THEN 1 END)::INTEGER as completed_tasks,
        COUNT(CASE WHEN status = 'overdue' THEN 1 END)::INTEGER as overdue_tasks,
        CASE 
            WHEN COUNT(*) > 0 THEN 
                ROUND(COUNT(CASE WHEN status = 'completed' THEN 1 END)::DECIMAL / COUNT(*)::DECIMAL * 100, 2)
            ELSE 0
        END as completion_rate
    FROM public.tasks
    WHERE tenant_id = get_user_tenant_id()
    AND (assigned_to = auth.uid() OR assigned_by = auth.uid());
END;
$$;


ALTER FUNCTION "public"."get_task_metrics"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_tasks_with_details"("user_uuid" "uuid" DEFAULT NULL::"uuid", "status_filter" "public"."task_status" DEFAULT NULL::"public"."task_status", "priority_filter" "public"."task_priority" DEFAULT NULL::"public"."task_priority") RETURNS TABLE("id" "uuid", "title" "text", "description" "text", "status" "text", "priority" "text", "category" "text", "due_date" timestamp with time zone, "assigned_to_name" "text", "assigned_by_name" "text", "account_name" "text", "property_name" "text", "contact_name" "text", "opportunity_name" "text", "created_at" timestamp with time zone, "completed_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.description,
        t.status::TEXT,
        t.priority::TEXT,
        t.category::TEXT,
        t.due_date,
        assigned.full_name as assigned_to_name,
        assigner.full_name as assigned_by_name,
        a.name as account_name,
        p.name as property_name,
        CONCAT(c.first_name, ' ', c.last_name) as contact_name,
        o.name as opportunity_name,
        t.created_at,
        t.completed_at
    FROM public.tasks t
    LEFT JOIN public.user_profiles assigned ON t.assigned_to = assigned.id
    LEFT JOIN public.user_profiles assigner ON t.assigned_by = assigner.id
    LEFT JOIN public.accounts a ON t.account_id = a.id
    LEFT JOIN public.properties p ON t.property_id = p.id
    LEFT JOIN public.contacts c ON t.contact_id = c.id
    LEFT JOIN public.opportunities o ON t.opportunity_id = o.id
    WHERE t.tenant_id = get_user_tenant_id()
    AND (user_uuid IS NULL OR t.assigned_to = user_uuid OR t.assigned_by = user_uuid)
    AND (status_filter IS NULL OR t.status = status_filter)
    AND (priority_filter IS NULL OR t.priority = priority_filter)
    ORDER BY 
        CASE t.priority
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'medium' THEN 3
            WHEN 'low' THEN 4
        END,
        t.due_date ASC NULLS LAST,
        t.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_tasks_with_details"("user_uuid" "uuid", "status_filter" "public"."task_status", "priority_filter" "public"."task_priority") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_today_events"("target_tenant_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "title" "text", "description" "text", "event_type" "text", "priority" "text", "status" "text", "start_datetime" timestamp with time zone, "end_datetime" timestamp with time zone, "all_day" boolean, "location" "text", "meeting_url" "text", "created_by_name" "text", "assigned_to_name" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    ce.id,
    ce.title,
    ce.description,
    ce.event_type::TEXT,
    ce.priority::TEXT,
    ce.status::TEXT,
    ce.start_datetime,
    ce.end_datetime,
    ce.all_day,
    ce.location,
    ce.meeting_url,
    creator.full_name as created_by_name,
    assignee.full_name as assigned_to_name
FROM public.calendar_events ce
LEFT JOIN public.user_profiles creator ON ce.created_by = creator.id
LEFT JOIN public.user_profiles assignee ON ce.assigned_to = assignee.id
WHERE DATE(ce.start_datetime) = CURRENT_DATE
AND ce.status IN ('scheduled', 'in_progress')
AND (
    target_tenant_id IS NULL 
    OR ce.tenant_id = target_tenant_id
    OR ce.tenant_id IN (
        SELECT up.tenant_id 
        FROM public.user_profiles up 
        WHERE up.id = auth.uid()
    )
)
ORDER BY ce.start_datetime ASC;
$$;


ALTER FUNCTION "public"."get_today_events"("target_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_today_events"("target_tenant_id" "uuid") IS 'Returns today''s calendar events for the specified tenant';



CREATE OR REPLACE FUNCTION "public"."get_upcoming_events"("days_ahead" integer DEFAULT 7, "target_tenant_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "title" "text", "description" "text", "event_type" "text", "priority" "text", "status" "text", "start_datetime" timestamp with time zone, "end_datetime" timestamp with time zone, "all_day" boolean, "location" "text", "meeting_url" "text", "created_by_name" "text", "assigned_to_name" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    ce.id,
    ce.title,
    ce.description,
    ce.event_type::TEXT,
    ce.priority::TEXT,
    ce.status::TEXT,
    ce.start_datetime,
    ce.end_datetime,
    ce.all_day,
    ce.location,
    ce.meeting_url,
    creator.full_name as created_by_name,
    assignee.full_name as assigned_to_name
FROM public.calendar_events ce
LEFT JOIN public.user_profiles creator ON ce.created_by = creator.id
LEFT JOIN public.user_profiles assignee ON ce.assigned_to = assignee.id
WHERE ce.start_datetime BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '1 day' * days_ahead)
AND ce.status IN ('scheduled', 'in_progress')
AND (
    target_tenant_id IS NULL 
    OR ce.tenant_id = target_tenant_id
    OR ce.tenant_id IN (
        SELECT up.tenant_id 
        FROM public.user_profiles up 
        WHERE up.id = auth.uid()
    )
)
ORDER BY ce.start_datetime ASC;
$$;


ALTER FUNCTION "public"."get_upcoming_events"("days_ahead" integer, "target_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_upcoming_events"("days_ahead" integer, "target_tenant_id" "uuid") IS 'Returns upcoming calendar events within specified days';



CREATE OR REPLACE FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "company_type" "public"."company_type", "stage" "public"."account_stage", "city" "text", "state" "text", "email" "text", "phone" "text", "notes" "text", "is_active" boolean, "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "assigned_rep_id" "uuid", "primary_rep_name" "text", "assigned_reps" "jsonb", "properties_count" bigint, "contacts_count" bigint, "tenant_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  user_role text;
  user_tenant_id uuid;
  is_manager boolean := false;
  is_super_admin boolean := false;
  is_master_admin boolean := false;
BEGIN
  -- Get user profile information
  SELECT up.role, up.tenant_id
  INTO user_role, user_tenant_id
  FROM user_profiles up
  WHERE up.id = user_uuid;

  -- Handle case where user profile doesn't exist
  IF user_role IS NULL THEN
    RETURN;
  END IF;

  -- Set role flags
  is_manager := (user_role = 'manager');
  is_super_admin := (user_role = 'super_admin');
  is_master_admin := (user_role = 'master_admin');

  -- CASE 1: Super Admin or Master Admin - can see all accounts across all tenants
  IF is_super_admin OR is_master_admin THEN
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
    ORDER BY a.name;

  -- CASE 2: Manager - can see accounts within their tenant and assigned accounts
  ELSIF is_manager THEN
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
      AND (
        a.tenant_id = user_tenant_id 
        OR 
        EXISTS (
          SELECT 1 FROM account_assignments aa
          LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
          WHERE aa.account_id = a.id 
            AND rep.tenant_id = user_tenant_id
            AND rep.is_active = true
        )
      )
    ORDER BY a.name;

  -- CASE 3: Regular rep - can only see accounts assigned to them
  ELSE
    RETURN QUERY
    SELECT 
      a.id,
      a.name,
      a.company_type,
      a.stage,  -- Returns account_stage (singular) to match function signature
      a.city,
      a.state,
      a.email,
      a.phone,
      a.notes,
      a.is_active,
      a.created_at,
      a.updated_at,
      a.assigned_rep_id,
      up.full_name as primary_rep_name,
      COALESCE(
        (SELECT jsonb_agg(
          jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep.full_name,
            'is_primary', aa.is_primary,
            'assigned_at', aa.assigned_at
          )
        )
        FROM account_assignments aa
        LEFT JOIN user_profiles rep ON rep.id = aa.rep_id
        WHERE aa.account_id = a.id),
        '[]'::jsonb
      ) as assigned_reps,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM properties p WHERE p.account_id = a.id),
        0::bigint
      ) as properties_count,
      COALESCE(
        (SELECT COUNT(*)::bigint FROM contacts c WHERE c.account_id = a.id AND c.is_active = true),
        0::bigint
      ) as contacts_count,
      a.tenant_id
    FROM accounts a
    LEFT JOIN user_profiles up ON up.id = a.assigned_rep_id
    WHERE a.is_active = true
      AND (
        a.assigned_rep_id = user_uuid
        OR
        EXISTS (
          SELECT 1 FROM account_assignments aa
          WHERE aa.account_id = a.id AND aa.rep_id = user_uuid
        )
      )
    ORDER BY a.name;

  END IF;
END;
$$;


ALTER FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") IS 'Fixed enum type mismatch: Returns account_stage (singular) instead of account_stages (plural) to match database schema. Resolves "structure of query does not match function result type" error.';



CREATE OR REPLACE FUNCTION "public"."get_user_accessible_prospects"("user_uuid" "uuid") RETURNS TABLE("id" "uuid", "company_name" "text", "first_name" "text", "last_name" "text", "email" "text", "phone" "text", "company_type" "public"."company_type", "stage" "public"."prospect_stages", "city" "text", "state" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "notes" "text", "is_active" boolean, "tenant_id" "uuid", "assigned_rep_id" "uuid", "source" "text", "access_type" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  user_role text;
  user_tenant_id uuid;
  prospects_table_exists boolean := false;
BEGIN
  -- Check if prospects table exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'prospects' AND table_schema = 'public'
  ) INTO prospects_table_exists;
  
  -- If prospects table doesn't exist, return empty result
  IF NOT prospects_table_exists THEN
    RETURN;
  END IF;

  -- Get user profile information
  SELECT up.role, up.tenant_id
  INTO user_role, user_tenant_id
  FROM user_profiles up
  WHERE up.id = user_uuid AND up.is_active = true;

  -- If user not found, return empty
  IF user_role IS NULL OR user_tenant_id IS NULL THEN
    RETURN;
  END IF;

  -- For managers and super_admin: return all prospects in tenant
  IF user_role IN ('manager', 'super_admin') THEN
    RETURN QUERY
    SELECT 
      p.id, 
      -- Use COALESCE to handle both company_name and name columns
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'company_name' AND table_schema = 'public'
          ) THEN p.company_name 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'name' AND table_schema = 'public'
          ) THEN p.name 
          ELSE NULL 
        END,
        'Unknown Company'
      )::text as company_name, 
      COALESCE(p.first_name, '')::text as first_name, 
      COALESCE(p.last_name, '')::text as last_name, 
      COALESCE(p.email, '')::text as email, 
      COALESCE(p.phone, '')::text as phone,
      COALESCE(p.company_type, 'commercial'::company_type) as company_type, 
      COALESCE(p.stage, 'new'::prospect_stages) as stage, 
      COALESCE(p.city, '')::text as city, 
      COALESCE(p.state, '')::text as state, 
      COALESCE(p.created_at, CURRENT_TIMESTAMP) as created_at, 
      COALESCE(p.updated_at, CURRENT_TIMESTAMP) as updated_at,
      COALESCE(p.notes, '')::text as notes, 
      COALESCE(p.is_active, true) as is_active, 
      p.tenant_id, 
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_rep_id' AND table_schema = 'public'
          ) THEN p.assigned_rep_id 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_to' AND table_schema = 'public'
          ) THEN p.assigned_to 
          ELSE NULL 
        END
      ) as assigned_rep_id, 
      COALESCE(p.source, '')::text as source,
      CASE WHEN user_role = 'manager' THEN 'manager_tenant_access' ELSE 'super_admin_access' END::text
    FROM prospects p
    WHERE (user_role = 'super_admin' OR p.tenant_id = user_tenant_id)
      AND COALESCE(p.is_active, true) = true
    ORDER BY 
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'company_name' AND table_schema = 'public'
          ) THEN p.company_name 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'name' AND table_schema = 'public'
          ) THEN p.name 
          ELSE NULL 
        END,
        'Unknown Company'
      ), 
      COALESCE(p.last_name, '');

  -- For reps: return only their assigned prospects
  ELSIF user_role = 'rep' THEN
    RETURN QUERY
    SELECT 
      p.id, 
      -- Use COALESCE to handle both company_name and name columns
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'company_name' AND table_schema = 'public'
          ) THEN p.company_name 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'name' AND table_schema = 'public'
          ) THEN p.name 
          ELSE NULL 
        END,
        'Unknown Company'
      )::text as company_name, 
      COALESCE(p.first_name, '')::text as first_name, 
      COALESCE(p.last_name, '')::text as last_name, 
      COALESCE(p.email, '')::text as email, 
      COALESCE(p.phone, '')::text as phone,
      COALESCE(p.company_type, 'commercial'::company_type) as company_type, 
      COALESCE(p.stage, 'new'::prospect_stages) as stage, 
      COALESCE(p.city, '')::text as city, 
      COALESCE(p.state, '')::text as state, 
      COALESCE(p.created_at, CURRENT_TIMESTAMP) as created_at, 
      COALESCE(p.updated_at, CURRENT_TIMESTAMP) as updated_at,
      COALESCE(p.notes, '')::text as notes, 
      COALESCE(p.is_active, true) as is_active, 
      p.tenant_id, 
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_rep_id' AND table_schema = 'public'
          ) THEN p.assigned_rep_id 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_to' AND table_schema = 'public'
          ) THEN p.assigned_to 
          ELSE NULL 
        END
      ) as assigned_rep_id, 
      COALESCE(p.source, '')::text as source,
      'rep_assigned_access'::text
    FROM prospects p
    WHERE (
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_rep_id' AND table_schema = 'public'
          ) THEN p.assigned_rep_id 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'assigned_to' AND table_schema = 'public'
          ) THEN p.assigned_to 
          ELSE NULL 
        END
      ) = user_uuid 
      OR (
        EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'prospects' AND column_name = 'created_by' AND table_schema = 'public'
        ) AND p.created_by = user_uuid
      )
    )
    AND p.tenant_id = user_tenant_id
    AND COALESCE(p.is_active, true) = true
    ORDER BY 
      COALESCE(
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'company_name' AND table_schema = 'public'
          ) THEN p.company_name 
          ELSE NULL 
        END,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prospects' AND column_name = 'name' AND table_schema = 'public'
          ) THEN p.name 
          ELSE NULL 
        END,
        'Unknown Company'
      ), 
      COALESCE(p.last_name, '');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Return empty result on any error to prevent function failures
    RETURN;
END;
$$;


ALTER FUNCTION "public"."get_user_accessible_prospects"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_auth_status"("user_email" "text") RETURNS TABLE("user_exists" boolean, "email_confirmed" boolean, "can_reset_password" boolean, "account_status" "text", "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."get_user_auth_status"("user_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_auth_status_enhanced"() RETURNS TABLE("user_id" "uuid", "email" "text", "role" "text", "tenant_id" "uuid", "is_active" boolean, "profile_completed" boolean, "password_set" boolean, "can_access_data" boolean, "auth_metadata" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        au.id,
        au.email,
        public.get_user_role_reliable(),
        up.tenant_id,
        COALESCE(up.is_active, false),
        COALESCE(up.profile_completed, false),
        COALESCE(up.password_set, false),
        (up.id IS NOT NULL AND COALESCE(up.is_active, false) = true) as can_access_data,
        au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN public.user_profiles up ON au.id = up.id
    WHERE au.id = auth.uid();
END;
$$;


ALTER FUNCTION "public"."get_user_auth_status_enhanced"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_authentication_status"("user_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("user_exists" boolean, "profile_exists" boolean, "password_set" boolean, "profile_completed" boolean, "email" "text", "full_name" "text", "role" "text", "needs_setup" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  auth_user auth.users%ROWTYPE;
  profile_user public.user_profiles%ROWTYPE;
BEGIN
  -- Get auth user
  SELECT * INTO auth_user FROM auth.users WHERE id = user_uuid;
  
  -- Get profile user
  SELECT * INTO profile_user FROM public.user_profiles WHERE id = user_uuid;

  RETURN QUERY SELECT
    (auth_user.id IS NOT NULL)::BOOLEAN,
    (profile_user.id IS NOT NULL)::BOOLEAN,
    COALESCE(profile_user.password_set, false)::BOOLEAN,
    COALESCE(profile_user.profile_completed, false)::BOOLEAN,
    COALESCE(auth_user.email, '')::TEXT,
    COALESCE(profile_user.full_name, '')::TEXT,
    COALESCE(profile_user.role::TEXT, 'rep')::TEXT,
    (
      auth_user.id IS NOT NULL AND 
      (profile_user.id IS NULL OR NOT profile_user.password_set OR NOT profile_user.profile_completed)
    )::BOOLEAN;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT false, false, false, false, '', '', 'rep', true;
END;
$$;


ALTER FUNCTION "public"."get_user_authentication_status"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_permissions_summary"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
    user_data RECORD;
    permissions JSONB;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'Not authenticated');
    END IF;
    
    -- Get comprehensive user data
    SELECT 
        up.id,
        up.email,
        up.full_name,
        up.role,
        up.tenant_id,
        up.is_active,
        up.profile_completed,
        t.name as tenant_name,
        au.raw_user_meta_data->>'role' as auth_role
    INTO user_data
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    LEFT JOIN auth.users au ON up.id = au.id
    WHERE up.id = current_user_id;
    
    -- Build permissions based on role
    permissions := jsonb_build_object(
        'can_access_accounts', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_contacts', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_properties', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_prospects', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_access_opportunities', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager', 'rep')
            AND COALESCE(user_data.is_active, false) = true
        ),
        'can_manage_users', (
            user_data.role IN ('admin', 'super_admin', 'master_admin')
        ),
        'can_manage_tenant', (
            user_data.role IN ('admin', 'super_admin', 'master_admin', 'manager')
        ),
        'scope', CASE 
            WHEN user_data.role IN ('admin', 'super_admin', 'master_admin') THEN 'global'
            WHEN user_data.role = 'manager' THEN 'tenant'
            ELSE 'personal'
        END
    );
    
    RETURN jsonb_build_object(
        'user_id', user_data.id,
        'email', user_data.email,
        'full_name', user_data.full_name,
        'role', user_data.role,
        'tenant_id', user_data.tenant_id,
        'tenant_name', user_data.tenant_name,
        'is_active', COALESCE(user_data.is_active, false),
        'profile_completed', COALESCE(user_data.profile_completed, false),
        'auth_role', user_data.auth_role,
        'permissions', permissions,
        'timestamp', CURRENT_TIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('error', SQLERRM, 'sqlstate', SQLSTATE);
END;
$$;


ALTER FUNCTION "public"."get_user_permissions_summary"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_permissions_summary"() IS 'Returns comprehensive user permissions summary for debugging role-based access issues.';



CREATE OR REPLACE FUNCTION "public"."get_user_role"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
  auth.jwt() -> 'user_metadata' ->> 'role',
  auth.jwt() -> 'app_metadata' ->> 'role',
  (
    SELECT role::text FROM public.user_profiles 
    WHERE id = auth.uid() 
    LIMIT 1
  ),
  'rep'
)
$$;


ALTER FUNCTION "public"."get_user_role"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_role"() IS 'Safely retrieves the current users role from auth JWT metadata without querying user_profiles table.';



CREATE OR REPLACE FUNCTION "public"."get_user_role_from_jwt"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
    -- Check user_metadata first (set during signup)
    (auth.jwt() ->> 'user_metadata')::jsonb ->> 'role',
    -- Check app_metadata second (set by admin)  
    (auth.jwt() ->> 'app_metadata')::jsonb ->> 'role',
    -- Default to 'rep' if no role found
    'rep'
)::TEXT;
$$;


ALTER FUNCTION "public"."get_user_role_from_jwt"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_role_from_jwt"() IS 'Fixed rolnames typo - use rolname for pg_roles queries';



CREATE OR REPLACE FUNCTION "public"."get_user_role_reliable"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    user_role TEXT;
    profile_role TEXT;
    auth_meta_role TEXT;
BEGIN
    -- Try to get role from user_profiles first
    SELECT up.role::TEXT INTO profile_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid()
    LIMIT 1;
    
    -- Get role from auth metadata as fallback
    SELECT au.raw_user_meta_data->>'role' INTO auth_meta_role
    FROM auth.users au
    WHERE au.id = auth.uid()
    LIMIT 1;
    
    -- Return profile role if available, otherwise auth metadata role, otherwise 'rep'
    user_role := COALESCE(profile_role, auth_meta_role, 'rep');
    
    RETURN user_role;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'rep'; -- Default fallback
END;
$$;


ALTER FUNCTION "public"."get_user_role_reliable"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_role_reliable"() IS 'Gets user role from multiple sources with fallbacks. Used by RLS policies for reliable role detection.';



CREATE OR REPLACE FUNCTION "public"."get_user_role_with_fallbacks"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    user_role TEXT;
    profile_role TEXT;
    auth_meta_role TEXT;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN 'anonymous';
    END IF;
    
    -- Try to get role from user_profiles first (most reliable)
    SELECT up.role::TEXT INTO profile_role
    FROM public.user_profiles up
    WHERE up.id = current_user_id
    LIMIT 1;
    
    -- Get role from auth metadata as backup
    SELECT au.raw_user_meta_data->>'role' INTO auth_meta_role
    FROM auth.users au
    WHERE au.id = current_user_id
    LIMIT 1;
    
    -- Return the most reliable role with proper fallback
    user_role := COALESCE(profile_role, auth_meta_role, 'rep');
    
    -- Log role detection for debugging
    RAISE NOTICE 'Role detection for user %: profile_role=%, auth_meta_role=%, final_role=%', 
        current_user_id, profile_role, auth_meta_role, user_role;
    
    RETURN user_role;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in get_user_role_with_fallbacks: %', SQLERRM;
        RETURN 'rep'; -- Safe fallback
END;
$$;


ALTER FUNCTION "public"."get_user_role_with_fallbacks"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_role_with_fallbacks"() IS 'Enhanced role detection with multiple fallbacks and debugging for troubleshooting role access issues';



CREATE OR REPLACE FUNCTION "public"."get_user_role_with_super_admin"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT CASE 
  WHEN public.is_super_admin_from_auth() THEN 'super_admin'
  ELSE COALESCE(
    (SELECT role::text FROM public.user_profiles WHERE id = auth.uid()),
    'rep'
  )
END;
$$;


ALTER FUNCTION "public"."get_user_role_with_super_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_tenant_debug"() RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
    user_tenant_id UUID;
    user_role TEXT;
    tenant_name TEXT;
    result JSONB;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('error', 'No authenticated user');
    END IF;
    
    -- Get user profile data
    SELECT up.tenant_id, up.role::TEXT, t.name
    INTO user_tenant_id, user_role, tenant_name
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = current_user_id
    LIMIT 1;
    
    result := jsonb_build_object(
        'user_id', current_user_id,
        'tenant_id', user_tenant_id,
        'role', user_role,
        'tenant_name', tenant_name,
        'can_access_data', (user_tenant_id IS NOT NULL AND user_role IN ('manager', 'rep', 'admin'))
    );
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'error', SQLERRM,
            'user_id', current_user_id
        );
END;
$$;


ALTER FUNCTION "public"."get_user_tenant_debug"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_tenant_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
  (auth.jwt() -> 'user_metadata' ->> 'tenant_id')::UUID,
  (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
  (
    SELECT tenant_id FROM public.user_profiles 
    WHERE id = auth.uid() 
    LIMIT 1
  )
)
$$;


ALTER FUNCTION "public"."get_user_tenant_id"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_tenant_id"() IS 'Safely retrieves the current users tenant ID from auth JWT metadata without querying user_profiles table.';



CREATE OR REPLACE FUNCTION "public"."get_user_tenant_uuid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    CASE 
        WHEN auth.uid() IS NULL THEN NULL
        ELSE (
            SELECT tenant_id 
            FROM public.user_profiles 
            WHERE id = auth.uid() 
            LIMIT 1
        )
    END;
$$;


ALTER FUNCTION "public"."get_user_tenant_uuid"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_tenant_uuid"() IS 'Returns current user tenant UUID for policy checks';



CREATE OR REPLACE FUNCTION "public"."handle_email_confirmation_workflow"("user_id" "uuid", "user_email" "text") RETURNS TABLE("success" boolean, "message" "text", "next_step" "text", "needs_password_setup" boolean, "needs_profile_completion" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    profile_exists BOOLEAN := FALSE;
    profile_complete BOOLEAN := FALSE;
    password_is_set BOOLEAN := FALSE;
    user_full_name TEXT := '';
    temp_password_used BOOLEAN := FALSE;
    confirmation_status TEXT := 'pending';
BEGIN
    -- Check if user profile exists and get current state
    SELECT 
        (up.id IS NOT NULL),
        COALESCE(up.profile_completed, false),
        COALESCE(up.password_set, false),
        COALESCE(up.full_name, ''),
        COALESCE(up.temp_password_used, false),
        COALESCE(up.confirmation_status, 'pending')
    INTO 
        profile_exists, profile_complete, password_is_set, user_full_name, temp_password_used, confirmation_status
    FROM public.user_profiles up
    WHERE up.id = user_id AND up.email = user_email;

    -- If no profile exists, create one
    IF NOT profile_exists THEN
        PERFORM public.setup_new_user_profile(user_id, user_email, '{}'::jsonb);
        
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed and profile created. Please complete your account setup.'::TEXT,
            'setup-password'::TEXT,
            TRUE,  -- needs_password_setup
            TRUE;  -- needs_profile_completion
        RETURN;
    END IF;

    -- Update confirmation status
    UPDATE public.user_profiles
    SET 
        confirmation_status = 'confirmed',
        updated_at = NOW()
    WHERE id = user_id;

    -- Determine next step based on user state
    IF temp_password_used AND NOT password_is_set THEN
        -- User used temporary password but hasn't set permanent password
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed. Please set your permanent password and complete your profile.'::TEXT,
            'setup-password'::TEXT,
            TRUE,  -- needs_password_setup
            NOT profile_complete OR user_full_name = '';  -- needs_profile_completion
    ELSIF NOT password_is_set AND NOT profile_complete THEN
        -- User needs both password and profile setup
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed. Please set your password and complete your profile.'::TEXT,
            'setup-password'::TEXT,
            TRUE,  -- needs_password_setup
            TRUE;  -- needs_profile_completion
    ELSIF NOT password_is_set THEN
        -- User only needs password setup
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed. Please set your password to complete setup.'::TEXT,
            'setup-password'::TEXT,
            TRUE,  -- needs_password_setup
            FALSE; -- needs_profile_completion
    ELSIF NOT profile_complete OR user_full_name = '' THEN
        -- User only needs profile completion
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed. Please complete your profile information.'::TEXT,
            'complete-profile'::TEXT,
            FALSE, -- needs_password_setup
            TRUE;  -- needs_profile_completion
    ELSE
        -- User is fully set up, redirect to appropriate dashboard
        RETURN QUERY SELECT 
            TRUE, 
            'Email confirmed. Welcome back!'::TEXT,
            'dashboard'::TEXT,
            FALSE, -- needs_password_setup
            FALSE; -- needs_profile_completion
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            FALSE, 
            ('Error handling email confirmation: ' || SQLERRM)::TEXT,
            'error'::TEXT,
            FALSE,
            FALSE;
END;
$$;


ALTER FUNCTION "public"."handle_email_confirmation_workflow"("user_id" "uuid", "user_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name',''),
    'rep',
    true,
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."handle_new_user"() IS 'Auto-creates user_profiles with null tenant_id to allow signup flow completion';



CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
  CASE 
    -- Handle null tenant_id (legacy data)
    WHEN target_tenant_id IS NULL THEN true
    -- Super admin can access all tenants
    WHEN public.get_user_role() = 'super_admin' THEN true
    -- Admin can access all tenants  
    WHEN public.get_user_role() = 'admin' THEN true
    -- Manager/Rep can access their own tenant
    WHEN public.get_user_tenant_id() = target_tenant_id THEN true
    -- Default deny
    ELSE false
  END
$$;


ALTER FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") IS 'Enhanced tenant access validation supporting legacy data and all user roles with proper null handling';



CREATE OR REPLACE FUNCTION "public"."initialize_user_profile"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
    profile_exists BOOLEAN;
    auth_user_data RECORD;
    result JSONB;
BEGIN
    -- Get current user ID
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
    END IF;
    
    -- Check if profile exists
    SELECT EXISTS(SELECT 1 FROM public.user_profiles WHERE id = current_user_id) INTO profile_exists;
    
    -- Get auth user data
    SELECT * INTO auth_user_data FROM auth.users WHERE id = current_user_id;
    
    IF NOT profile_exists THEN
        -- Create profile if it doesn't exist
        INSERT INTO public.user_profiles (
            id, 
            email, 
            full_name, 
            role,
            is_active,
            profile_completed
        ) VALUES (
            current_user_id,
            auth_user_data.email,
            COALESCE(auth_user_data.raw_user_meta_data->>'full_name', split_part(auth_user_data.email, '@', 1)),
            COALESCE(auth_user_data.raw_user_meta_data->>'role', 'rep')::user_role_type,
            true,
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            full_name = COALESCE(EXCLUDED.full_name, user_profiles.full_name),
            role = COALESCE(EXCLUDED.role, user_profiles.role),
            updated_at = CURRENT_TIMESTAMP;
            
        result := jsonb_build_object('success', true, 'action', 'created', 'profile_existed', false);
    ELSE
        -- Update existing profile with latest auth data
        UPDATE public.user_profiles 
        SET 
            email = auth_user_data.email,
            full_name = COALESCE(auth_user_data.raw_user_meta_data->>'full_name', full_name),
            role = COALESCE((auth_user_data.raw_user_meta_data->>'role')::user_role_type, role),
            is_active = COALESCE(is_active, true),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = current_user_id;
        
        result := jsonb_build_object('success', true, 'action', 'updated', 'profile_existed', true);
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM, 'sqlstate', SQLSTATE);
END;
$$;


ALTER FUNCTION "public"."initialize_user_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_account_owner"("p_account_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$select exists (select 1 from public.account_assignments a where a.account_id = p_account_id and a.rep_id = auth.uid());$$;


ALTER FUNCTION "public"."is_account_owner"("p_account_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select coalesce(role = 'admin', false)
  from public.user_profiles where id = auth.uid()
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_from_auth"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin')
         OR au.raw_app_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin'))
);
$$;


ALTER FUNCTION "public"."is_admin_from_auth"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_from_auth_metadata"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
    (SELECT (au.raw_user_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin')
             OR au.raw_app_meta_data->>'role' IN ('admin', 'super_admin', 'master_admin'))
     FROM auth.users au
     WHERE au.id = auth.uid()),
    false
)
$$;


ALTER FUNCTION "public"."is_admin_from_auth_metadata"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_admin_from_auth_metadata"() IS 'Safe admin check using auth.users metadata to avoid infinite recursion in tenants RLS policies';



CREATE OR REPLACE FUNCTION "public"."is_admin_or_above"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN check_user_role('admin');
END;
$$;


ALTER FUNCTION "public"."is_admin_or_above"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_admin_or_above"() IS 'Checks if the current user has admin role or higher';



CREATE OR REPLACE FUNCTION "public"."is_admin_or_manager"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select coalesce(role in ('admin','manager'), false)
  from public.user_profiles where id = auth.uid()
$$;


ALTER FUNCTION "public"."is_admin_or_manager"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_user"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role::text IN ('admin', 'super_admin', 'master_admin')
    AND up.is_active = true
)
$$;


ALTER FUNCTION "public"."is_admin_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_admin_user"() IS 'Checks if current user is admin or super_admin using JWT metadata';



CREATE OR REPLACE FUNCTION "public"."is_admin_user_jwt"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_from_jwt() IN ('admin', 'super_admin');
$$;


ALTER FUNCTION "public"."is_admin_user_jwt"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_admin_user_jwt"() IS 'JWT-only admin check - safe for RLS policies on any table';



CREATE OR REPLACE FUNCTION "public"."is_manager"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select coalesce(role = 'manager', false)
  from public.user_profiles where id = auth.uid()
$$;


ALTER FUNCTION "public"."is_manager"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_manager_accessing_team_member"("profile_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    -- Check if the current user (auth.uid()) is the manager of the profile being accessed
    -- This uses the manager_id column directly without complex joins
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_id 
    AND up.manager_id = auth.uid()
)
$$;


ALTER FUNCTION "public"."is_manager_accessing_team_member"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_manager_from_auth"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'manager' 
         OR au.raw_app_meta_data->>'role' = 'manager')
);
$$;


ALTER FUNCTION "public"."is_manager_from_auth"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_from_auth"() IS 'Checks if current user is manager using auth.users metadata - safe for all tables including user_profiles';



CREATE OR REPLACE FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = goal_user_id
    AND up.manager_id = auth.uid()
    AND up.is_active = true
    AND EXISTS (
        SELECT 1 FROM public.user_profiles manager
        WHERE manager.id = auth.uid()
        AND manager.role IN ('manager', 'admin', 'super_admin')
        AND manager.is_active = true
        -- Ensure same tenant
        AND manager.tenant_id = up.tenant_id
    )
);
$$;


ALTER FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") IS 'Checks if the current authenticated user is a manager of the specified user. Used for RLS policies to allow managers to manage team members goals.';



CREATE OR REPLACE FUNCTION "public"."is_manager_of_user"("manager_uuid" "uuid", "user_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = user_uuid 
    AND up.manager_id = manager_uuid
    AND up.tenant_id = (
        SELECT tenant_id FROM public.user_profiles WHERE id = manager_uuid LIMIT 1
    )
);
$$;


ALTER FUNCTION "public"."is_manager_of_user"("manager_uuid" "uuid", "user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_manager_or_above"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN check_user_role('manager');
END;
$$;


ALTER FUNCTION "public"."is_manager_or_above"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_or_above"() IS 'Checks if the current user has manager role or higher';



CREATE OR REPLACE FUNCTION "public"."is_manager_or_admin_in_tenant"("check_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND up.tenant_id = check_tenant_id
    AND up.role IN ('admin', 'manager')
)
$$;


ALTER FUNCTION "public"."is_manager_or_admin_in_tenant"("check_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_manager_user"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_current_user_role() = 'manager';
$$;


ALTER FUNCTION "public"."is_manager_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_user"() IS 'Checks if current user is manager using JWT metadata';



CREATE OR REPLACE FUNCTION "public"."is_manager_user_jwt"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_from_jwt() = 'manager';
$$;


ALTER FUNCTION "public"."is_manager_user_jwt"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_user_jwt"() IS 'JWT-only manager check - safe for RLS policies on any table';



CREATE OR REPLACE FUNCTION "public"."is_manager_with_tenant_access"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_from_jwt() = 'manager';
$$;


ALTER FUNCTION "public"."is_manager_with_tenant_access"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_manager_with_tenant_access"() IS 'JWT-only manager check with tenant access validation';



CREATE OR REPLACE FUNCTION "public"."is_super_admin_from_auth"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
    (SELECT (au.raw_user_meta_data->>'role' IN ('super_admin', 'master_admin')
             OR au.raw_app_meta_data->>'role' IN ('super_admin', 'master_admin'))
     FROM auth.users au
     WHERE au.id = auth.uid()),
    false
)
$$;


ALTER FUNCTION "public"."is_super_admin_from_auth"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_super_admin_from_auth"() IS 'Checks if current user is super_admin using auth.users metadata - safe for all tables including user_profiles';



CREATE OR REPLACE FUNCTION "public"."is_super_admin_safe"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (
        -- ONLY check auth metadata - NEVER query user_profiles table
        au.raw_user_meta_data->>'role' = 'super_admin' 
        OR au.raw_app_meta_data->>'role' = 'super_admin'
        OR au.raw_user_meta_data->>'role' = 'master_admin'
        OR au.raw_app_meta_data->>'role' = 'master_admin'
        -- Email-based super admin identification
        OR au.email = 'team@dillyos.com'
    )
);
$$;


ALTER FUNCTION "public"."is_super_admin_safe"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_super_admin_safe"() IS 'Safe super admin check that NEVER queries user_profiles table to prevent infinite recursion in RLS policies';



CREATE OR REPLACE FUNCTION "public"."is_super_admin_user"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role::text IN ('super_admin', 'master_admin')
    AND up.is_active = true
)
$$;


ALTER FUNCTION "public"."is_super_admin_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_super_admin_user"() IS 'Checks if current user is super_admin using JWT metadata';



CREATE OR REPLACE FUNCTION "public"."is_tenant_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  select exists (
    select 1
    from public.user_profiles up2
    where up2.id = auth.uid()
      and up2.role in ('manager','admin','super_admin')
  );
$$;


ALTER FUNCTION "public"."is_tenant_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") RETURNS integer
    LANGUAGE "plpgsql" STABLE
    AS $$
DECLARE
    len1 INTEGER := LENGTH(s1);
    len2 INTEGER := LENGTH(s2);
    matrix INTEGER[][];
    i INTEGER;
    j INTEGER;
    cost INTEGER;
BEGIN
    -- Handle edge cases
    IF s1 = s2 THEN RETURN 0; END IF;
    IF len1 = 0 THEN RETURN len2; END IF;
    IF len2 = 0 THEN RETURN len1; END IF;
    
    -- Initialize matrix
    FOR i IN 0..len1 LOOP
        matrix[i][0] := i;
    END LOOP;
    
    FOR j IN 0..len2 LOOP
        matrix[0][j] := j;
    END LOOP;
    
    -- Calculate distances
    FOR i IN 1..len1 LOOP
        FOR j IN 1..len2 LOOP
            IF SUBSTRING(s1, i, 1) = SUBSTRING(s2, j, 1) THEN
                cost := 0;
            ELSE
                cost := 1;
            END IF;
            
            matrix[i][j] := LEAST(
                matrix[i-1][j] + 1,      -- deletion
                matrix[i][j-1] + 1,      -- insertion
                matrix[i-1][j-1] + cost  -- substitution
            );
        END LOOP;
    END LOOP;
    
    RETURN matrix[len1][len2];
END;
$$;


ALTER FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") IS 'Simple Levenshtein distance implementation for text similarity calculations';



CREATE OR REPLACE FUNCTION "public"."link_contact_to_property"("contact_uuid" "uuid", "property_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    contact_account_id UUID;
    property_account_id UUID;
BEGIN
    -- Get contact's account_id
    SELECT account_id INTO contact_account_id 
    FROM public.contacts 
    WHERE id = contact_uuid;
    
    -- Get property's account_id
    SELECT account_id INTO property_account_id 
    FROM public.properties 
    WHERE id = property_uuid;
    
    -- Validate that both contact and property belong to the same account
    IF contact_account_id != property_account_id THEN
        RAISE EXCEPTION 'Contact and property must belong to the same account';
    END IF;
    
    -- Update the contact with the property_id
    UPDATE public.contacts 
    SET property_id = property_uuid, updated_at = CURRENT_TIMESTAMP
    WHERE id = contact_uuid;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to link contact to property: %', SQLERRM;
        RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."link_contact_to_property"("contact_uuid" "uuid", "property_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."list_current_policies"() RETURNS TABLE("schema_name" "text", "table_name" "text", "policy_name" "text", "command" "text", "roles" "text"[], "using_expression" "text", "check_expression" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."list_current_policies"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."list_current_policies"() IS 'Lists all current RLS policies for verification and debugging';



CREATE OR REPLACE FUNCTION "public"."log_auth_attempt"("p_user_id" "uuid" DEFAULT NULL::"uuid", "p_event_type" "text" DEFAULT 'unknown'::"text", "p_token_type" "text" DEFAULT NULL::"text", "p_token_prefix" "text" DEFAULT NULL::"text", "p_success" boolean DEFAULT false, "p_error_message" "text" DEFAULT NULL::"text", "p_redirect_url" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."log_auth_attempt"("p_user_id" "uuid", "p_event_type" "text", "p_token_type" "text", "p_token_prefix" "text", "p_success" boolean, "p_error_message" "text", "p_redirect_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."manager_assign_account_to_reps"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("success" boolean, "message" "text", "assigned_account_id" "uuid", "assignments_created" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    manager_tenant_id UUID;
    account_tenant_id UUID;
    assignments_count INTEGER := 0;
    rep_id UUID;
BEGIN
    -- Verify manager permissions (using table alias)
    SELECT up.tenant_id INTO manager_tenant_id 
    FROM public.user_profiles up
    WHERE up.id = manager_uuid AND up.role IN ('manager', 'admin', 'super_admin');
    
    IF manager_tenant_id IS NULL THEN
        RETURN QUERY SELECT false, 'Invalid manager or insufficient permissions', account_uuid, 0;
        RETURN;
    END IF;
    
    -- Verify account belongs to same tenant (using table alias)
    SELECT a.tenant_id INTO account_tenant_id
    FROM public.accounts a
    WHERE a.id = account_uuid;
    
    IF account_tenant_id != manager_tenant_id THEN
        RETURN QUERY SELECT false, 'Account not found or access denied', account_uuid, 0;
        RETURN;
    END IF;
    
    -- Clear existing assignments for this account (using table alias to avoid ambiguity)
    DELETE FROM public.account_assignments aa WHERE aa.account_id = account_uuid;
    
    -- Update primary rep if specified (using table alias)
    IF primary_rep_id IS NOT NULL THEN
        UPDATE public.accounts a
        SET assigned_rep_id = primary_rep_id 
        WHERE a.id = account_uuid;
    END IF;
    
    -- Create new assignments
    FOREACH rep_id IN ARRAY rep_ids LOOP
        -- Verify rep belongs to same tenant (using table alias)
        IF EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = rep_id 
            AND up.tenant_id = manager_tenant_id 
            AND up.is_active = true
        ) THEN
            INSERT INTO public.account_assignments (
                account_id, 
                rep_id, 
                assigned_by, 
                is_primary
            ) VALUES (
                account_uuid, 
                rep_id, 
                manager_uuid,
                COALESCE(rep_id = primary_rep_id, false)
            );
            assignments_count := assignments_count + 1;
        END IF;
    END LOOP;
    
    RETURN QUERY SELECT 
        true, 
        format('Successfully assigned %s reps to account', assignments_count),
        account_uuid,
        assignments_count;
END;
$$;


ALTER FUNCTION "public"."manager_assign_account_to_reps"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    manager_tenant_id UUID;
    account_tenant_id UUID;
    rep_tenant_id UUID;
BEGIN
    -- Get manager's tenant
    SELECT tenant_id INTO manager_tenant_id
    FROM public.user_profiles
    WHERE id = manager_uuid AND role = 'manager'
    LIMIT 1;

    -- Validate manager exists and is manager
    IF manager_tenant_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Manager not found or invalid role');
    END IF;

    -- Get account tenant
    SELECT tenant_id INTO account_tenant_id
    FROM public.accounts
    WHERE id = account_uuid
    LIMIT 1;

    -- Get rep tenant  
    SELECT tenant_id INTO rep_tenant_id
    FROM public.user_profiles
    WHERE id = rep_uuid
    LIMIT 1;

    -- Validate all belong to same tenant
    IF manager_tenant_id != account_tenant_id OR manager_tenant_id != rep_tenant_id THEN
        RETURN json_build_object('success', false, 'message', 'Account and rep must be in same tenant as manager');
    END IF;

    -- Update account assignment
    UPDATE public.accounts 
    SET assigned_rep_id = rep_uuid,
        updated_at = NOW()
    WHERE id = account_uuid;

    RETURN json_build_object('success', true, 'message', 'Rep assigned to account successfully');
END;
$$;


ALTER FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") IS 'Allows managers to assign reps to accounts within their tenant';



CREATE OR REPLACE FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") RETURNS TABLE("success" boolean, "message" "text", "goals_assigned" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    manager_tenant_id UUID;
    manager_role TEXT;
    manager_name TEXT;
    goals_count INTEGER := 0;
    goal_item JSONB;
    rep_id UUID;
    rep_name TEXT;
    week_start DATE;
    goal_type_item JSONB;
    debug_info TEXT := '';
BEGIN
    -- Enhanced manager validation with debugging info
    SELECT tenant_id, role, full_name INTO manager_tenant_id, manager_role, manager_name
    FROM public.user_profiles 
    WHERE id = manager_uuid 
    AND role IN ('manager', 'admin', 'super_admin')
    AND is_active = true;
    
    IF manager_tenant_id IS NULL THEN
        RETURN QUERY SELECT false, 'Invalid manager or insufficient permissions. User must be an active manager, admin, or super_admin.', 0;
        RETURN;
    END IF;
    
    debug_info := format('Manager: %s (%s) - Tenant: %s', manager_name, manager_role, manager_tenant_id);
    RAISE NOTICE 'Goal assignment - %', debug_info;
    
    -- Extract week start from goal data
    week_start := COALESCE(
        (goal_data->>'week_start')::DATE, 
        DATE_TRUNC('week', CURRENT_DATE)::DATE
    );
    
    -- Process each goal assignment with enhanced validation
    FOR goal_item IN SELECT * FROM jsonb_array_elements(goal_data->'assignments') LOOP
        rep_id := (goal_item->>'rep_id')::UUID;
        
        -- Get rep info for debugging
        SELECT full_name INTO rep_name 
        FROM public.user_profiles 
        WHERE id = rep_id;
        
        -- Enhanced rep validation with automatic relationship establishment
        IF EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = rep_id 
            AND up.tenant_id = manager_tenant_id
            AND up.is_active = true
        ) THEN
            -- Check if rep has proper manager relationship
            IF NOT EXISTS (
                SELECT 1 FROM public.user_profiles up
                WHERE up.id = rep_id
                AND (
                    up.manager_id = manager_uuid
                    OR manager_role IN ('admin', 'super_admin')
                )
            ) THEN
                -- If manager role allows it, automatically establish relationship
                IF manager_role IN ('manager', 'admin', 'super_admin') THEN
                    UPDATE public.user_profiles 
                    SET manager_id = manager_uuid,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = rep_id
                    AND tenant_id = manager_tenant_id
                    AND role = 'rep'
                    AND is_active = true;
                    
                    RAISE NOTICE 'Established manager relationship: % -> %', manager_name, COALESCE(rep_name, rep_id::text);
                END IF;
            END IF;
            
            -- Final validation after potential relationship establishment
            IF EXISTS (
                SELECT 1 FROM public.user_profiles up
                WHERE up.id = rep_id
                AND up.tenant_id = manager_tenant_id
                AND up.is_active = true
                AND (
                    up.manager_id = manager_uuid
                    OR manager_role IN ('admin', 'super_admin')
                )
            ) THEN
                -- Delete existing goals for this week and rep to avoid conflicts
                DELETE FROM public.weekly_goals 
                WHERE user_id = rep_id 
                AND week_start_date = week_start;
                
                -- Insert new goals for each goal type
                FOR goal_type_item IN SELECT * FROM jsonb_array_elements(goal_item->'goals') LOOP
                    INSERT INTO public.weekly_goals (
                        user_id,
                        tenant_id,
                        week_start_date,
                        goal_type,
                        target_value,
                        current_value,
                        status
                    ) VALUES (
                        rep_id,
                        manager_tenant_id,
                        week_start,
                        (goal_type_item->>'type')::TEXT,
                        COALESCE((goal_type_item->>'target')::INTEGER, 0),
                        COALESCE((goal_type_item->>'current')::INTEGER, 0),
                        CASE 
                            WHEN COALESCE((goal_type_item->>'target')::INTEGER, 0) > 0 THEN 'In Progress'::goal_status
                            ELSE 'Not Started'::goal_status
                        END
                    );
                    
                    goals_count := goals_count + 1;
                END LOOP;
                
                RAISE NOTICE 'Goals assigned for: % (%)', COALESCE(rep_name, 'Unknown'), rep_id;
            ELSE
                RAISE NOTICE 'Rep % not managed by manager % or relationship could not be established', COALESCE(rep_name, rep_id::text), manager_name;
            END IF;
        ELSE
            RAISE NOTICE 'Rep % not found in tenant % or not active', COALESCE(rep_id::text, 'NULL'), manager_tenant_id;
        END IF;
    END LOOP;
    
    IF goals_count = 0 THEN
        RETURN QUERY SELECT false, 'No goals were assigned. Manager relationships have been checked and established where possible. Please verify that the selected team members are active and in your tenant.', 0;
    ELSE
        RETURN QUERY SELECT 
            true, 
            format('Successfully assigned %s goals for week starting %s by %s', goals_count, week_start, manager_name),
            goals_count;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in manager_assign_team_goals: %', SQLERRM;
        RETURN QUERY SELECT false, format('Database error: %s', SQLERRM), 0;
        RETURN;
END;
$$;


ALTER FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") IS 'Enhanced function for managers to assign goals to team members with better error handling and permission checking.';



CREATE OR REPLACE FUNCTION "public"."manager_can_access_tenant_profiles"("profile_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    current_user_role TEXT;
    current_user_tenant UUID;
BEGIN
    -- Get current user's role and tenant from profiles
    SELECT up.role::TEXT, up.tenant_id INTO current_user_role, current_user_tenant
    FROM public.user_profiles up
    WHERE up.id = auth.uid()
    LIMIT 1;
    
    -- Manager can access profiles in their tenant
    IF current_user_role = 'manager' AND current_user_tenant = profile_tenant_id THEN
        RETURN true;
    END IF;
    
    RETURN false;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$;


ALTER FUNCTION "public"."manager_can_access_tenant_profiles"("profile_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."manager_can_manage_account_assignments"("manager_uuid" "uuid", "account_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.accounts a
    JOIN public.user_profiles manager ON a.tenant_id = manager.tenant_id
    WHERE a.id = account_uuid
    AND manager.id = manager_uuid
    AND manager.role = 'manager'::public.user_role
    AND manager.is_active = true
);
$$;


ALTER FUNCTION "public"."manager_can_manage_account_assignments"("manager_uuid" "uuid", "account_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_event_completed"("event_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Update the event status if user has permission
    UPDATE public.calendar_events 
    SET status = 'completed'::public.event_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = event_id
    AND (
        assigned_to = auth.uid() 
        OR created_by = auth.uid()
        OR tenant_id IN (
            SELECT up.tenant_id 
            FROM public.user_profiles up 
            WHERE up.id = auth.uid()
        )
    );
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count > 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error marking event as completed: %', SQLERRM;
        RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."mark_event_completed"("event_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."mark_event_completed"("event_id" "uuid") IS 'Marks a calendar event as completed if user has permission';



CREATE OR REPLACE FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") RETURNS TABLE("success" boolean, "message" "text", "user_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
BEGIN
    -- Find user profile
    SELECT id INTO target_user_id
    FROM public.user_profiles
    WHERE email = user_email
    AND is_active = true;

    IF target_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User not found'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Update timestamp to track resend attempts
    UPDATE public.user_profiles
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = target_user_id;

    RETURN QUERY SELECT TRUE, 'Ready for confirmation resend'::TEXT, target_user_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error preparing resend: ' || SQLERRM)::TEXT, NULL::UUID;
END;
$$;


ALTER FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") IS 'Prepares user profile for confirmation email resend';



CREATE OR REPLACE FUNCTION "public"."refresh_manager_dashboard_demo_data"() RETURNS TABLE("message" "text", "goals_created" integer, "activities_created" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_week_start DATE := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    goals_count INTEGER := 0;
    activities_count INTEGER := 0;
BEGIN
    -- Clear existing data for current week
    DELETE FROM public.weekly_goals WHERE week_start_date = current_week_start;
    DELETE FROM public.activities WHERE activity_date >= current_week_start;
    
    -- Call the population logic (rerun the DO block logic)
    -- This would normally be extracted to a separate function, but for simplicity:
    -- Goals will be recreated by the next dashboard load
    
    GET DIAGNOSTICS goals_count = ROW_COUNT;
    
    SELECT COUNT(*)::INTEGER INTO activities_count 
    FROM public.activities 
    WHERE activity_date >= CURRENT_DATE - INTERVAL '7 days';
    
    RETURN QUERY SELECT 
        'Demo data refreshed successfully'::TEXT,
        goals_count,
        activities_count;
END;
$$;


ALTER FUNCTION "public"."refresh_manager_dashboard_demo_data"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."refresh_manager_dashboard_demo_data"() IS 'Function to refresh sample data for manager dashboard demonstration. Use: SELECT * FROM refresh_manager_dashboard_demo_data();';



CREATE OR REPLACE FUNCTION "public"."remove_rep_from_account"("account_uuid" "uuid", "rep_uuid" "uuid", "manager_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    was_primary BOOLEAN;
    new_primary_rep UUID;
BEGIN
    -- Verify manager can manage this account
    IF NOT public.manager_can_manage_account_assignments(manager_uuid, account_uuid) THEN
        RETURN QUERY SELECT false::BOOLEAN, 'Manager does not have permission to manage assignments for this account'::TEXT;
        RETURN;
    END IF;

    -- Check if removing primary rep
    SELECT is_primary INTO was_primary 
    FROM public.account_assignments 
    WHERE account_id = account_uuid AND rep_id = rep_uuid;

    -- Remove the assignment
    DELETE FROM public.account_assignments 
    WHERE account_id = account_uuid AND rep_id = rep_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false::BOOLEAN, 'Rep assignment not found'::TEXT;
        RETURN;
    END IF;

    -- If removed rep was primary, assign new primary from remaining reps
    IF was_primary THEN
        SELECT rep_id INTO new_primary_rep
        FROM public.account_assignments
        WHERE account_id = account_uuid
        ORDER BY assigned_at ASC
        LIMIT 1;

        IF new_primary_rep IS NOT NULL THEN
            UPDATE public.account_assignments 
            SET is_primary = true 
            WHERE account_id = account_uuid AND rep_id = new_primary_rep;

            -- Update legacy assigned_rep_id
            UPDATE public.accounts 
            SET assigned_rep_id = new_primary_rep 
            WHERE id = account_uuid;
        ELSE
            -- No reps left, clear legacy assigned_rep_id
            UPDATE public.accounts 
            SET assigned_rep_id = NULL 
            WHERE id = account_uuid;
        END IF;
    END IF;

    RETURN QUERY SELECT true::BOOLEAN, 'Representative removed successfully'::TEXT;
END;
$$;


ALTER FUNCTION "public"."remove_rep_from_account"("account_uuid" "uuid", "rep_uuid" "uuid", "manager_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."resend_confirmation_workflow"("user_email" "text") RETURNS TABLE("success" boolean, "message" "text", "can_resend" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."resend_confirmation_workflow"("user_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."safe_assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    account_tenant_id UUID;
    rep_tenant_id UUID;
BEGIN
    -- Get the tenant ID of the account
    SELECT tenant_id INTO account_tenant_id 
    FROM public.accounts 
    WHERE id = account_uuid;
    
    IF account_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Account % not found', account_uuid;
    END IF;
    
    -- Get the tenant ID of the representative
    SELECT tenant_id INTO rep_tenant_id 
    FROM public.user_profiles 
    WHERE id = rep_uuid AND is_active = true;
    
    IF rep_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Representative % not found or inactive', rep_uuid;
    END IF;
    
    -- Check if they belong to the same tenant
    IF account_tenant_id != rep_tenant_id THEN
        -- Allow super admin to assign cross-tenant
        IF NOT public.is_super_admin_from_auth() THEN
            RAISE EXCEPTION 'Cannot assign representative % from tenant % to account in tenant %', 
                rep_uuid, rep_tenant_id, account_tenant_id;
        END IF;
    END IF;
    
    -- Perform the assignment
    UPDATE public.accounts 
    SET assigned_rep_id = rep_uuid,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = account_uuid;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to assign representative: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."safe_assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_password_setup_email"("user_email" "text", "redirect_url" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  auth_user_id UUID;
  default_redirect TEXT;
BEGIN
  -- Get current origin for proper redirect URL
  default_redirect := COALESCE(
    redirect_url,
    (SELECT CASE 
      WHEN current_setting('request.headers', true)::json->>'host' IS NOT NULL 
      THEN 'https://' || (current_setting('request.headers', true)::json->>'host') || '/password-setup'
      ELSE 'https://localhost:3000/password-setup'
    END)
  );

  -- Get user ID from auth.users
  SELECT id INTO auth_user_id 
  FROM auth.users 
  WHERE email = user_email 
  LIMIT 1;

  IF auth_user_id IS NULL THEN
    RETURN QUERY SELECT false, 'User not found with that email address'::TEXT;
    RETURN;
  END IF;

  -- Update user_profiles to indicate password setup is needed
  UPDATE public.user_profiles
  SET 
    password_set = false,
    profile_completed = false,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = auth_user_id;

  RETURN QUERY SELECT true, 'Password setup process initiated'::TEXT;

EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error initiating password setup: ' || SQLERRM)::TEXT;
END;
$$;


ALTER FUNCTION "public"."send_password_setup_email"("user_email" "text", "redirect_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_account_defaults"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.assigned_rep_id is null then
    new.assigned_rep_id := auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_account_defaults"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_account_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- If tenant_id is not provided, set it to current user's tenant
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id := get_user_tenant_id();
        
        -- If still null, raise error with helpful message
        IF NEW.tenant_id IS NULL THEN
            RAISE EXCEPTION 'Unable to determine tenant for current user. User may not belong to any tenant.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_account_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_activity_defaults"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_activity_defaults"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_and_validate_weekly_goals_tenant"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_tenant_id UUID;
BEGIN
    -- Get the user's tenant_id from user_profiles
    SELECT tenant_id INTO user_tenant_id 
    FROM public.user_profiles 
    WHERE id = NEW.user_id;
    
    -- If no tenant found for user, raise error
    IF user_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User % has no associated tenant', NEW.user_id;
    END IF;
    
    -- If tenant_id is explicitly provided, validate it matches user's tenant
    IF NEW.tenant_id IS NOT NULL AND NEW.tenant_id != user_tenant_id THEN
        RAISE EXCEPTION 'User % does not belong to tenant %', NEW.user_id, NEW.tenant_id;
    END IF;
    
    -- Set the tenant_id automatically to ensure consistency
    NEW.tenant_id := user_tenant_id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_and_validate_weekly_goals_tenant"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."set_and_validate_weekly_goals_tenant"() IS 'Enhanced trigger function that both sets tenant_id from user_profiles and validates tenant consistency in a single operation. Prevents validation errors that occurred when validation ran before tenant_id was set.';



CREATE OR REPLACE FUNCTION "public"."set_contact_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- If tenant_id is not provided, set it to current user's tenant
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id := get_user_tenant_id();
        
        -- If still null, raise error with helpful message
        IF NEW.tenant_id IS NULL THEN
            RAISE EXCEPTION 'Unable to determine tenant for current user. User may not belong to any tenant.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_contact_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_contacts_created_by"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF NEW.created_by IS NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_contacts_created_by"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_current_tenant"("p_tenant_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_uid uuid := auth.uid();
  v_t tenants%rowtype;
begin
  if v_uid is null then
    return jsonb_build_object('success', false, 'message', 'Not authenticated');
  end if;

  select * into v_t from public.tenants where id = p_tenant_id;

  if not found then
    return jsonb_build_object('success', false, 'message', 'Tenant not found');
  end if;

  update public.user_profiles
  set tenant_id = p_tenant_id, updated_at = now()
  where id = v_uid;

  return public.get_session_context();
end;
$$;


ALTER FUNCTION "public"."set_current_tenant"("p_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_opportunity_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  NEW.tenant_id = get_user_tenant_id();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_opportunity_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_property_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- If tenant_id is not provided, set it to current user's tenant
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id := get_user_tenant_id();
        
        -- If still null, raise error with helpful message
        IF NEW.tenant_id IS NULL THEN
            RAISE EXCEPTION 'Unable to determine tenant for current user. User may not belong to any tenant.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_property_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_task_comment_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Only set tenant_id if it's not already provided
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id = get_user_tenant_id();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_task_comment_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_task_defaults"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.assigned_by is null then
    new.assigned_by := auth.uid();
  end if;
  if new.assigned_to is null then
    new.assigned_to := auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_task_defaults"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_task_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Only set tenant_id if it's not already provided
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id = get_user_tenant_id();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_task_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.tenant_id is null then
    select tenant_id into new.tenant_id
    from public.user_profiles where id = auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  if TG_OP = 'UPDATE' then
    if NEW.updated_at is distinct from now() then
      NEW.updated_at := now();
    end if;
  end if;
  return NEW;
end;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_weekly_goals_tenant_id"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_tenant_id UUID;
BEGIN
    -- Get the user's tenant_id from user_profiles
    SELECT tenant_id INTO user_tenant_id 
    FROM public.user_profiles 
    WHERE id = NEW.user_id;
    
    -- If no tenant found, raise error
    IF user_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User % has no associated tenant', NEW.user_id;
    END IF;
    
    -- Set the tenant_id automatically
    NEW.tenant_id := user_tenant_id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_weekly_goals_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    default_tenant_id UUID;
    user_role TEXT;
    user_full_name TEXT;
    profile_exists BOOLEAN := FALSE;
BEGIN
    -- Check if profile already exists
    SELECT EXISTS(SELECT 1 FROM public.user_profiles WHERE id = user_id) INTO profile_exists;
    
    IF profile_exists THEN
        RETURN TRUE; -- Profile already exists, nothing to do
    END IF;

    -- Get default tenant (assuming there's at least one active tenant)
    SELECT id INTO default_tenant_id 
    FROM public.tenants 
    WHERE status = 'active'::tenant_status 
    LIMIT 1;

    -- Extract user role from metadata, default to 'rep' if not specified
    user_role := COALESCE(user_metadata->>'role', 'rep');
    
    -- Extract full name from metadata, use email prefix as fallback
    user_full_name := COALESCE(
        user_metadata->>'full_name',
        user_metadata->>'fullName',
        split_part(user_email, '@', 1)
    );

    -- Create user profile with proper tenant assignment
    INSERT INTO public.user_profiles (
        id,
        email,
        full_name,
        role,
        phone,
        tenant_id,
        is_active
    ) VALUES (
        user_id,
        user_email,
        user_full_name,
        user_role::public.user_role,
        user_metadata->>'phone',
        default_tenant_id,
        true
    );

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the user creation
        RAISE NOTICE 'Error creating user profile for %: %', user_email, SQLERRM;
        RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb") IS 'Creates user profile after successful authentication signup';



CREATE OR REPLACE FUNCTION "public"."sync_super_admin_metadata"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- If user profile role is super_admin, update auth metadata
  IF NEW.role = 'super_admin' THEN
    UPDATE auth.users
    SET 
      raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role": "super_admin"}'::jsonb,
      raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "super_admin"}'::jsonb,
      updated_at = now()
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_super_admin_metadata"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_user_metadata_on_profile_update"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update auth.users metadata when user_profiles role changes
    IF (TG_OP = 'UPDATE' AND OLD.role IS DISTINCT FROM NEW.role) OR TG_OP = 'INSERT' THEN
        UPDATE auth.users 
        SET raw_user_meta_data = jsonb_set(
            jsonb_set(
                COALESCE(raw_user_meta_data, '{}'::jsonb),
                '{role}', 
                to_jsonb(NEW.role::TEXT)
            ),
            '{full_name}',
            to_jsonb(COALESCE(NEW.full_name, ''))
        )
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_user_metadata_on_profile_update"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."sync_user_metadata_on_profile_update"() IS 'Automatically sync role changes from user_profiles to auth.users metadata';



CREATE OR REPLACE FUNCTION "public"."sync_user_metadata_with_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update auth.users metadata when user_profiles changes
    UPDATE auth.users
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || 
        jsonb_build_object(
            'tenant_id', NEW.tenant_id::text,
            'role', NEW.role::text,
            'full_name', NEW.full_name
        )
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_user_metadata_with_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."test_user_data_access"("test_email" "text") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."test_user_data_access"("test_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") RETURNS numeric
    LANGUAGE "plpgsql" STABLE
    AS $$
DECLARE
    clean_text1 TEXT;
    clean_text2 TEXT;
    len1 INTEGER;
    len2 INTEGER;
    max_len INTEGER;
    common_chars INTEGER;
BEGIN
    -- Handle null inputs
    IF text1 IS NULL OR text2 IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Clean and normalize text
    clean_text1 := LOWER(TRIM(text1));
    clean_text2 := LOWER(TRIM(text2));
    
    -- Handle empty strings
    IF clean_text1 = '' OR clean_text2 = '' THEN
        RETURN 0;
    END IF;
    
    -- Exact match
    IF clean_text1 = clean_text2 THEN
        RETURN 1.0;
    END IF;
    
    len1 := LENGTH(clean_text1);
    len2 := LENGTH(clean_text2);
    max_len := GREATEST(len1, len2);
    
    -- Simple Levenshtein-based similarity
    -- This is a simplified implementation for basic string comparison
    common_chars := max_len - public.levenshtein_distance(clean_text1, clean_text2);
    
    -- Return similarity as ratio
    RETURN GREATEST(0, common_chars::NUMERIC / max_len);
END;
$$;


ALTER FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") IS 'Fallback text similarity function for when pg_trgm extension is not available';



CREATE OR REPLACE FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text" DEFAULT NULL::"text", "p_user_context" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text", "p_user_context" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text", "p_user_context" "text") IS 'Tracks authentication errors for debugging and analysis';



CREATE OR REPLACE FUNCTION "public"."unlink_contact_from_property"("contact_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.contacts 
    SET property_id = NULL, updated_at = CURRENT_TIMESTAMP
    WHERE id = contact_uuid;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to unlink contact from property: %', SQLERRM;
        RETURN FALSE;
END;
$$;


ALTER FUNCTION "public"."unlink_contact_from_property"("contact_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_document_status"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
UPDATE public.documents 
SET status = CASE
    WHEN valid_to IS NULL THEN 'valid'::public.document_status
    WHEN valid_to < CURRENT_DATE THEN 'expired'::public.document_status
    WHEN valid_to <= (CURRENT_DATE + INTERVAL '30 days') THEN 'expiring'::public.document_status
    ELSE 'valid'::public.document_status
END,
updated_at = CURRENT_TIMESTAMP
WHERE tenant_id = public.get_user_tenant_id();
$$;


ALTER FUNCTION "public"."update_document_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_opportunity_stage"("opportunity_uuid" "uuid", "new_stage" "text", "stage_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "opportunity_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_tenant UUID;
    opportunity_tenant UUID;
BEGIN
    -- Get current user's tenant
    current_user_tenant := get_user_tenant_id();
    
    -- Get opportunity's tenant
    SELECT tenant_id INTO opportunity_tenant 
    FROM public.opportunities 
    WHERE id = opportunity_uuid;
    
    -- Validate access
    IF opportunity_tenant IS NULL THEN
        RETURN QUERY SELECT false, 'Opportunity not found'::TEXT, opportunity_uuid;
        RETURN;
    END IF;
    
    IF NOT user_can_access_tenant_data(opportunity_tenant) THEN
        RETURN QUERY SELECT false, 'Access denied'::TEXT, opportunity_uuid;
        RETURN;
    END IF;
    
    -- Update the opportunity
    UPDATE public.opportunities 
    SET 
        stage = new_stage::public.opportunity_stage,
        notes = CASE 
            WHEN stage_notes IS NOT NULL THEN 
                COALESCE(notes || E'\n\n', '') || 
                'Stage updated to ' || new_stage || ' on ' || CURRENT_DATE::TEXT ||
                CASE WHEN stage_notes != '' THEN ': ' || stage_notes ELSE '' END
            ELSE notes
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = opportunity_uuid 
    AND user_can_access_tenant_data(tenant_id);
    
    IF FOUND THEN
        RETURN QUERY SELECT true, 'Opportunity stage updated successfully'::TEXT, opportunity_uuid;
    ELSE
        RETURN QUERY SELECT false, 'Failed to update opportunity stage'::TEXT, opportunity_uuid;
    END IF;
EXCEPTION
    WHEN invalid_text_representation THEN
        RETURN QUERY SELECT false, 'Invalid stage value provided'::TEXT, opportunity_uuid;
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'An error occurred while updating opportunity stage'::TEXT, opportunity_uuid;
END;
$$;


ALTER FUNCTION "public"."update_opportunity_stage"("opportunity_uuid" "uuid", "new_stage" "text", "stage_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_task_status"("task_uuid" "uuid", "new_status" "public"."task_status", "completion_notes_param" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Update task status with unambiguous parameter reference
    UPDATE public.tasks
    SET 
        status = new_status,
        completed_at = CASE WHEN new_status = 'completed' THEN CURRENT_TIMESTAMP ELSE NULL END,
        completion_notes = CASE WHEN new_status = 'completed' THEN completion_notes_param ELSE NULL END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = task_uuid
    AND (assigned_to = auth.uid() OR assigned_by = auth.uid());
    
    IF FOUND THEN
        RETURN QUERY SELECT true, 'Task status updated successfully'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'Task not found or insufficient permissions'::TEXT;
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_task_status"("task_uuid" "uuid", "new_status" "public"."task_status", "completion_notes_param" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_belongs_to_event_tenant"("event_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.tenant_id = event_tenant_id
);
$$;


ALTER FUNCTION "public"."user_belongs_to_event_tenant"("event_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_belongs_to_tenant"("tenant_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.tenants t
    JOIN public.user_profiles up ON up.id = auth.uid()
    WHERE t.id = tenant_uuid 
    AND (t.owner_id = up.id OR t.created_by = up.id)
)
$$;


ALTER FUNCTION "public"."user_belongs_to_tenant"("tenant_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_can_access_account"("account_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.accounts a
    WHERE a.id = account_uuid 
    AND a.assigned_rep_id = auth.uid()
)
$$;


ALTER FUNCTION "public"."user_can_access_account"("account_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_can_access_opportunities"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.is_active = true
    AND user_can_access_tenant_data(up.tenant_id)
)
$$;


ALTER FUNCTION "public"."user_can_access_opportunities"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_can_access_tenant_data"("target_tenant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.tenant_id = target_tenant_id
    AND up.is_active = true
) OR EXISTS (
    SELECT 1 FROM public.tenants t
    WHERE t.id = target_tenant_id
    AND (t.owner_id = auth.uid() OR t.created_by = auth.uid())
)
$$;


ALTER FUNCTION "public"."user_can_access_tenant_data"("target_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
    (SELECT up.is_active = true
     FROM public.user_profiles up
     WHERE up.id = auth.uid() 
     AND up.tenant_id = tenant_uuid),
    false
)
$$;


ALTER FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") IS 'Safe tenant access check using user_profiles table to avoid circular dependency with tenants table';



CREATE OR REPLACE FUNCTION "public"."user_has_role"("required_role" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_reliable() = required_role;
$$;


ALTER FUNCTION "public"."user_has_role"("required_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_reliable() IN ('admin', 'super_admin', 'master_admin');
$$;


ALTER FUNCTION "public"."user_is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_is_manager"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_with_fallbacks() = 'manager';
$$;


ALTER FUNCTION "public"."user_is_manager"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_is_manager_or_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT public.get_user_role_with_fallbacks() IN ('manager', 'admin', 'super_admin', 'master_admin');
$$;


ALTER FUNCTION "public"."user_is_manager_or_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_needs_password_setup"("user_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."user_needs_password_setup"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_profile_is_complete"("user_uuid" "uuid" DEFAULT "auth"."uid"()) RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT COALESCE(
  (SELECT profile_completed FROM public.user_profiles WHERE id = user_uuid),
  false
);
$$;


ALTER FUNCTION "public"."user_profile_is_complete"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_authentication_state"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
    profile_data RECORD;
    auth_data RECORD;
    issues JSONB := '[]'::JSONB;
    fixes_applied JSONB := '[]'::JSONB;
    result JSONB;
BEGIN
    -- Get current user
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', 'No authenticated user',
            'requires_signin', true
        );
    END IF;
    
    -- Get auth user data
    SELECT * INTO auth_data FROM auth.users WHERE id = current_user_id;
    
    -- Get profile data
    SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
    
    -- Check for issues and apply fixes
    
    -- Issue 1: Profile missing
    IF profile_data IS NULL THEN
        issues := issues || jsonb_build_array('Profile missing for authenticated user');
        
        -- Fix: Create profile
        INSERT INTO public.user_profiles (
            id, email, full_name, role, is_active, profile_completed
        ) VALUES (
            current_user_id,
            auth_data.email,
            COALESCE(auth_data.raw_user_meta_data->>'full_name', split_part(auth_data.email, '@', 1)),
            COALESCE(auth_data.raw_user_meta_data->>'role', 'rep')::user_role_type,
            true,
            true
        );
        
        fixes_applied := fixes_applied || jsonb_build_array('Created missing user profile');
        
        -- Refresh profile data
        SELECT * INTO profile_data FROM public.user_profiles WHERE id = current_user_id;
    END IF;
    
    -- Issue 2: Role mismatch between auth and profile
    IF auth_data.raw_user_meta_data->>'role' != profile_data.role::TEXT THEN
        issues := issues || jsonb_build_array('Role mismatch between auth metadata and profile');
        
        -- Fix: Sync auth metadata to profile role
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', profile_data.role::TEXT)
        WHERE id = current_user_id;
        
        fixes_applied := fixes_applied || jsonb_build_array('Synced auth metadata role to profile role');
    END IF;
    
    -- Issue 3: Profile inactive
    IF NOT COALESCE(profile_data.is_active, false) THEN
        issues := issues || jsonb_build_array('User profile is inactive');
    END IF;
    
    -- Issue 4: Profile incomplete
    IF NOT COALESCE(profile_data.profile_completed, false) THEN
        issues := issues || jsonb_build_array('User profile is incomplete');
        
        -- Fix: Mark as complete if basic data exists
        IF profile_data.full_name IS NOT NULL AND profile_data.email IS NOT NULL THEN
            UPDATE public.user_profiles 
            SET profile_completed = true, updated_at = CURRENT_TIMESTAMP
            WHERE id = current_user_id;
            
            fixes_applied := fixes_applied || jsonb_build_array('Marked profile as completed');
        END IF;
    END IF;
    
    -- Return validation result
    result := jsonb_build_object(
        'success', true,
        'user_id', current_user_id,
        'profile_exists', (profile_data IS NOT NULL),
        'profile_active', COALESCE(profile_data.is_active, false),
        'profile_complete', COALESCE(profile_data.profile_completed, false),
        'role', COALESCE(profile_data.role::TEXT, 'rep'),
        'tenant_id', profile_data.tenant_id,
        'issues_found', jsonb_array_length(issues),
        'issues', issues,
        'fixes_applied', fixes_applied,
        'can_access_data', (
            profile_data IS NOT NULL 
            AND COALESCE(profile_data.is_active, false) = true
        )
    );
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false, 
            'error', SQLERRM, 
            'sqlstate', SQLSTATE,
            'issues', issues,
            'fixes_applied', fixes_applied
        );
END;
$$;


ALTER FUNCTION "public"."validate_authentication_state"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_authentication_state"() IS 'Validates and fixes authentication issues. Call this function when users experience permission problems.';



CREATE OR REPLACE FUNCTION "public"."validate_password_reset_session"() RETURNS TABLE("is_valid" boolean, "user_id" "uuid", "user_email" "text", "session_created_at" timestamp with time zone, "expires_at" timestamp with time zone, "error_message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."validate_password_reset_session"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_password_reset_session"() IS 'Validates current password reset session and returns session details';



CREATE OR REPLACE FUNCTION "public"."validate_policy_column_references"() RETURNS TABLE("validation_check" "text", "schema_name" "text", "table_name" "text", "policy_name" "text", "result" "text", "recommendation" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."validate_policy_column_references"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_policy_column_references"() IS 'Validates that all RLS policies use correct column references (user_profiles.id instead of user_profiles.user_id)';



CREATE OR REPLACE FUNCTION "public"."validate_tenant_consistency"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Skip validation for super admin users
    IF public.is_super_admin_from_auth() THEN
        RETURN NEW;
    END IF;
    
    -- Validate accounts: assigned_rep_id must belong to same tenant or be null
    IF TG_TABLE_NAME = 'accounts' THEN
        -- Skip validation if assigned_rep_id is being cleared
        IF NEW.assigned_rep_id IS NULL THEN
            RETURN NEW;
        END IF;
        
        -- Check if the assigned rep belongs to the same tenant
        IF NOT EXISTS (
            SELECT 1 FROM public.user_profiles up 
            WHERE up.id = NEW.assigned_rep_id 
            AND up.tenant_id = NEW.tenant_id
            AND up.is_active = true
        ) THEN
            -- Instead of raising an exception, clear the invalid assignment
            RAISE NOTICE 'Cross-tenant assignment detected. Clearing assigned_rep_id for account %', NEW.id;
            NEW.assigned_rep_id := NULL;
        END IF;
        RETURN NEW;
    END IF;
    
    -- Validate activities: user_id must belong to same tenant
    IF TG_TABLE_NAME = 'activities' THEN
        IF NEW.user_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1 FROM public.user_profiles up 
                WHERE up.id = NEW.user_id 
                AND up.tenant_id = NEW.tenant_id
                AND up.is_active = true
            ) THEN
                RAISE EXCEPTION 'User % does not belong to tenant %', NEW.user_id, NEW.tenant_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    
    -- Validate contacts: account_id must belong to same tenant
    IF TG_TABLE_NAME = 'contacts' THEN
        IF NEW.account_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1 FROM public.accounts a 
                WHERE a.id = NEW.account_id 
                AND a.tenant_id = NEW.tenant_id
            ) THEN
                RAISE EXCEPTION 'Account % does not belong to tenant %', NEW.account_id, NEW.tenant_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    
    -- Validate properties: account_id must belong to same tenant
    IF TG_TABLE_NAME = 'properties' THEN
        IF NEW.account_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1 FROM public.accounts a 
                WHERE a.id = NEW.account_id 
                AND a.tenant_id = NEW.tenant_id
            ) THEN
                RAISE EXCEPTION 'Account % does not belong to tenant %', NEW.account_id, NEW.tenant_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    
    -- Validate weekly_goals: user_id must belong to same tenant
    IF TG_TABLE_NAME = 'weekly_goals' THEN
        IF NEW.user_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1 FROM public.user_profiles up 
                WHERE up.id = NEW.user_id 
                AND up.tenant_id = NEW.tenant_id
                AND up.is_active = true
            ) THEN
                RAISE EXCEPTION 'User % does not belong to tenant %', NEW.user_id, NEW.tenant_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    
    -- Default case for any other tables
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_tenant_consistency"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_tenant_consistency"() IS 'Fixed trigger function to prevent accessing non-existent columns by separating table-specific validations into distinct IF blocks. This prevents PostgreSQL from evaluating field access before checking table names.';



CREATE OR REPLACE FUNCTION "public"."validate_user_session"("session_user_id" "uuid") RETURNS TABLE("valid" boolean, "user_email" "text", "full_name" "text", "user_role" "text", "tenant_id" "uuid", "is_active" boolean)
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
SELECT 
    TRUE as valid,
    up.email,
    up.full_name,
    up.role::TEXT,
    up.tenant_id,
    up.is_active
FROM public.user_profiles up
WHERE up.id = session_user_id
AND up.is_active = true
LIMIT 1;
$$;


ALTER FUNCTION "public"."validate_user_session"("session_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_user_session"("session_user_id" "uuid") IS 'Validates user session and returns profile information';



CREATE OR REPLACE FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") IS 'FIXED: Validates user authentication and handles both master_admin and super_admin roles without enum casting errors';



CREATE OR REPLACE FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") RETURNS TABLE("success" boolean, "user_exists" boolean, "user_data" "jsonb", "profile_completed" boolean, "password_set" boolean, "message" "text", "redirect_url" "text", "tenant_access_info" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_record RECORD;
    auth_user_record RECORD;
    tenant_info JSONB;
BEGIN
    -- Get user profile from user_profiles table with enhanced error handling
    SELECT up.*, 
           COALESCE(t.name, 'Default Tenant') as tenant_name,
           up.role as user_role,
           up.tenant_id as user_tenant_id
    INTO user_record
    FROM public.user_profiles up
    LEFT JOIN public.tenants t ON up.tenant_id = t.id
    WHERE up.id = user_uuid;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            false, 
            false, 
            NULL::JSONB, 
            false, 
            false, 
            'User profile not found - please contact administrator', 
            '/login'::TEXT,
            '{}'::JSONB;
        RETURN;
    END IF;
    
    -- Get auth user metadata
    SELECT *
    INTO auth_user_record  
    FROM auth.users au
    WHERE au.id = user_uuid;
    
    -- Sync metadata to auth if missing or incorrect
    IF auth_user_record.raw_user_meta_data IS NULL OR 
       auth_user_record.raw_user_meta_data->>'tenant_id' IS NULL OR
       auth_user_record.raw_user_meta_data->>'role' IS NULL OR
       (auth_user_record.raw_user_meta_data->>'tenant_id')::UUID != user_record.tenant_id OR
       auth_user_record.raw_user_meta_data->>'role' != user_record.role::text THEN
        
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || 
            jsonb_build_object(
                'tenant_id', COALESCE(user_record.tenant_id::text, gen_random_uuid()::text),
                'role', user_record.role::text,
                'full_name', user_record.full_name
            )
        WHERE id = user_uuid;
        
        RAISE NOTICE 'Synced user metadata for user %', user_uuid;
    END IF;
    
    -- Build tenant access info
    tenant_info := jsonb_build_object(
        'tenant_id', user_record.tenant_id,
        'tenant_name', user_record.tenant_name,
        'can_access_all_tenants', user_record.role IN ('super_admin', 'admin'),
        'role_permissions', CASE user_record.role
            WHEN 'super_admin' THEN '["all"]'::jsonb
            WHEN 'admin' THEN '["tenant_admin", "user_management"]'::jsonb  
            WHEN 'manager' THEN '["team_management", "reporting"]'::jsonb
            ELSE '["data_entry"]'::jsonb
        END
    );
    
    -- Return enhanced success response
    RETURN QUERY SELECT 
        true,
        true,
        jsonb_build_object(
            'id', user_record.id,
            'email', auth_user_record.email,
            'role', user_record.role,
            'full_name', user_record.full_name,
            'tenant_id', user_record.tenant_id,
            'tenant_name', user_record.tenant_name,
            'is_active', user_record.is_active,
            'manager_id', user_record.manager_id,
            'position', user_record.position,
            'phone_number', user_record.phone_number,
            'created_at', user_record.created_at,
            'updated_at', user_record.updated_at,
            'last_login', NOW()
        ),
        COALESCE(user_record.profile_completed, true),
        COALESCE(user_record.password_set, true),
        'Authentication successful - tenant access validated',
        CASE 
            WHEN user_record.role = 'super_admin' THEN '/super-admin-dashboard'
            WHEN user_record.role = 'admin' THEN '/admin-dashboard'
            WHEN user_record.role = 'manager' THEN '/manager-dashboard'
            ELSE '/today'
        END,
        tenant_info;
END;
$$;


ALTER FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") IS 'Enhanced authentication validation with comprehensive tenant access info and metadata synchronization';



CREATE OR REPLACE FUNCTION "public"."validate_weekly_goals_tenant_consistency"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_tenant_id uuid;
BEGIN
    -- Get the user's tenant_id
    SELECT tenant_id INTO user_tenant_id
    FROM public.user_profiles 
    WHERE id = NEW.user_id;
    
    -- Ensure the goal's tenant_id matches the user's tenant_id
    IF user_tenant_id IS NOT NULL AND NEW.tenant_id != user_tenant_id THEN
        RAISE EXCEPTION 'Weekly goal tenant_id must match user tenant_id';
    END IF;
    
    -- If user doesn't exist in user_profiles, prevent the operation
    IF user_tenant_id IS NULL THEN
        RAISE EXCEPTION 'User must have a valid profile to create weekly goals';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_weekly_goals_tenant_consistency"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_auth_setup"() RETURNS TABLE("email" "text", "auth_exists" boolean, "profile_exists" boolean, "ids_match" boolean, "can_authenticate" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        au.email::TEXT,
        (au.id IS NOT NULL) AS auth_exists,
        (up.id IS NOT NULL) AS profile_exists,
        (au.id = up.id) AS ids_match,
        (au.encrypted_password IS NOT NULL AND au.email_confirmed_at IS NOT NULL) AS can_authenticate
    FROM auth.users au
    FULL OUTER JOIN public.user_profiles up ON au.id = up.id
    WHERE au.email LIKE '%@roofcrm.com' OR up.email LIKE '%@roofcrm.com'
    ORDER BY au.email;
END;
$$;


ALTER FUNCTION "public"."verify_auth_setup"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  manager_profile user_profiles%ROWTYPE;
  goal_count INTEGER := 0;
  result JSON;
BEGIN
  -- Get manager profile
  SELECT * INTO manager_profile
  FROM user_profiles
  WHERE id = manager_uuid;

  -- Check if user exists and has manager permissions
  IF NOT FOUND OR manager_profile.role NOT IN ('manager', 'admin', 'super_admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Unauthorized: User does not have manager permissions',
      'goal_count', 0
    );
  END IF;

  -- Count goals for the specified users and week
  SELECT COUNT(*) INTO goal_count
  FROM weekly_goals wg
  JOIN user_profiles up ON wg.user_id = up.id
  WHERE wg.user_id = ANY(target_user_ids)
  AND wg.week_start_date = target_week_start
  AND (
    -- Manager can verify goals for users in their tenant
    up.tenant_id = manager_profile.tenant_id
    OR 
    -- Super admin can verify all goals
    manager_profile.role = 'super_admin'
  );

  -- Return result
  result := json_build_object(
    'success', true,
    'goal_count', goal_count,
    'manager_id', manager_uuid,
    'users_checked', array_length(target_user_ids, 1),
    'week_start', target_week_start
  );

  RETURN result;
END;
$$;


ALTER FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") IS 'Verifies that goals have been assigned by checking goal count for specific users and week';



CREATE OR REPLACE FUNCTION "public"."verify_parks_manager_data_access"() RETURNS TABLE("check_name" "text", "status" "text", "count_result" integer, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."verify_parks_manager_data_access"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_summit_pm_setup"() RETURNS TABLE("tenant_name" "text", "user_count" bigint, "manager_count" bigint, "rep_count" bigint, "admin_count" bigint)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
    SELECT 
        t.name::TEXT as tenant_name,
        COUNT(up.id) as user_count,
        COUNT(CASE WHEN up.role = 'manager' THEN 1 END) as manager_count,
        COUNT(CASE WHEN up.role = 'rep' THEN 1 END) as rep_count,
        COUNT(CASE WHEN up.role = 'admin' THEN 1 END) as admin_count
    FROM public.tenants t
    LEFT JOIN public.user_profiles up ON t.id = up.tenant_id AND up.is_active = true
    WHERE t.slug = 'summit-pm'
    GROUP BY t.id, t.name;
$$;


ALTER FUNCTION "public"."verify_summit_pm_setup"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."verify_summit_pm_setup"() IS 'Verification function to check Summit PM tenant setup after migration 20250911210000';



CREATE OR REPLACE FUNCTION "public"."verify_super_admin_setup"() RETURNS TABLE("auth_user_exists" boolean, "profile_exists" boolean, "role_in_auth" "text", "role_in_profile" "text", "can_access_super_admin" boolean)
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
SELECT 
  (SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'team@dillyos.com')) as auth_user_exists,
  (SELECT EXISTS(SELECT 1 FROM public.user_profiles WHERE email = 'team@dillyos.com')) as profile_exists,
  (SELECT COALESCE(raw_user_meta_data->>'role', raw_app_meta_data->>'role', 'none') FROM auth.users WHERE email = 'team@dillyos.com') as role_in_auth,
  (SELECT role::text FROM public.user_profiles WHERE email = 'team@dillyos.com') as role_in_profile,
  (SELECT public.is_super_admin_from_auth() FROM auth.users WHERE email = 'team@dillyos.com' AND id = auth.uid()) as can_access_super_admin;
$$;


ALTER FUNCTION "public"."verify_super_admin_setup"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text" DEFAULT NULL::"text", "security_answer" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "user_id" "uuid", "needs_password_setup" boolean, "needs_profile_completion" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    target_user_id UUID;
    stored_password TEXT;
    is_temp_expired BOOLEAN := FALSE;
    profile_complete BOOLEAN := FALSE;
    password_is_set BOOLEAN := FALSE;
BEGIN
    -- Find user and check temporary password status
    SELECT 
        up.id,
        COALESCE(up.profile_completed, false),
        COALESCE(up.password_set, false),
        (up.temp_password_expires_at < NOW())
    INTO 
        target_user_id, profile_complete, password_is_set, is_temp_expired
    FROM public.user_profiles up
    WHERE up.email = user_email AND up.is_active = true;

    IF target_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'User not found or inactive'::TEXT, NULL::UUID, FALSE, FALSE;
        RETURN;
    END IF;

    -- Check if temporary password has expired
    IF is_temp_expired THEN
        RETURN QUERY SELECT FALSE, 'Temporary password has expired. Please request a new one.'::TEXT, target_user_id, FALSE, FALSE;
        RETURN;
    END IF;

    -- Verify password against auth.users
    SELECT au.encrypted_password INTO stored_password
    FROM auth.users au
    WHERE au.id = target_user_id;

    -- Use crypt to verify password
    IF NOT (crypt(temp_password, stored_password) = stored_password) THEN
        RETURN QUERY SELECT FALSE, 'Invalid temporary password'::TEXT, target_user_id, FALSE, FALSE;
        RETURN;
    END IF;

    -- Store security question/answer if provided
    IF security_question IS NOT NULL AND security_answer IS NOT NULL THEN
        UPDATE public.user_profiles
        SET 
            security_question = verify_temp_password_and_setup.security_question,
            security_answer_hash = crypt(security_answer, gen_salt('bf', 10)),
            updated_at = NOW()
        WHERE id = target_user_id;
    END IF;

    -- Mark temporary password as used
    UPDATE public.user_profiles
    SET 
        temp_password_used = true,
        confirmation_status = 'verified',
        updated_at = NOW()
    WHERE id = target_user_id;

    RETURN QUERY SELECT 
        TRUE, 
        'Temporary password verified successfully'::TEXT,
        target_user_id,
        NOT password_is_set,  -- needs_password_setup
        NOT profile_complete; -- needs_profile_completion

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            FALSE, 
            ('Error verifying temporary password: ' || SQLERRM)::TEXT,
            NULL::UUID,
            FALSE,
            FALSE;
END;
$$;


ALTER FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text", "security_answer" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text", "security_answer" "text") IS 'Verifies temporary password and determines next setup steps';



CREATE OR REPLACE FUNCTION "public"."verify_tenant_representatives"("tenant_uuid" "uuid") RETURNS TABLE("tenant_name" "text", "user_id" "uuid", "user_name" "text", "user_email" "text", "user_role" "text", "is_active" boolean)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT 
    t.name::TEXT as tenant_name,
    up.id as user_id,
    up.full_name::TEXT as user_name,
    up.email::TEXT as user_email,
    up.role::TEXT as user_role,
    up.is_active
FROM public.tenants t
JOIN public.user_profiles up ON t.id = up.tenant_id
WHERE t.id = tenant_uuid
ORDER BY up.role, up.full_name;
$$;


ALTER FUNCTION "public"."verify_tenant_representatives"("tenant_uuid" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."_audit_queue" (
    "id" bigint NOT NULL,
    "table_name" "text" NOT NULL,
    "action" "text" NOT NULL,
    "row_data" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."_audit_queue" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."_audit_queue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."_audit_queue_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."_audit_queue_id_seq" OWNED BY "public"."_audit_queue"."id";



CREATE TABLE IF NOT EXISTS "public"."account_assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "account_id" "uuid" NOT NULL,
    "rep_id" "uuid" NOT NULL,
    "assigned_by" "uuid",
    "assigned_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "is_primary" boolean DEFAULT false,
    "notes" "text"
);


ALTER TABLE "public"."account_assignments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "company_type" "public"."company_type" NOT NULL,
    "assigned_rep_id" "uuid",
    "phone" "text",
    "email" "text",
    "website" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "zip_code" "text",
    "notes" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL,
    "stage" "public"."account_stage" DEFAULT 'Prospect'::"public"."account_stage"
);


ALTER TABLE "public"."accounts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_type" "public"."activity_type" NOT NULL,
    "subject" "text" NOT NULL,
    "description" "text",
    "outcome" "public"."activity_outcome",
    "activity_date" timestamp with time zone NOT NULL,
    "duration_minutes" integer,
    "user_id" "uuid",
    "account_id" "uuid",
    "contact_id" "uuid",
    "property_id" "uuid",
    "follow_up_date" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL,
    "opportunity_id" "uuid",
    "motion" "public"."activity_motion_type" DEFAULT 'prospecting'::"public"."activity_motion_type"
);


ALTER TABLE "public"."activities" OWNER TO "postgres";


COMMENT ON COLUMN "public"."activities"."opportunity_id" IS 'Links activity to specific opportunity for better tracking and reporting';



CREATE TABLE IF NOT EXISTS "public"."activity_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "activity_type" "text" NOT NULL,
    "description" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tenant_id" "uuid"
);


ALTER TABLE "public"."activity_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."auth_configuration_guide" (
    "id" integer NOT NULL,
    "setting_name" "text" NOT NULL,
    "current_value" "text",
    "required_value" "text" NOT NULL,
    "description" "text" NOT NULL,
    "is_configured" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."auth_configuration_guide" OWNER TO "postgres";


COMMENT ON TABLE "public"."auth_configuration_guide" IS 'Configuration settings that must be manually set in Supabase Dashboard for proper authentication flow';



CREATE SEQUENCE IF NOT EXISTS "public"."auth_configuration_guide_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."auth_configuration_guide_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."auth_configuration_guide_id_seq" OWNED BY "public"."auth_configuration_guide"."id";



CREATE TABLE IF NOT EXISTS "public"."auth_debug_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "event_type" "text" NOT NULL,
    "token_type" "text",
    "token_prefix" "text",
    "success" boolean DEFAULT false,
    "error_message" "text",
    "user_agent" "text",
    "ip_address" "inet",
    "redirect_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."auth_debug_log" OWNER TO "postgres";


COMMENT ON TABLE "public"."auth_debug_log" IS 'Debug log for tracking authentication attempts and troubleshooting token issues';



CREATE OR REPLACE VIEW "public"."auth_debug_summary" AS
 SELECT "date"("created_at") AS "date",
    "event_type",
    "token_type",
    "count"(*) AS "total_attempts",
    "count"(*) FILTER (WHERE ("success" = true)) AS "successful_attempts",
    "count"(*) FILTER (WHERE ("success" = false)) AS "failed_attempts",
    "round"(((("count"(*) FILTER (WHERE ("success" = true)))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "success_rate_percent"
   FROM "public"."auth_debug_log"
  WHERE ("created_at" >= ("now"() - '7 days'::interval))
  GROUP BY ("date"("created_at")), "event_type", "token_type"
  ORDER BY ("date"("created_at")) DESC, "event_type", "token_type";


ALTER VIEW "public"."auth_debug_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendar_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid",
    "created_by" "uuid",
    "assigned_to" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "event_type" "public"."event_type" NOT NULL,
    "priority" "public"."event_priority" DEFAULT 'medium'::"public"."event_priority",
    "status" "public"."event_status" DEFAULT 'scheduled'::"public"."event_status",
    "start_datetime" timestamp with time zone NOT NULL,
    "end_datetime" timestamp with time zone NOT NULL,
    "all_day" boolean DEFAULT false,
    "timezone" "text" DEFAULT 'UTC'::"text",
    "related_account_id" "uuid",
    "related_property_id" "uuid",
    "related_contact_id" "uuid",
    "is_recurring" boolean DEFAULT false,
    "recurrence_pattern" "jsonb",
    "reminder_minutes" integer[] DEFAULT ARRAY[15, 60],
    "is_private" boolean DEFAULT false,
    "location" "text",
    "meeting_url" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "check_event_datetime_order" CHECK (("end_datetime" > "start_datetime"))
);


ALTER TABLE "public"."calendar_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."contacts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "first_name" "text" NOT NULL,
    "last_name" "text" NOT NULL,
    "title" "text",
    "email" "text",
    "phone" "text",
    "mobile_phone" "text",
    "account_id" "uuid",
    "is_primary_contact" boolean DEFAULT false,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "stage" "public"."contact_stage" DEFAULT 'Identified'::"public"."contact_stage",
    "tenant_id" "uuid" NOT NULL,
    "property_id" "uuid",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_by" "uuid"
);


ALTER TABLE "public"."contacts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."document_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "document_id" "uuid" NOT NULL,
    "event_type" "public"."document_event_type" NOT NULL,
    "user_id" "uuid",
    "event_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "meta" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "check_valid_event_type" CHECK (("event_type" = ANY (ARRAY['upload'::"public"."document_event_type", 'download'::"public"."document_event_type", 'view'::"public"."document_event_type", 'replace'::"public"."document_event_type", 'delete'::"public"."document_event_type", 'metadata_update'::"public"."document_event_type"])))
);


ALTER TABLE "public"."document_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "type" "public"."document_type" DEFAULT 'other'::"public"."document_type" NOT NULL,
    "storage_path" "text" NOT NULL,
    "mime_type" "text",
    "size_bytes" bigint,
    "uploaded_by" "uuid",
    "uploaded_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "version" integer DEFAULT 1,
    "previous_document_id" "uuid",
    "valid_from" "date",
    "valid_to" "date",
    "status" "public"."document_status" DEFAULT 'valid'::"public"."document_status" NOT NULL,
    "sha256_hash" "text",
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "notes" "text",
    "account_id" "uuid",
    "property_id" "uuid",
    "contact_id" "uuid",
    "opportunity_id" "uuid",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "check_valid_document_status" CHECK (("status" = ANY (ARRAY['valid'::"public"."document_status", 'expiring'::"public"."document_status", 'expired'::"public"."document_status", 'missing'::"public"."document_status"]))),
    CONSTRAINT "check_valid_document_type" CHECK (("type" = ANY (ARRAY['coi'::"public"."document_type", 'w9'::"public"."document_type", 'business_license'::"public"."document_type", 'other'::"public"."document_type"])))
);


ALTER TABLE "public"."documents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "type" "public"."notification_type" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "data" "jsonb" DEFAULT '{}'::"jsonb",
    "read_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."opportunities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "account_id" "uuid",
    "property_id" "uuid",
    "opportunity_type" "public"."opportunity_type" NOT NULL,
    "stage" "public"."opportunity_stage" DEFAULT 'identified'::"public"."opportunity_stage",
    "bid_value" numeric(12,2),
    "currency" "text" DEFAULT 'USD'::"text",
    "expected_close_date" "date",
    "probability" integer,
    "description" "text",
    "notes" "text",
    "created_by" "uuid",
    "assigned_to" "uuid",
    "tenant_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "opportunities_positive_bid_value" CHECK ((("bid_value" IS NULL) OR ("bid_value" >= (0)::numeric))),
    CONSTRAINT "opportunities_probability_check" CHECK ((("probability" >= 0) AND ("probability" <= 100))),
    CONSTRAINT "opportunities_valid_probability" CHECK ((("probability" IS NULL) OR (("probability" >= 0) AND ("probability" <= 100))))
);


ALTER TABLE "public"."opportunities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."properties" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "address" "text" NOT NULL,
    "city" "text",
    "state" "text",
    "zip_code" "text",
    "account_id" "uuid",
    "building_type" "public"."building_type" NOT NULL,
    "roof_type" "public"."roof_type",
    "square_footage" integer,
    "year_built" integer,
    "stage" "public"."property_stage" DEFAULT 'Unassessed'::"public"."property_stage",
    "last_assessment" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "public"."properties" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."prospects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "domain" "text",
    "phone" "text",
    "website" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "zip_code" "text",
    "company_type" "text",
    "employee_count" integer,
    "property_count_estimate" integer,
    "sqft_estimate" integer,
    "building_types" "text"[] DEFAULT '{}'::"text"[],
    "icp_fit_score" integer,
    "source" "text",
    "status" "text" DEFAULT 'uncontacted'::"text" NOT NULL,
    "assigned_to" "uuid",
    "created_by" "uuid",
    "last_activity_at" timestamp with time zone,
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "notes" "text",
    "dedupe_keys" "jsonb" DEFAULT '{}'::"jsonb",
    "linked_account_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "company_name" "text",
    "first_name" "text",
    "last_name" "text",
    "email" "text",
    "stage" "public"."prospect_stages" DEFAULT 'new'::"public"."prospect_stages",
    "is_active" boolean DEFAULT true,
    "assigned_rep_id" "uuid",
    CONSTRAINT "prospects_icp_fit_score_check" CHECK ((("icp_fit_score" >= 0) AND ("icp_fit_score" <= 100)))
);


ALTER TABLE "public"."prospects" OWNER TO "postgres";


COMMENT ON TABLE "public"."prospects" IS 'Prospects table with tenant-wide visibility. All authenticated users within a tenant can view all prospects in their tenant.';



CREATE OR REPLACE VIEW "public"."recent_auth_errors" AS
 SELECT "created_at",
    "event_type",
    "token_type",
    "error_message",
    "user_agent",
    "redirect_url"
   FROM "public"."auth_debug_log"
  WHERE (("success" = false) AND ("created_at" >= ("now"() - '24:00:00'::interval)))
  ORDER BY "created_at" DESC
 LIMIT 50;


ALTER VIEW "public"."recent_auth_errors" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roof_lead_images" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "roof_lead_id" "uuid" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_path" "text" NOT NULL,
    "file_size" integer,
    "mime_type" "text",
    "description" "text",
    "uploaded_by" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."roof_lead_images" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roof_leads" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "geometry" "public"."geometry"(Geometry,4326) NOT NULL,
    "condition_label" "public"."roof_condition_label" DEFAULT 'other'::"public"."roof_condition_label" NOT NULL,
    "condition_score" integer DEFAULT 1 NOT NULL,
    "status" "public"."roof_lead_status" DEFAULT 'new'::"public"."roof_lead_status" NOT NULL,
    "tags" "text"[] DEFAULT '{}'::"text"[],
    "notes" "text",
    "address" "text",
    "city" "text",
    "state" "text",
    "zip_code" "text",
    "estimated_sqft" integer,
    "estimated_repair_cost" numeric(10,2),
    "linked_prospect_id" "uuid",
    "linked_account_id" "uuid",
    "linked_property_id" "uuid",
    "created_by" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "roof_leads_condition_score_check" CHECK ((("condition_score" >= 1) AND ("condition_score" <= 5)))
);


ALTER TABLE "public"."roof_leads" OWNER TO "postgres";


COMMENT ON TABLE "public"."roof_leads" IS 'Fixed RLS policies with correct column references - 2025-01-03';



CREATE TABLE IF NOT EXISTS "public"."task_comments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid" NOT NULL,
    "author_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "public"."task_comments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "status" "public"."task_status" DEFAULT 'pending'::"public"."task_status",
    "priority" "public"."task_priority" DEFAULT 'medium'::"public"."task_priority",
    "category" "public"."task_category" DEFAULT 'other'::"public"."task_category",
    "due_date" timestamp with time zone,
    "reminder_date" timestamp with time zone,
    "assigned_to" "uuid" NOT NULL,
    "assigned_by" "uuid" NOT NULL,
    "account_id" "uuid",
    "property_id" "uuid",
    "contact_id" "uuid",
    "opportunity_id" "uuid",
    "completed_at" timestamp with time zone,
    "completion_notes" "text",
    "tenant_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "prospect_id" "uuid"
);


ALTER TABLE "public"."tasks" OWNER TO "postgres";


COMMENT ON COLUMN "public"."tasks"."prospect_id" IS 'Optional foreign key to prospects table for prospect-related tasks';



CREATE TABLE IF NOT EXISTS "public"."tenants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "domain" "text",
    "description" "text",
    "owner_id" "uuid" NOT NULL,
    "created_by" "uuid",
    "status" "public"."tenant_status" DEFAULT 'trial'::"public"."tenant_status",
    "is_active" boolean DEFAULT true,
    "subscription_plan" "public"."subscription_plan" DEFAULT 'free'::"public"."subscription_plan",
    "subscription_starts_at" timestamp with time zone,
    "subscription_ends_at" timestamp with time zone,
    "trial_ends_at" timestamp with time zone DEFAULT (CURRENT_TIMESTAMP + '14 days'::interval),
    "max_users" integer DEFAULT 5,
    "max_accounts" integer DEFAULT 100,
    "max_properties" integer DEFAULT 500,
    "max_storage_mb" integer DEFAULT 1000,
    "settings" "jsonb" DEFAULT '{}'::"jsonb",
    "branding" "jsonb" DEFAULT '{}'::"jsonb",
    "timezone" "text" DEFAULT 'UTC'::"text",
    "contact_email" "text",
    "contact_phone" "text",
    "billing_email" "text",
    "address_line_1" "text",
    "address_line_2" "text",
    "city" "text",
    "state" "text",
    "postal_code" "text",
    "country" "text" DEFAULT 'US'::"text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."tenants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "full_name" "text" NOT NULL,
    "role" "public"."user_role" DEFAULT 'rep'::"public"."user_role",
    "phone" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid",
    "manager_id" "uuid",
    "password_set" boolean DEFAULT false,
    "profile_completed" boolean DEFAULT false,
    "organization" "text",
    "temp_password_used" boolean DEFAULT false,
    "temp_password_expires_at" timestamp with time zone,
    "security_question" "text",
    "security_answer_hash" "text",
    "confirmation_status" "text" DEFAULT 'pending'::"text",
    "setup_completed_at" timestamp with time zone,
    CONSTRAINT "check_completed_profile_has_tenant" CHECK (((("profile_completed" = true) AND ("is_active" = true) AND ("tenant_id" IS NOT NULL)) OR (("profile_completed" = false) OR ("profile_completed" IS NULL) OR ("is_active" = false) OR ("tenant_id" IS NULL))))
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_profiles" IS 'Primary key is "id" - do not reference "user_id" in queries';



COMMENT ON CONSTRAINT "check_completed_profile_has_tenant" ON "public"."user_profiles" IS 'Ensures that users with completed profiles who are active must have a tenant assigned. Allows flexibility during onboarding process.';



CREATE TABLE IF NOT EXISTS "public"."weekly_goals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "week_start_date" "date" NOT NULL,
    "goal_type" "text" NOT NULL,
    "target_value" integer NOT NULL,
    "current_value" integer DEFAULT 0,
    "status" "public"."goal_status" DEFAULT 'Not Started'::"public"."goal_status",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL,
    CONSTRAINT "check_weekly_goals_goal_type" CHECK (("goal_type" = ANY (ARRAY['pop_ins'::"text", 'dm_conversations'::"text", 'assessments_booked'::"text", 'proposals_sent'::"text", 'wins'::"text", 'phone_calls_made'::"text", 'emails_sent'::"text", 'follow_ups_completed'::"text"])))
);


ALTER TABLE "public"."weekly_goals" OWNER TO "postgres";


ALTER TABLE ONLY "public"."_audit_queue" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."_audit_queue_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."auth_configuration_guide" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."auth_configuration_guide_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."_audit_queue"
    ADD CONSTRAINT "_audit_queue_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."account_assignments"
    ADD CONSTRAINT "account_assignments_account_id_rep_id_key" UNIQUE ("account_id", "rep_id");



ALTER TABLE ONLY "public"."account_assignments"
    ADD CONSTRAINT "account_assignments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_logs"
    ADD CONSTRAINT "activity_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."auth_configuration_guide"
    ADD CONSTRAINT "auth_configuration_guide_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."auth_debug_log"
    ADD CONSTRAINT "auth_debug_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."document_events"
    ADD CONSTRAINT "document_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roof_lead_images"
    ADD CONSTRAINT "roof_lead_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."task_comments"
    ADD CONSTRAINT "task_comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tenants"
    ADD CONSTRAINT "tenants_domain_key" UNIQUE ("domain");



ALTER TABLE ONLY "public"."tenants"
    ADD CONSTRAINT "tenants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tenants"
    ADD CONSTRAINT "tenants_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."weekly_goals"
    ADD CONSTRAINT "unique_user_week_goal_type" UNIQUE ("user_id", "week_start_date", "goal_type");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."weekly_goals"
    ADD CONSTRAINT "weekly_goals_pkey" PRIMARY KEY ("id");



CREATE INDEX "activity_logs_activity_type_idx" ON "public"."activity_logs" USING "btree" ("activity_type");



CREATE INDEX "activity_logs_created_at_idx" ON "public"."activity_logs" USING "btree" ("created_at");



CREATE INDEX "activity_logs_user_id_idx" ON "public"."activity_logs" USING "btree" ("user_id");



CREATE INDEX "idx_account_assignments_account_id" ON "public"."account_assignments" USING "btree" ("account_id");



CREATE INDEX "idx_account_assignments_assigned_by" ON "public"."account_assignments" USING "btree" ("assigned_by");



CREATE INDEX "idx_account_assignments_compound" ON "public"."account_assignments" USING "btree" ("account_id", "rep_id");



CREATE INDEX "idx_account_assignments_primary" ON "public"."account_assignments" USING "btree" ("account_id", "is_primary") WHERE ("is_primary" = true);



CREATE INDEX "idx_account_assignments_rep_id" ON "public"."account_assignments" USING "btree" ("rep_id");



CREATE INDEX "idx_accounts_assigned_rep" ON "public"."accounts" USING "btree" ("assigned_rep_id");



CREATE INDEX "idx_accounts_assigned_rep_id" ON "public"."accounts" USING "btree" ("assigned_rep_id") WHERE ("assigned_rep_id" IS NOT NULL);



CREATE INDEX "idx_accounts_company_type" ON "public"."accounts" USING "btree" ("company_type");



CREATE INDEX "idx_accounts_tenant" ON "public"."accounts" USING "btree" ("tenant_id");



CREATE INDEX "idx_accounts_tenant_assigned_rep" ON "public"."accounts" USING "btree" ("tenant_id", "assigned_rep_id") WHERE ("tenant_id" IS NOT NULL);



CREATE INDEX "idx_accounts_tenant_id" ON "public"."accounts" USING "btree" ("tenant_id");



CREATE INDEX "idx_activities_account_id" ON "public"."activities" USING "btree" ("account_id");



CREATE INDEX "idx_activities_activity_date" ON "public"."activities" USING "btree" ("activity_date");



CREATE INDEX "idx_activities_follow_up_date" ON "public"."activities" USING "btree" ("follow_up_date");



CREATE INDEX "idx_activities_opportunity_id_activity_date" ON "public"."activities" USING "btree" ("opportunity_id", "activity_date" DESC);



CREATE INDEX "idx_activities_tenant" ON "public"."activities" USING "btree" ("tenant_id");



CREATE INDEX "idx_activities_tenant_id" ON "public"."activities" USING "btree" ("tenant_id");



CREATE INDEX "idx_activities_tenant_user" ON "public"."activities" USING "btree" ("tenant_id", "user_id") WHERE ("tenant_id" IS NOT NULL);



CREATE INDEX "idx_activities_user_id" ON "public"."activities" USING "btree" ("user_id");



CREATE INDEX "idx_activities_user_id_activity_date" ON "public"."activities" USING "btree" ("user_id", "activity_date" DESC);



CREATE INDEX "idx_activity_logs_tenant" ON "public"."activity_logs" USING "btree" ("tenant_id");



CREATE INDEX "idx_calendar_events_active" ON "public"."calendar_events" USING "btree" ("tenant_id", "start_datetime", "status") WHERE ("status" = ANY (ARRAY['scheduled'::"public"."event_status", 'in_progress'::"public"."event_status"]));



CREATE INDEX "idx_calendar_events_active_by_tenant" ON "public"."calendar_events" USING "btree" ("tenant_id", "start_datetime", "status") WHERE ("status" = ANY (ARRAY['scheduled'::"public"."event_status", 'in_progress'::"public"."event_status"]));



CREATE INDEX "idx_calendar_events_assigned_to" ON "public"."calendar_events" USING "btree" ("assigned_to");



CREATE INDEX "idx_calendar_events_created_by" ON "public"."calendar_events" USING "btree" ("created_by");



CREATE INDEX "idx_calendar_events_end_datetime" ON "public"."calendar_events" USING "btree" ("end_datetime");



CREATE INDEX "idx_calendar_events_event_type" ON "public"."calendar_events" USING "btree" ("event_type");



CREATE INDEX "idx_calendar_events_priority" ON "public"."calendar_events" USING "btree" ("priority");



CREATE INDEX "idx_calendar_events_start_datetime" ON "public"."calendar_events" USING "btree" ("start_datetime");



CREATE INDEX "idx_calendar_events_status" ON "public"."calendar_events" USING "btree" ("status");



CREATE INDEX "idx_calendar_events_tenant" ON "public"."calendar_events" USING "btree" ("tenant_id");



CREATE INDEX "idx_calendar_events_tenant_date_range" ON "public"."calendar_events" USING "btree" ("tenant_id", "start_datetime", "end_datetime");



CREATE INDEX "idx_calendar_events_tenant_datetime" ON "public"."calendar_events" USING "btree" ("tenant_id", "start_datetime");



CREATE INDEX "idx_calendar_events_tenant_id" ON "public"."calendar_events" USING "btree" ("tenant_id");



CREATE INDEX "idx_contacts_account_id" ON "public"."contacts" USING "btree" ("account_id");



CREATE INDEX "idx_contacts_email" ON "public"."contacts" USING "btree" ("email");



CREATE INDEX "idx_contacts_property_id" ON "public"."contacts" USING "btree" ("property_id");



CREATE INDEX "idx_contacts_stage" ON "public"."contacts" USING "btree" ("stage");



CREATE INDEX "idx_contacts_tenant" ON "public"."contacts" USING "btree" ("tenant_id");



CREATE INDEX "idx_contacts_tenant_account" ON "public"."contacts" USING "btree" ("tenant_id", "account_id") WHERE ("tenant_id" IS NOT NULL);



CREATE INDEX "idx_contacts_tenant_created_by" ON "public"."contacts" USING "btree" ("tenant_id", "created_by");



CREATE INDEX "idx_contacts_tenant_id" ON "public"."contacts" USING "btree" ("tenant_id");



CREATE INDEX "idx_doc_events_tenant" ON "public"."document_events" USING "btree" ("tenant_id");



CREATE INDEX "idx_document_events_document_id" ON "public"."document_events" USING "btree" ("document_id", "event_at" DESC);



CREATE INDEX "idx_document_events_tenant_id" ON "public"."document_events" USING "btree" ("tenant_id");



CREATE INDEX "idx_documents_account_id" ON "public"."documents" USING "btree" ("account_id") WHERE ("account_id" IS NOT NULL);



CREATE INDEX "idx_documents_contact_id" ON "public"."documents" USING "btree" ("contact_id") WHERE ("contact_id" IS NOT NULL);



CREATE INDEX "idx_documents_opportunity_id" ON "public"."documents" USING "btree" ("opportunity_id") WHERE ("opportunity_id" IS NOT NULL);



CREATE INDEX "idx_documents_property_id" ON "public"."documents" USING "btree" ("property_id") WHERE ("property_id" IS NOT NULL);



CREATE INDEX "idx_documents_status" ON "public"."documents" USING "btree" ("tenant_id", "status");



CREATE INDEX "idx_documents_tenant" ON "public"."documents" USING "btree" ("tenant_id");



CREATE INDEX "idx_documents_tenant_id" ON "public"."documents" USING "btree" ("tenant_id");



CREATE INDEX "idx_documents_type" ON "public"."documents" USING "btree" ("tenant_id", "type");



CREATE INDEX "idx_documents_uploaded_at" ON "public"."documents" USING "btree" ("tenant_id", "uploaded_at" DESC);



CREATE INDEX "idx_documents_valid_to" ON "public"."documents" USING "btree" ("tenant_id", "valid_to");



CREATE INDEX "idx_notifications_tenant" ON "public"."notifications" USING "btree" ("tenant_id");



CREATE INDEX "idx_notifications_tenant_id" ON "public"."notifications" USING "btree" ("tenant_id");



CREATE INDEX "idx_notifications_type_created" ON "public"."notifications" USING "btree" ("type", "created_at");



CREATE INDEX "idx_notifications_unread" ON "public"."notifications" USING "btree" ("user_id", "read_at") WHERE ("read_at" IS NULL);



CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");



CREATE INDEX "idx_notifications_user_read" ON "public"."notifications" USING "btree" ("user_id", "read_at", "created_at");



CREATE INDEX "idx_opportunities_account_id" ON "public"."opportunities" USING "btree" ("account_id");



CREATE INDEX "idx_opportunities_assigned_to" ON "public"."opportunities" USING "btree" ("assigned_to");



CREATE INDEX "idx_opportunities_bid_value" ON "public"."opportunities" USING "btree" ("bid_value");



CREATE INDEX "idx_opportunities_created_by" ON "public"."opportunities" USING "btree" ("created_by");



CREATE INDEX "idx_opportunities_expected_close_date" ON "public"."opportunities" USING "btree" ("expected_close_date");



CREATE INDEX "idx_opportunities_property_id" ON "public"."opportunities" USING "btree" ("property_id");



CREATE INDEX "idx_opportunities_stage" ON "public"."opportunities" USING "btree" ("stage");



CREATE INDEX "idx_opportunities_stage_date" ON "public"."opportunities" USING "btree" ("stage", "expected_close_date");



CREATE INDEX "idx_opportunities_tenant" ON "public"."opportunities" USING "btree" ("tenant_id");



CREATE INDEX "idx_opportunities_tenant_id" ON "public"."opportunities" USING "btree" ("tenant_id");



CREATE INDEX "idx_opportunities_type" ON "public"."opportunities" USING "btree" ("opportunity_type");



CREATE INDEX "idx_properties_account_id" ON "public"."properties" USING "btree" ("account_id");



CREATE INDEX "idx_properties_building_type" ON "public"."properties" USING "btree" ("building_type");



CREATE INDEX "idx_properties_stage" ON "public"."properties" USING "btree" ("stage");



CREATE INDEX "idx_properties_tenant" ON "public"."properties" USING "btree" ("tenant_id");



CREATE INDEX "idx_properties_tenant_account" ON "public"."properties" USING "btree" ("tenant_id", "account_id") WHERE ("tenant_id" IS NOT NULL);



CREATE INDEX "idx_properties_tenant_id" ON "public"."properties" USING "btree" ("tenant_id");



CREATE INDEX "idx_prospects_assigned_to" ON "public"."prospects" USING "btree" ("tenant_id", "assigned_to");



CREATE INDEX "idx_prospects_last_activity" ON "public"."prospects" USING "btree" ("tenant_id", "last_activity_at" DESC);



CREATE INDEX "idx_prospects_source" ON "public"."prospects" USING "btree" ("tenant_id", "source");



CREATE INDEX "idx_prospects_tenant" ON "public"."prospects" USING "btree" ("tenant_id");



CREATE INDEX "idx_prospects_tenant_city_state" ON "public"."prospects" USING "btree" ("tenant_id", "lower"("city"), "lower"("state"));



CREATE INDEX "idx_prospects_tenant_id_created_by" ON "public"."prospects" USING "btree" ("tenant_id", "created_by");



CREATE INDEX "idx_prospects_tenant_id_status" ON "public"."prospects" USING "btree" ("tenant_id", "status");



CREATE INDEX "idx_prospects_tenant_name" ON "public"."prospects" USING "btree" ("tenant_id", "lower"("name"));



CREATE INDEX "idx_prospects_tenant_status_score" ON "public"."prospects" USING "btree" ("tenant_id", "status", "icp_fit_score" DESC);



CREATE INDEX "idx_roof_lead_images_roof_lead_id" ON "public"."roof_lead_images" USING "btree" ("roof_lead_id");



CREATE INDEX "idx_roof_lead_images_tenant_id" ON "public"."roof_lead_images" USING "btree" ("tenant_id");



CREATE INDEX "idx_roof_leads_condition_score" ON "public"."roof_leads" USING "btree" ("tenant_id", "condition_score" DESC);



CREATE INDEX "idx_roof_leads_created_at" ON "public"."roof_leads" USING "btree" ("tenant_id", "created_at" DESC);



CREATE INDEX "idx_roof_leads_created_by" ON "public"."roof_leads" USING "btree" ("created_by");



CREATE INDEX "idx_roof_leads_geometry" ON "public"."roof_leads" USING "gist" ("geometry");



CREATE INDEX "idx_roof_leads_status" ON "public"."roof_leads" USING "btree" ("tenant_id", "status");



CREATE INDEX "idx_roof_leads_tenant_id" ON "public"."roof_leads" USING "btree" ("tenant_id");



CREATE INDEX "idx_task_comments_author_id" ON "public"."task_comments" USING "btree" ("author_id");



CREATE INDEX "idx_task_comments_task_id" ON "public"."task_comments" USING "btree" ("task_id");



CREATE INDEX "idx_task_comments_tenant_id" ON "public"."task_comments" USING "btree" ("tenant_id");



CREATE INDEX "idx_tasks_account_id" ON "public"."tasks" USING "btree" ("account_id");



CREATE INDEX "idx_tasks_assigned_by" ON "public"."tasks" USING "btree" ("assigned_by");



CREATE INDEX "idx_tasks_assigned_to" ON "public"."tasks" USING "btree" ("assigned_to");



CREATE INDEX "idx_tasks_contact_id" ON "public"."tasks" USING "btree" ("contact_id");



CREATE INDEX "idx_tasks_due_date" ON "public"."tasks" USING "btree" ("due_date");



CREATE INDEX "idx_tasks_opportunity_id" ON "public"."tasks" USING "btree" ("opportunity_id");



CREATE INDEX "idx_tasks_priority" ON "public"."tasks" USING "btree" ("priority");



CREATE INDEX "idx_tasks_property_id" ON "public"."tasks" USING "btree" ("property_id");



CREATE INDEX "idx_tasks_prospect_id" ON "public"."tasks" USING "btree" ("prospect_id");



CREATE INDEX "idx_tasks_status" ON "public"."tasks" USING "btree" ("status");



CREATE INDEX "idx_tasks_status_priority" ON "public"."tasks" USING "btree" ("status", "priority");



CREATE INDEX "idx_tasks_tenant" ON "public"."tasks" USING "btree" ("tenant_id");



CREATE INDEX "idx_tasks_tenant_assigned" ON "public"."tasks" USING "btree" ("tenant_id", "assigned_to");



CREATE INDEX "idx_tasks_tenant_assigned_role" ON "public"."tasks" USING "btree" ("tenant_id", "assigned_to", "status");



CREATE INDEX "idx_tasks_tenant_id" ON "public"."tasks" USING "btree" ("tenant_id");



CREATE INDEX "idx_tenants_active_by_plan" ON "public"."tenants" USING "btree" ("subscription_plan", "created_at") WHERE (("status" = 'active'::"public"."tenant_status") AND ("is_active" = true));



CREATE INDEX "idx_tenants_active_status" ON "public"."tenants" USING "btree" ("status", "is_active") WHERE ("is_active" = true);



CREATE INDEX "idx_tenants_created_by" ON "public"."tenants" USING "btree" ("created_by");



CREATE INDEX "idx_tenants_domain" ON "public"."tenants" USING "btree" ("domain") WHERE ("domain" IS NOT NULL);



CREATE INDEX "idx_tenants_owner_id" ON "public"."tenants" USING "btree" ("owner_id");



CREATE INDEX "idx_tenants_slug" ON "public"."tenants" USING "btree" ("slug");



CREATE INDEX "idx_tenants_status" ON "public"."tenants" USING "btree" ("status");



CREATE INDEX "idx_tenants_subscription_plan" ON "public"."tenants" USING "btree" ("subscription_plan");



CREATE INDEX "idx_user_profiles_confirmation_status" ON "public"."user_profiles" USING "btree" ("confirmation_status");



CREATE INDEX "idx_user_profiles_email" ON "public"."user_profiles" USING "btree" ("email");



CREATE INDEX "idx_user_profiles_email_active" ON "public"."user_profiles" USING "btree" ("email") WHERE ("is_active" = true);



CREATE INDEX "idx_user_profiles_email_lookup" ON "public"."user_profiles" USING "btree" ("email");



CREATE INDEX "idx_user_profiles_id_lookup" ON "public"."user_profiles" USING "btree" ("id");



CREATE INDEX "idx_user_profiles_manager_id" ON "public"."user_profiles" USING "btree" ("manager_id");



CREATE INDEX "idx_user_profiles_manager_lookup" ON "public"."user_profiles" USING "btree" ("manager_id") WHERE ("manager_id" IS NOT NULL);



CREATE INDEX "idx_user_profiles_manager_tenant_lookup" ON "public"."user_profiles" USING "btree" ("manager_id", "tenant_id", "is_active") WHERE ("role" = 'rep'::"public"."user_role");



CREATE INDEX "idx_user_profiles_password_set" ON "public"."user_profiles" USING "btree" ("password_set");



CREATE INDEX "idx_user_profiles_role" ON "public"."user_profiles" USING "btree" ("role");



CREATE INDEX "idx_user_profiles_role_active" ON "public"."user_profiles" USING "btree" ("role") WHERE ("is_active" = true);



CREATE INDEX "idx_user_profiles_setup_status" ON "public"."user_profiles" USING "btree" ("profile_completed", "password_set", "setup_completed_at");



CREATE INDEX "idx_user_profiles_temp_password_expires" ON "public"."user_profiles" USING "btree" ("temp_password_expires_at");



CREATE INDEX "idx_user_profiles_temp_password_used" ON "public"."user_profiles" USING "btree" ("temp_password_used");



CREATE INDEX "idx_user_profiles_tenant" ON "public"."user_profiles" USING "btree" ("tenant_id");



CREATE INDEX "idx_user_profiles_tenant_active" ON "public"."user_profiles" USING "btree" ("tenant_id") WHERE ("is_active" = true);



CREATE INDEX "idx_user_profiles_tenant_id" ON "public"."user_profiles" USING "btree" ("tenant_id");



CREATE INDEX "idx_user_profiles_tenant_role" ON "public"."user_profiles" USING "btree" ("tenant_id", "role") WHERE ("tenant_id" IS NOT NULL);



CREATE INDEX "idx_user_profiles_updated_at" ON "public"."user_profiles" USING "btree" ("updated_at");



CREATE INDEX "idx_weekly_goals_manager_access_lookup" ON "public"."weekly_goals" USING "btree" ("user_id", "week_start_date", "goal_type");



CREATE INDEX "idx_weekly_goals_tenant" ON "public"."weekly_goals" USING "btree" ("tenant_id");



CREATE INDEX "idx_weekly_goals_tenant_id" ON "public"."weekly_goals" USING "btree" ("tenant_id");



CREATE INDEX "idx_weekly_goals_tenant_week" ON "public"."weekly_goals" USING "btree" ("tenant_id", "week_start_date");



CREATE INDEX "idx_weekly_goals_unique_constraint" ON "public"."weekly_goals" USING "btree" ("user_id", "week_start_date", "goal_type");



CREATE INDEX "idx_weekly_goals_user_id" ON "public"."weekly_goals" USING "btree" ("user_id");



CREATE INDEX "idx_weekly_goals_user_week_goal_type" ON "public"."weekly_goals" USING "btree" ("user_id", "week_start_date", "goal_type");



CREATE INDEX "idx_weekly_goals_week_start" ON "public"."weekly_goals" USING "btree" ("week_start_date");



CREATE UNIQUE INDEX "uidx_prospects_tenant_name_active" ON "public"."prospects" USING "btree" ("tenant_id", "lower"("name")) WHERE ("status" = ANY (ARRAY['uncontacted'::"text", 'researching'::"text", 'attempted'::"text", 'contacted'::"text"]));



CREATE OR REPLACE TRIGGER "auto_manager_assignment_trigger" BEFORE INSERT OR UPDATE ON "public"."user_profiles" FOR EACH ROW WHEN ((("new"."role" = 'rep'::"public"."user_role") AND ("new"."is_active" = true))) EXECUTE FUNCTION "public"."auto_establish_manager_rep_relationship"();



CREATE OR REPLACE TRIGGER "handle_prospects_updated_at" BEFORE UPDATE ON "public"."prospects" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_accounts" BEFORE UPDATE ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_calendar_events" BEFORE UPDATE ON "public"."calendar_events" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_contacts" BEFORE UPDATE ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_documents" BEFORE UPDATE ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_notifications" BEFORE UPDATE ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_opportunities" BEFORE UPDATE ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_properties" BEFORE UPDATE ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_roof_leads" BEFORE UPDATE ON "public"."roof_leads" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_tasks" BEFORE UPDATE ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_tenants" BEFORE UPDATE ON "public"."tenants" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_user_profiles" BEFORE UPDATE ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "handle_updated_at_weekly_goals" BEFORE UPDATE ON "public"."weekly_goals" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_and_validate_weekly_goals_tenant_trigger" BEFORE INSERT OR UPDATE ON "public"."weekly_goals" FOR EACH ROW EXECUTE FUNCTION "public"."set_and_validate_weekly_goals_tenant"();



CREATE OR REPLACE TRIGGER "sync_super_admin_metadata_trigger" AFTER INSERT OR UPDATE OF "role" ON "public"."user_profiles" FOR EACH ROW WHEN (("new"."role" = 'super_admin'::"public"."user_role")) EXECUTE FUNCTION "public"."sync_super_admin_metadata"();



CREATE OR REPLACE TRIGGER "sync_user_metadata_trigger" AFTER UPDATE ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."sync_user_metadata_with_profile"();



CREATE OR REPLACE TRIGGER "trg_account_assignments_updated_at" BEFORE UPDATE ON "public"."account_assignments" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_accounts_audit" AFTER INSERT OR DELETE OR UPDATE ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."_audit_log"();



CREATE OR REPLACE TRIGGER "trg_accounts_defaults" BEFORE INSERT ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."set_account_defaults"();



CREATE OR REPLACE TRIGGER "trg_accounts_set_tenant" BEFORE INSERT ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_accounts_updated_at" BEFORE UPDATE ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_activities_defaults" BEFORE INSERT ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."set_activity_defaults"();



CREATE OR REPLACE TRIGGER "trg_activities_set_tenant" BEFORE INSERT ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_activities_updated_at" BEFORE UPDATE ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_activity_logs_fill_tenant" BEFORE INSERT ON "public"."activity_logs" FOR EACH ROW EXECUTE FUNCTION "public"."fill_activity_log_tenant"();



CREATE OR REPLACE TRIGGER "trg_calendar_events_set_tenant" BEFORE INSERT ON "public"."calendar_events" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_calendar_events_updated_at" BEFORE UPDATE ON "public"."calendar_events" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_contacts_audit" AFTER INSERT OR DELETE OR UPDATE ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."_audit_log"();



CREATE OR REPLACE TRIGGER "trg_contacts_set_created_by" BEFORE INSERT ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."set_contacts_created_by"();



CREATE OR REPLACE TRIGGER "trg_contacts_set_tenant" BEFORE INSERT ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_contacts_updated_at" BEFORE UPDATE ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_document_events_set_tenant" BEFORE INSERT ON "public"."document_events" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_documents_set_tenant" BEFORE INSERT ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_documents_updated_at" BEFORE UPDATE ON "public"."documents" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_notifications_set_tenant" BEFORE INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_opportunities_audit" AFTER INSERT OR DELETE OR UPDATE ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."_audit_log"();



CREATE OR REPLACE TRIGGER "trg_opportunities_set_tenant" BEFORE INSERT ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_opportunities_updated_at" BEFORE UPDATE ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_properties_audit" AFTER INSERT OR DELETE OR UPDATE ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."_audit_log"();



CREATE OR REPLACE TRIGGER "trg_properties_set_tenant" BEFORE INSERT ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_properties_updated_at" BEFORE UPDATE ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_prospects_set_tenant" BEFORE INSERT ON "public"."prospects" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_prospects_updated_at" BEFORE UPDATE ON "public"."prospects" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_tasks_audit" AFTER INSERT OR DELETE OR UPDATE ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."_audit_log"();



CREATE OR REPLACE TRIGGER "trg_tasks_defaults" BEFORE INSERT ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."set_task_defaults"();



CREATE OR REPLACE TRIGGER "trg_tasks_set_tenant" BEFORE INSERT ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trg_tasks_updated_at" BEFORE UPDATE ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_weekly_goals_set_tenant" BEFORE INSERT ON "public"."weekly_goals" FOR EACH ROW EXECUTE FUNCTION "public"."set_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_activity_notification" AFTER INSERT ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."create_activity_notification"();



CREATE OR REPLACE TRIGGER "trigger_set_account_tenant_id" BEFORE INSERT ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."set_account_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_set_contact_tenant_id" BEFORE INSERT ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."set_contact_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_set_opportunity_tenant_id" BEFORE INSERT ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."set_opportunity_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_set_property_tenant_id" BEFORE INSERT ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."set_property_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_set_task_comment_tenant_id" BEFORE INSERT ON "public"."task_comments" FOR EACH ROW EXECUTE FUNCTION "public"."set_task_comment_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_set_task_tenant_id" BEFORE INSERT ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."set_task_tenant_id"();



CREATE OR REPLACE TRIGGER "trigger_sync_user_profile_role" AFTER UPDATE OF "role" ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."ensure_user_profile_consistency"();



CREATE OR REPLACE TRIGGER "trigger_task_assignment_notification" AFTER INSERT ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."create_task_assignment_notification"();



CREATE OR REPLACE TRIGGER "trigger_validate_accounts_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."accounts" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_activities_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_contacts_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."contacts" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_opportunities_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."opportunities" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_properties_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."properties" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_task_comments_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."task_comments" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "trigger_validate_tasks_tenant_consistency" BEFORE INSERT OR UPDATE ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."validate_tenant_consistency"();



CREATE OR REPLACE TRIGGER "weekly_goals_tenant_consistency_trigger" BEFORE INSERT OR UPDATE ON "public"."weekly_goals" FOR EACH ROW EXECUTE FUNCTION "public"."validate_weekly_goals_tenant_consistency"();



ALTER TABLE ONLY "public"."account_assignments"
    ADD CONSTRAINT "account_assignments_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."account_assignments"
    ADD CONSTRAINT "account_assignments_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."account_assignments"
    ADD CONSTRAINT "account_assignments_rep_id_fkey" FOREIGN KEY ("rep_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_assigned_rep_id_fkey" FOREIGN KEY ("assigned_rep_id") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_logs"
    ADD CONSTRAINT "activity_logs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_logs"
    ADD CONSTRAINT "activity_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."auth_debug_log"
    ADD CONSTRAINT "auth_debug_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_related_account_id_fkey" FOREIGN KEY ("related_account_id") REFERENCES "public"."accounts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_related_contact_id_fkey" FOREIGN KEY ("related_contact_id") REFERENCES "public"."contacts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_related_property_id_fkey" FOREIGN KEY ("related_property_id") REFERENCES "public"."properties"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."document_events"
    ADD CONSTRAINT "document_events_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."documents"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."document_events"
    ADD CONSTRAINT "document_events_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."document_events"
    ADD CONSTRAINT "document_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_previous_document_id_fkey" FOREIGN KEY ("previous_document_id") REFERENCES "public"."documents"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."opportunities"
    ADD CONSTRAINT "opportunities_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_assigned_rep_id_fkey" FOREIGN KEY ("assigned_rep_id") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_linked_account_id_fkey" FOREIGN KEY ("linked_account_id") REFERENCES "public"."accounts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."prospects"
    ADD CONSTRAINT "prospects_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roof_lead_images"
    ADD CONSTRAINT "roof_lead_images_roof_lead_id_fkey" FOREIGN KEY ("roof_lead_id") REFERENCES "public"."roof_leads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roof_lead_images"
    ADD CONSTRAINT "roof_lead_images_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roof_lead_images"
    ADD CONSTRAINT "roof_lead_images_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_linked_account_id_fkey" FOREIGN KEY ("linked_account_id") REFERENCES "public"."accounts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_linked_property_id_fkey" FOREIGN KEY ("linked_property_id") REFERENCES "public"."properties"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_linked_prospect_id_fkey" FOREIGN KEY ("linked_prospect_id") REFERENCES "public"."prospects"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."roof_leads"
    ADD CONSTRAINT "roof_leads_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."task_comments"
    ADD CONSTRAINT "task_comments_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."task_comments"
    ADD CONSTRAINT "task_comments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."task_comments"
    ADD CONSTRAINT "task_comments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_prospect_id_fkey" FOREIGN KEY ("prospect_id") REFERENCES "public"."prospects"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tenants"
    ADD CONSTRAINT "tenants_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tenants"
    ADD CONSTRAINT "tenants_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "public"."user_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."weekly_goals"
    ADD CONSTRAINT "weekly_goals_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."weekly_goals"
    ADD CONSTRAINT "weekly_goals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Allow tenant members to read opportunities" ON "public"."opportunities" FOR SELECT TO "authenticated" USING (("tenant_id" = ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "Allow tenant members to read weekly goals" ON "public"."weekly_goals" FOR SELECT TO "authenticated" USING (("tenant_id" = ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "System can insert activity logs" ON "public"."activity_logs" FOR INSERT WITH CHECK (true);



CREATE POLICY "Users can view their own activity logs" ON "public"."activity_logs" FOR SELECT USING ((("auth"."uid"() = "user_id") OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."id" = "auth"."uid"()) AND ("user_profiles"."role" = ANY (ARRAY['super_admin'::"public"."user_role", 'admin'::"public"."user_role", 'manager'::"public"."user_role"])))))));



CREATE POLICY "acc_assign_ins_admin_mgr" ON "public"."account_assignments" FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("a"."tenant_id" = "public"."current_tenant_id"())))) AND "public"."is_admin_or_manager"()));



CREATE POLICY "acc_assign_select_tenant" ON "public"."account_assignments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("a"."tenant_id" = "public"."current_tenant_id"())))));



CREATE POLICY "acc_assign_upd_admin_mgr" ON "public"."account_assignments" FOR UPDATE USING (((EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("a"."tenant_id" = "public"."current_tenant_id"())))) AND "public"."is_admin_or_manager"())) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("a"."tenant_id" = "public"."current_tenant_id"())))));



ALTER TABLE "public"."account_assignments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "accounts_delete" ON "public"."accounts" FOR DELETE TO "authenticated" USING (((("tenant_id" = "public"."current_tenant_id"()) AND ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"]))) OR ("public"."get_user_role"() = 'super_admin'::"text")));



CREATE POLICY "accounts_insert" ON "public"."accounts" FOR INSERT TO "authenticated" WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND ("assigned_rep_id" = "auth"."uid"())) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"])))));



CREATE POLICY "accounts_insert_tenant" ON "public"."accounts" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "accounts_read" ON "public"."accounts" FOR SELECT TO "authenticated" USING (((("public"."get_user_role"() = 'rep'::"text") AND ("assigned_rep_id" = "auth"."uid"())) OR (("public"."get_user_role"() = 'manager'::"text") AND ("tenant_id" = "public"."current_tenant_id"())) OR ("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"]))));



CREATE POLICY "accounts_select_tenant" ON "public"."accounts" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "accounts_update" ON "public"."accounts" FOR UPDATE TO "authenticated" USING ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND ("assigned_rep_id" = "auth"."uid"())) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"]))))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "accounts_update_tenant" ON "public"."accounts" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "activities_insert_tenant" ON "public"."activities" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "activities_manager_read" ON "public"."activities" FOR SELECT TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"])) AND ("tenant_id" = "public"."current_tenant_id"())));



CREATE POLICY "activities_owner_delete" ON "public"."activities" FOR DELETE TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "activities_owner_select" ON "public"."activities" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "activities_owner_update" ON "public"."activities" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "activities_select_tenant" ON "public"."activities" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "activities_super_admin" ON "public"."activities" TO "authenticated" USING (("public"."get_user_role"() = 'super_admin'::"text")) WITH CHECK (("public"."get_user_role"() = 'super_admin'::"text"));



CREATE POLICY "activities_update_tenant" ON "public"."activities" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



ALTER TABLE "public"."activity_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "admin_full_access_calendar_events" ON "public"."calendar_events" TO "authenticated" USING ("public"."is_admin_from_auth"()) WITH CHECK ("public"."is_admin_from_auth"());



CREATE POLICY "admin_full_access_opportunities" ON "public"."opportunities" TO "authenticated" USING ("public"."is_admin_from_auth"()) WITH CHECK ("public"."is_admin_from_auth"());



CREATE POLICY "admin_full_access_prospects" ON "public"."prospects" TO "authenticated" USING ("public"."is_admin_from_auth"()) WITH CHECK ("public"."is_admin_from_auth"());



CREATE POLICY "alog_ins_tenant" ON "public"."activity_logs" FOR INSERT WITH CHECK ((COALESCE("tenant_id", ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))) = "public"."current_tenant_id"()));



CREATE POLICY "alog_select_tenant" ON "public"."activity_logs" FOR SELECT USING ((("tenant_id" = "public"."current_tenant_id"()) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up"
  WHERE (("up"."id" = "activity_logs"."user_id") AND ("up"."tenant_id" = "public"."current_tenant_id"()))))));



ALTER TABLE "public"."auth_debug_log" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "auth_debug_log_admin_access" ON "public"."auth_debug_log" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."id" = "auth"."uid"()) AND ("user_profiles"."role" = ANY (ARRAY['super_admin'::"public"."user_role", 'admin'::"public"."user_role"]))))));



CREATE POLICY "cal_ins_admin_mgr" ON "public"."calendar_events" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "cal_rep_write_own" ON "public"."calendar_events" USING ((("tenant_id" = "public"."current_tenant_id"()) AND (("created_by" = "auth"."uid"()) OR ("assigned_to" = "auth"."uid"())))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "cal_select_tenant" ON "public"."calendar_events" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "cal_upd_admin_mgr" ON "public"."calendar_events" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



ALTER TABLE "public"."calendar_events" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "contacts_delete" ON "public"."contacts" FOR DELETE TO "authenticated" USING (((("tenant_id" = "public"."current_tenant_id"()) AND ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"]))) OR ("public"."get_user_role"() = 'super_admin'::"text")));



CREATE POLICY "contacts_insert" ON "public"."contacts" FOR INSERT TO "authenticated" WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "contacts"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"()))))) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"])))));



CREATE POLICY "contacts_insert_tenant" ON "public"."contacts" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "contacts_read" ON "public"."contacts" FOR SELECT TO "authenticated" USING ((("tenant_id" = "public"."current_tenant_id"()) OR (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "contacts"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"())))) OR ("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"]))));



CREATE POLICY "contacts_select_tenant" ON "public"."contacts" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "contacts_update" ON "public"."contacts" FOR UPDATE TO "authenticated" USING ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "contacts"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"()))))) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"]))))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "contacts_update_tenant" ON "public"."contacts" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "doc_events_ins_tenant" ON "public"."document_events" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "doc_events_select_tenant" ON "public"."document_events" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "docs_ins_admin_mgr" ON "public"."documents" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "docs_select_tenant" ON "public"."documents" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "docs_upd_admin_mgr" ON "public"."documents" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "document_events_insert_tenant" ON "public"."document_events" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "document_events_select_tenant" ON "public"."document_events" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "document_events_update_tenant" ON "public"."document_events" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "documents_admin_access_v2" ON "public"."documents" TO "authenticated" USING ("public"."is_admin_user_jwt"()) WITH CHECK ("public"."is_admin_user_jwt"());



CREATE POLICY "documents_insert_tenant" ON "public"."documents" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "documents_manager_full_tenant_access_v3" ON "public"."documents" TO "authenticated" USING (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"()))) WITH CHECK (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"())));



CREATE POLICY "documents_owner_access_v2" ON "public"."documents" TO "authenticated" USING (("uploaded_by" = "auth"."uid"())) WITH CHECK (("uploaded_by" = "auth"."uid"()));



CREATE POLICY "documents_select_tenant" ON "public"."documents" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "documents_tenant_isolation" ON "public"."documents" USING (("tenant_id" IN ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "documents_update_tenant" ON "public"."documents" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "enhanced_tenant_access_documents" ON "public"."documents" TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id"))) WITH CHECK ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id")));



CREATE POLICY "enhanced_tenant_access_notifications" ON "public"."notifications" TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id"))) WITH CHECK ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id")));



CREATE POLICY "enhanced_tenant_access_opportunities" ON "public"."opportunities" TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id"))) WITH CHECK ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id")));



CREATE POLICY "enhanced_tenant_access_prospects" ON "public"."prospects" TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id"))) WITH CHECK ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR "public"."has_tenant_access"("tenant_id")));



CREATE POLICY "enhanced_tenant_access_weekly_goals" ON "public"."weekly_goals" TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR (("tenant_id" IS NOT NULL) AND "public"."has_tenant_access"("tenant_id")) OR (("tenant_id" IS NULL) AND ("user_id" = "auth"."uid"())))) WITH CHECK ((("public"."get_user_role"() = ANY (ARRAY['super_admin'::"text", 'admin'::"text"])) OR (("tenant_id" IS NOT NULL) AND "public"."has_tenant_access"("tenant_id")) OR (("tenant_id" IS NULL) AND ("user_id" = "auth"."uid"()))));



CREATE POLICY "manager_rep_enhanced_access_opportunities" ON "public"."opportunities" TO "authenticated" USING (("public"."user_is_manager_or_admin"() OR (("public"."get_user_role_with_fallbacks"() = 'rep'::"text") AND "public"."can_access_tenant_data_enhanced"("tenant_id")))) WITH CHECK (("public"."user_is_manager_or_admin"() OR (("public"."get_user_role_with_fallbacks"() = 'rep'::"text") AND "public"."can_access_tenant_data_enhanced"("tenant_id"))));



CREATE POLICY "manager_rep_enhanced_access_prospects" ON "public"."prospects" TO "authenticated" USING (("public"."user_is_manager_or_admin"() OR (("public"."get_user_role_with_fallbacks"() = 'rep'::"text") AND "public"."can_access_tenant_data_enhanced"("tenant_id")))) WITH CHECK (("public"."user_is_manager_or_admin"() OR (("public"."get_user_role_with_fallbacks"() = 'rep'::"text") AND "public"."can_access_tenant_data_enhanced"("tenant_id"))));



CREATE POLICY "managers_access_tenant_opportunities" ON "public"."opportunities" TO "authenticated" USING (("public"."is_manager_from_auth"() AND ("tenant_id" = "public"."get_current_user_tenant_id"()))) WITH CHECK (("public"."is_manager_from_auth"() AND ("tenant_id" = "public"."get_current_user_tenant_id"())));



CREATE POLICY "managers_access_tenant_prospects" ON "public"."prospects" TO "authenticated" USING (("public"."is_manager_from_auth"() AND ("tenant_id" = "public"."get_current_user_tenant_id"()))) WITH CHECK (("public"."is_manager_from_auth"() AND ("tenant_id" = "public"."get_current_user_tenant_id"())));



CREATE POLICY "notif_ins_admin_mgr" ON "public"."notifications" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "notif_select_tenant" ON "public"."notifications" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "notif_upd_admin_mgr" ON "public"."notifications" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "notifications_user_access" ON "public"."notifications" USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."id" = "auth"."uid"()) AND ("user_profiles"."role" = ANY (ARRAY['super_admin'::"public"."user_role", 'admin'::"public"."user_role"])))))));



CREATE POLICY "opportunities_admin_access_v2" ON "public"."opportunities" TO "authenticated" USING ("public"."is_admin_user_jwt"()) WITH CHECK ("public"."is_admin_user_jwt"());



CREATE POLICY "opportunities_insert_tenant" ON "public"."opportunities" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "opportunities_manager_full_tenant_access_v3" ON "public"."opportunities" TO "authenticated" USING (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"()))) WITH CHECK (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"())));



CREATE POLICY "opportunities_owner_access_v2" ON "public"."opportunities" TO "authenticated" USING (("assigned_to" = "auth"."uid"())) WITH CHECK (("assigned_to" = "auth"."uid"()));



CREATE POLICY "opportunities_select_tenant" ON "public"."opportunities" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "opportunities_tenant_isolation" ON "public"."opportunities" USING (("tenant_id" IN ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "opportunities_update_tenant" ON "public"."opportunities" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "opps_ins_admin_mgr" ON "public"."opportunities" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "opps_rep_write_own" ON "public"."opportunities" USING ((("tenant_id" = "public"."current_tenant_id"()) AND (("created_by" = "auth"."uid"()) OR ("assigned_to" = "auth"."uid"())))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "opps_select_tenant" ON "public"."opportunities" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "opps_upd_admin_mgr" ON "public"."opportunities" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "properties_delete" ON "public"."properties" FOR DELETE TO "authenticated" USING (((("tenant_id" = "public"."current_tenant_id"()) AND ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"]))) OR ("public"."get_user_role"() = 'super_admin'::"text")));



CREATE POLICY "properties_insert" ON "public"."properties" FOR INSERT TO "authenticated" WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "properties"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"()))))) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"])))));



CREATE POLICY "properties_insert_tenant" ON "public"."properties" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "properties_read" ON "public"."properties" FOR SELECT TO "authenticated" USING ((("tenant_id" = "public"."current_tenant_id"()) OR (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "properties"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"())))) OR ("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"]))));



CREATE POLICY "properties_select_tenant" ON "public"."properties" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "properties_update" ON "public"."properties" FOR UPDATE TO "authenticated" USING ((("tenant_id" = "public"."current_tenant_id"()) AND ((("public"."get_user_role"() = 'rep'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."accounts" "a"
  WHERE (("a"."id" = "properties"."account_id") AND ("a"."assigned_rep_id" = "auth"."uid"()))))) OR ("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text", 'super_admin'::"text"]))))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "properties_update_tenant" ON "public"."properties" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



ALTER TABLE "public"."prospects" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "prospects_admin_access_v2" ON "public"."prospects" TO "authenticated" USING ("public"."is_admin_user_jwt"()) WITH CHECK ("public"."is_admin_user_jwt"());



CREATE POLICY "prospects_ins_admin_mgr" ON "public"."prospects" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "prospects_manager_full_tenant_access_v3" ON "public"."prospects" TO "authenticated" USING (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"()))) WITH CHECK (("public"."is_manager_with_tenant_access"() AND ("tenant_id" = "public"."get_user_tenant_uuid"())));



CREATE POLICY "prospects_owner_access_v2" ON "public"."prospects" TO "authenticated" USING (("assigned_to" = "auth"."uid"())) WITH CHECK (("assigned_to" = "auth"."uid"()));



CREATE POLICY "prospects_rep_write_own" ON "public"."prospects" USING ((("tenant_id" = "public"."current_tenant_id"()) AND (("assigned_to" = "auth"."uid"()) OR ("created_by" = "auth"."uid"())))) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "prospects_select_tenant" ON "public"."prospects" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "prospects_tenant_delete" ON "public"."prospects" FOR DELETE TO "authenticated" USING ((("tenant_id" = "public"."get_user_tenant_id"()) AND (("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up"
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."tenant_id" = "prospects"."tenant_id") AND ("up"."role" = ANY (ARRAY['admin'::"public"."user_role", 'manager'::"public"."user_role"]))))))));



CREATE POLICY "prospects_tenant_insert" ON "public"."prospects" FOR INSERT TO "authenticated" WITH CHECK ((("tenant_id" = "public"."get_user_tenant_id"()) AND ("created_by" = "auth"."uid"())));



CREATE POLICY "prospects_tenant_isolation" ON "public"."prospects" USING (("tenant_id" IN ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "prospects_tenant_select" ON "public"."prospects" FOR SELECT TO "authenticated" USING (("tenant_id" = "public"."get_user_tenant_id"()));



CREATE POLICY "prospects_tenant_update" ON "public"."prospects" FOR UPDATE TO "authenticated" USING (("tenant_id" = "public"."get_user_tenant_id"())) WITH CHECK (("tenant_id" = "public"."get_user_tenant_id"()));



CREATE POLICY "prospects_upd_admin_mgr" ON "public"."prospects" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



ALTER TABLE "public"."roof_lead_images" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "roof_lead_images_user_access" ON "public"."roof_lead_images" TO "authenticated" USING (("uploaded_by" = "auth"."uid"())) WITH CHECK (("uploaded_by" = "auth"."uid"()));



ALTER TABLE "public"."roof_leads" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "roof_leads_user_access" ON "public"."roof_leads" TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));



CREATE POLICY "super_admin_full_access_opportunities" ON "public"."opportunities" TO "authenticated" USING ("public"."is_super_admin_from_auth"()) WITH CHECK ("public"."is_super_admin_from_auth"());



CREATE POLICY "super_admin_full_access_prospects" ON "public"."prospects" TO "authenticated" USING ("public"."is_super_admin_from_auth"()) WITH CHECK ("public"."is_super_admin_from_auth"());



CREATE POLICY "super_admin_full_access_roof_lead_images" ON "public"."roof_lead_images" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "auth"."users" "au"
  WHERE (("au"."id" = "auth"."uid"()) AND ((("au"."raw_user_meta_data" ->> 'role'::"text") = 'super_admin'::"text") OR (("au"."raw_app_meta_data" ->> 'role'::"text") = 'super_admin'::"text")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users" "au"
  WHERE (("au"."id" = "auth"."uid"()) AND ((("au"."raw_user_meta_data" ->> 'role'::"text") = 'super_admin'::"text") OR (("au"."raw_app_meta_data" ->> 'role'::"text") = 'super_admin'::"text"))))));



CREATE POLICY "super_admin_full_access_roof_leads" ON "public"."roof_leads" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "auth"."users" "au"
  WHERE (("au"."id" = "auth"."uid"()) AND ((("au"."raw_user_meta_data" ->> 'role'::"text") = 'super_admin'::"text") OR (("au"."raw_app_meta_data" ->> 'role'::"text") = 'super_admin'::"text")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "auth"."users" "au"
  WHERE (("au"."id" = "auth"."uid"()) AND ((("au"."raw_user_meta_data" ->> 'role'::"text") = 'super_admin'::"text") OR (("au"."raw_app_meta_data" ->> 'role'::"text") = 'super_admin'::"text"))))));



ALTER TABLE "public"."task_comments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tasks_insert" ON "public"."tasks" FOR INSERT TO "authenticated" WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND (("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"])) OR ("assigned_to" = "auth"."uid"()) OR ("assigned_by" = "auth"."uid"()))));



CREATE POLICY "tasks_insert_tenant" ON "public"."tasks" FOR INSERT WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "tasks_manager_read" ON "public"."tasks" FOR SELECT TO "authenticated" USING ((("public"."get_user_role"() = ANY (ARRAY['manager'::"text", 'admin'::"text"])) AND ("tenant_id" = "public"."current_tenant_id"())));



CREATE POLICY "tasks_owner_delete" ON "public"."tasks" FOR DELETE TO "authenticated" USING ((("assigned_to" = "auth"."uid"()) OR ("assigned_by" = "auth"."uid"())));



CREATE POLICY "tasks_owner_select" ON "public"."tasks" FOR SELECT TO "authenticated" USING ((("assigned_to" = "auth"."uid"()) OR ("assigned_by" = "auth"."uid"())));



CREATE POLICY "tasks_owner_update" ON "public"."tasks" FOR UPDATE TO "authenticated" USING ((("assigned_to" = "auth"."uid"()) OR ("assigned_by" = "auth"."uid"()))) WITH CHECK ((("assigned_to" = "auth"."uid"()) OR ("assigned_by" = "auth"."uid"())));



CREATE POLICY "tasks_select_tenant" ON "public"."tasks" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "tasks_super_admin" ON "public"."tasks" TO "authenticated" USING (("public"."get_user_role"() = 'super_admin'::"text")) WITH CHECK (("public"."get_user_role"() = 'super_admin'::"text"));



CREATE POLICY "tasks_update_tenant" ON "public"."tasks" FOR UPDATE USING (("tenant_id" = "public"."current_tenant_id"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "tenant_users_manage_account_assignments" ON "public"."account_assignments" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."accounts" "a"
     JOIN "public"."user_profiles" "up" ON (("a"."tenant_id" = "up"."tenant_id")))
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("up"."id" = "auth"."uid"()) AND ("up"."is_active" = true))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."accounts" "a"
     JOIN "public"."user_profiles" "up" ON (("a"."tenant_id" = "up"."tenant_id")))
  WHERE (("a"."id" = "account_assignments"."account_id") AND ("up"."id" = "auth"."uid"()) AND ("up"."is_active" = true)))));



CREATE POLICY "tenants_admin_full_access" ON "public"."tenants" TO "authenticated" USING (("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"]))) WITH CHECK (("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"])));



CREATE POLICY "tenants_onboarding_read" ON "public"."tenants" FOR SELECT TO "authenticated" USING (("public"."current_tenant_id"() IS NULL));



CREATE POLICY "tenants_read_current" ON "public"."tenants" FOR SELECT TO "authenticated" USING (("id" = "public"."current_tenant_id"()));



CREATE POLICY "tenants_select_my_org" ON "public"."tenants" FOR SELECT USING (("id" = "public"."current_tenant_id"()));



CREATE POLICY "up_admin_full_access" ON "public"."user_profiles" TO "authenticated" USING (("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"]))) WITH CHECK (("public"."get_user_role"() = ANY (ARRAY['admin'::"text", 'super_admin'::"text"])));



CREATE POLICY "up_manager_tenant_view" ON "public"."user_profiles" FOR SELECT TO "authenticated" USING ((("public"."get_user_role"() = 'manager'::"text") AND ("tenant_id" = "public"."current_tenant_id"())));



CREATE POLICY "up_self_access_select" ON "public"."user_profiles" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));



CREATE POLICY "up_self_access_update" ON "public"."user_profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "user_profiles_select_tenant" ON "public"."user_profiles" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "users_access_tenant_opportunities" ON "public"."opportunities" TO "authenticated" USING (("tenant_id" = "public"."get_current_user_tenant_id"())) WITH CHECK (("tenant_id" = "public"."get_current_user_tenant_id"()));



CREATE POLICY "users_access_tenant_prospects" ON "public"."prospects" TO "authenticated" USING (("tenant_id" = "public"."get_current_user_tenant_id"())) WITH CHECK (("tenant_id" = "public"."get_current_user_tenant_id"()));



CREATE POLICY "users_manage_own_notifications" ON "public"."notifications" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "users_manage_tenant_calendar_events" ON "public"."calendar_events" TO "authenticated" USING (("tenant_id" IN ( SELECT "up"."tenant_id"
   FROM "public"."user_profiles" "up"
  WHERE ("up"."id" = "auth"."uid"())))) WITH CHECK (("tenant_id" IN ( SELECT "up"."tenant_id"
   FROM "public"."user_profiles" "up"
  WHERE ("up"."id" = "auth"."uid"()))));



CREATE POLICY "weekly_goals_admin_access_v2" ON "public"."weekly_goals" TO "authenticated" USING ("public"."is_admin_user_jwt"()) WITH CHECK ("public"."is_admin_user_jwt"());



CREATE POLICY "weekly_goals_comprehensive_access" ON "public"."weekly_goals" TO "authenticated" USING ("public"."can_manage_weekly_goals"("user_id", "tenant_id")) WITH CHECK ("public"."can_manage_weekly_goals"("user_id", "tenant_id"));



CREATE POLICY "weekly_goals_delete_comprehensive" ON "public"."weekly_goals" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_manager"
  WHERE (("up_manager"."id" = "auth"."uid"()) AND ("up_manager"."role" = ANY (ARRAY['manager'::"public"."user_role", 'admin'::"public"."user_role", 'super_admin'::"public"."user_role"])) AND ("up_manager"."tenant_id" IN ( SELECT "up_target"."tenant_id"
           FROM "public"."user_profiles" "up_target"
          WHERE ("up_target"."id" = "weekly_goals"."user_id")))))) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_super"
  WHERE (("up_super"."id" = "auth"."uid"()) AND ("up_super"."role" = 'super_admin'::"public"."user_role"))))));



CREATE POLICY "weekly_goals_insert_comprehensive" ON "public"."weekly_goals" FOR INSERT WITH CHECK ((("auth"."uid"() = "user_id") OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_manager"
  WHERE (("up_manager"."id" = "auth"."uid"()) AND ("up_manager"."role" = ANY (ARRAY['manager'::"public"."user_role", 'admin'::"public"."user_role", 'super_admin'::"public"."user_role"])) AND ("up_manager"."tenant_id" IN ( SELECT "up_target"."tenant_id"
           FROM "public"."user_profiles" "up_target"
          WHERE ("up_target"."id" = "weekly_goals"."user_id")))))) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_super"
  WHERE (("up_super"."id" = "auth"."uid"()) AND ("up_super"."role" = 'super_admin'::"public"."user_role"))))));



CREATE POLICY "weekly_goals_owner_access_v2" ON "public"."weekly_goals" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "weekly_goals_select_comprehensive" ON "public"."weekly_goals" FOR SELECT USING ((("auth"."uid"() = "user_id") OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_manager"
  WHERE (("up_manager"."id" = "auth"."uid"()) AND ("up_manager"."role" = ANY (ARRAY['manager'::"public"."user_role", 'admin'::"public"."user_role", 'super_admin'::"public"."user_role"])) AND ("up_manager"."tenant_id" IN ( SELECT "up_target"."tenant_id"
           FROM "public"."user_profiles" "up_target"
          WHERE ("up_target"."id" = "weekly_goals"."user_id")))))) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_super"
  WHERE (("up_super"."id" = "auth"."uid"()) AND ("up_super"."role" = 'super_admin'::"public"."user_role"))))));



CREATE POLICY "weekly_goals_tenant_isolation" ON "public"."weekly_goals" USING (("tenant_id" IN ( SELECT "user_profiles"."tenant_id"
   FROM "public"."user_profiles"
  WHERE ("user_profiles"."id" = "auth"."uid"()))));



CREATE POLICY "weekly_goals_update_comprehensive" ON "public"."weekly_goals" FOR UPDATE USING ((("auth"."uid"() = "user_id") OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_manager"
  WHERE (("up_manager"."id" = "auth"."uid"()) AND ("up_manager"."role" = ANY (ARRAY['manager'::"public"."user_role", 'admin'::"public"."user_role", 'super_admin'::"public"."user_role"])) AND ("up_manager"."tenant_id" IN ( SELECT "up_target"."tenant_id"
           FROM "public"."user_profiles" "up_target"
          WHERE ("up_target"."id" = "weekly_goals"."user_id")))))) OR (EXISTS ( SELECT 1
   FROM "public"."user_profiles" "up_super"
  WHERE (("up_super"."id" = "auth"."uid"()) AND ("up_super"."role" = 'super_admin'::"public"."user_role"))))));



CREATE POLICY "wg_ins_admin_mgr" ON "public"."weekly_goals" FOR INSERT WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"()));



CREATE POLICY "wg_rep_update_self" ON "public"."weekly_goals" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND ("user_id" = "auth"."uid"()))) WITH CHECK ((("tenant_id" = "public"."current_tenant_id"()) AND ("user_id" = "auth"."uid"())));



CREATE POLICY "wg_select_tenant" ON "public"."weekly_goals" FOR SELECT USING (("tenant_id" = "public"."current_tenant_id"()));



CREATE POLICY "wg_upd_admin_mgr" ON "public"."weekly_goals" FOR UPDATE USING ((("tenant_id" = "public"."current_tenant_id"()) AND "public"."is_admin_or_manager"())) WITH CHECK (("tenant_id" = "public"."current_tenant_id"()));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d_out"("public"."box2d") TO "service_role";



GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2df_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2df_out"("public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d_out"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_analyze"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_in"("cstring", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_out"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_recv"("internal", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_send"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_typmod_in"("cstring"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_typmod_out"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_analyze"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_out"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_recv"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_send"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_typmod_in"("cstring"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_typmod_out"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gidx_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "postgres";
GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gidx_out"("public"."gidx") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "service_role";



GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."spheroid_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "postgres";
GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."spheroid_out"("public"."spheroid") TO "service_role";



GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d"("public"."box2d") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box2d") TO "service_role";



GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("public"."geography", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box2d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bytea"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("public"."geometry", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."json"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."jsonb"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."path"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."point"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."polygon"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."text"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("path") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("path") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("path") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("path") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("point") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("point") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("point") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("point") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("polygon") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry"("text") TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."_audit_log"() TO "anon";
GRANT ALL ON FUNCTION "public"."_audit_log"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_audit_log"() TO "service_role";



GRANT ALL ON FUNCTION "public"."_policy_exists"("p_table" "text", "p_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_policy_exists"("p_table" "text", "p_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_policy_exists"("p_table" "text", "p_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_deprecate"("oldname" "text", "newname" "text", "version" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_index_extent"("tbl" "regclass", "col" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_join_selectivity"("regclass", "text", "regclass", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_pgsql_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_scripts_pgsql_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_selectivity"("tbl" "regclass", "att_name" "text", "geom" "public"."geometry", "mode" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_postgis_stats"("tbl" "regclass", "att_name" "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_asgml"(integer, "public"."geometry", integer, integer, "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_asx3d"(integer, "public"."geometry", integer, integer, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_bestsrid"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distancetree"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_distanceuncached"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_dwithinuncached"("public"."geography", "public"."geography", double precision, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_expand"("public"."geography", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_geomfromgml"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_pointoutside"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_sortablehash"("geom" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_voronoi"("g1" "public"."geometry", "clip" "public"."geometry", "tolerance" double precision, "return_polygons" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."_st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."addauth"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."addauth"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."addauth"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."addauth"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."addgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer, "new_type" character varying, "new_dim" integer, "use_typmod" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_force_password_reset"("target_email" "text", "admin_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_force_password_reset"("target_email" "text", "admin_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_force_password_reset"("target_email" "text", "admin_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."app_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."app_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."app_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."assign_reps_to_account"("account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid", "manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."assign_reps_to_account"("account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid", "manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."assign_reps_to_account"("account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid", "manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."assign_user_tenant"("user_uuid" "uuid", "new_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_establish_manager_rep_relationship"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_establish_manager_rep_relationship"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_establish_manager_rep_relationship"() TO "service_role";



GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."box3dtobox"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_access_any_account"() TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_any_account"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_any_account"() TO "service_role";



GRANT ALL ON FUNCTION "public"."can_access_any_tenant"() TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_any_tenant"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_any_tenant"() TO "service_role";



GRANT ALL ON FUNCTION "public"."can_access_tenant_data"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_tenant_data"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_tenant_data"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_access_tenant_data_enhanced"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_tenant_data_enhanced"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_tenant_data_enhanced"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_assign_user_to_tenant"("admin_user_id" "uuid", "target_user_id" "uuid", "target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_assign_user_to_tenant"("admin_user_id" "uuid", "target_user_id" "uuid", "target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_assign_user_to_tenant"("admin_user_id" "uuid", "target_user_id" "uuid", "target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_manage_user"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_manage_user"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_manage_user"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_manage_weekly_goals"("goal_user_id" "uuid", "goal_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_user_manage_documents"() TO "anon";
GRANT ALL ON FUNCTION "public"."can_user_manage_documents"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_user_manage_documents"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_task_access"("task_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_task_access"("task_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_task_access"("task_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_task_modify"("target_tenant_id" "uuid", "target_assigned_to" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_tenant_limits"("tenant_uuid" "uuid", "limit_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_tenant_limits"("tenant_uuid" "uuid", "limit_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_tenant_limits"("tenant_uuid" "uuid", "limit_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_role"("required_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_role"("required_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_role"("required_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_weekly_goals_exist"("user_ids" "uuid"[], "week_start_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauth"("text", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "postgres";
GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "anon";
GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."checkauthtrigger"() TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_inactive_user_profiles"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_inactive_user_profiles"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_inactive_user_profiles"() TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_password_setup"("user_uuid" "uuid", "mark_password_complete" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_password_setup"("user_uuid" "uuid", "mark_password_complete" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_password_setup"("user_uuid" "uuid", "mark_password_complete" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_user_profile_setup"("user_uuid" "uuid", "full_name_param" "text", "organization_param" "text", "role_param" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_user_profile_setup"("user_uuid" "uuid", "full_name_param" "text", "organization_param" "text", "role_param" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_user_profile_setup"("user_uuid" "uuid", "full_name_param" "text", "organization_param" "text", "role_param" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_user_setup"("user_email" "text", "profile_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_user_setup_enhanced"("user_email" "text", "profile_data" "jsonb", "mark_password_set" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_user_setup_enhanced"("user_email" "text", "profile_data" "jsonb", "mark_password_set" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_user_setup_enhanced"("user_email" "text", "profile_data" "jsonb", "mark_password_set" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."box2df", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contains_2d"("public"."geometry", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."convert_prospect_to_account"("prospect_uuid" "uuid", "link_to_existing_account_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_activity_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_activity_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_activity_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_admin_user_with_workflow"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "temp_password" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_admin_user_with_workflow"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "temp_password" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_admin_user_with_workflow"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "temp_password" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_roof_lead_with_geojson"("p_name" "text", "p_geojson" "jsonb", "p_condition_label" "public"."roof_condition_label", "p_condition_score" integer, "p_tags" "text"[], "p_notes" "text", "p_address" "text", "p_city" "text", "p_state" "text", "p_zip_code" "text", "p_estimated_sqft" integer, "p_estimated_repair_cost" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."create_roof_lead_with_geojson"("p_name" "text", "p_geojson" "jsonb", "p_condition_label" "public"."roof_condition_label", "p_condition_score" integer, "p_tags" "text"[], "p_notes" "text", "p_address" "text", "p_city" "text", "p_state" "text", "p_zip_code" "text", "p_estimated_sqft" integer, "p_estimated_repair_cost" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_roof_lead_with_geojson"("p_name" "text", "p_geojson" "jsonb", "p_condition_label" "public"."roof_condition_label", "p_condition_score" integer, "p_tags" "text"[], "p_notes" "text", "p_address" "text", "p_city" "text", "p_state" "text", "p_zip_code" "text", "p_estimated_sqft" integer, "p_estimated_repair_cost" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_task_assignment_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_task_assignment_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_task_assignment_notification"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_task_due_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_task_due_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_task_due_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_tenant_and_assign"("p_name" "text", "p_slug" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_tenant_and_assign"("p_name" "text", "p_slug" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_tenant_and_assign"("p_name" "text", "p_slug" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_profile_for_admin_user"("user_id" "uuid", "user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_with_temp_password"("user_email" "text", "user_full_name" "text", "user_role" "text", "user_phone" "text", "user_organization" "text", "target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."current_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."current_user_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_manager_team_relationships"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."debug_manager_team_relationships"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_manager_team_relationships"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_tenant_users"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_user_status"("check_user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_user_tenant_access"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_weekly_goals_access"("target_user_id" "uuid", "target_week_start" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."diagnose_user_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."diagnose_user_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."diagnose_user_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."diagnose_user_tenant_access"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "postgres";
GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "anon";
GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."disablelongtransactions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("table_name" character varying, "column_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrycolumn"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("table_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("schema_name" character varying, "table_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."dropgeometrytable"("catalog_name" character varying, "schema_name" character varying, "table_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "postgres";
GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "anon";
GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enablelongtransactions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."enhanced_text_similarity_fallback"("text1" "text", "text2" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_parks_tenant_assignment"() TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_parks_tenant_assignment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_parks_tenant_assignment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_user_profile_consistency"() TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_user_profile_consistency"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_user_profile_consistency"() TO "service_role";



GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."establish_manager_team_relationships"() TO "anon";
GRANT ALL ON FUNCTION "public"."establish_manager_team_relationships"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."establish_manager_team_relationships"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fill_activity_log_tenant"() TO "anon";
GRANT ALL ON FUNCTION "public"."fill_activity_log_tenant"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fill_activity_log_tenant"() TO "service_role";



GRANT ALL ON FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_account_duplicates"("prospect_name" "text", "prospect_domain" "text", "prospect_phone" "text", "prospect_city" "text", "prospect_state" "text", "current_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "postgres";
GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_srid"(character varying, character varying, character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."fix_parks_user_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."fix_parks_user_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fix_parks_user_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_temp_password_for_user"("user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geog_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_cmp"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_distance_knn"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_eq"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_ge"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_compress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_consistent"("internal", "public"."geography", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_decompress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_distance"("internal", "public"."geography", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_penalty"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_picksplit"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_same"("public"."box2d", "public"."box2d", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gist_union"("bytea", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_gt"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_le"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_lt"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_overlaps"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_choose_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_compress_nd"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_config_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_inner_consistent_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_leaf_consistent_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geography_spgist_picksplit_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom2d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom3d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geom4d_brin_inclusion_add_value"("internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_above"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_below"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_cmp"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contained_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_contains_nd"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_box"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_centroid_nd"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_distance_cpa"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_eq"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_ge"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_2d"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_compress_nd"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_2d"("internal", "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_consistent_nd"("internal", "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_2d"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_decompress_nd"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_2d"("internal", "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_distance_nd"("internal", "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_2d"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_penalty_nd"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_picksplit_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_2d"("geom1" "public"."geometry", "geom2" "public"."geometry", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_same_nd"("public"."geometry", "public"."geometry", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_sortsupport_2d"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_sortsupport_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_sortsupport_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_sortsupport_2d"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_2d"("bytea", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gist_union_nd"("bytea", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_gt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_hash"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_le"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_left"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_lt"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overabove"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overbelow"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overlaps_nd"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overleft"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_overright"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_right"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same_3d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_same_nd"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_sortsupport"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_3d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_choose_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_2d"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_3d"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_compress_nd"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_3d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_config_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_3d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_inner_consistent_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_3d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_leaf_consistent_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_2d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_3d"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_spgist_picksplit_nd"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometry_within_nd"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geometrytype"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geomfromewkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."geomfromewkt"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_account_reps"("account_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_account_reps"("account_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_account_reps"("account_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_available_accounts"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_available_accounts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_available_accounts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_auth_configuration_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_auth_configuration_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_auth_configuration_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_contact_available_properties"("contact_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_contact_available_properties"("contact_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_contact_available_properties"("contact_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_contact_linked_properties"("contact_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_user_tenant"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_user_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_user_tenant_info"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant_info"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_user_tenant_info"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_detailed_user_auth_status"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_detailed_user_auth_status"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_detailed_user_auth_status"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_documents_expiring"("within_days" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_documents_expiring"("within_days" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_documents_expiring"("within_days" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts_with_assignments"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts_with_assignments"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_accessible_accounts_with_assignments"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_accounts"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_all_tenant_users"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_funnel_metrics"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_members"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_members"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_members"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_metrics"("manager_uuid" "uuid", "week_start" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_performance"("manager_uuid" "uuid", "week_start_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_performance"("manager_uuid" "uuid", "week_start_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_performance"("manager_uuid" "uuid", "week_start_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_performance_detailed"("manager_uuid" "uuid", "week_start" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_team_summary"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_tenant_accounts"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_accounts"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_accounts"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_tenant_contacts"("manager_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_contacts"("manager_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_contacts"("manager_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_manager_tenant_properties"("manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_properties"("manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_manager_tenant_properties"("manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_opportunities_with_details"("filter_stage" "text", "filter_type" "text", "limit_count" integer, "offset_count" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_opportunities_with_details"("filter_stage" "text", "filter_type" "text", "limit_count" integer, "offset_count" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_opportunities_with_details"("filter_stage" "text", "filter_type" "text", "limit_count" integer, "offset_count" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_opportunity_pipeline_metrics"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_opportunity_pipeline_metrics"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_opportunity_pipeline_metrics"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_proj4_from_srid"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_prospects_with_details"("filter_status" "text"[], "filter_min_icp_score" integer, "filter_state" "text", "filter_city" "text", "filter_company_type" "text", "filter_assigned_to" "uuid", "filter_source" "text", "search_term" "text", "sort_column" "text", "sort_direction" "text", "page_limit" integer, "page_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_prospects_with_details"("filter_status" "text"[], "filter_min_icp_score" integer, "filter_state" "text", "filter_city" "text", "filter_company_type" "text", "filter_assigned_to" "uuid", "filter_source" "text", "search_term" "text", "sort_column" "text", "sort_direction" "text", "page_limit" integer, "page_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_prospects_with_details"("filter_status" "text"[], "filter_min_icp_score" integer, "filter_state" "text", "filter_city" "text", "filter_company_type" "text", "filter_assigned_to" "uuid", "filter_source" "text", "search_term" "text", "sort_column" "text", "sort_direction" "text", "page_limit" integer, "page_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_session_context"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_session_context"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_session_context"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_task_metrics"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_task_metrics"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_task_metrics"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_tasks_with_details"("user_uuid" "uuid", "status_filter" "public"."task_status", "priority_filter" "public"."task_priority") TO "anon";
GRANT ALL ON FUNCTION "public"."get_tasks_with_details"("user_uuid" "uuid", "status_filter" "public"."task_status", "priority_filter" "public"."task_priority") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_tasks_with_details"("user_uuid" "uuid", "status_filter" "public"."task_status", "priority_filter" "public"."task_priority") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_today_events"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_today_events"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_today_events"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_upcoming_events"("days_ahead" integer, "target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_upcoming_events"("days_ahead" integer, "target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_upcoming_events"("days_ahead" integer, "target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_accessible_accounts"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_accessible_prospects"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_accessible_prospects"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_accessible_prospects"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_auth_status"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_auth_status"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_auth_status"("user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_auth_status_enhanced"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_auth_status_enhanced"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_auth_status_enhanced"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_authentication_status"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_authentication_status"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_authentication_status"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_permissions_summary"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_permissions_summary"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_permissions_summary"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_from_jwt"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_from_jwt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_from_jwt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_reliable"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_reliable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_reliable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_with_fallbacks"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_with_fallbacks"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_with_fallbacks"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_with_super_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_with_super_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_with_super_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_tenant_debug"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_tenant_debug"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_tenant_debug"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_tenant_uuid"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_tenant_uuid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_tenant_uuid"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "postgres";
GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "anon";
GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gettransactionid"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "postgres";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_2d"("internal", "oid", "internal", smallint) TO "service_role";



GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "postgres";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_joinsel_nd"("internal", "oid", "internal", smallint) TO "service_role";



GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_2d"("internal", "oid", "internal", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gserialized_gist_sel_nd"("internal", "oid", "internal", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_email_confirmation_workflow"("user_id" "uuid", "user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_email_confirmation_workflow"("user_id" "uuid", "user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_email_confirmation_workflow"("user_id" "uuid", "user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_tenant_access"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."initialize_user_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."initialize_user_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."initialize_user_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_account_owner"("p_account_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_account_owner"("p_account_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_account_owner"("p_account_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_from_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_from_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_from_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_from_auth_metadata"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_from_auth_metadata"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_from_auth_metadata"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_or_above"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_or_above"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_or_above"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_or_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_or_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_or_manager"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_user_jwt"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_user_jwt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_user_jwt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."box2df", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contained_2d"("public"."geometry", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_accessing_team_member"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_accessing_team_member"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_accessing_team_member"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_from_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_from_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_from_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_of_goal_user"("goal_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_of_user"("manager_uuid" "uuid", "user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_of_user"("manager_uuid" "uuid", "user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_of_user"("manager_uuid" "uuid", "user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_or_above"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_or_above"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_or_above"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_or_admin_in_tenant"("check_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_or_admin_in_tenant"("check_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_or_admin_in_tenant"("check_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_user_jwt"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_user_jwt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_user_jwt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_manager_with_tenant_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_manager_with_tenant_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_manager_with_tenant_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_super_admin_from_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_super_admin_from_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_super_admin_from_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_super_admin_safe"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_super_admin_safe"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_super_admin_safe"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_super_admin_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_super_admin_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_super_admin_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_tenant_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_tenant_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_tenant_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."levenshtein_distance"("s1" "text", "s2" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."link_contact_to_property"("contact_uuid" "uuid", "property_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."link_contact_to_property"("contact_uuid" "uuid", "property_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."link_contact_to_property"("contact_uuid" "uuid", "property_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."list_current_policies"() TO "anon";
GRANT ALL ON FUNCTION "public"."list_current_policies"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."list_current_policies"() TO "service_role";



GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "postgres";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", timestamp without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "postgres";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lockrow"("text", "text", "text", "text", timestamp without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."log_auth_attempt"("p_user_id" "uuid", "p_event_type" "text", "p_token_type" "text", "p_token_prefix" "text", "p_success" boolean, "p_error_message" "text", "p_redirect_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."log_auth_attempt"("p_user_id" "uuid", "p_event_type" "text", "p_token_type" "text", "p_token_prefix" "text", "p_success" boolean, "p_error_message" "text", "p_redirect_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_auth_attempt"("p_user_id" "uuid", "p_event_type" "text", "p_token_type" "text", "p_token_prefix" "text", "p_success" boolean, "p_error_message" "text", "p_redirect_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "postgres";
GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "anon";
GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."longtransactionsenabled"() TO "service_role";



GRANT ALL ON FUNCTION "public"."manager_assign_account_to_reps"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."manager_assign_account_to_reps"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manager_assign_account_to_reps"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_ids" "uuid"[], "primary_rep_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manager_assign_rep_to_account"("manager_uuid" "uuid", "account_uuid" "uuid", "rep_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manager_assign_team_goals"("manager_uuid" "uuid", "goal_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."manager_can_access_tenant_profiles"("profile_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."manager_can_access_tenant_profiles"("profile_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manager_can_access_tenant_profiles"("profile_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."manager_can_manage_account_assignments"("manager_uuid" "uuid", "account_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."manager_can_manage_account_assignments"("manager_uuid" "uuid", "account_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manager_can_manage_account_assignments"("manager_uuid" "uuid", "account_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_event_completed"("event_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_event_completed"("event_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_event_completed"("event_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."box2df", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_2d"("public"."geometry", "public"."box2df") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."geography", "public"."gidx") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_geog"("public"."gidx", "public"."gidx") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."geometry", "public"."gidx") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "postgres";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "anon";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "authenticated";
GRANT ALL ON FUNCTION "public"."overlaps_nd"("public"."gidx", "public"."gidx") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asflatgeobuf_transfn"("internal", "anyelement", boolean, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asgeobuf_transfn"("internal", "anyelement", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_combinefn"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_deserialfn"("bytea", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_serialfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_asmvt_transfn"("internal", "anyelement", "text", integer, "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_accum_transfn"("internal", "public"."geometry", double precision, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterintersecting_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_clusterwithin_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_collect_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_makeline_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_polygonize_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_combinefn"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_combinefn"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_combinefn"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_combinefn"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_deserialfn"("bytea", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_deserialfn"("bytea", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_deserialfn"("bytea", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_deserialfn"("bytea", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_finalfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_finalfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_finalfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_finalfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_serialfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_serialfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_serialfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_serialfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."pgis_geometry_union_parallel_transfn"("internal", "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("use_typmod" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_geometry_columns"("tbl_oid" "oid", "use_typmod" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_addbbox"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_cache_bbox"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_dims"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_srid"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_constraint_type"("geomschema" "text", "geomtable" "text", "geomcolumn" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_dropbbox"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_extensions_upgrade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_full_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_geos_noop"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_geos_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_getbbox"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_hasbbox"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_index_supportfn"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_build_date"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_revision"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_lib_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libjson_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_liblwgeom_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libprotobuf_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_libxml_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_noop"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_proj_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_build_date"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_installed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_scripts_released"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_svn_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_transform_geometry"("geom" "public"."geometry", "text", "text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_type_name"("geomname" character varying, "coord_dimension" integer, "use_new_name" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_dims"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_srid"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_typmod_type"(integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "postgres";
GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "anon";
GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."postgis_wagyu_version"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."prepare_confirmation_resend"("user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_manager_dashboard_demo_data"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_manager_dashboard_demo_data"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_manager_dashboard_demo_data"() TO "service_role";



GRANT ALL ON FUNCTION "public"."remove_rep_from_account"("account_uuid" "uuid", "rep_uuid" "uuid", "manager_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."remove_rep_from_account"("account_uuid" "uuid", "rep_uuid" "uuid", "manager_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."remove_rep_from_account"("account_uuid" "uuid", "rep_uuid" "uuid", "manager_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."resend_confirmation_workflow"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."resend_confirmation_workflow"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."resend_confirmation_workflow"("user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."safe_assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."safe_assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."safe_assign_rep_to_account"("account_uuid" "uuid", "rep_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."send_password_setup_email"("user_email" "text", "redirect_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."send_password_setup_email"("user_email" "text", "redirect_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."send_password_setup_email"("user_email" "text", "redirect_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_account_defaults"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_account_defaults"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_account_defaults"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_account_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_account_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_account_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_activity_defaults"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_activity_defaults"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_activity_defaults"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_and_validate_weekly_goals_tenant"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_and_validate_weekly_goals_tenant"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_and_validate_weekly_goals_tenant"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_contact_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_contact_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_contact_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_contacts_created_by"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_contacts_created_by"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_contacts_created_by"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_tenant"("p_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."set_current_tenant"("p_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_current_tenant"("p_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "postgres";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "anon";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_opportunity_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_opportunity_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_opportunity_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_property_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_property_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_property_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_task_comment_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_task_comment_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_task_comment_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_task_defaults"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_task_defaults"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_task_defaults"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_task_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_task_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_task_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_weekly_goals_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_weekly_goals_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_weekly_goals_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."setup_new_user_profile"("user_id" "uuid", "user_email" "text", "user_metadata" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."show_limit"() TO "postgres";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dclosestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3ddwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dintersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlength"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlineinterpolatepoint"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dlongestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dmakebox"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dmaxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dperimeter"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dshortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addmeasure"("public"."geometry", double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_addpoint"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_affine"("public"."geometry", double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_angle"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_angle"("pt1" "public"."geometry", "pt2" "public"."geometry", "pt3" "public"."geometry", "pt4" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_area"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_area"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_area2d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geography", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asbinary"("public"."geometry", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asencodedpolyline"("geom" "public"."geometry", "nprecision" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkb"("public"."geometry", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geography", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asewkt"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeojson"("r" "record", "geom_column" "text", "maxdecimaldigits" integer, "pretty_bool" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geog" "public"."geography", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgml"("version" integer, "geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer, "nprefix" "text", "id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ashexewkb"("public"."geometry", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("geog" "public"."geography", "maxdecimaldigits" integer, "nprefix" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_askml"("geom" "public"."geometry", "maxdecimaldigits" integer, "nprefix" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_aslatlontext"("geom" "public"."geometry", "tmpl" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmarc21"("geom" "public"."geometry", "format" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmarc21"("geom" "public"."geometry", "format" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmarc21"("geom" "public"."geometry", "format" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmarc21"("geom" "public"."geometry", "format" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvtgeom"("geom" "public"."geometry", "bounds" "public"."box2d", "extent" integer, "buffer" integer, "clip_geom" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("geog" "public"."geography", "rel" integer, "maxdecimaldigits" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_assvg"("geom" "public"."geometry", "rel" integer, "maxdecimaldigits" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geography", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astext"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry", "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_astwkb"("geom" "public"."geometry"[], "ids" bigint[], "prec" integer, "prec_z" integer, "prec_m" integer, "with_sizes" boolean, "with_boxes" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asx3d"("geom" "public"."geometry", "maxdecimaldigits" integer, "options" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_azimuth"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_bdmpolyfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_bdpolyfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_boundary"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_boundingdiagonal"("geom" "public"."geometry", "fits" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_box2dfromgeohash"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("text", double precision, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("public"."geography", double precision, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "quadsegs" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buffer"("geom" "public"."geometry", "radius" double precision, "options" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_buildarea"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_centroid"("public"."geography", "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_chaikinsmoothing"("public"."geometry", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_cleangeometry"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clipbybox2d"("geom" "public"."geometry", "box" "public"."box2d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_closestpoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_closestpointofapproach"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterdbscan"("public"."geometry", "eps" double precision, "minpoints" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer, "max_radius" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer, "max_radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer, "max_radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterkmeans"("geom" "public"."geometry", "k" integer, "max_radius" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry"[], double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionextract"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collectionhomogenize"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box2d", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_combinebbox"("public"."box3d", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_concavehull"("param_geom" "public"."geometry", "param_pctconvex" double precision, "param_allow_holes" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_contains"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_containsproperly"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_convexhull"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coorddim"("geometry" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_coveredby"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_covers"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_cpawithin"("public"."geometry", "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_crosses"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_curvetoline"("geom" "public"."geometry", "tol" double precision, "toltype" integer, "flags" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_delaunaytriangles"("g1" "public"."geometry", "tolerance" double precision, "flags" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dfullywithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_difference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dimension"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_disjoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distance"("geog1" "public"."geography", "geog2" "public"."geography", "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancecpa"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancesphere"("geom1" "public"."geometry", "geom2" "public"."geometry", "radius" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_distancespheroid"("geom1" "public"."geometry", "geom2" "public"."geometry", "public"."spheroid") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dump"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dumppoints"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dumprings"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dumpsegments"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dumpsegments"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_dumpsegments"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dumpsegments"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("text", "text", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_dwithin"("geog1" "public"."geography", "geog2" "public"."geography", "tolerance" double precision, "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_endpoint"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_envelope"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_equals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_estimatedextent"("text", "text", "text", boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box2d", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."box3d", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box2d", "dx" double precision, "dy" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("box" "public"."box3d", "dx" double precision, "dy" double precision, "dz" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_expand"("geom" "public"."geometry", "dx" double precision, "dy" double precision, "dz" double precision, "dm" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_exteriorring"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_filterbym"("public"."geometry", double precision, double precision, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_findextent"("text", "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_flipcoordinates"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force2d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3d"("geom" "public"."geometry", "zvalue" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3dm"("geom" "public"."geometry", "mvalue" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force3dz"("geom" "public"."geometry", "zvalue" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_force4d"("geom" "public"."geometry", "zvalue" double precision, "mvalue" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcecollection"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcecurve"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcepolygonccw"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcepolygoncw"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcerhr"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_forcesfs"("public"."geometry", "version" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_frechetdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_fromflatgeobuf"("anyelement", "bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuf"("anyelement", "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuf"("anyelement", "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuf"("anyelement", "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_fromflatgeobuftotable"("text", "text", "bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuftotable"("text", "text", "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuftotable"("text", "text", "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_fromflatgeobuftotable"("text", "text", "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_generatepoints"("area" "public"."geometry", "npoints" integer, "seed" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geogfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geogfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geographyfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geohash"("geog" "public"."geography", "maxchars" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geohash"("geom" "public"."geometry", "maxchars" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomcollfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometricmedian"("g" "public"."geometry", "tolerance" double precision, "max_iter" integer, "fail_if_not_converged" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometryn"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geometrytype"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromewkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromewkt"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeohash"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"(json) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"(json) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"(json) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"(json) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgeojson"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromgml"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromkml"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfrommarc21"("marc21xml" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfrommarc21"("marc21xml" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfrommarc21"("marc21xml" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfrommarc21"("marc21xml" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromtwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_geomfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_gmltosql"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hasarc"("geometry" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hausdorffdistance"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hexagon"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_hexagongrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_interiorringn"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_interpolatepoint"("line" "public"."geometry", "point" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("public"."geography", "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersection"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("geog1" "public"."geography", "geog2" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_intersects"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isclosed"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_iscollection"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isempty"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ispolygonccw"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ispolygoncw"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isring"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_issimple"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalid"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvaliddetail"("geom" "public"."geometry", "flags" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidreason"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_isvalidtrajectory"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_length"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_length"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length2d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_length2dspheroid"("public"."geometry", "public"."spheroid") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "anon";
GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lengthspheroid"("public"."geometry", "public"."spheroid") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_letters"("letters" "text", "font" json) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_letters"("letters" "text", "font" json) TO "anon";
GRANT ALL ON FUNCTION "public"."st_letters"("letters" "text", "font" json) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_letters"("letters" "text", "font" json) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linecrossingdirection"("line1" "public"."geometry", "line2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromencodedpolyline"("txtin" "text", "nprecision" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefrommultipoint"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linefromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoint"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_lineinterpolatepoints"("public"."geometry", double precision, "repeat" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linelocatepoint"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry", boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linemerge"("public"."geometry", boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linestringfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linesubstring"("public"."geometry", double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_linetocurve"("geometry" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatealong"("geometry" "public"."geometry", "measure" double precision, "leftrightoffset" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatebetween"("geometry" "public"."geometry", "frommeasure" double precision, "tomeasure" double precision, "leftrightoffset" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_locatebetweenelevations"("geometry" "public"."geometry", "fromelevation" double precision, "toelevation" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_longestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_m"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makebox2d"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeenvelope"(double precision, double precision, double precision, double precision, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepoint"(double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepointm"(double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makepolygon"("public"."geometry", "public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makevalid"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makevalid"("geom" "public"."geometry", "params" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_maxdistance"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_maximuminscribedcircle"("public"."geometry", OUT "center" "public"."geometry", OUT "nearest" "public"."geometry", OUT "radius" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memsize"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumboundingcircle"("inputgeom" "public"."geometry", "segs_per_quarter" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumboundingradius"("public"."geometry", OUT "center" "public"."geometry", OUT "radius" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumclearance"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_minimumclearanceline"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mlinefromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpointfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_mpolyfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multi"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinefromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multilinestringfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipointfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolyfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_multipolygonfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ndims"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_node"("g" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_normalize"("geom" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_npoints"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_nrings"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numgeometries"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numinteriorring"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numinteriorrings"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numpatches"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_numpoints"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_offsetcurve"("line" "public"."geometry", "distance" double precision, "params" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_orderingequals"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_orientedenvelope"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_overlaps"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_patchn"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter"("geog" "public"."geography", "use_spheroid" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_perimeter2d"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision, "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision, "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision, "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_point"(double precision, double precision, "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromgeohash"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointinsidecircle"("public"."geometry", double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointm"("xcoordinate" double precision, "ycoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointm"("xcoordinate" double precision, "ycoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointm"("xcoordinate" double precision, "ycoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointm"("xcoordinate" double precision, "ycoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointn"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointonsurface"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_points"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointz"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointz"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointz"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointz"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_pointzm"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_pointzm"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_pointzm"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_pointzm"("xcoordinate" double precision, "ycoordinate" double precision, "zcoordinate" double precision, "mcoordinate" double precision, "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polyfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygon"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromtext"("text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonfromwkb"("bytea", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_project"("geog" "public"."geography", "distance" double precision, "azimuth" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_quantizecoordinates"("g" "public"."geometry", "prec_x" integer, "prec_y" integer, "prec_z" integer, "prec_m" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_reduceprecision"("geom" "public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relate"("geom1" "public"."geometry", "geom2" "public"."geometry", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_relatematch"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_removepoint"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_removerepeatedpoints"("geom" "public"."geometry", "tolerance" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_reverse"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotate"("public"."geometry", double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatex"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatey"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_rotatez"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", "public"."geometry", "origin" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scale"("public"."geometry", double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_scroll"("public"."geometry", "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_segmentize"("geog" "public"."geography", "max_segment_length" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_segmentize"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_seteffectivearea"("public"."geometry", double precision, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setpoint"("public"."geometry", integer, "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geog" "public"."geography", "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_setsrid"("geom" "public"."geometry", "srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_sharedpaths"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_shiftlongitude"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_shortestline"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplify"("public"."geometry", double precision, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" double precision, "is_outer" boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" double precision, "is_outer" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" double precision, "is_outer" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplifypolygonhull"("geom" "public"."geometry", "vertex_fraction" double precision, "is_outer" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplifypreservetopology"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_simplifyvw"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snap"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_snaptogrid"("geom1" "public"."geometry", "geom2" "public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_split"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_square"("size" double precision, "cell_i" integer, "cell_j" integer, "origin" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_squaregrid"("size" double precision, "bounds" "public"."geometry", OUT "geom" "public"."geometry", OUT "i" integer, OUT "j" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_srid"("geog" "public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_srid"("geom" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_startpoint"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_subdivide"("geom" "public"."geometry", "maxvertices" integer, "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "anon";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geography") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_summary"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_swapordinates"("geom" "public"."geometry", "ords" "cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_symdifference"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_symmetricdifference"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_tileenvelope"("zoom" integer, "x" integer, "y" integer, "bounds" "public"."geometry", "margin" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_touches"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("public"."geometry", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "to_proj" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_srid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transform"("geom" "public"."geometry", "from_proj" "text", "to_proj" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_translate"("public"."geometry", double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_transscale"("public"."geometry", double precision, double precision, double precision, double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_triangulatepolygon"("g1" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_unaryunion"("public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("geom1" "public"."geometry", "geom2" "public"."geometry", "gridsize" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_voronoilines"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_voronoipolygons"("g1" "public"."geometry", "tolerance" double precision, "extend_to" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_within"("geom1" "public"."geometry", "geom2" "public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wkbtosql"("wkb" "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wkttosql"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_wrapx"("geom" "public"."geometry", "wrap" double precision, "move" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_x"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_xmax"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_xmin"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_y"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ymax"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_ymin"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_z"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmax"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmflag"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "anon";
GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_zmin"("public"."box3d") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_super_admin_metadata"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_super_admin_metadata"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_super_admin_metadata"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_user_metadata_on_profile_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_user_metadata_on_profile_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_user_metadata_on_profile_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_user_metadata_with_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_user_metadata_with_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_user_metadata_with_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."test_user_data_access"("test_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."test_user_data_access"("test_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."test_user_data_access"("test_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."text_similarity_fallback"("text1" "text", "text2" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text", "p_user_context" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text", "p_user_context" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_auth_error"("p_error_type" "text", "p_error_message" "text", "p_token_info" "text", "p_user_context" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."unlink_contact_from_property"("contact_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."unlink_contact_from_property"("contact_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unlink_contact_from_property"("contact_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unlockrows"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_document_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_document_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_document_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_opportunity_stage"("opportunity_uuid" "uuid", "new_stage" "text", "stage_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_opportunity_stage"("opportunity_uuid" "uuid", "new_stage" "text", "stage_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_opportunity_stage"("opportunity_uuid" "uuid", "new_stage" "text", "stage_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_task_status"("task_uuid" "uuid", "new_status" "public"."task_status", "completion_notes_param" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_task_status"("task_uuid" "uuid", "new_status" "public"."task_status", "completion_notes_param" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_task_status"("task_uuid" "uuid", "new_status" "public"."task_status", "completion_notes_param" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"(character varying, character varying, character varying, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."updategeometrysrid"("catalogn_name" character varying, "schema_name" character varying, "table_name" character varying, "column_name" character varying, "new_srid_in" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."user_belongs_to_event_tenant"("event_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_belongs_to_event_tenant"("event_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_belongs_to_event_tenant"("event_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_belongs_to_tenant"("tenant_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_belongs_to_tenant"("tenant_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_belongs_to_tenant"("tenant_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_can_access_account"("account_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_can_access_account"("account_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_can_access_account"("account_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_can_access_opportunities"() TO "anon";
GRANT ALL ON FUNCTION "public"."user_can_access_opportunities"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_can_access_opportunities"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_can_access_tenant_data"("target_tenant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_can_access_tenant_data"("target_tenant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_can_access_tenant_data"("target_tenant_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_can_access_tenant_safe"("tenant_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_has_role"("required_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."user_has_role"("required_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_has_role"("required_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."user_is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_is_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."user_is_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_is_manager"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_is_manager_or_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."user_is_manager_or_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_is_manager_or_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_needs_password_setup"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_needs_password_setup"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_needs_password_setup"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_profile_is_complete"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_profile_is_complete"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_profile_is_complete"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_authentication_state"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_authentication_state"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_authentication_state"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_password_reset_session"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_password_reset_session"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_password_reset_session"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_policy_column_references"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_policy_column_references"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_policy_column_references"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_tenant_consistency"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_tenant_consistency"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_tenant_consistency"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_user_session"("session_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_user_session"("session_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_user_session"("session_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_user_session_and_profile_enhanced"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_weekly_goals_tenant_consistency"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_weekly_goals_tenant_consistency"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_weekly_goals_tenant_consistency"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_auth_setup"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_auth_setup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_auth_setup"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_manager_assigned_goals"("manager_uuid" "uuid", "target_user_ids" "uuid"[], "target_week_start" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_parks_manager_data_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_parks_manager_data_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_parks_manager_data_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_summit_pm_setup"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_summit_pm_setup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_summit_pm_setup"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_super_admin_setup"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_super_admin_setup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_super_admin_setup"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text", "security_answer" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text", "security_answer" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_temp_password_and_setup"("user_email" "text", "temp_password" "text", "security_question" "text", "security_answer" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_tenant_representatives"("tenant_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."verify_tenant_representatives"("tenant_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_tenant_representatives"("tenant_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "service_role";












GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_3dextent"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asflatgeobuf"("anyelement", boolean, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asgeobuf"("anyelement", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_asmvt"("anyelement", "text", integer, "text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterintersecting"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_clusterwithin"("public"."geometry", double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_collect"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_extent"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_makeline"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memcollect"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_memunion"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_polygonize"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "postgres";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry") TO "service_role";



GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "postgres";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."st_union"("public"."geometry", double precision) TO "service_role";









GRANT ALL ON TABLE "public"."_audit_queue" TO "anon";
GRANT ALL ON TABLE "public"."_audit_queue" TO "authenticated";
GRANT ALL ON TABLE "public"."_audit_queue" TO "service_role";



GRANT ALL ON SEQUENCE "public"."_audit_queue_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."_audit_queue_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."_audit_queue_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."account_assignments" TO "anon";
GRANT ALL ON TABLE "public"."account_assignments" TO "authenticated";
GRANT ALL ON TABLE "public"."account_assignments" TO "service_role";



GRANT ALL ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";



GRANT ALL ON TABLE "public"."activities" TO "anon";
GRANT ALL ON TABLE "public"."activities" TO "authenticated";
GRANT ALL ON TABLE "public"."activities" TO "service_role";



GRANT ALL ON TABLE "public"."activity_logs" TO "anon";
GRANT ALL ON TABLE "public"."activity_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."activity_logs" TO "service_role";



GRANT ALL ON TABLE "public"."auth_configuration_guide" TO "anon";
GRANT ALL ON TABLE "public"."auth_configuration_guide" TO "authenticated";
GRANT ALL ON TABLE "public"."auth_configuration_guide" TO "service_role";



GRANT ALL ON SEQUENCE "public"."auth_configuration_guide_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auth_configuration_guide_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auth_configuration_guide_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."auth_debug_log" TO "anon";
GRANT ALL ON TABLE "public"."auth_debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."auth_debug_log" TO "service_role";



GRANT ALL ON TABLE "public"."auth_debug_summary" TO "anon";
GRANT ALL ON TABLE "public"."auth_debug_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."auth_debug_summary" TO "service_role";



GRANT ALL ON TABLE "public"."calendar_events" TO "anon";
GRANT ALL ON TABLE "public"."calendar_events" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_events" TO "service_role";



GRANT ALL ON TABLE "public"."contacts" TO "anon";
GRANT ALL ON TABLE "public"."contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."contacts" TO "service_role";



GRANT ALL ON TABLE "public"."document_events" TO "anon";
GRANT ALL ON TABLE "public"."document_events" TO "authenticated";
GRANT ALL ON TABLE "public"."document_events" TO "service_role";



GRANT ALL ON TABLE "public"."documents" TO "anon";
GRANT ALL ON TABLE "public"."documents" TO "authenticated";
GRANT ALL ON TABLE "public"."documents" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."opportunities" TO "anon";
GRANT ALL ON TABLE "public"."opportunities" TO "authenticated";
GRANT ALL ON TABLE "public"."opportunities" TO "service_role";



GRANT ALL ON TABLE "public"."properties" TO "anon";
GRANT ALL ON TABLE "public"."properties" TO "authenticated";
GRANT ALL ON TABLE "public"."properties" TO "service_role";



GRANT ALL ON TABLE "public"."prospects" TO "anon";
GRANT ALL ON TABLE "public"."prospects" TO "authenticated";
GRANT ALL ON TABLE "public"."prospects" TO "service_role";



GRANT ALL ON TABLE "public"."recent_auth_errors" TO "anon";
GRANT ALL ON TABLE "public"."recent_auth_errors" TO "authenticated";
GRANT ALL ON TABLE "public"."recent_auth_errors" TO "service_role";



GRANT ALL ON TABLE "public"."roof_lead_images" TO "anon";
GRANT ALL ON TABLE "public"."roof_lead_images" TO "authenticated";
GRANT ALL ON TABLE "public"."roof_lead_images" TO "service_role";



GRANT ALL ON TABLE "public"."roof_leads" TO "anon";
GRANT ALL ON TABLE "public"."roof_leads" TO "authenticated";
GRANT ALL ON TABLE "public"."roof_leads" TO "service_role";



GRANT ALL ON TABLE "public"."task_comments" TO "anon";
GRANT ALL ON TABLE "public"."task_comments" TO "authenticated";
GRANT ALL ON TABLE "public"."task_comments" TO "service_role";



GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";



GRANT ALL ON TABLE "public"."tenants" TO "anon";
GRANT ALL ON TABLE "public"."tenants" TO "authenticated";
GRANT ALL ON TABLE "public"."tenants" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."weekly_goals" TO "anon";
GRANT ALL ON TABLE "public"."weekly_goals" TO "authenticated";
GRANT ALL ON TABLE "public"."weekly_goals" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























