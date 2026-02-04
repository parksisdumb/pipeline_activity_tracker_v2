-- Extend follow-up rules to support properties

ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS last_touch_at timestamptz,
  ADD COLUMN IF NOT EXISTS next_touch_due_at timestamptz,
  ADD COLUMN IF NOT EXISTS temperature text NOT NULL DEFAULT 'cold',
  ADD COLUMN IF NOT EXISTS touch_interval_override_days int;

DO $$
DECLARE
  constraint_name text;
BEGIN
  SELECT conname
  INTO constraint_name
  FROM pg_constraint
  WHERE conrelid = 'public.follow_up_rules'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%entity_type%';

  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.follow_up_rules DROP CONSTRAINT %I', constraint_name);
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.follow_up_rules'::regclass
      AND conname = 'follow_up_rules_entity_type_check'
  ) THEN
    ALTER TABLE public.follow_up_rules
      ADD CONSTRAINT follow_up_rules_entity_type_check
      CHECK (entity_type IN ('account', 'contact', 'property'));
  END IF;
END $$;

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

  IF p_entity_type = 'property' THEN
    SELECT temperature, stage::text, touch_interval_override_days
    INTO v_temperature, v_stage, v_override
    FROM public.properties
    WHERE id = p_entity_id
      AND tenant_id = p_tenant_id;

    IF NOT FOUND THEN
      RETURN;
    END IF;

    v_interval := COALESCE(
      v_override,
      public.get_follow_up_interval_days(
        p_tenant_id,
        'property',
        COALESCE(v_temperature, 'cold'),
        COALESCE(v_stage, 'default')
      )
    );

    UPDATE public.properties
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

  IF NEW.property_id IS NOT NULL THEN
    PERFORM public.apply_next_touch_due_at(NEW.tenant_id, 'property', NEW.property_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS after_activity_set_next_touch ON public.activities;
CREATE TRIGGER after_activity_set_next_touch
AFTER INSERT ON public.activities
FOR EACH ROW
EXECUTE FUNCTION public.trg_after_activity_set_next_touch();

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
    ('property', 'cold', 'default', 30, 100),
    ('property', 'warm', 'default', 14, 100),
    ('property', 'hot', 'default', 7, 100)
) AS r(entity_type, temperature, stage, interval_days, priority)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.follow_up_rules fr
  WHERE fr.tenant_id = t.id
    AND fr.entity_type = r.entity_type
    AND fr.temperature = r.temperature
    AND fr.stage = r.stage
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.follow_up_rules TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.follow_up_rules TO service_role;

NOTIFY pgrst, 'reload schema';
