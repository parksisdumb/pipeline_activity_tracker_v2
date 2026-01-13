-- Location: supabase/migrations/20250104194000_add_calendar_events.sql
-- Schema Analysis: Existing CRM system with tenants, user_profiles, accounts, properties, activities tables
-- Integration Type: Addition - New calendar events table for tenant-wide calendar functionality  
-- Dependencies: References existing user_profiles and tenants tables

-- Create event type enum for categorizing events
CREATE TYPE public.event_type AS ENUM ('meeting', 'deadline', 'company_event', 'appointment', 'training', 'holiday', 'maintenance', 'inspection');

-- Create event priority enum
CREATE TYPE public.event_priority AS ENUM ('low', 'medium', 'high', 'critical');

-- Create event status enum
CREATE TYPE public.event_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'rescheduled');

-- Create calendar events table for tenant-wide events
CREATE TABLE public.calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,

    
    -- Event details
    title TEXT NOT NULL,
    description TEXT,
    event_type public.event_type NOT NULL,
    priority public.event_priority DEFAULT 'medium'::public.event_priority,
    status public.event_status DEFAULT 'scheduled'::public.event_status,
    
    -- Scheduling
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    all_day BOOLEAN DEFAULT false,
    timezone TEXT DEFAULT 'UTC',
    
    -- Optional relationships
    related_account_id UUID REFERENCES public.accounts(id) ON DELETE SET NULL,
    related_property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    related_contact_id UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
    
    -- Event settings
    is_recurring BOOLEAN DEFAULT false,
    recurrence_pattern JSONB,
    reminder_minutes INTEGER[] DEFAULT ARRAY[15, 60],
    is_private BOOLEAN DEFAULT false,
    location TEXT,
    meeting_url TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add constraint to ensure end_datetime is after start_datetime
ALTER TABLE public.calendar_events 
ADD CONSTRAINT check_event_datetime_order 
CHECK (end_datetime > start_datetime);

-- Create indexes for performance
CREATE INDEX idx_calendar_events_tenant_id ON public.calendar_events(tenant_id);
CREATE INDEX idx_calendar_events_created_by ON public.calendar_events(created_by);
CREATE INDEX idx_calendar_events_assigned_to ON public.calendar_events(assigned_to);
CREATE INDEX idx_calendar_events_start_datetime ON public.calendar_events(start_datetime);
CREATE INDEX idx_calendar_events_end_datetime ON public.calendar_events(end_datetime);
CREATE INDEX idx_calendar_events_event_type ON public.calendar_events(event_type);
CREATE INDEX idx_calendar_events_status ON public.calendar_events(status);
CREATE INDEX idx_calendar_events_priority ON public.calendar_events(priority);

-- Composite index for efficient date range queries
CREATE INDEX idx_calendar_events_tenant_date_range ON public.calendar_events(tenant_id, start_datetime, end_datetime);

-- Index for active events (scheduled and in_progress) - FIXED: removed CURRENT_DATE
CREATE INDEX idx_calendar_events_active ON public.calendar_events(tenant_id, start_datetime, status) 
WHERE status IN ('scheduled', 'in_progress');

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Add updated_at trigger
CREATE TRIGGER handle_updated_at_calendar_events
    BEFORE UPDATE ON public.calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable RLS
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;

-- Helper function to get user's tenant (marked as IMMUTABLE for index compatibility)
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT up.tenant_id
FROM public.user_profiles up
WHERE up.id = auth.uid()
LIMIT 1
$$;

-- Helper function to check if user belongs to tenant
CREATE OR REPLACE FUNCTION public.user_belongs_to_event_tenant(event_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.tenant_id = event_tenant_id
)
$$;

-- RLS Policies using Pattern 2 (Simple User Ownership) and tenant isolation
CREATE POLICY "users_manage_tenant_calendar_events"
ON public.calendar_events
FOR ALL
TO authenticated
USING (
    tenant_id IN (
        SELECT up.tenant_id 
        FROM public.user_profiles up 
        WHERE up.id = auth.uid()
    )
)
WITH CHECK (
    tenant_id IN (
        SELECT up.tenant_id 
        FROM public.user_profiles up 
        WHERE up.id = auth.uid()
    )
);

-- Additional policy for admin access using Pattern 6 (auth.users metadata)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE POLICY "admin_full_access_calendar_events"
ON public.calendar_events
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Create helper functions for calendar queries
CREATE OR REPLACE FUNCTION public.get_today_events(target_tenant_id UUID DEFAULT NULL)
RETURNS TABLE(
    id UUID,
    title TEXT,
    description TEXT,
    event_type TEXT,
    priority TEXT,
    status TEXT,
    start_datetime TIMESTAMPTZ,
    end_datetime TIMESTAMPTZ,
    all_day BOOLEAN,
    location TEXT,
    meeting_url TEXT,
    created_by_name TEXT,
    assigned_to_name TEXT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
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
WHERE ce.start_datetime::date = CURRENT_DATE
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

CREATE OR REPLACE FUNCTION public.get_upcoming_events(days_ahead INTEGER DEFAULT 7, target_tenant_id UUID DEFAULT NULL)
RETURNS TABLE(
    id UUID,
    title TEXT,
    description TEXT,
    event_type TEXT,
    priority TEXT,
    status TEXT,
    start_datetime TIMESTAMPTZ,
    end_datetime TIMESTAMPTZ,
    all_day BOOLEAN,
    location TEXT,
    meeting_url TEXT,
    created_by_name TEXT,
    assigned_to_name TEXT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
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

-- Sample data for testing calendar functionality
DO $$
DECLARE
    existing_tenant_id UUID;
    existing_user_id UUID;
    existing_account_id UUID;
    existing_property_id UUID;
    event1_id UUID := gen_random_uuid();
    event2_id UUID := gen_random_uuid();
    event3_id UUID := gen_random_uuid();
BEGIN
    -- Get existing tenant, user, account, and property IDs from existing data
    SELECT id INTO existing_tenant_id FROM public.tenants LIMIT 1;
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_account_id FROM public.accounts LIMIT 1;
    SELECT id INTO existing_property_id FROM public.properties LIMIT 1;
    
    -- Only create sample data if we have existing references
    IF existing_tenant_id IS NOT NULL AND existing_user_id IS NOT NULL THEN
        -- Create sample calendar events
        INSERT INTO public.calendar_events (
            id, tenant_id, created_by, assigned_to, title, description, event_type,
            priority, status, start_datetime, end_datetime, all_day,
            related_account_id, related_property_id, location, notes
        ) VALUES
        (
            event1_id,
            existing_tenant_id,
            existing_user_id,
            existing_user_id,
            'Weekly Team Meeting',
            'Discuss project progress and upcoming deadlines',
            'meeting'::public.event_type,
            'high'::public.event_priority,
            'scheduled'::public.event_status,
            CURRENT_DATE + INTERVAL '10 hours',
            CURRENT_DATE + INTERVAL '11 hours',
            false,
            existing_account_id,
            NULL,
            'Conference Room A',
            'Bring quarterly reports and project updates'
        ),
        (
            event2_id,
            existing_tenant_id,
            existing_user_id,
            existing_user_id,
            'Property Inspection',
            'Annual roof inspection and maintenance check',
            'inspection'::public.event_type,
            'medium'::public.event_priority,
            'scheduled'::public.event_status,
            CURRENT_DATE + INTERVAL '2 days' + INTERVAL '14 hours',
            CURRENT_DATE + INTERVAL '2 days' + INTERVAL '16 hours',
            false,
            existing_account_id,
            existing_property_id,
            'Client site location',
            'Bring inspection tools and safety equipment'
        ),
        (
            event3_id,
            existing_tenant_id,
            existing_user_id,
            existing_user_id,
            'Company Holiday - New Year',
            'Office closed for New Year celebration',
            'holiday'::public.event_type,
            'low'::public.event_priority,
            'scheduled'::public.event_status,
            '2025-01-01 00:00:00+00',
            '2025-01-01 23:59:59+00',
            true,
            NULL,
            NULL,
            'All offices',
            'Happy New Year! Office will be closed.'
        );

        RAISE NOTICE 'Sample calendar events created successfully';
    ELSE
        RAISE NOTICE 'No existing tenant or user found. Sample events not created.';
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error creating sample events: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error creating sample events: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error creating sample events: %', SQLERRM;
END $$;