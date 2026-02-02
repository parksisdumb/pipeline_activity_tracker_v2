-- Ensure get_user_tenant_id exists before downstream migrations reference it
CREATE OR REPLACE FUNCTION public.get_user_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT NULLIF(
  (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id'),
  ''
)::uuid
$$;

GRANT EXECUTE ON FUNCTION public.get_user_tenant_id() TO anon;
GRANT EXECUTE ON FUNCTION public.get_user_tenant_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_tenant_id() TO service_role;
