-- Location: supabase/migrations/20251227040000_populate_comprehensive_sample_data.sql
-- Schema Analysis: Existing comprehensive CRM system with all core tables present
-- Integration Type: Sample data population for existing schema
-- Dependencies: accounts, prospects, contacts, opportunities, properties, activities, user_profiles

-- Comprehensive sample data population for CRM system
-- This migration adds realistic test data to populate empty tables

DO $$
DECLARE
    -- Existing user IDs to reference
    parks_user_id UUID := '7a068df9-ef0f-474c-b868-0d283ff71cd1'; -- Parks Flowers (manager)
    
    -- Generated UUIDs for new entities
    account1_id UUID := gen_random_uuid();
    account2_id UUID := gen_random_uuid();
    account3_id UUID := gen_random_uuid();
    account4_id UUID := gen_random_uuid();
    account5_id UUID := gen_random_uuid();
    
    property1_id UUID := gen_random_uuid();
    property2_id UUID := gen_random_uuid();
    property3_id UUID := gen_random_uuid();
    property4_id UUID := gen_random_uuid();
    property5_id UUID := gen_random_uuid();
    property6_id UUID := gen_random_uuid();
    
    contact1_id UUID := gen_random_uuid();
    contact2_id UUID := gen_random_uuid();
    contact3_id UUID := gen_random_uuid();
    contact4_id UUID := gen_random_uuid();
    contact5_id UUID := gen_random_uuid();
    contact6_id UUID := gen_random_uuid();
    
    prospect1_id UUID := gen_random_uuid();
    prospect2_id UUID := gen_random_uuid();
    prospect3_id UUID := gen_random_uuid();
    prospect4_id UUID := gen_random_uuid();
    prospect5_id UUID := gen_random_uuid();
    
    opportunity1_id UUID := gen_random_uuid();
    opportunity2_id UUID := gen_random_uuid();
    opportunity3_id UUID := gen_random_uuid();
    opportunity4_id UUID := gen_random_uuid();
    
    tenant_id UUID := '89d54870-46cc-4ffb-b5ad-e79c8c0814c7'; -- FOX Roofing tenant
    
BEGIN
    -- Check if data already exists to prevent duplicates
    IF EXISTS (SELECT 1 FROM public.accounts LIMIT 1) THEN
        RAISE NOTICE 'Sample data already exists, skipping population...';
        RETURN;
    END IF;

    RAISE NOTICE 'Populating comprehensive sample data for CRM system...';

    -- 1. ACCOUNTS: Create diverse commercial accounts
    INSERT INTO public.accounts (
        id, tenant_id, name, company_type, email, phone, website, 
        address, city, state, zip_code, stage, assigned_to, created_by, 
        is_active, created_at, updated_at
    ) VALUES
        (account1_id, tenant_id, 'Metro Shopping Center', 'retail'::public.company_type, 
         'facilities@metroshoppingcenter.com', '(555) 234-5678', 'https://metroshoppingcenter.com',
         '1234 Commerce Drive', 'Atlanta', 'GA', '30309', 'qualified'::public.account_stages, 
         parks_user_id, parks_user_id, true, NOW() - INTERVAL '15 days', NOW() - INTERVAL '10 days'),
         
        (account2_id, tenant_id, 'Industrial Park LLC', 'manufacturing'::public.company_type, 
         'maintenance@industrialpark.com', '(555) 345-6789', 'https://industrialpark.com',
         '567 Industrial Blvd', 'Birmingham', 'AL', '35203', 'proposal_sent'::public.account_stages, 
         parks_user_id, parks_user_id, true, NOW() - INTERVAL '22 days', NOW() - INTERVAL '5 days'),
         
        (account3_id, tenant_id, 'Sunrise Medical Center', 'healthcare'::public.company_type, 
         'facilities@sunrisemedical.org', '(555) 456-7890', 'https://sunrisemedical.org',
         '890 Health Plaza', 'Nashville', 'TN', '37203', 'contracted'::public.account_stages, 
         parks_user_id, parks_user_id, true, NOW() - INTERVAL '45 days', NOW() - INTERVAL '2 days'),
         
        (account4_id, tenant_id, 'Tech Campus Solutions', 'technology'::public.company_type, 
         'facilities@techcampus.com', '(555) 567-8901', 'https://techcampus.com',
         '1122 Innovation Way', 'Charlotte', 'NC', '28202', 'researching'::public.account_stages, 
         parks_user_id, parks_user_id, true, NOW() - INTERVAL '8 days', NOW() - INTERVAL '1 day'),
         
        (account5_id, tenant_id, 'Heritage Office Complex', 'office'::public.company_type, 
         'management@heritageoffice.com', '(555) 678-9012', 'https://heritageoffice.com',
         '2244 Business Parkway', 'Jacksonville', 'FL', '32216', 'initial_contact'::public.account_stages, 
         parks_user_id, parks_user_id, true, NOW() - INTERVAL '3 days', NOW());

    -- 2. PROPERTIES: Create properties for each account
    INSERT INTO public.properties (
        id, tenant_id, account_id, name, building_type, address, city, state, zip_code,
        square_footage, year_built, roof_type, last_inspection, assigned_to, created_by,
        is_active, created_at, updated_at
    ) VALUES
        (property1_id, tenant_id, account1_id, 'Main Shopping Center', 'retail'::public.building_type,
         '1234 Commerce Drive', 'Atlanta', 'GA', '30309', 85000, 1998, 'Modified Bitumen', 
         '2023-08-15', parks_user_id, parks_user_id, true, NOW() - INTERVAL '15 days', NOW() - INTERVAL '10 days'),
         
        (property2_id, tenant_id, account1_id, 'Parking Garage Structure', 'parking'::public.building_type,
         '1240 Commerce Drive', 'Atlanta', 'GA', '30309', 45000, 2001, 'Concrete', 
         '2023-09-22', parks_user_id, parks_user_id, true, NOW() - INTERVAL '12 days', NOW() - INTERVAL '8 days'),
         
        (property3_id, tenant_id, account2_id, 'Manufacturing Facility A', 'manufacturing'::public.building_type,
         '567 Industrial Blvd', 'Birmingham', 'AL', '35203', 120000, 1985, 'TPO', 
         '2023-07-10', parks_user_id, parks_user_id, true, NOW() - INTERVAL '22 days', NOW() - INTERVAL '18 days'),
         
        (property4_id, tenant_id, account3_id, 'Medical Center Main Building', 'healthcare'::public.building_type,
         '890 Health Plaza', 'Nashville', 'TN', '37203', 95000, 1992, 'EPDM', 
         '2023-06-05', parks_user_id, parks_user_id, true, NOW() - INTERVAL '45 days', NOW() - INTERVAL '40 days'),
         
        (property5_id, tenant_id, account4_id, 'Tech Campus Building 1', 'office'::public.building_type,
         '1122 Innovation Way', 'Charlotte', 'NC', '28202', 75000, 2015, 'TPO', 
         '2024-01-12', parks_user_id, parks_user_id, true, NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days'),
         
        (property6_id, tenant_id, account5_id, 'Heritage Office Tower', 'office'::public.building_type,
         '2244 Business Parkway', 'Jacksonville', 'FL', '32216', 110000, 2008, 'Modified Bitumen', 
         NULL, parks_user_id, parks_user_id, true, NOW() - INTERVAL '3 days', NOW());

    -- 3. CONTACTS: Create primary and secondary contacts for accounts
    INSERT INTO public.contacts (
        id, tenant_id, account_id, first_name, last_name, title, email, phone, mobile,
        is_primary_contact, stage, assigned_to, created_by, is_active, created_at, updated_at
    ) VALUES
        (contact1_id, tenant_id, account1_id, 'Sarah', 'Mitchell', 'Facilities Director', 
         'sarah.mitchell@metroshoppingcenter.com', '(555) 234-5678', '(555) 234-5679', 
         true, 'qualified'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '15 days', NOW() - INTERVAL '12 days'),
         
        (contact2_id, tenant_id, account2_id, 'Robert', 'Chen', 'Maintenance Manager', 
         'robert.chen@industrialpark.com', '(555) 345-6789', '(555) 345-6790', 
         true, 'proposal_requested'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '22 days', NOW() - INTERVAL '20 days'),
         
        (contact3_id, tenant_id, account3_id, 'Dr. Jennifer', 'Williams', 'Facilities Administrator', 
         'j.williams@sunrisemedical.org', '(555) 456-7890', '(555) 456-7891', 
         true, 'contracted'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '45 days', NOW() - INTERVAL '42 days'),
         
        (contact4_id, tenant_id, account4_id, 'Michael', 'Thompson', 'Operations Director', 
         'michael.thompson@techcampus.com', '(555) 567-8901', '(555) 567-8902', 
         true, 'initial_contact'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '8 days', NOW() - INTERVAL '6 days'),
         
        (contact5_id, tenant_id, account5_id, 'Lisa', 'Rodriguez', 'Property Manager', 
         'lisa.rodriguez@heritageoffice.com', '(555) 678-9012', '(555) 678-9013', 
         true, 'initial_contact'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'),
         
        (contact6_id, tenant_id, account2_id, 'Amanda', 'Foster', 'Assistant Facilities Manager', 
         'amanda.foster@industrialpark.com', '(555) 345-6795', '(555) 345-6796', 
         false, 'qualified'::public.contact_stages, parks_user_id, parks_user_id, true, 
         NOW() - INTERVAL '18 days', NOW() - INTERVAL '15 days');

    -- 4. PROSPECTS: Create unqualified potential customers
    INSERT INTO public.prospects (
        id, tenant_id, name, domain, email, phone, website, address, city, state, zip_code,
        industry, company_size, source, status, icp_fit_score, assigned_to, created_by,
        notes, created_at, updated_at, last_activity_at
    ) VALUES
        (prospect1_id, tenant_id, 'Riverside Distribution Center', 'riverside-dist.com', 
         'info@riverside-dist.com', '(555) 789-0123', 'https://riverside-dist.com',
         '3456 Warehouse Row', 'Memphis', 'TN', '38103', 'logistics', '50-200', 'website',
         'researching'::public.prospect_status, 85, parks_user_id, parks_user_id,
         'Large distribution center needing roof maintenance program', 
         NOW() - INTERVAL '12 days', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
         
        (prospect2_id, tenant_id, 'Coastal Manufacturing Group', 'coastal-mfg.com', 
         'facilities@coastal-mfg.com', '(555) 890-1234', 'https://coastal-mfg.com',
         '7890 Industrial Coast Blvd', 'Mobile', 'AL', '36602', 'manufacturing', '200-500', 'referral',
         'contacted'::public.prospect_status, 92, parks_user_id, parks_user_id,
         'Multiple facilities requiring comprehensive roofing services', 
         NOW() - INTERVAL '18 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
         
        (prospect3_id, tenant_id, 'University Research Campus', 'research-campus.edu', 
         'facilities@research-campus.edu', '(555) 901-2345', 'https://research-campus.edu',
         '1357 Academic Drive', 'Gainesville', 'FL', '32611', 'education', '500+', 'cold_call',
         'attempted'::public.prospect_status, 78, parks_user_id, parks_user_id,
         'State university with aging roof infrastructure', 
         NOW() - INTERVAL '25 days', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
         
        (prospect4_id, tenant_id, 'Retail Plaza Management', 'retailplaza-mgmt.com', 
         'ops@retailplaza-mgmt.com', '(555) 012-3456', 'https://retailplaza-mgmt.com',
         '2468 Shopping Center Way', 'Savannah', 'GA', '31405', 'retail', '200-500', 'linkedin',
         'uncontacted'::public.prospect_status, 88, parks_user_id, parks_user_id,
         'Manages multiple retail properties in Southeast region', 
         NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NULL),
         
        (prospect5_id, tenant_id, 'Central Hospital System', 'central-hospital.org', 
         'maintenance@central-hospital.org', '(555) 123-4567', 'https://central-hospital.org',
         '9876 Medical Center Drive', 'Little Rock', 'AR', '72201', 'healthcare', '500+', 'trade_show',
         'researching'::public.prospect_status, 94, parks_user_id, parks_user_id,
         'Hospital system expanding facilities, high priority prospect', 
         NOW() - INTERVAL '9 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    -- 5. OPPORTUNITIES: Create sales opportunities linked to accounts and properties
    INSERT INTO public.opportunities (
        id, tenant_id, account_id, property_id, name, opportunity_type, stage, 
        bid_value, probability, expected_close_date, assigned_to, created_by,
        description, notes, created_at, updated_at
    ) VALUES
        (opportunity1_id, tenant_id, account1_id, property1_id, 'Metro Shopping Center - Annual Maintenance Contract', 
         'maintenance'::public.opportunity_types, 'proposal_sent'::public.opportunity_stages, 
         45000, 75, DATE '2024-02-15', parks_user_id, parks_user_id,
         'Comprehensive annual maintenance program for 85,000 sq ft retail center',
         'Client very interested, waiting for budget approval', 
         NOW() - INTERVAL '15 days', NOW() - INTERVAL '8 days'),
         
        (opportunity2_id, tenant_id, account2_id, property3_id, 'Industrial Park - TPO Roof Replacement', 
         're_roof'::public.opportunity_types, 'negotiation'::public.opportunity_stages, 
         180000, 85, DATE '2024-01-30', parks_user_id, parks_user_id,
         'Complete TPO roof replacement for manufacturing facility',
         'In final negotiations, very promising opportunity', 
         NOW() - INTERVAL '22 days', NOW() - INTERVAL '4 days'),
         
        (opportunity3_id, tenant_id, account3_id, property4_id, 'Sunrise Medical - Emergency Repair Services', 
         'repair'::public.opportunity_types, 'won'::public.opportunity_stages, 
         28500, 100, DATE '2023-12-20', parks_user_id, parks_user_id,
         'Emergency leak repairs and preventive maintenance',
         'Contract awarded and work completed successfully', 
         NOW() - INTERVAL '45 days', NOW() - INTERVAL '30 days'),
         
        (opportunity4_id, tenant_id, account4_id, property5_id, 'Tech Campus - New Construction Roofing', 
         'new_construction'::public.opportunity_types, 'qualified'::public.opportunity_stages, 
         125000, 60, DATE '2024-03-01', parks_user_id, parks_user_id,
         'Roofing for new tech campus expansion building',
         'Still in early planning phase, good potential', 
         NOW() - INTERVAL '8 days', NOW() - INTERVAL '5 days');

    -- 6. ACTIVITIES: Create recent activities for prospects, contacts, and opportunities
    INSERT INTO public.activities (
        id, tenant_id, contact_id, prospect_id, opportunity_id, activity_type, 
        description, outcome, activity_date, duration_minutes, assigned_to, created_by,
        created_at, updated_at
    ) VALUES
        -- Contact activities
        (gen_random_uuid(), tenant_id, contact1_id, NULL, opportunity1_id, 'Phone Call',
         'Discussed annual maintenance contract details and pricing',
         'Positive - client requested formal proposal', NOW() - INTERVAL '8 days', 45,
         parks_user_id, parks_user_id, NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
         
        (gen_random_uuid(), tenant_id, contact2_id, NULL, opportunity2_id, 'Site Visit',
         'Conducted comprehensive roof inspection for replacement project',
         'Identified additional areas needing attention', NOW() - INTERVAL '4 days', 120,
         parks_user_id, parks_user_id, NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
         
        (gen_random_uuid(), tenant_id, contact3_id, NULL, opportunity3_id, 'Email',
         'Sent final completion report and warranty documentation',
         'Client satisfied with work quality', NOW() - INTERVAL '2 days', 15,
         parks_user_id, parks_user_id, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
         
        -- Prospect activities
        (gen_random_uuid(), tenant_id, NULL, prospect2_id, NULL, 'Phone Call',
         'Initial discovery call to understand facility requirements',
         'Qualified - scheduled site visit next week', NOW() - INTERVAL '3 days', 30,
         parks_user_id, parks_user_id, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
         
        (gen_random_uuid(), tenant_id, NULL, prospect5_id, NULL, 'Email',
         'Sent company capabilities brochure and case studies',
         'Prospect expressed interest in learning more', NOW() - INTERVAL '2 days', 10,
         parks_user_id, parks_user_id, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
         
        -- Follow-up activities
        (gen_random_uuid(), tenant_id, contact4_id, NULL, opportunity4_id, 'Meeting',
         'Presented preliminary proposal for tech campus roofing',
         'Need to revise specs based on client feedback', NOW() - INTERVAL '5 days', 90,
         parks_user_id, parks_user_id, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');

    RAISE NOTICE 'Successfully populated comprehensive sample data:';
    RAISE NOTICE '- 5 Accounts with various company types and stages';
    RAISE NOTICE '- 6 Properties across different building types';
    RAISE NOTICE '- 6 Contacts including primary and secondary contacts';
    RAISE NOTICE '- 5 Prospects in different sales stages';
    RAISE NOTICE '- 4 Opportunities with various deal values and stages';
    RAISE NOTICE '- 6 Activities tracking recent interactions';

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint error during data population: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint violation during data population: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error during data population: %', SQLERRM;
        RAISE NOTICE 'Error detail: %', SQLSTATE;
END $$;
