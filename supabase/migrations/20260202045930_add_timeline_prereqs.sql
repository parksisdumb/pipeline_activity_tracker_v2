-- Add task/activity linkage fields required by timeline view
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS task_type text,
  ADD COLUMN IF NOT EXISTS source_activity_id uuid,
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id uuid,
  ADD COLUMN IF NOT EXISTS due_at timestamptz;

ALTER TABLE public.tasks
  ALTER COLUMN task_type SET DEFAULT 'general';

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

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS source_task_id text,
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id text,
  ADD COLUMN IF NOT EXISTS direction text DEFAULT 'outbound',
  ADD COLUMN IF NOT EXISTS activity_purpose text DEFAULT 'sustain',
  ADD COLUMN IF NOT EXISTS created_from_grow boolean DEFAULT false;

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

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'tasks_source_activity_id_fkey'
      AND conrelid = 'public.tasks'::regclass
  ) THEN
    ALTER TABLE public.tasks
      ADD CONSTRAINT tasks_source_activity_id_fkey
      FOREIGN KEY (source_activity_id)
      REFERENCES public.activities(id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON public.tasks(due_at);
CREATE INDEX IF NOT EXISTS idx_tasks_source_activity_id ON public.tasks(source_activity_id);
CREATE INDEX IF NOT EXISTS idx_tasks_linked_entity ON public.tasks(linked_entity_type, linked_entity_id);
