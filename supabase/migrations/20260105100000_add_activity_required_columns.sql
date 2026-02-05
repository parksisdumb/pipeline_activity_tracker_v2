-- Add missing activities columns in one pass
ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id text,
  ADD COLUMN IF NOT EXISTS direction text DEFAULT 'outbound',
  ADD COLUMN IF NOT EXISTS activity_purpose text DEFAULT 'sustain',
  ADD COLUMN IF NOT EXISTS source_task_id text;
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'activities'
      AND column_name = 'linked_entity_id'
      AND data_type <> 'text'
  ) THEN
    ALTER TABLE public.activities
      ALTER COLUMN linked_entity_id TYPE text USING linked_entity_id::text;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'activities'
      AND column_name = 'source_task_id'
      AND data_type <> 'text'
  ) THEN
    ALTER TABLE public.activities
      ALTER COLUMN source_task_id TYPE text USING source_task_id::text;
  END IF;
END $$;
