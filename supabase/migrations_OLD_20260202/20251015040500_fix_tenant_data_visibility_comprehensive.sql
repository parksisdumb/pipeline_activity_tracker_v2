-- Migration: Fix Tenant Data Visibility for Managers
-- Date: 2025-10-15
-- Purpose: Resolve issue where managers can't see tenant-wide accounts, prospects, contacts, and opportunities

-- ==============================================================================
-- STEP 1: Create/Update User Accessible Accounts Function
-- ==============================================================================

CREATE OR REPLACE FUNCTION get_user_accessible_accounts(user_uuid uuid)
RETURNS TABLE(
  id uuid,
  name text,
  company_type company_type,
  stage account_stages,
  city text,
  state text,
  email text,
  phone text,
  created_at timestamptz,
  updated_at timestamptz,
  notes text,
  is_active boolean,
  tenant_id uuid,
  assigned_rep_id uuid,
  primary_rep_name text,
  assigned_reps jsonb,
  properties_count integer,
  contacts_count integer,
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

  -- For managers: return all accounts in their tenant
  IF user_role = 'manager' THEN
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
      a.is_active,
      a.tenant_id,
      a.assigned_rep_id,
      assigned_rep.full_name as primary_rep_name,
      COALESCE(
        jsonb_agg(
          DISTINCT jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep_profile.full_name,
            'is_primary', aa.is_primary
          )
        ) FILTER (WHERE aa.rep_id IS NOT NULL), 
        '[]'::jsonb
      ) as assigned_reps,
      (SELECT COUNT(*)::integer FROM properties p WHERE p.account_id = a.id) as properties_count,
      (SELECT COUNT(*)::integer FROM contacts c WHERE c.account_id = a.id) as contacts_count,
      'manager_tenant_access'::text as access_type
    FROM accounts a
    LEFT JOIN user_profiles assigned_rep ON assigned_rep.id = a.assigned_rep_id
    LEFT JOIN account_assignments aa ON aa.account_id = a.id
    LEFT JOIN user_profiles rep_profile ON rep_profile.id = aa.rep_id
    WHERE a.tenant_id = user_tenant_id
      AND a.is_active = true
    GROUP BY a.id, a.name, a.company_type, a.stage, a.city, a.state, 
             a.email, a.phone, a.created_at, a.updated_at, a.notes, 
             a.is_active, a.tenant_id, a.assigned_rep_id, assigned_rep.full_name
    ORDER BY a.name;

  -- For super_admin: return all accounts
  ELSIF user_role = 'super_admin' THEN
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
      a.is_active,
      a.tenant_id,
      a.assigned_rep_id,
      assigned_rep.full_name as primary_rep_name,
      COALESCE(
        jsonb_agg(
          DISTINCT jsonb_build_object(
            'rep_id', aa.rep_id,
            'rep_name', rep_profile.full_name,
            'is_primary', aa.is_primary
          )
        ) FILTER (WHERE aa.rep_id IS NOT NULL), 
        '[]'::jsonb
      ) as assigned_reps,
      (SELECT COUNT(*)::integer FROM properties p WHERE p.account_id = a.id) as properties_count,
      (SELECT COUNT(*)::integer FROM contacts c WHERE c.account_id = a.id) as contacts_count,
      'super_admin_access'::text as access_type
    FROM accounts a
    LEFT JOIN user_profiles assigned_rep ON assigned_rep.id = a.assigned_rep_id
    LEFT JOIN account_assignments aa ON aa.account_id = a.id
    LEFT JOIN user_profiles rep_profile ON rep_profile.id = aa.rep_id
    WHERE a.is_active = true
    GROUP BY a.id, a.name, a.company_type, a.stage, a.city, a.state, 
             a.email, a.phone, a.created_at, a.updated_at, a.notes, 
             a.is_active, a.tenant_id, a.assigned_rep_id, assigned_rep.full_name
    ORDER BY a.name;

  -- For reps: return only their assigned accounts
  ELSIF user_role = 'rep' THEN
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
      a.is_active,
      a.tenant_id,
      a.assigned_rep_id,
      assigned_rep.full_name as primary_rep_name,
      jsonb_build_array(
        jsonb_build_object(
          'rep_id', user_uuid,
          'rep_name', user_profile.full_name,
          'is_primary', true
        )
      ) as assigned_reps,
      (SELECT COUNT(*)::integer FROM properties p WHERE p.account_id = a.id) as properties_count,
      (SELECT COUNT(*)::integer FROM contacts c WHERE c.account_id = a.id) as contacts_count,
      'rep_assigned_access'::text as access_type
    FROM accounts a
    LEFT JOIN user_profiles assigned_rep ON assigned_rep.id = a.assigned_rep_id
    LEFT JOIN user_profiles user_profile ON user_profile.id = user_uuid
    WHERE (a.assigned_rep_id = user_uuid OR 
           EXISTS(SELECT 1 FROM account_assignments aa WHERE aa.account_id = a.id AND aa.rep_id = user_uuid))
      AND a.tenant_id = user_tenant_id
      AND a.is_active = true
    GROUP BY a.id, a.name, a.company_type, a.stage, a.city, a.state, 
             a.email, a.phone, a.created_at, a.updated_at, a.notes, 
             a.is_active, a.tenant_id, a.assigned_rep_id, assigned_rep.full_name, user_profile.full_name
    ORDER BY a.name;

  -- For other roles: return empty
  ELSE
    RETURN;
  END IF;
END;
$$;

-- ==============================================================================
-- STEP 2: Create Tenant Data Access Functions for Other Entities
-- ==============================================================================

-- Function to get user accessible prospects
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

-- Function to get user accessible contacts
CREATE OR REPLACE FUNCTION get_user_accessible_contacts(user_uuid uuid)
RETURNS TABLE(
  id uuid,
  first_name text,
  last_name text,
  email text,
  phone text,
  mobile_phone text,
  title text,
  stage contact_stages,
  is_primary_contact boolean,
  created_at timestamptz,
  updated_at timestamptz,
  notes text,
  is_active boolean,
  tenant_id uuid,
  account_id uuid,
  account_name text,
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

  -- For managers and super_admin: return all contacts in tenant
  IF user_role IN ('manager', 'super_admin') THEN
    RETURN QUERY
    SELECT 
      c.id, c.first_name, c.last_name, c.email, c.phone, c.mobile_phone,
      c.title, c.stage, c.is_primary_contact, c.created_at, c.updated_at,
      c.notes, c.is_active, c.tenant_id, c.account_id, a.name as account_name,
      CASE WHEN user_role = 'manager' THEN 'manager_tenant_access' ELSE 'super_admin_access' END::text
    FROM contacts c
    LEFT JOIN accounts a ON a.id = c.account_id
    WHERE (user_role = 'super_admin' OR c.tenant_id = user_tenant_id)
      AND c.is_active = true
    ORDER BY c.last_name, c.first_name;

  -- For reps: return contacts for their assigned accounts
  ELSIF user_role = 'rep' THEN
    RETURN QUERY
    SELECT 
      c.id, c.first_name, c.last_name, c.email, c.phone, c.mobile_phone,
      c.title, c.stage, c.is_primary_contact, c.created_at, c.updated_at,
      c.notes, c.is_active, c.tenant_id, c.account_id, a.name as account_name,
      'rep_assigned_access'::text
    FROM contacts c
    LEFT JOIN accounts a ON a.id = c.account_id
    WHERE c.tenant_id = user_tenant_id
      AND c.is_active = true
      AND (c.account_id IN (
        SELECT acc.id FROM accounts acc 
        WHERE acc.assigned_rep_id = user_uuid OR 
              EXISTS(SELECT 1 FROM account_assignments aa WHERE aa.account_id = acc.id AND aa.rep_id = user_uuid)
      ))
    ORDER BY c.last_name, c.first_name;
  END IF;
END;
$$;

-- Function to get user accessible opportunities
CREATE OR REPLACE FUNCTION get_user_accessible_opportunities(user_uuid uuid)
RETURNS TABLE(
  id uuid,
  name text,
  stage opportunity_stages,
  opportunity_type opportunity_type,
  bid_value decimal,
  probability integer,
  expected_close_date date,
  created_at timestamptz,
  updated_at timestamptz,
  notes text,
  is_active boolean,
  tenant_id uuid,
  account_id uuid,
  assigned_rep_id uuid,
  property_id uuid,
  account_name text,
  property_name text,
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

  -- For managers and super_admin: return all opportunities in tenant
  IF user_role IN ('manager', 'super_admin') THEN
    RETURN QUERY
    SELECT 
      o.id, o.name, o.stage, o.opportunity_type, o.bid_value, o.probability,
      o.expected_close_date, o.created_at, o.updated_at, o.notes, o.is_active,
      o.tenant_id, o.account_id, o.assigned_rep_id, o.property_id,
      a.name as account_name, p.name as property_name,
      CASE WHEN user_role = 'manager' THEN 'manager_tenant_access' ELSE 'super_admin_access' END::text
    FROM opportunities o
    LEFT JOIN accounts a ON a.id = o.account_id
    LEFT JOIN properties p ON p.id = o.property_id
    WHERE (user_role = 'super_admin' OR o.tenant_id = user_tenant_id)
      AND o.is_active = true
    ORDER BY o.expected_close_date, o.name;

  -- For reps: return opportunities for their assigned accounts/properties
  ELSIF user_role = 'rep' THEN
    RETURN QUERY
    SELECT 
      o.id, o.name, o.stage, o.opportunity_type, o.bid_value, o.probability,
      o.expected_close_date, o.created_at, o.updated_at, o.notes, o.is_active,
      o.tenant_id, o.account_id, o.assigned_rep_id, o.property_id,
      a.name as account_name, p.name as property_name,
      'rep_assigned_access'::text
    FROM opportunities o
    LEFT JOIN accounts a ON a.id = o.account_id
    LEFT JOIN properties p ON p.id = o.property_id
    WHERE o.tenant_id = user_tenant_id
      AND o.is_active = true
      AND (o.assigned_rep_id = user_uuid OR
           o.account_id IN (
             SELECT acc.id FROM accounts acc 
             WHERE acc.assigned_rep_id = user_uuid OR 
                   EXISTS(SELECT 1 FROM account_assignments aa WHERE aa.account_id = acc.id AND aa.rep_id = user_uuid)
           ))
    ORDER BY o.expected_close_date, o.name;
  END IF;
END;
$$;

-- ==============================================================================
-- STEP 3: Create Sample Data for FOX Roofing Tenant
-- ==============================================================================

-- Insert sample data for FOX Roofing tenant (Parks manager's tenant)
DO $$
DECLARE
  fox_tenant_id uuid := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7'::uuid;
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  sample_rep_id uuid;
  sample_account_id uuid;
  sample_property_id uuid;
  sample_contact_id uuid;
BEGIN
  -- Check if FOX Roofing tenant exists
  IF NOT EXISTS (SELECT 1 FROM tenants WHERE id = fox_tenant_id) THEN
    INSERT INTO tenants (id, name, domain, is_active, created_at, updated_at)
    VALUES (fox_tenant_id, 'FOX Roofing', 'foxroofing.com', true, NOW(), NOW());
  END IF;

  -- Create a sample rep for the tenant if needed
  INSERT INTO user_profiles (
    id, email, full_name, role, tenant_id, is_active, created_at, updated_at
  )
  VALUES (
    gen_random_uuid(), 
    'sarah.rep@foxroofing.com', 
    'Sarah Thompson', 
    'rep', 
    fox_tenant_id, 
    true, 
    NOW(), 
    NOW()
  )
  ON CONFLICT (email) DO UPDATE SET
    full_name = 'Sarah Thompson',
    tenant_id = fox_tenant_id,
    is_active = true
  RETURNING id INTO sample_rep_id;

  -- Get the rep ID if it already existed
  IF sample_rep_id IS NULL THEN
    SELECT id INTO sample_rep_id FROM user_profiles WHERE email = 'sarah.rep@foxroofing.com';
  END IF;

  -- Create sample accounts
  INSERT INTO accounts (
    id, name, company_type, stage, city, state, email, phone, 
    tenant_id, assigned_rep_id, is_active, created_at, updated_at, notes
  )
  VALUES 
    (
      gen_random_uuid(),
      'ABC Manufacturing Inc',
      'commercial'::company_type,
      'qualified'::account_stages,
      'Dallas',
      'TX',
      'info@abcmanufacturing.com',
      '(214) 555-0101',
      fox_tenant_id,
      sample_rep_id,
      true,
      NOW() - interval '30 days',
      NOW() - interval '2 days',
      'Large manufacturing facility, potential for extensive roofing project'
    ),
    (
      gen_random_uuid(),
      'Metro Office Complex',
      'commercial'::company_type,
      'proposal_sent'::account_stages,
      'Fort Worth',
      'TX',
      'facilities@metrooffice.com',
      '(817) 555-0102',
      fox_tenant_id,
      parks_user_id,
      true,
      NOW() - interval '20 days',
      NOW() - interval '1 day',
      'Multi-building office complex, quote requested for Building A'
    ),
    (
      gen_random_uuid(),
      'Johnson Residence',
      'residential'::company_type,
      'appointment_set'::account_stages,
      'Arlington',
      'TX',
      'mike.johnson@email.com',
      '(469) 555-0103',
      fox_tenant_id,
      sample_rep_id,
      true,
      NOW() - interval '10 days',
      NOW(),
      'Residential home, storm damage repair needed'
    ),
    (
      gen_random_uuid(),
      'TechStart Headquarters',
      'commercial'::company_type,
      'initial_contact'::account_stages,
      'Plano',
      'TX',
      'admin@techstart.com',
      '(972) 555-0104',
      fox_tenant_id,
      parks_user_id,
      true,
      NOW() - interval '5 days',
      NOW() - interval '3 hours',
      'Technology company, interested in sustainable roofing solutions'
    ),
    (
      gen_random_uuid(),
      'Retail Plaza Partners',
      'commercial'::company_type,
      'follow_up'::account_stages,
      'Irving',
      'TX',
      'management@retailplaza.com',
      '(214) 555-0105',
      fox_tenant_id,
      sample_rep_id,
      true,
      NOW() - interval '15 days',
      NOW() - interval '1 week',
      'Shopping center with multiple buildings, initial assessment completed'
    )
  ON CONFLICT (name, tenant_id) DO NOTHING
  RETURNING id INTO sample_account_id;

  -- Create sample prospects
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
      sample_rep_id,
      'cold_call',
      true,
      NOW() - interval '1 week',
      NOW() - interval '2 days',
      'Manages multiple warehouse buildings, budget approved for Q1'
    )
  ON CONFLICT (email, tenant_id) DO NOTHING;

  -- Get a sample account ID for creating related data
  SELECT id INTO sample_account_id FROM accounts WHERE tenant_id = fox_tenant_id AND name = 'ABC Manufacturing Inc' LIMIT 1;
  
  IF sample_account_id IS NOT NULL THEN
    -- Create sample properties
    INSERT INTO properties (
      id, name, building_type, address, city, state, zip_code, 
      square_footage, year_built, stage, account_id, tenant_id, 
      is_active, created_at, updated_at, notes
    )
    VALUES (
      gen_random_uuid(),
      'Main Manufacturing Building',
      'industrial',
      '1234 Industrial Blvd',
      'Dallas',
      'TX',
      '75201',
      50000,
      2010,
      'assessment_needed'::property_stages,
      sample_account_id,
      fox_tenant_id,
      true,
      NOW() - interval '15 days',
      NOW() - interval '1 day',
      'Primary manufacturing facility with aging roof system'
    )
    ON CONFLICT (name, account_id) DO NOTHING
    RETURNING id INTO sample_property_id;

    -- Create sample contacts
    INSERT INTO contacts (
      id, first_name, last_name, title, email, phone, mobile_phone,
      stage, is_primary_contact, account_id, tenant_id, is_active,
      created_at, updated_at, notes
    )
    VALUES (
      gen_random_uuid(),
      'David',
      'Anderson',
      'Facilities Manager',
      'd.anderson@abcmanufacturing.com',
      '(214) 555-0101',
      '(214) 555-0110',
      'engaged'::contact_stages,
      true,
      sample_account_id,
      fox_tenant_id,
      true,
      NOW() - interval '25 days',
      NOW() - interval '2 days',
      'Main point of contact for facility maintenance decisions'
    )
    ON CONFLICT (email, tenant_id) DO NOTHING
    RETURNING id INTO sample_contact_id;

    -- Get property ID if it already existed
    IF sample_property_id IS NULL THEN
      SELECT id INTO sample_property_id FROM properties WHERE account_id = sample_account_id LIMIT 1;
    END IF;

    -- Create sample opportunities if we have a property
    IF sample_property_id IS NOT NULL THEN
      INSERT INTO opportunities (
        id, name, stage, opportunity_type, bid_value, probability,
        expected_close_date, account_id, property_id, assigned_rep_id,
        tenant_id, is_active, created_at, updated_at, notes
      )
      VALUES (
        gen_random_uuid(),
        'Manufacturing Facility Roof Replacement',
        'proposal_sent'::opportunity_stages,
        'replacement'::opportunity_type,
        125000.00,
        75,
        CURRENT_DATE + interval '45 days',
        sample_account_id,
        sample_property_id,
        sample_rep_id,
        fox_tenant_id,
        true,
        NOW() - interval '10 days',
        NOW() - interval '3 days',
        'Complete roof replacement with 20-year warranty'
      )
      ON CONFLICT (name, account_id) DO NOTHING;
    END IF;

    -- Create sample activities
    INSERT INTO activities (
      id, activity_type, activity_date, subject, outcome, notes,
      duration_minutes, account_id, contact_id, tenant_id, created_by_id,
      is_active, created_at, updated_at
    )
    VALUES 
      (
        gen_random_uuid(),
        'phone_call'::activity_type,
        NOW() - interval '3 days',
        'Initial consultation call',
        'positive'::activity_outcome,
        'Discussed facility needs and scheduled site visit',
        45,
        sample_account_id,
        sample_contact_id,
        fox_tenant_id,
        sample_rep_id,
        true,
        NOW() - interval '3 days',
        NOW() - interval '3 days'
      ),
      (
        gen_random_uuid(),
        'site_visit'::activity_type,
        NOW() - interval '1 day',
        'Site assessment and measurements',
        'positive'::activity_outcome,
        'Completed roof inspection, took measurements, identified repair areas',
        120,
        sample_account_id,
        sample_contact_id,
        fox_tenant_id,
        sample_rep_id,
        true,
        NOW() - interval '1 day',
        NOW() - interval '1 day'
      )
    ON CONFLICT DO NOTHING;

  END IF;

  RAISE NOTICE 'Sample data creation completed for FOX Roofing tenant';
END;
$$;

-- ==============================================================================
-- STEP 4: Update RLS Policies for Tenant Data Access
-- ==============================================================================

-- Drop and recreate accounts RLS policies
DROP POLICY IF EXISTS "accounts_select_policy" ON accounts;
CREATE POLICY "accounts_select_policy" ON accounts FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see accounts in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- Drop and recreate prospects RLS policies
DROP POLICY IF EXISTS "prospects_select_policy" ON prospects;
CREATE POLICY "prospects_select_policy" ON prospects FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see prospects in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- Drop and recreate contacts RLS policies
DROP POLICY IF EXISTS "contacts_select_policy" ON contacts;
CREATE POLICY "contacts_select_policy" ON contacts FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see contacts in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- Drop and recreate opportunities RLS policies
DROP POLICY IF EXISTS "opportunities_select_policy" ON opportunities;
CREATE POLICY "opportunities_select_policy" ON opportunities FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see opportunities in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- Drop and recreate properties RLS policies
DROP POLICY IF EXISTS "properties_select_policy" ON properties;
CREATE POLICY "properties_select_policy" ON properties FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see properties in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- Drop and recreate activities RLS policies
DROP POLICY IF EXISTS "activities_select_policy" ON activities;
CREATE POLICY "activities_select_policy" ON activities FOR SELECT
  USING (
    -- Super admin can see all
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'super_admin' AND up.is_active = true
    )
    OR
    -- Users can see activities in their tenant
    (tenant_id IN (
      SELECT up.tenant_id FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.is_active = true
    ))
  );

-- ==============================================================================
-- STEP 5: Grant Function Permissions
-- ==============================================================================

-- Grant execute permissions on the new functions
GRANT EXECUTE ON FUNCTION get_user_accessible_accounts(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_prospects(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_contacts(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_accessible_opportunities(uuid) TO authenticated;

-- ==============================================================================
-- STEP 6: Create Performance Indexes
-- ==============================================================================

-- Create indexes for better performance on tenant-based queries
CREATE INDEX IF NOT EXISTS idx_accounts_tenant_id_active ON accounts(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_prospects_tenant_id_active ON prospects(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_contacts_tenant_id_active ON contacts(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_opportunities_tenant_id_active ON opportunities(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_properties_tenant_id_active ON properties(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_activities_tenant_id_active ON activities(tenant_id, is_active);

-- Create indexes for user-based queries
CREATE INDEX IF NOT EXISTS idx_accounts_assigned_rep_tenant ON accounts(assigned_rep_id, tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_prospects_assigned_rep_tenant ON prospects(assigned_rep_id, tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_opportunities_assigned_rep_tenant ON opportunities(assigned_rep_id, tenant_id, is_active);

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Test the functions work for Parks manager
DO $$
DECLARE
  parks_user_id uuid := '7a068df9-ef0f-474c-b868-0d283ff71cd1'::uuid;
  accounts_count integer;
  prospects_count integer;
  contacts_count integer;
  opportunities_count integer;
BEGIN
  -- Test account access
  SELECT COUNT(*) INTO accounts_count FROM get_user_accessible_accounts(parks_user_id);
  RAISE NOTICE 'Parks manager can access % accounts', accounts_count;
  
  -- Test prospect access
  SELECT COUNT(*) INTO prospects_count FROM get_user_accessible_prospects(parks_user_id);
  RAISE NOTICE 'Parks manager can access % prospects', prospects_count;
  
  -- Test contact access
  SELECT COUNT(*) INTO contacts_count FROM get_user_accessible_contacts(parks_user_id);
  RAISE NOTICE 'Parks manager can access % contacts', contacts_count;
  
  -- Test opportunity access
  SELECT COUNT(*) INTO opportunities_count FROM get_user_accessible_opportunities(parks_user_id);
  RAISE NOTICE 'Parks manager can access % opportunities', opportunities_count;
  
  IF accounts_count = 0 THEN
    RAISE WARNING 'No accounts found for Parks manager - check tenant assignment and sample data';
  END IF;
END;
$$;

-- Final success message
SELECT 'Tenant data visibility migration completed successfully' as status;