-- Task/activity linkage fields for follow-ups without extra tables
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS task_type text,
  ADD COLUMN IF NOT EXISTS source_activity_id uuid,
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id uuid;
ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS source_task_id uuid,
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id uuid;
