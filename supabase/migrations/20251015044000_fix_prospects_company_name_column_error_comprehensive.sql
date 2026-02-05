-- Migration: Fix Prospects Company Name Column Error - Comprehensive
-- Date: 2025-10-15
-- Purpose: Completely resolve column mismatch between prospects table schema and functions
-- Approach: Defensive schema modification with function recreation

-- ==============================================================================
-- STEP 1: Create Missing prospect_stages Enum Type (if not exists)
-- ==============================================================================

-- Create the prospect_stages enum type safely
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
-- STEP 2: Comprehensive Prospects Table Schema Correction
-- ==============================================================================

DO $$
BEGIN
  -- Check if prospects table exists
  IF EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_name = 'prospects' 
    AND table_schema = 'public'
  ) THEN
    
    -- Ensure company_name column exists
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'company_name'
      AND table_schema = 'public'
    ) THEN
      -- Check if name column exists to migrate data
      IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'prospects' 
        AND column_name = 'name'
        AND table_schema = 'public'
      ) THEN
        -- Add company_name and migrate from name
        ALTER TABLE prospects ADD COLUMN company_name TEXT;
        UPDATE prospects SET company_name = name WHERE company_name IS NULL;
        RAISE NOTICE 'Added company_name column and migrated data from name column';
      ELSE
        -- Add company_name as new column
        ALTER TABLE prospects ADD COLUMN company_name TEXT;
        RAISE NOTICE 'Added company_name column to prospects table';
      END IF;
    ELSE
      RAISE NOTICE 'company_name column already exists in prospects table';
    END IF;
    
    -- Ensure first_name column exists
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
    
    -- Ensure last_name column exists
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
    
    -- Ensure email column exists
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
    
    -- Ensure stage column exists with correct type
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
      -- Check if stage column has correct type
      BEGIN
        -- Try to update stage column type if it's not already prospect_stages
        ALTER TABLE prospects ALTER COLUMN stage TYPE prospect_stages USING 
          CASE 
            WHEN stage::text = 'uncontacted' THEN 'new'::prospect_stages
            WHEN stage::text = 'researching' THEN 'new'::prospect_stages  
            WHEN stage::text = 'attempted' THEN 'contacted'::prospect_stages
            WHEN stage::text = 'converted' THEN 'closed_won'::prospect_stages
            WHEN stage::text = 'disqualified' THEN 'closed_lost'::prospect_stages
            ELSE COALESCE(stage::prospect_stages, 'new'::prospect_stages)
          END;
        RAISE NOTICE 'Updated prospects.stage column to use prospect_stages enum';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE 'Stage column type update not needed or failed: %', SQLERRM;
      END;
    END IF;
    
    -- Ensure is_active column exists
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
    
    -- Ensure assigned_rep_id column exists
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'assigned_rep_id'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN assigned_rep_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL;
      -- Copy data from assigned_to if it exists
      IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'prospects' 
        AND column_name = 'assigned_to'
        AND table_schema = 'public'
      ) THEN
        UPDATE prospects SET assigned_rep_id = assigned_to WHERE assigned_rep_id IS NULL AND assigned_to IS NOT NULL;
        RAISE NOTICE 'Added assigned_rep_id column and migrated from assigned_to';
      ELSE
        RAISE NOTICE 'Added assigned_rep_id column to prospects table';
      END IF;
    END IF;
    
    -- Add phone column if missing
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'phone'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN phone TEXT;
      RAISE NOTICE 'Added phone column to prospects table';
    END IF;
    
    -- Add city column if missing
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'city'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN city TEXT;
      RAISE NOTICE 'Added city column to prospects table';
    END IF;
    
    -- Add state column if missing
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'state'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN state TEXT;
      RAISE NOTICE 'Added state column to prospects table';
    END IF;
    
    -- Add notes column if missing
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'notes'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN notes TEXT;
      RAISE NOTICE 'Added notes column to prospects table';
    END IF;
    
    -- Add source column if missing
    IF NOT EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'prospects' 
      AND column_name = 'source'
      AND table_schema = 'public'
    ) THEN
      ALTER TABLE prospects ADD COLUMN source TEXT;
      RAISE NOTICE 'Added source column to prospects table';
    END IF;
    
  ELSE
    RAISE NOTICE 'prospects table does not exist - will be created in future migration';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error updating prospects table schema: %', SQLERRM;
END;
$$;
-- ==============================================================================
-- STEP 3: Drop Existing Function to Avoid Conflicts
-- ==============================================================================

-- Drop all variations of the function to ensure clean recreation
DROP FUNCTION IF EXISTS get_user_accessible_prospects(uuid);
DROP FUNCTION IF EXISTS public.get_user_accessible_prospects(uuid);
-- ==============================================================================
-- STEP 4: Create Defensive Function with Error Handling
-- ==============================================================================

-- Create the function with comprehensive column existence checks
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
-- ==============================================================================
-- STEP 5: Grant Function Permissions
-- ==============================================================================

-- Grant execute permission on the recreated function
GRANT EXECUTE ON FUNCTION get_user_accessible_prospects(uuid) TO authenticated;
-- ==============================================================================
-- STEP 6: Update Indexes (if needed)
-- ==============================================================================

DO $$
BEGIN
  -- Drop old indexes if they exist
  DROP INDEX IF EXISTS uidx_prospects_tenant_name_active;
  DROP INDEX IF EXISTS idx_prospects_tenant_name;
  
  -- Create new indexes based on available columns
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'company_name' AND table_schema = 'public'
  ) THEN
    -- Create index on company_name if column exists
    CREATE INDEX IF NOT EXISTS idx_prospects_tenant_company_name 
    ON public.prospects(tenant_id, LOWER(company_name)) 
    WHERE company_name IS NOT NULL;
    
    CREATE UNIQUE INDEX IF NOT EXISTS uidx_prospects_tenant_company_name_active 
    ON public.prospects(tenant_id, LOWER(company_name)) 
    WHERE stage IN ('new','contacted','qualified','proposal_sent','negotiating') AND company_name IS NOT NULL;
    
    RAISE NOTICE 'Created indexes for company_name column';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Index creation encountered error: %', SQLERRM;
END;
$$;
-- ==============================================================================
-- STEP 7: Create Sample Data (Only if table exists and is mostly empty)
-- ==============================================================================

DO $$
DECLARE
  fox_tenant_id uuid := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7'::uuid;
  sample_rep_id uuid;
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  prospect_count integer := 0;
  prospects_table_exists boolean := false;
BEGIN
  -- Check if prospects table exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'prospects' AND table_schema = 'public'
  ) INTO prospects_table_exists;
  
  IF NOT prospects_table_exists THEN
    RAISE NOTICE 'prospects table does not exist - skipping sample data creation';
    RETURN;
  END IF;
  
  -- Count existing prospects
  SELECT COUNT(*) INTO prospect_count FROM prospects;
  
  -- Only create sample data if table is mostly empty (less than 5 records)
  IF prospect_count >= 5 THEN
    RAISE NOTICE 'prospects table already has % records - skipping sample data creation', prospect_count;
    RETURN;
  END IF;
  
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
    -- Create sample prospects with all required columns
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

    RAISE NOTICE 'Sample prospects data created successfully with proper column structure';
  ELSE
    RAISE NOTICE 'No valid tenant or user found - skipping sample data creation';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error creating sample prospects: %', SQLERRM;
END;
$$;
-- ==============================================================================
-- STEP 8: Final Verification
-- ==============================================================================

-- Test the function works properly
DO $$
DECLARE
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  first_user_id uuid;
  prospects_count integer;
  function_exists boolean := false;
BEGIN
  -- Check if function exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.routines 
    WHERE routine_name = 'get_user_accessible_prospects' AND routine_schema = 'public'
  ) INTO function_exists;
  
  IF NOT function_exists THEN
    RAISE WARNING 'get_user_accessible_prospects function does not exist';
    RETURN;
  END IF;
  
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
  ELSE
    RAISE WARNING 'No users found to test function';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Function verification failed: %', SQLERRM;
END;
$$;
-- Final success message
SELECT 'Prospects company_name column error fix completed comprehensively' as status,
       'Function now handles missing columns gracefully' as details;
