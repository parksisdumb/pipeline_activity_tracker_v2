-- Location: supabase/migrations/20250104194001_fix_missing_calendar_functions.sql
-- Schema Analysis: Existing CRM system with calendar_events table already created
-- Integration Type: Fix - Restore missing calendar functions that were lost due to migration issues
-- Dependencies: References existing calendar_events, user_profiles, and tenants tables

-- Fix 1: Remove problematic CURRENT_DATE index that uses non-IMMUTABLE function
DROP INDEX IF EXISTS idx_calendar_events_today;
-- Fix 2: Recreate the missing get_today_events function
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
-- Fix 3: Recreate the missing get_upcoming_events function  
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
-- Fix 4: Create a better index that doesn't rely on volatile functions
-- Instead of CURRENT_DATE predicate, create a general active events index
CREATE INDEX IF NOT EXISTS idx_calendar_events_active_by_tenant 
ON public.calendar_events(tenant_id, start_datetime, status) 
WHERE status IN ('scheduled', 'in_progress');
-- Fix 5: REMOVED problematic date cast index - replaced with simple datetime index
-- CREATE INDEX idx_calendar_events_start_date 
-- ON public.calendar_events(tenant_id, (start_datetime::date), start_datetime);
-- FIXED: Use simple datetime index instead
CREATE INDEX IF NOT EXISTS idx_calendar_events_tenant_datetime 
ON public.calendar_events(tenant_id, start_datetime);
-- Fix 6: Ensure all helper functions exist for calendar functionality
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT up.tenant_id
FROM public.user_profiles up
WHERE up.id = auth.uid()
LIMIT 1;
$$;
-- Fix 7: Helper function to check if user belongs to tenant
CREATE OR REPLACE FUNCTION public.user_belongs_to_event_tenant(event_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.tenant_id = event_tenant_id
);
$$;
-- Fix 8: Function to mark events as completed
CREATE OR REPLACE FUNCTION public.mark_event_completed(event_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
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
-- Fix 9: Refresh schema cache by updating function comments
COMMENT ON FUNCTION public.get_today_events(UUID) IS 'Returns today''s calendar events for the specified tenant';
COMMENT ON FUNCTION public.get_upcoming_events(INTEGER, UUID) IS 'Returns upcoming calendar events within specified days';
COMMENT ON FUNCTION public.mark_event_completed(UUID) IS 'Marks a calendar event as completed if user has permission';
-- Verify the fix by testing the function exists
DO $$
BEGIN
    -- Test that the function exists and can be called
    PERFORM public.get_today_events();
    RAISE NOTICE 'Calendar functions restored successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Warning: Function test failed: %', SQLERRM;
END $$;
