-- Location: supabase/migrations/20250106132100_add_affiliate_company_types.sql
-- Schema Analysis: CRM system with existing company_type enum that needs extension
-- Integration Type: Extension - adding new enum values to existing type
-- Dependencies: Extends existing public.company_type enum used by accounts table

-- Check if enum values exist before adding them to prevent duplicate errors
DO $$ 
BEGIN
    -- Add 'Affiliate: Real Estate' if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'Affiliate: Real Estate' 
        AND enumtypid = (
            SELECT oid FROM pg_type 
            WHERE typname = 'company_type' 
            AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        )
    ) THEN
        ALTER TYPE public.company_type ADD VALUE 'Affiliate: Real Estate';
    END IF;
    
    -- Add 'Affiliate: Manufacturer' if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'Affiliate: Manufacturer' 
        AND enumtypid = (
            SELECT oid FROM pg_type 
            WHERE typname = 'company_type' 
            AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        )
    ) THEN
        ALTER TYPE public.company_type ADD VALUE 'Affiliate: Manufacturer';
    END IF;
END $$;
