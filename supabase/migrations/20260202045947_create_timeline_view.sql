-- Unified timeline view for tasks + activities
-- Timeline items are derived from existing tables to avoid data duplication.

CREATE OR REPLACE VIEW public.timeline_items AS
SELECT
  t.id,
  'task'::text AS source_type,
  t.id AS source_id,
  t.title,
  t.description,
  t.status::text AS status,
  t.priority::text AS priority,
  t.category::text AS category,
  t.task_type::text AS task_type,
  NULL::text AS activity_type,
  NULL::text AS outcome,
  NULL::text AS direction,
  NULL::text AS activity_purpose,
  FALSE::boolean AS created_from_grow,
  t.due_at,
  t.due_date,
  COALESCE(t.due_at, t.due_date, t.created_at) AS event_at,
  t.created_at,
  t.updated_at,
  t.assigned_to AS user_id,
  t.assigned_by,
  t.tenant_id,
  t.account_id,
  t.property_id,
  t.contact_id,
  t.opportunity_id,
  t.prospect_id,
  COALESCE(
    NULLIF(t.linked_entity_type, ''),
    CASE
      WHEN t.opportunity_id IS NOT NULL THEN 'opportunity'
      WHEN t.property_id IS NOT NULL THEN 'property'
      WHEN t.contact_id IS NOT NULL THEN 'contact'
      WHEN t.account_id IS NOT NULL THEN 'account'
      WHEN t.prospect_id IS NOT NULL THEN 'prospect'
      ELSE NULL
    END
  ) AS entity_type,
  COALESCE(
    NULLIF(t.linked_entity_id::text, ''),
    t.opportunity_id::text,
    t.property_id::text,
    t.contact_id::text,
    t.account_id::text,
    t.prospect_id::text
  ) AS entity_id,
  a.name AS account_name,
  p.name AS property_name,
  CASE
    WHEN c.id IS NULL THEN NULL
    ELSE CONCAT(c.first_name, ' ', c.last_name)
  END AS contact_name,
  o.name AS opportunity_name,
  t.source_activity_id::text AS source_activity_id,
  NULL::text AS source_task_id,
  CASE
    WHEN t.category::text ILIKE '%review%' THEN 'review'
    WHEN t.category::text ILIKE '%grow%' OR t.category::text ILIKE '%prospect%' THEN 'grow'
    ELSE 'execute'
  END AS timeline_category
FROM public.tasks t
LEFT JOIN public.accounts a ON a.id = t.account_id
LEFT JOIN public.properties p ON p.id = t.property_id
LEFT JOIN public.contacts c ON c.id = t.contact_id
LEFT JOIN public.opportunities o ON o.id = t.opportunity_id

UNION ALL

SELECT
  a2.id,
  'activity'::text AS source_type,
  a2.id AS source_id,
  a2.subject AS title,
  COALESCE(a2.notes, a2.description) AS description,
  'completed'::text AS status,
  NULL::text AS priority,
  a2.activity_type::text AS category,
  NULL::text AS task_type,
  a2.activity_type::text AS activity_type,
  a2.outcome::text AS outcome,
  a2.direction::text AS direction,
  a2.activity_purpose::text AS activity_purpose,
  COALESCE(a2.created_from_grow, false) AS created_from_grow,
  NULL::timestamptz AS due_at,
  a2.follow_up_date AS due_date,
  COALESCE(a2.activity_date, a2.created_at) AS event_at,
  a2.created_at,
  a2.created_at AS updated_at,
  a2.user_id AS user_id,
  NULL::uuid AS assigned_by,
  a2.tenant_id,
  a2.account_id,
  a2.property_id,
  a2.contact_id,
  a2.opportunity_id,
  NULL::uuid AS prospect_id,
  COALESCE(
    NULLIF(a2.linked_entity_type, ''),
    CASE
      WHEN a2.opportunity_id IS NOT NULL THEN 'opportunity'
      WHEN a2.property_id IS NOT NULL THEN 'property'
      WHEN a2.contact_id IS NOT NULL THEN 'contact'
      WHEN a2.account_id IS NOT NULL THEN 'account'
      ELSE NULL
    END
  ) AS entity_type,
  COALESCE(
    NULLIF(a2.linked_entity_id, ''),
    a2.opportunity_id::text,
    a2.property_id::text,
    a2.contact_id::text,
    a2.account_id::text
  ) AS entity_id,
  a3.name AS account_name,
  p2.name AS property_name,
  CASE
    WHEN c2.id IS NULL THEN NULL
    ELSE CONCAT(c2.first_name, ' ', c2.last_name)
  END AS contact_name,
  o2.name AS opportunity_name,
  NULL::text AS source_activity_id,
  a2.source_task_id::text AS source_task_id,
  CASE
    WHEN COALESCE(a2.created_from_grow, false) THEN 'grow'
    WHEN COALESCE(a2.activity_purpose, '') ILIKE '%review%' THEN 'review'
    WHEN COALESCE(a2.activity_purpose, '') ILIKE '%grow%' THEN 'grow'
    ELSE 'execute'
  END AS timeline_category
FROM public.activities a2
LEFT JOIN public.accounts a3 ON a3.id = a2.account_id
LEFT JOIN public.properties p2 ON p2.id = a2.property_id
LEFT JOIN public.contacts c2 ON c2.id = a2.contact_id
LEFT JOIN public.opportunities o2 ON o2.id = a2.opportunity_id;

ALTER VIEW public.timeline_items SET (security_invoker = true);

GRANT SELECT ON public.timeline_items TO anon;
GRANT SELECT ON public.timeline_items TO authenticated;
GRANT SELECT ON public.timeline_items TO service_role;

NOTIFY pgrst, 'reload schema';
