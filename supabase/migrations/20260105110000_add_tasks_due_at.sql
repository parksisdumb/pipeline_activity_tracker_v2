-- Add due_at column and backfill from legacy due_date/due_on
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS due_at timestamptz;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'tasks'
      AND column_name = 'due_date'
  ) THEN
    UPDATE public.tasks
    SET due_at = COALESCE(due_at, due_date)
    WHERE due_at IS NULL AND due_date IS NOT NULL;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'tasks'
      AND column_name = 'due_on'
  ) THEN
    UPDATE public.tasks
    SET due_at = COALESCE(due_at, due_on)
    WHERE due_at IS NULL AND due_on IS NOT NULL;
  END IF;
END $$;
