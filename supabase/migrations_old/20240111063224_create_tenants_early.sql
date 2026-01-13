-- Create tenants table early so other migrations can reference it
CREATE TABLE IF NOT EXISTS public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Optional: updated_at trigger if you already use one
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_proc
    WHERE proname = 'handle_updated_at'
  ) THEN
    DROP TRIGGER IF EXISTS handle_updated_at_tenants ON public.tenants;
    CREATE TRIGGER handle_updated_at_tenants
      BEFORE UPDATE ON public.tenants
      FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END $$;
