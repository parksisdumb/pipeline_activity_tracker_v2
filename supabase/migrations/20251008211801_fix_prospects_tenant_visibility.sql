-- Location: supabase/migrations/20251008211801_fix_prospects_tenant_visibility.sql
-- Schema Analysis: Existing prospects table with RLS policies restricting visibility
-- Integration Type: MODIFICATIVE - Fixing existing RLS policies for tenant-wide visibility
-- Dependencies: prospects, user_profiles tables

-- Issue: Prospects are only visible to managers and prospect creators
-- Solution: Update RLS policies to allow tenant-wide visibility while maintaining security

-- Step 1: Drop existing restrictive policies on prospects table
DROP POLICY IF EXISTS "prospects_tenant_visibility" ON public.prospects;
DROP POLICY IF EXISTS "prospects_insert_policy" ON public.prospects;
DROP POLICY IF EXISTS "prospects_select_policy" ON public.prospects;
DROP POLICY IF EXISTS "prospects_update_policy" ON public.prospects;
DROP POLICY IF EXISTS "prospects_delete_policy" ON public.prospects;
-- Step 2: Create helper function for tenant-based access (queries different table - user_profiles)
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
-- Step 3: Create comprehensive tenant-wide RLS policies for prospects
-- This allows all authenticated users within the same tenant to see all prospects

-- SELECT policy: Users can view all prospects in their tenant
CREATE POLICY "prospects_tenant_select"
ON public.prospects
FOR SELECT
TO authenticated
USING (
    tenant_id = public.get_user_tenant_id()
);
-- INSERT policy: Users can create prospects in their tenant
CREATE POLICY "prospects_tenant_insert"
ON public.prospects
FOR INSERT
TO authenticated
WITH CHECK (
    tenant_id = public.get_user_tenant_id()
    AND created_by = auth.uid()
);
-- UPDATE policy: Users can update prospects in their tenant
CREATE POLICY "prospects_tenant_update"
ON public.prospects
FOR UPDATE
TO authenticated
USING (
    tenant_id = public.get_user_tenant_id()
)
WITH CHECK (
    tenant_id = public.get_user_tenant_id()
);
-- DELETE policy: Only prospect creators and managers can delete prospects
CREATE POLICY "prospects_tenant_delete"
ON public.prospects
FOR DELETE
TO authenticated
USING (
    tenant_id = public.get_user_tenant_id()
    AND (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = auth.uid()
            AND up.tenant_id = prospects.tenant_id
            AND up.role IN ('admin', 'manager')
        )
    )
);
-- Step 4: Create additional function for role-based operations (if needed)
CREATE OR REPLACE FUNCTION public.is_manager_or_admin_in_tenant(check_tenant_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid()
    AND up.tenant_id = check_tenant_id
    AND up.role IN ('admin', 'manager')
)
$$;
-- Step 5: Update prospects service queries to work with new policies
-- Note: The existing prospectsService.js should work without changes
-- as it already includes tenant_id in the user profile fetching

-- Step 6: Ensure proper indexing for performance
CREATE INDEX IF NOT EXISTS idx_prospects_tenant_id_status ON public.prospects(tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_prospects_tenant_id_created_by ON public.prospects(tenant_id, created_by);
-- Step 7: Add comment to document the change
COMMENT ON TABLE public.prospects IS 'Prospects table with tenant-wide visibility. All authenticated users within a tenant can view all prospects in their tenant.';
