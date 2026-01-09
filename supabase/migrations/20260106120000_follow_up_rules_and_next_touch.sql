-- Follow-up rules and next-touch automation

-- Phase 1: Add follow-up tracking fields
ALTER TABLE public.accounts
  ADD COLUMN IF NOT EXISTS last_touch_at timestamptz,
  ADD COLUMN IF NOT EXISTS next_touch_due_at timestamptz,
  ADD COLUMN IF NOT EXISTS temperature text NOT NULL DEFAULT 'cold',
  ADD COLUMN IF NOT EXISTS touch_interval_override_days int;

ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS last_touch_at timestamptz,
  ADD COLUMN IF NOT EXISTS next_touch_due_at timestamptz,
  ADD COLUMN IF NOT EXISTS temperature text NOT NULL DEFAULT 'cold',
  ADD COLUMN IF NOT EXISTS touch_interval_override_days int;

-- Stage columns (only add if missing - existing enums are preserved)
ALTER TABLE public.accounts
  ADD COLUMN IF NOT EXISTS stage text NOT NULL DEFAULT 'prospecting';

ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS stage text NOT NULL DEFAULT 'contacted';

-- Phase 1: Follow-up rules table (manager-configurable)
CREATE TABLE IF NOT EXISTS public.follow_up_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  entity_type text NOT NULL CHECK (entity_type IN ('account', 'contact')),
  temperature text NOT NULL CHECK (temperature IN ('cold', 'warm', 'hot')),
  stage text NOT NULL,
  interval_days int NOT NULL CHECK (interval_days BETWEEN 1 AND 365),
  priority int NOT NULL DEFAULT 100,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_follow_up_rules_lookup
  ON public.follow_up_rules(tenant_id, entity_type, temperature, stage);

-- Phase 1: Manager-defined user goals table
CREATE TABLE IF NOT EXISTS public.user_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  user_id uuid NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  period text NOT NULL CHECK (period IN ('weekly', 'monthly')),
  metric text NOT NULL CHECK (metric IN ('calls', 'new_contacts', 'touches')),
  target int NOT NULL CHECK (target >= 0),
  created_at timestamptz DEFAULT now(),
  is_active boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_user_goals_lookup
  ON public.user_goals(tenant_id, user_id, period, metric);

-- Phase 1: Ensure tasks table supports task linkage fields
ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS task_type text DEFAULT 'general',
  ADD COLUMN IF NOT EXISTS linked_entity_type text,
  ADD COLUMN IF NOT EXISTS linked_entity_id uuid,
  ADD COLUMN IF NOT EXISTS source_activity_id uuid;

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

CREATE INDEX IF NOT EXISTS idx_tasks_due_at
  ON public.tasks(due_at);

CREATE INDEX IF NOT EXISTS idx_tasks_tenant_assigned
  ON public.tasks(tenant_id, assigned_to);

CREATE INDEX IF NOT EXISTS idx_tasks_source_activity_id
  ON public.tasks(source_activity_id);

CREATE INDEX IF NOT EXISTS idx_tasks_linked_entity
  ON public.tasks(linked_entity_type, linked_entity_id);

-- Phase 2: Follow-up interval helpers
CREATE OR REPLACE FUNCTION public.get_follow_up_interval_days(
  p_tenant_id uuid,
  p_entity_type text,
  p_temperature text,
  p_stage text
) RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE
  v_interval int;
BEGIN
  SELECT fr.interval_days
  INTO v_interval
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = p_tenant_id
    AND fr.entity_type = p_entity_type
    AND fr.temperature = p_temperature
    AND fr.stage = p_stage
    AND fr.is_active = true
  ORDER BY fr.priority ASC, fr.interval_days ASC
  LIMIT 1;

  IF v_interval IS NOT NULL THEN
    RETURN v_interval;
  END IF;

  SELECT fr.interval_days
  INTO v_interval
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = p_tenant_id
    AND fr.entity_type = p_entity_type
    AND fr.temperature = p_temperature
    AND fr.stage = '*'
    AND fr.is_active = true
  ORDER BY fr.priority ASC, fr.interval_days ASC
  LIMIT 1;

  IF v_interval IS NOT NULL THEN
    RETURN v_interval;
  END IF;

  SELECT fr.interval_days
  INTO v_interval
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = p_tenant_id
    AND fr.entity_type = p_entity_type
    AND fr.temperature = p_temperature
    AND fr.stage = 'default'
    AND fr.is_active = true
  ORDER BY fr.priority ASC, fr.interval_days ASC
  LIMIT 1;

  RETURN COALESCE(v_interval, 30);
END;
$$;

CREATE OR REPLACE FUNCTION public.apply_next_touch_due_at(
  p_tenant_id uuid,
  p_entity_type text,
  p_entity_id uuid
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_temperature text;
  v_stage text;
  v_override int;
  v_interval int;
BEGIN
  IF p_entity_type = 'contact' THEN
    SELECT temperature, stage::text, touch_interval_override_days
    INTO v_temperature, v_stage, v_override
    FROM public.contacts
    WHERE id = p_entity_id
      AND tenant_id = p_tenant_id;

    IF NOT FOUND THEN
      RETURN;
    END IF;

    v_interval := COALESCE(
      v_override,
      public.get_follow_up_interval_days(
        p_tenant_id,
        'contact',
        COALESCE(v_temperature, 'cold'),
        COALESCE(v_stage, 'default')
      )
    );

    UPDATE public.contacts
    SET last_touch_at = now(),
        next_touch_due_at = now() + make_interval(days => v_interval)
    WHERE id = p_entity_id
      AND tenant_id = p_tenant_id;
    RETURN;
  END IF;

  IF p_entity_type = 'account' THEN
    SELECT temperature, stage::text, touch_interval_override_days
    INTO v_temperature, v_stage, v_override
    FROM public.accounts
    WHERE id = p_entity_id
      AND tenant_id = p_tenant_id;

    IF NOT FOUND THEN
      RETURN;
    END IF;

    v_interval := COALESCE(
      v_override,
      public.get_follow_up_interval_days(
        p_tenant_id,
        'account',
        COALESCE(v_temperature, 'cold'),
        COALESCE(v_stage, 'default')
      )
    );

    UPDATE public.accounts
    SET last_touch_at = now(),
        next_touch_due_at = now() + make_interval(days => v_interval)
    WHERE id = p_entity_id
      AND tenant_id = p_tenant_id;
    RETURN;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_after_activity_set_next_touch()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.contact_id IS NOT NULL THEN
    PERFORM public.apply_next_touch_due_at(NEW.tenant_id, 'contact', NEW.contact_id);
  END IF;

  IF NEW.account_id IS NOT NULL THEN
    PERFORM public.apply_next_touch_due_at(NEW.tenant_id, 'account', NEW.account_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS after_activity_set_next_touch ON public.activities;
CREATE TRIGGER after_activity_set_next_touch
AFTER INSERT ON public.activities
FOR EACH ROW
EXECUTE FUNCTION public.trg_after_activity_set_next_touch();

-- Phase 3: Seed default follow-up rules per tenant
INSERT INTO public.follow_up_rules (
  tenant_id,
  entity_type,
  temperature,
  stage,
  interval_days,
  priority
)
SELECT t.id,
       r.entity_type,
       r.temperature,
       r.stage,
       r.interval_days,
       r.priority
FROM public.tenants t
CROSS JOIN (
  VALUES
    ('account', 'cold', 'default', 30, 100),
    ('account', 'warm', 'default', 14, 100),
    ('account', 'hot', 'default', 7, 100),
    ('contact', 'cold', 'default', 30, 100),
    ('contact', 'warm', 'default', 14, 100),
    ('contact', 'hot', 'default', 7, 100)
) AS r(entity_type, temperature, stage, interval_days, priority)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = t.id
    AND fr.entity_type = r.entity_type
    AND fr.temperature = r.temperature
    AND fr.stage = r.stage
);

INSERT INTO public.follow_up_rules (
  tenant_id,
  entity_type,
  temperature,
  stage,
  interval_days,
  priority
)
SELECT t.id,
       e.entity_type,
       temp.temperature,
       s.stage,
       s.interval_days,
       s.priority
FROM public.tenants t
CROSS JOIN (VALUES ('account'), ('contact')) AS e(entity_type)
CROSS JOIN (VALUES ('cold'), ('warm'), ('hot')) AS temp(temperature)
CROSS JOIN (
  VALUES
    ('onboarding', 7, 10),
    ('proposal_sent', 5, 20),
    ('negotiation', 3, 10),
    ('estimating', 5, 20),
    ('site_visit_scheduled', 3, 10)
) AS s(stage, interval_days, priority)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = t.id
    AND fr.entity_type = e.entity_type
    AND fr.temperature = temp.temperature
    AND fr.stage = s.stage
);

-- Phase 3: Seed default weekly goals per tenant
INSERT INTO public.user_goals (
  tenant_id,
  user_id,
  period,
  metric,
  target
)
SELECT t.id,
       NULL,
       g.period,
       g.metric,
       g.target
FROM public.tenants t
CROSS JOIN (
  VALUES
    ('weekly', 'calls', 100),
    ('weekly', 'new_contacts', 5),
    ('weekly', 'touches', 25)
) AS g(period, metric, target)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.user_goals ug
  WHERE ug.tenant_id = t.id
    AND ug.user_id IS NULL
    AND ug.period = g.period
    AND ug.metric = g.metric
);

-- Phase 6: RLS sanity for new tables
ALTER TABLE public.follow_up_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS follow_up_rules_select ON public.follow_up_rules;
CREATE POLICY follow_up_rules_select
  ON public.follow_up_rules
  FOR SELECT
  TO authenticated
  USING (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS follow_up_rules_insert ON public.follow_up_rules;
CREATE POLICY follow_up_rules_insert
  ON public.follow_up_rules
  FOR INSERT
  TO authenticated
  WITH CHECK (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  );

DROP POLICY IF EXISTS follow_up_rules_update ON public.follow_up_rules;
CREATE POLICY follow_up_rules_update
  ON public.follow_up_rules
  FOR UPDATE
  TO authenticated
  USING (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  )
  WITH CHECK (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  );

DROP POLICY IF EXISTS user_goals_select ON public.user_goals;
CREATE POLICY user_goals_select
  ON public.user_goals
  FOR SELECT
  TO authenticated
  USING (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS user_goals_insert ON public.user_goals;
CREATE POLICY user_goals_insert
  ON public.user_goals
  FOR INSERT
  TO authenticated
  WITH CHECK (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  );

DROP POLICY IF EXISTS user_goals_update ON public.user_goals;
CREATE POLICY user_goals_update
  ON public.user_goals
  FOR UPDATE
  TO authenticated
  USING (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  )
  WITH CHECK (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  );

DROP POLICY IF EXISTS user_goals_delete ON public.user_goals;
CREATE POLICY user_goals_delete
  ON public.user_goals
  FOR DELETE
  TO authenticated
  USING (
    tenant_id = public.current_tenant_id()
    AND public.get_user_role() IN ('manager', 'admin', 'super_admin')
  );

-- PostgREST schema reload
NOTIFY pgrst, 'reload schema';
