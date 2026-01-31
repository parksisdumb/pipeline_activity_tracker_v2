-- Re-add grow tracking fields to properties after baseline reset
ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS created_by uuid;
