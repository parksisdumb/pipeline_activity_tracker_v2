-- Add GROW tracking fields for pipeline motions
ALTER TABLE public.accounts
  ADD COLUMN IF NOT EXISTS source text,
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS created_by uuid;

ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false;

ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS created_by uuid;

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS direction text;

ALTER TABLE public.opportunities
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false;
