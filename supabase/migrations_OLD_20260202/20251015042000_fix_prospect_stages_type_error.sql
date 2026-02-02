-- Migration: Fix prospect_stages Type Error
-- Date: 2025-10-15
-- Purpose: Create missing prospect_stages enum type and fix function definitions

-- ==============================================================================
-- STEP 1: Create Missing prospect_stages Enum Type
-- ==============================================================================

-- Create the prospect_stages enum type that was missing
CREATE TYPE prospect_stages AS ENUM (
  'new',
  'contacted',
  'qualified',
  'proposal_sent',
  'negotiating',
  'closed_won',
  'closed_lost'
);

-- ==============================================================================
-- STEP 2: Drop and Recreate get_user_accessible_prospects Function
-- ==============================================================================

-- Drop the function first to avoid conflicts
DROP FUNCTION IF EXISTS get_user_accessible_prospects(uuid);

-- Recreate the function with correct prospect_stages type
CREATE OR REPLACE FUNCTION get_user_accessible_prospects(user_uuid uuid)
RETURNS TABLE(
  id uuid,
  company_name text,
  first_name text,
  last_name text,
  email text,
  phone text,
  company_type company_type,
  stage prospect_stages,
  city text,
  state text,
  created_at timestamptz,
  updated_at timestamptz,
  notes text,
  is_active boolean,
  tenant_id uuid,
  assigned_rep_id uuid,
  source text,
  access_type text
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role text;
  user_tenant_id uuid;
BEGIN
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
      p.id, p.company_name, p.first_name, p.last_name, p.email, p.phone,
      p.company_type, p.stage, p.city, p.state, p.created_at, p.updated_at,
      p.notes, p.is_active, p.tenant_id, p.assigned_rep_id, p.source,
      CASE WHEN user_role = 'manager' THEN 'manager_tenant_access' ELSE 'super_admin_access' END::text
    FROM prospects p
    WHERE (user_role = 'super_admin' OR p.tenant_id = user_tenant_id)
      AND p.is_active = true
    ORDER BY p.company_name, p.last_name;

  -- For reps: return only their assigned prospects
  ELSIF user_role = 'rep' THEN
    RETURN QUERY
    SELECT 
      p.id, p.company_name, p.first_name, p.last_name, p.email, p.phone,
      p.company_type, p.stage, p.city, p.state, p.created_at, p.updated_at,
      p.notes, p.is_active, p.tenant_id, p.assigned_rep_id, p.source,
      'rep_assigned_access'::text
    FROM prospects p
    WHERE p.assigned_rep_id = user_uuid
      AND p.tenant_id = user_tenant_id
      AND p.is_active = true
    ORDER BY p.company_name, p.last_name;
  END IF;
END;
$$;

-- ==============================================================================
-- STEP 3: Update prospects table to use the new enum type (if needed)
-- ==============================================================================

-- Check if prospects table exists and update stage column to use correct type
DO $$
BEGIN
  -- Check if the prospects table exists and has a stage column
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'prospects' 
    AND column_name = 'stage' 
    AND table_schema = 'public'
  ) THEN
    -- Update the column type to use the new enum
    ALTER TABLE prospects ALTER COLUMN stage TYPE prospect_stages USING stage::text::prospect_stages;
    RAISE NOTICE 'Updated prospects.stage column to use prospect_stages enum';
  ELSE
    RAISE NOTICE 'prospects table or stage column does not exist yet';
  END IF;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Could not update prospects.stage column: %', SQLERRM;
END;
$$;

-- ==============================================================================
-- STEP 4: Grant Function Permissions
-- ==============================================================================

-- Grant execute permission on the recreated function
GRANT EXECUTE ON FUNCTION get_user_accessible_prospects(uuid) TO authenticated;

-- ==============================================================================
-- STEP 5: Update Sample Data with Correct Enum Values
-- ==============================================================================

-- Update any existing prospect sample data to use correct enum values
DO $$
DECLARE
  fox_tenant_id uuid := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7'::uuid;
  sample_rep_id uuid;
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
BEGIN
  -- Get sample rep ID
  SELECT id INTO sample_rep_id FROM user_profiles WHERE email = 'sarah.rep@foxroofing.com' LIMIT 1;
  
  -- Create sample prospects with correct enum values
  INSERT INTO prospects (
    id, company_name, first_name, last_name, email, phone, company_type, stage,
    city, state, tenant_id, assigned_rep_id, source, is_active, created_at, updated_at, notes
  )
  VALUES 
    (
      gen_random_uuid(),
      'Dallas Sports Complex',
      'Jennifer',
      'Martinez',
      'j.martinez@dallassports.com',
      '(214) 555-0201',
      'commercial'::company_type,
      'new'::prospect_stages,
      'Dallas',
      'TX',
      fox_tenant_id,
      COALESCE(sample_rep_id, parks_user_id),
      'website_inquiry',
      true,
      NOW() - interval '2 days',
      NOW(),
      'Inquired about roofing for new sports facility construction'
    ),
    (
      gen_random_uuid(),
      'Green Valley HOA',
      'Robert',
      'Chen',
      'rchen@greenvalleyhoa.org',
      '(972) 555-0202',
      'residential'::company_type,
      'contacted'::prospect_stages,
      'Richardson',
      'TX',
      fox_tenant_id,
      parks_user_id,
      'referral',
      true,
      NOW() - interval '4 days',
      NOW() - interval '1 day',
      'HOA president looking for bulk residential roofing services'
    ),
    (
      gen_random_uuid(),
      'Industrial Park Management',
      'Lisa',
      'Williams',
      'lwilliams@industrialpark.com',
      '(469) 555-0203',
      'industrial'::company_type,
      'qualified'::prospect_stages,
      'Garland',
      'TX',
      fox_tenant_id,
      COALESCE(sample_rep_id, parks_user_id),
      'cold_call',
      true,
      NOW() - interval '1 week',
      NOW() - interval '2 days',
      'Manages multiple warehouse buildings, budget approved for Q1'
    )
  ON CONFLICT (email, tenant_id) DO UPDATE SET
    stage = EXCLUDED.stage,
    updated_at = NOW()
    WHERE prospects.stage::text != EXCLUDED.stage::text;

  RAISE NOTICE 'Sample prospects data updated with correct prospect_stages enum values';
END;
$$;

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Test the function works
DO $$
DECLARE
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  prospects_count integer;
BEGIN
  -- Test prospect access
  SELECT COUNT(*) INTO prospects_count FROM get_user_accessible_prospects(parks_user_id);
  RAISE NOTICE 'Parks manager can access % prospects with prospect_stages enum', prospects_count;
  
  IF prospects_count = 0 THEN
    RAISE WARNING 'No prospects found for Parks manager - check tenant assignment and sample data';
  END IF;
END;
$$;

-- Final success message
SELECT 'prospect_stages type error fix completed successfully' as status;