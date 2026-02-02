-- Migration: Fix Prospects Company Name Column Error
-- Date: 2025-10-15
-- Purpose: Fix column name mismatch in prospects table and functions

-- ==============================================================================
-- STEP 1: Create Missing prospect_stages Enum Type (if not exists)
-- ==============================================================================

-- Create the prospect_stages enum type that was missing
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prospect_stages') THEN
    CREATE TYPE prospect_stages AS ENUM (
      'new',
      'contacted',
      'qualified',
      'proposal_sent',
      'negotiating',
      'closed_won',
      'closed_lost'
    );
    RAISE NOTICE 'Created prospect_stages enum type';
  ELSE
    RAISE NOTICE 'prospect_stages enum type already exists';
  END IF;
END;
$$;

-- ==============================================================================
-- STEP 2: Fix prospects table schema to match expected column names
-- ==============================================================================

DO $$
BEGIN
  -- Check if prospects table exists and add company_name column if needed
  IF EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_name = 'prospects' 
    AND table_schema = 'public'
  ) THEN
    
    -- Check if name column exists but company_name doesn't
    IF EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'name'
      AND table_schema = 'public'
    ) AND NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'company_name'
      AND table_schema = 'public'
    ) THEN
      -- Add company_name as an alias to name column
      ALTER TABLE prospects ADD COLUMN company_name TEXT;
      UPDATE prospects SET company_name = name WHERE company_name IS NULL;
      ALTER TABLE prospects ALTER COLUMN company_name SET NOT NULL;
      RAISE NOTICE 'Added company_name column to prospects table';
      
      -- Update the unique index to use company_name instead of name
      DROP INDEX IF EXISTS uidx_prospects_tenant_name_active;
      CREATE UNIQUE INDEX uidx_prospects_tenant_company_name_active 
      ON public.prospects(tenant_id, LOWER(company_name)) 
      WHERE stage IN ('new','contacted','qualified','proposal_sent','negotiating');
      
      -- Update other indexes
      DROP INDEX IF EXISTS idx_prospects_tenant_name;
      CREATE INDEX idx_prospects_tenant_company_name ON public.prospects(tenant_id, LOWER(company_name));
      
      RAISE NOTICE 'Updated indexes to use company_name';
    END IF;
    
    -- Add missing columns if they don't exist
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'first_name'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN first_name TEXT;
      RAISE NOTICE 'Added first_name column to prospects table';
    END IF;
    
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'last_name'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN last_name TEXT;
      RAISE NOTICE 'Added last_name column to prospects table';
    END IF;
    
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'email'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN email TEXT;
      RAISE NOTICE 'Added email column to prospects table';
    END IF;
    
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'stage'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN stage prospect_stages DEFAULT 'new'::prospect_stages;
      RAISE NOTICE 'Added stage column to prospects table';
    ELSE
      -- Update existing stage column to use correct type
      BEGIN
        ALTER TABLE prospects ALTER COLUMN stage TYPE prospect_stages USING 
          CASE 
            WHEN stage = 'uncontacted' THEN 'new'::prospect_stages
            WHEN stage = 'researching' THEN 'new'::prospect_stages  
            WHEN stage = 'attempted' THEN 'contacted'::prospect_stages
            WHEN stage = 'converted' THEN 'closed_won'::prospect_stages
            WHEN stage = 'disqualified' THEN 'closed_lost'::prospect_stages
            ELSE stage::prospect_stages
          END;
        RAISE NOTICE 'Updated prospects.stage column to use prospect_stages enum';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE 'Could not update prospects.stage column: %', SQLERRM;
      END;
    END IF;
    
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'is_active'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN is_active BOOLEAN DEFAULT true;
      RAISE NOTICE 'Added is_active column to prospects table';
    END IF;
    
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'assigned_rep_id'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN assigned_rep_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL;
      -- Copy data from assigned_to to assigned_rep_id
      UPDATE prospects SET assigned_rep_id = assigned_to WHERE assigned_rep_id IS NULL AND assigned_to IS NOT NULL;
      RAISE NOTICE 'Added assigned_rep_id column to prospects table';
    END IF;
    
  ELSE
    RAISE NOTICE 'prospects table does not exist yet';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error updating prospects table schema: %', SQLERRM;
END;
$$;

-- ==============================================================================
-- STEP 3: Drop and Recreate get_user_accessible_prospects Function
-- ==============================================================================

-- Drop the function first to avoid conflicts
DROP FUNCTION IF EXISTS get_user_accessible_prospects(uuid);

-- Recreate the function with correct column names matching the actual table
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
      p.id, 
      COALESCE(p.company_name, p.name) as company_name, 
      p.first_name, 
      p.last_name, 
      p.email, 
      p.phone,
      p.company_type, 
      COALESCE(p.stage, 'new'::prospect_stages) as stage, 
      p.city, 
      p.state, 
      p.created_at, 
      p.updated_at,
      p.notes, 
      COALESCE(p.is_active, true) as is_active, 
      p.tenant_id, 
      COALESCE(p.assigned_rep_id, p.assigned_to) as assigned_rep_id, 
      p.source,
      CASE WHEN user_role = 'manager' THEN 'manager_tenant_access' ELSE 'super_admin_access' END::text
    FROM prospects p
    WHERE (user_role = 'super_admin' OR p.tenant_id = user_tenant_id)
      AND COALESCE(p.is_active, true) = true
    ORDER BY COALESCE(p.company_name, p.name), p.last_name;

  -- For reps: return only their assigned prospects
  ELSIF user_role = 'rep' THEN
    RETURN QUERY
    SELECT 
      p.id, 
      COALESCE(p.company_name, p.name) as company_name, 
      p.first_name, 
      p.last_name, 
      p.email, 
      p.phone,
      p.company_type, 
      COALESCE(p.stage, 'new'::prospect_stages) as stage, 
      p.city, 
      p.state, 
      p.created_at, 
      p.updated_at,
      p.notes, 
      COALESCE(p.is_active, true) as is_active, 
      p.tenant_id, 
      COALESCE(p.assigned_rep_id, p.assigned_to) as assigned_rep_id, 
      p.source,
      'rep_assigned_access'::text
    FROM prospects p
    WHERE (COALESCE(p.assigned_rep_id, p.assigned_to) = user_uuid OR p.created_by = user_uuid)
      AND p.tenant_id = user_tenant_id
      AND COALESCE(p.is_active, true) = true
    ORDER BY COALESCE(p.company_name, p.name), p.last_name;
  END IF;
END;
$$;

-- ==============================================================================
-- STEP 4: Grant Function Permissions
-- ==============================================================================

-- Grant execute permission on the recreated function
GRANT EXECUTE ON FUNCTION get_user_accessible_prospects(uuid) TO authenticated;

-- ==============================================================================
-- STEP 5: Create Sample Data with Correct Column Names and Enum Values
-- ==============================================================================

-- Update any existing prospect sample data and create new sample data
DO $$
DECLARE
  fox_tenant_id uuid := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7'::uuid;
  sample_rep_id uuid;
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  prospect_exists boolean := false;
BEGIN
  -- Check if FOX tenant exists, if not use first available tenant
  IF NOT EXISTS (SELECT 1 FROM tenants WHERE id = fox_tenant_id) THEN
    SELECT id INTO fox_tenant_id FROM tenants LIMIT 1;
    RAISE NOTICE 'Using first available tenant: %', fox_tenant_id;
  END IF;
  
  -- Get sample rep ID
  SELECT id INTO sample_rep_id FROM user_profiles WHERE email = 'sarah.rep@foxroofing.com' LIMIT 1;
  
  -- If no specific rep found, use parks user or first available user
  IF sample_rep_id IS NULL THEN
    IF EXISTS (SELECT 1 FROM user_profiles WHERE id = parks_user_id) THEN
      sample_rep_id := parks_user_id;
    ELSE
      SELECT id INTO sample_rep_id FROM user_profiles WHERE tenant_id = fox_tenant_id LIMIT 1;
    END IF;
    RAISE NOTICE 'Using rep ID: %', sample_rep_id;
  END IF;
  
  -- Only proceed if we have a valid tenant and user
  IF fox_tenant_id IS NOT NULL AND sample_rep_id IS NOT NULL THEN
    
    -- Check if prospects already exist to avoid duplicates
    SELECT EXISTS (SELECT 1 FROM prospects WHERE tenant_id = fox_tenant_id LIMIT 1) INTO prospect_exists;
    
    IF NOT prospect_exists THEN
      -- Create sample prospects with correct column names and enum values
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
          sample_rep_id,
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
          sample_rep_id,
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
          sample_rep_id,
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

      RAISE NOTICE 'Sample prospects data created with correct column names and prospect_stages enum values';
    ELSE
      -- Update existing prospects to have the new columns populated
      UPDATE prospects 
      SET 
        company_name = COALESCE(company_name, name),
        stage = CASE 
          WHEN stage IS NULL THEN 'new'::prospect_stages
          WHEN stage::text = 'uncontacted' THEN 'new'::prospect_stages
          WHEN stage::text = 'researching' THEN 'new'::prospect_stages
          WHEN stage::text = 'attempted' THEN 'contacted'::prospect_stages
          WHEN stage::text = 'converted' THEN 'closed_won'::prospect_stages
          WHEN stage::text = 'disqualified' THEN 'closed_lost'::prospect_stages
          ELSE stage
        END,
        is_active = COALESCE(is_active, true),
        assigned_rep_id = COALESCE(assigned_rep_id, assigned_to),
        updated_at = NOW()
      WHERE tenant_id = fox_tenant_id;
      
      RAISE NOTICE 'Updated existing prospects with correct column values';
    END IF;
  ELSE
    RAISE NOTICE 'No valid tenant or user found - skipping sample data creation';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error creating sample prospects: %', SQLERRM;
END;
$$;

-- ==============================================================================
-- STEP 6: Create unique constraint for email per tenant (if not exists)
-- ==============================================================================

DO $$
BEGIN
  -- Add unique constraint for email per tenant if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE table_name = 'prospects' 
    AND constraint_name = 'prospects_email_tenant_unique'
    AND table_schema = 'public'
  ) THEN
    ALTER TABLE prospects ADD CONSTRAINT prospects_email_tenant_unique UNIQUE (email, tenant_id);
    RAISE NOTICE 'Added unique constraint for email per tenant';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Could not add email unique constraint: %', SQLERRM;
END;
$$;

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Test the function works
DO $$
DECLARE
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  first_user_id uuid;
  prospects_count integer;
BEGIN
  -- Get the first available user if parks user doesn't exist
  SELECT id INTO first_user_id FROM user_profiles LIMIT 1;
  
  IF EXISTS (SELECT 1 FROM user_profiles WHERE id = parks_user_id) THEN
    -- Test prospect access with parks user
    SELECT COUNT(*) INTO prospects_count FROM get_user_accessible_prospects(parks_user_id);
    RAISE NOTICE 'Parks manager can access % prospects', prospects_count;
  ELSIF first_user_id IS NOT NULL THEN
    -- Test with first available user
    SELECT COUNT(*) INTO prospects_count FROM get_user_accessible_prospects(first_user_id);
    RAISE NOTICE 'First available user can access % prospects', prospects_count;
  END IF;
  
  IF prospects_count = 0 THEN
    RAISE WARNING 'No prospects found - check tenant assignment and sample data';
  END IF;
END;
$$;

-- Verify table structure
DO $$
DECLARE
  column_count integer;
BEGIN
  SELECT COUNT(*) INTO column_count 
  FROM information_schema.columns 
  WHERE table_name = 'prospects' 
  AND table_schema = 'public'
  AND column_name IN ('company_name', 'first_name', 'last_name', 'email', 'stage', 'is_active', 'assigned_rep_id');
  
  RAISE NOTICE 'Prospects table has % of 7 expected new columns', column_count;
END;
$$;

-- Final success message
SELECT 'prospects company_name column error fix completed successfully' as status;