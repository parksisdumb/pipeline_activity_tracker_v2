-- Bootstrap core schema so older migrations can safely reference it
-- Keep this file SMALL and STABLE.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tenants (minimal)
CREATE TABLE IF NOT EXISTS public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Core user_role enum (create only if missing)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'user_role' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'rep');
  END IF;
END $$;

-- user_profiles (minimal: enough for FKs in older migrations)
-- NOTE: do NOT force auth.users FK here (it can break shadow DB init)
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY,
  tenant_id UUID NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  role public.user_role NOT NULL DEFAULT 'rep'::public.user_role,
  email TEXT NULL,
  full_name TEXT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

