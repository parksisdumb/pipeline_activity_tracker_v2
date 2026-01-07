-- Create join table for many-to-many property/contact relationships
create table if not exists public.property_contacts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid,
  property_id uuid not null references public.properties(id) on delete cascade,
  contact_id uuid not null references public.contacts(id) on delete cascade,
  relationship_type text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  constraint property_contacts_property_contact_unique unique (property_id, contact_id)
);

create index if not exists idx_property_contacts_workspace_id on public.property_contacts (workspace_id);
create index if not exists idx_property_contacts_property_id on public.property_contacts (property_id);
create index if not exists idx_property_contacts_contact_id on public.property_contacts (contact_id);

-- Backfill existing one-to-many relationships from contacts.property_id
insert into public.property_contacts (
  workspace_id,
  property_id,
  contact_id,
  is_primary,
  created_at
)
select
  c.tenant_id,
  c.property_id,
  c.id,
  c.is_primary_contact,
  coalesce(c.created_at, now())
from public.contacts c
where c.property_id is not null
on conflict (property_id, contact_id) do nothing;
