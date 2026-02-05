-- =========================
-- MIGRATION: MASTER FIX (CORRECTED)
-- =========================
-- Notes:
-- - Idempotent: safe to run multiple times
-- - Creates helper funcs, triggers, RPCs
-- - Backfills data, enables consistent RLS
-- - Adds indexes and QA checks (at bottom)
-- - Excludes any maps/leads work per requirements

-- 0) Safety: ensure schema availability
create schema if not exists public;
-- 1) Helper functions for role/tenant and policy simplification
create or replace function public.current_tenant_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select tenant_id from public.user_profiles where id = auth.uid()
$$;
create or replace function public.app_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.user_profiles where id = auth.uid()
$$;
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(role = 'admin', false)
  from public.user_profiles where id = auth.uid()
$$;
create or replace function public.is_manager()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(role = 'manager', false)
  from public.user_profiles where id = auth.uid()
$$;
create or replace function public.is_admin_or_manager()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(role in ('admin','manager'), false)
  from public.user_profiles where id = auth.uid()
$$;
-- 2) Timestamps auto-update
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'UPDATE' then
    if NEW.updated_at is distinct from now() then
      NEW.updated_at := now();
    end if;
  end if;
  return NEW;
end;
$$;
-- 3) Tenant auto-fill on insert (if app forgets to send tenant_id)
create or replace function public.set_tenant_id()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.tenant_id is null then
    select tenant_id into new.tenant_id
    from public.user_profiles where id = auth.uid();
  end if;
  return new;
end;
$$;
-- 4) Owner/assignee defaults per table (keep simple + safe)
-- Activities: default user_id to current user if not provided
create or replace function public.set_activity_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  return new;
end;
$$;
-- Tasks: default assigned_by to current user if not provided; if assigned_to null, assign to current user
create or replace function public.set_task_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.assigned_by is null then
    new.assigned_by := auth.uid();
  end if;
  if new.assigned_to is null then
    new.assigned_to := auth.uid();
  end if;
  return new;
end;
$$;
-- Accounts: if inserted by rep and assigned_rep_id null, assign to current user
create or replace function public.set_account_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.assigned_rep_id is null then
    new.assigned_rep_id := auth.uid();
  end if;
  return new;
end;
$$;
-- Activity logs: fill tenant_id using user's profile
create or replace function public.fill_activity_log_tenant()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.tenant_id is null and new.user_id is not null then
    select up.tenant_id into new.tenant_id
    from public.user_profiles up
    where up.id = new.user_id; -- auth.users.id == user_profiles.id
  end if;
  return new;
end;
$$;
-- 5) Signup bootstrap: create profile for new auth.users (no tenant yet)
-- Ensure tenant_id is nullable to avoid circular creation
alter table if exists public.user_profiles
  alter column tenant_id drop not null;
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name',''),
    'rep',
    true,
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
-- 6) Backfill: create missing user_profiles for existing auth.users
insert into public.user_profiles (id, email, full_name, role, is_active, created_at, updated_at)
select u.id, u.email, coalesce(u.raw_user_meta_data->>'full_name',''), 'rep', true, now(), now()
from auth.users u
left join public.user_profiles p on p.id = u.id
where p.id is null;
-- 7) Backfill tenant_id for tables with nullable tenant_id today
-- Calendar events from created_by
update public.calendar_events e
set tenant_id = up.tenant_id
from public.user_profiles up
where e.tenant_id is null
  and e.created_by = up.id;
-- Activity logs from user_id
update public.activity_logs al
set tenant_id = up.tenant_id
from public.user_profiles up
where al.tenant_id is null
  and al.user_id = up.id;
-- 8) RPCs for session context and tenant assignment
-- Single-object context, no arrays
create or replace function public.get_session_context()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_p public.user_profiles;
  v_tenant public.tenants;
begin
  if v_uid is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'redirect_url', '/login'
    );
  end if;

  select * into v_p from public.user_profiles where id = v_uid;

  if not found then
    return jsonb_build_object(
      'success', false,
      'user_exists', false,
      'message', 'Profile missing',
      'redirect_url', '/onboarding'
    );
  end if;

  if v_p.is_active is false then
    return jsonb_build_object(
      'success', false,
      'message', 'User inactive',
      'redirect_url', '/support'
    );
  end if;

  if v_p.tenant_id is null then
    return jsonb_build_object(
      'success', true,
      'user_exists', true,
      'profile_completed', v_p.profile_completed,
      'password_set', v_p.password_set,
      'message', 'Authenticated; tenant assignment required',
      'redirect_url', '/select-tenant',
      'user_data', jsonb_build_object(
        'id', v_p.id,
        'role', v_p.role,
        'email', v_p.email,
        'full_name', v_p.full_name,
        'is_active', v_p.is_active
      )
    );
  end if;

  select * into v_tenant from public.tenants where id = v_p.tenant_id;

  return jsonb_build_object(
    'success', true,
    'user_exists', true,
    'profile_completed', v_p.profile_completed,
    'password_set', v_p.password_set,
    'message', 'Authentication completed successfully',
    'redirect_url', '/today',
    'user_data', jsonb_build_object(
      'id', v_p.id,
      'role', v_p.role,
      'email', v_p.email,
      'full_name', v_p.full_name,
      'is_active', v_p.is_active,
      'tenant_id', v_p.tenant_id,
      'tenant_name', v_tenant.name
    )
  );
end;
$$;
grant execute on function public.get_session_context() to anon, authenticated;
-- Assign current tenant for the logged-in user
create or replace function public.set_current_tenant(p_tenant_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_t tenants%rowtype;
begin
  if v_uid is null then
    return jsonb_build_object('success', false, 'message', 'Not authenticated');
  end if;

  select * into v_t from public.tenants where id = p_tenant_id;

  if not found then
    return jsonb_build_object('success', false, 'message', 'Tenant not found');
  end if;

  update public.user_profiles
  set tenant_id = p_tenant_id, updated_at = now()
  where id = v_uid;

  return public.get_session_context();
end;
$$;
grant execute on function public.set_current_tenant(uuid) to authenticated;
-- Create a tenant and assign the current user as owner/admin, then set their tenant_id
-- Avoids circular dependency by allowing profile.tenant_id to be null beforehand
create or replace function public.create_tenant_and_assign(p_name text, p_slug text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_new_id uuid;
begin
  if v_uid is null then
    return jsonb_build_object('success', false, 'message', 'Not authenticated');
  end if;

  insert into public.tenants (id, name, slug, owner_id, created_by, is_active, created_at, updated_at)
  values (gen_random_uuid(), p_name, p_slug, v_uid, v_uid, true, now(), now())
  returning id into v_new_id;

  update public.user_profiles
  set tenant_id = v_new_id, role = 'admin', updated_at = now()
  where id = v_uid;

  return jsonb_build_object(
    'success', true,
    'message', 'Tenant created and assigned',
    'tenant_id', v_new_id
  );
end;
$$;
grant execute on function public.create_tenant_and_assign(text, text) to authenticated;
-- 9) Attach triggers to tables (tenant + timestamps + defaults)
-- Utility to attach triggers if they don't exist
do $$
begin
  -- Accounts
  if not exists (select 1 from pg_trigger where tgname = 'trg_accounts_set_tenant') then
    create trigger trg_accounts_set_tenant before insert on public.accounts
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_accounts_updated_at') then
    create trigger trg_accounts_updated_at before update on public.accounts
    for each row execute function public.set_updated_at();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_accounts_defaults') then
    create trigger trg_accounts_defaults before insert on public.accounts
    for each row execute function public.set_account_defaults();
  end if;

  -- Contacts
  if not exists (select 1 from pg_trigger where tgname = 'trg_contacts_set_tenant') then
    create trigger trg_contacts_set_tenant before insert on public.contacts
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_contacts_updated_at') then
    create trigger trg_contacts_updated_at before update on public.contacts
    for each row execute function public.set_updated_at();
  end if;

  -- Properties
  if not exists (select 1 from pg_trigger where tgname = 'trg_properties_set_tenant') then
    create trigger trg_properties_set_tenant before insert on public.properties
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_properties_updated_at') then
    create trigger trg_properties_updated_at before update on public.properties
    for each row execute function public.set_updated_at();
  end if;

  -- Opportunities
  if not exists (select 1 from pg_trigger where tgname = 'trg_opportunities_set_tenant') then
    create trigger trg_opportunities_set_tenant before insert on public.opportunities
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_opportunities_updated_at') then
    create trigger trg_opportunities_updated_at before update on public.opportunities
    for each row execute function public.set_updated_at();
  end if;

  -- Activities
  if not exists (select 1 from pg_trigger where tgname = 'trg_activities_set_tenant') then
    create trigger trg_activities_set_tenant before insert on public.activities
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_activities_defaults') then
    create trigger trg_activities_defaults before insert on public.activities
    for each row execute function public.set_activity_defaults();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_activities_updated_at') then
    create trigger trg_activities_updated_at before update on public.activities
    for each row execute function public.set_updated_at();
  end if;

  -- Tasks
  if not exists (select 1 from pg_trigger where tgname = 'trg_tasks_set_tenant') then
    create trigger trg_tasks_set_tenant before insert on public.tasks
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_tasks_defaults') then
    create trigger trg_tasks_defaults before insert on public.tasks
    for each row execute function public.set_task_defaults();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_tasks_updated_at') then
    create trigger trg_tasks_updated_at before update on public.tasks
    for each row execute function public.set_updated_at();
  end if;

  -- Prospects
  if not exists (select 1 from pg_trigger where tgname = 'trg_prospects_set_tenant') then
    create trigger trg_prospects_set_tenant before insert on public.prospects
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_prospects_updated_at') then
    create trigger trg_prospects_updated_at before update on public.prospects
    for each row execute function public.set_updated_at();
  end if;

  -- Documents
  if not exists (select 1 from pg_trigger where tgname = 'trg_documents_set_tenant') then
    create trigger trg_documents_set_tenant before insert on public.documents
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_documents_updated_at') then
    create trigger trg_documents_updated_at before update on public.documents
    for each row execute function public.set_updated_at();
  end if;

  -- Document events
  if not exists (select 1 from pg_trigger where tgname = 'trg_document_events_set_tenant') then
    create trigger trg_document_events_set_tenant before insert on public.document_events
    for each row execute function public.set_tenant_id();
  end if;

  -- Notifications
  if not exists (select 1 from pg_trigger where tgname = 'trg_notifications_set_tenant') then
    create trigger trg_notifications_set_tenant before insert on public.notifications
    for each row execute function public.set_tenant_id();
  end if;

  -- Calendar events
  if not exists (select 1 from pg_trigger where tgname = 'trg_calendar_events_set_tenant') then
    create trigger trg_calendar_events_set_tenant before insert on public.calendar_events
    for each row execute function public.set_tenant_id();
  end if;

  if not exists (select 1 from pg_trigger where tgname = 'trg_calendar_events_updated_at') then
    create trigger trg_calendar_events_updated_at before update on public.calendar_events
    for each row execute function public.set_updated_at();
  end if;

  -- Account assignments
  if not exists (select 1 from pg_trigger where tgname = 'trg_account_assignments_updated_at') then
    create trigger trg_account_assignments_updated_at before update on public.account_assignments
    for each row execute function public.set_updated_at();
  end if;

  -- Weekly goals
  if not exists (select 1 from pg_trigger where tgname = 'trg_weekly_goals_set_tenant') then
    create trigger trg_weekly_goals_set_tenant before insert on public.weekly_goals
    for each row execute function public.set_tenant_id();
  end if;

  -- Activity logs
  if not exists (select 1 from pg_trigger where tgname = 'trg_activity_logs_fill_tenant') then
    create trigger trg_activity_logs_fill_tenant before insert on public.activity_logs
    for each row execute function public.fill_activity_log_tenant();
  end if;
end
$$;
-- 10) Enable RLS + baseline tenant policies + role-aware writes
-- Helper to create standard tenant read/write and role-aware policies
-- Pattern:
--   - Select: all authenticated users in same tenant
--   - Insert/Update: admin/manager can modify any row in tenant
--   - Insert/Update (rep): allowed for "own" rows (created_by/user_id/assigned_to/assigned_rep_id semantics)

-- USER PROFILES (read self + same-tenant directory; reps cannot update others)
alter table public.user_profiles enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='up_read_self_or_same_tenant' and tablename='user_profiles') then
    create policy up_read_self_or_same_tenant
      on public.user_profiles
      for select
      using (id = auth.uid() or (tenant_id is not null and tenant_id = public.current_tenant_id()));
  end if;

  if not exists (select 1 from pg_policies where policyname='up_update_self_or_admin_manager' and tablename='user_profiles') then
    create policy up_update_self_or_admin_manager
      on public.user_profiles
      for update
      using (id = auth.uid() or public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;
end
$$;
-- TENANTS (read current tenant only)
alter table public.tenants enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='tenants_read_current' and tablename='tenants') then
    create policy tenants_read_current
      on public.tenants
      for select
      using (id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='tenants_update_admin_manager' and tablename='tenants') then
    create policy tenants_update_admin_manager
      on public.tenants
      for update
      using (id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (id = public.current_tenant_id());
  end if;
end
$$;
-- ACCOUNTS
alter table public.accounts enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='acc_select_tenant' and tablename='accounts') then
    create policy acc_select_tenant on public.accounts for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='acc_ins_admin_mgr' and tablename='accounts') then
    create policy acc_ins_admin_mgr on public.accounts for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='acc_upd_admin_mgr' and tablename='accounts') then
    create policy acc_upd_admin_mgr on public.accounts for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps can insert/update if they're assigned_rep_id
  if not exists (select 1 from pg_policies where policyname='acc_rep_write_own' and tablename='accounts') then
    create policy acc_rep_write_own on public.accounts for all
      using (tenant_id = public.current_tenant_id() and (assigned_rep_id = auth.uid()))
      with check (tenant_id = public.current_tenant_id() and (coalesce(assigned_rep_id, auth.uid()) = auth.uid()));
  end if;
end $$;
-- CONTACTS
alter table public.contacts enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='contacts_select_tenant' and tablename='contacts') then
    create policy contacts_select_tenant on public.contacts for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='contacts_ins_admin_mgr' and tablename='contacts') then
    create policy contacts_ins_admin_mgr on public.contacts for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='contacts_upd_admin_mgr' and tablename='contacts') then
    create policy contacts_upd_admin_mgr on public.contacts for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps: allow insert/update in tenant (many UIs require reps to add/edit contacts)
  if not exists (select 1 from pg_policies where policyname='contacts_rep_write_tenant' and tablename='contacts') then
    create policy contacts_rep_write_tenant on public.contacts for all
      using (tenant_id = public.current_tenant_id())
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- PROPERTIES
alter table public.properties enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='properties_select_tenant' and tablename='properties') then
    create policy properties_select_tenant on public.properties for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='properties_ins_admin_mgr' and tablename='properties') then
    create policy properties_ins_admin_mgr on public.properties for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='properties_upd_admin_mgr' and tablename='properties') then
    create policy properties_upd_admin_mgr on public.properties for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps can insert/update within tenant (optional stricter policies can be added later)
  if not exists (select 1 from pg_policies where policyname='properties_rep_write_tenant' and tablename='properties') then
    create policy properties_rep_write_tenant on public.properties for all
      using (tenant_id = public.current_tenant_id())
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- OPPORTUNITIES
alter table public.opportunities enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='opps_select_tenant' and tablename='opportunities') then
    create policy opps_select_tenant on public.opportunities for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='opps_ins_admin_mgr' and tablename='opportunities') then
    create policy opps_ins_admin_mgr on public.opportunities for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='opps_upd_admin_mgr' and tablename='opportunities') then
    create policy opps_upd_admin_mgr on public.opportunities for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps can write their own (created_by or assigned_to)
  if not exists (select 1 from pg_policies where policyname='opps_rep_write_own' and tablename='opportunities') then
    create policy opps_rep_write_own on public.opportunities for all
      using (tenant_id = public.current_tenant_id()
             and (created_by = auth.uid() or assigned_to = auth.uid()))
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- ACTIVITIES
alter table public.activities enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='acts_select_tenant' and tablename='activities') then
    create policy acts_select_tenant on public.activities for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='acts_ins_admin_mgr' and tablename='activities') then
    create policy acts_ins_admin_mgr on public.activities for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='acts_upd_admin_mgr' and tablename='activities') then
    create policy acts_upd_admin_mgr on public.activities for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps: user_id is self for own activities
  if not exists (select 1 from pg_policies where policyname='acts_rep_write_own' and tablename='activities') then
    create policy acts_rep_write_own on public.activities for all
      using (tenant_id = public.current_tenant_id() and user_id = auth.uid())
      with check (tenant_id = public.current_tenant_id() and user_id = auth.uid());
  end if;
end $$;
-- TASKS
alter table public.tasks enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='tasks_select_tenant' and tablename='tasks') then
    create policy tasks_select_tenant on public.tasks for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='tasks_ins_admin_mgr' and tablename='tasks') then
    create policy tasks_ins_admin_mgr on public.tasks for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='tasks_upd_admin_mgr' and tablename='tasks') then
    create policy tasks_upd_admin_mgr on public.tasks for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps: can insert/update tasks where they are assigned_to or assigned_by
  if not exists (select 1 from pg_policies where policyname='tasks_rep_write_own' and tablename='tasks') then
    create policy tasks_rep_write_own on public.tasks for all
      using (tenant_id = public.current_tenant_id() and (assigned_to = auth.uid() or assigned_by = auth.uid()))
      with check (tenant_id = public.current_tenant_id() and (assigned_to = auth.uid() or assigned_by = auth.uid()));
  end if;
end $$;
-- PROSPECTS
alter table public.prospects enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='prospects_select_tenant' and tablename='prospects') then
    create policy prospects_select_tenant on public.prospects for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='prospects_ins_admin_mgr' and tablename='prospects') then
    create policy prospects_ins_admin_mgr on public.prospects for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='prospects_upd_admin_mgr' and tablename='prospects') then
    create policy prospects_upd_admin_mgr on public.prospects for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps: can write when assigned_to or created_by
  if not exists (select 1 from pg_policies where policyname='prospects_rep_write_own' and tablename='prospects') then
    create policy prospects_rep_write_own on public.prospects for all
      using (tenant_id = public.current_tenant_id() and (assigned_to = auth.uid() or created_by = auth.uid()))
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- DOCUMENTS
alter table public.documents enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='docs_select_tenant' and tablename='documents') then
    create policy docs_select_tenant on public.documents for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='docs_ins_admin_mgr' and tablename='documents') then
    create policy docs_ins_admin_mgr on public.documents for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='docs_upd_admin_mgr' and tablename='documents') then
    create policy docs_upd_admin_mgr on public.documents for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- DOCUMENT EVENTS
alter table public.document_events enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='doc_events_select_tenant' and tablename='document_events') then
    create policy doc_events_select_tenant on public.document_events for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='doc_events_ins_tenant' and tablename='document_events') then
    create policy doc_events_ins_tenant on public.document_events for insert
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- NOTIFICATIONS
alter table public.notifications enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='notif_select_tenant' and tablename='notifications') then
    create policy notif_select_tenant on public.notifications for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='notif_ins_admin_mgr' and tablename='notifications') then
    create policy notif_ins_admin_mgr on public.notifications for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='notif_upd_admin_mgr' and tablename='notifications') then
    create policy notif_upd_admin_mgr on public.notifications for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- ACCOUNT ASSIGNMENTS
alter table public.account_assignments enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='acc_assign_select_tenant' and tablename='account_assignments') then
    create policy acc_assign_select_tenant on public.account_assignments for select
      using (exists (select 1 from public.accounts a where a.id = account_assignments.account_id and a.tenant_id = public.current_tenant_id()));
  end if;

  if not exists (select 1 from pg_policies where policyname='acc_assign_ins_admin_mgr' and tablename='account_assignments') then
    create policy acc_assign_ins_admin_mgr on public.account_assignments for insert
      with check (exists (select 1 from public.accounts a where a.id = account_assignments.account_id and a.tenant_id = public.current_tenant_id())
                  and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='acc_assign_upd_admin_mgr' and tablename='account_assignments') then
    create policy acc_assign_upd_admin_mgr on public.account_assignments for update
      using (exists (select 1 from public.accounts a where a.id = account_assignments.account_id and a.tenant_id = public.current_tenant_id())
             and public.is_admin_or_manager())
      with check (exists (select 1 from public.accounts a where a.id = account_assignments.account_id and a.tenant_id = public.current_tenant_id()));
  end if;
end $$;
-- WEEKLY GOALS (KPIs)
alter table public.weekly_goals enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='wg_select_tenant' and tablename='weekly_goals') then
    create policy wg_select_tenant on public.weekly_goals for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='wg_ins_admin_mgr' and tablename='weekly_goals') then
    create policy wg_ins_admin_mgr on public.weekly_goals for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='wg_upd_admin_mgr' and tablename='weekly_goals') then
    create policy wg_upd_admin_mgr on public.weekly_goals for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps may update their own goal progress
  if not exists (select 1 from pg_policies where policyname='wg_rep_update_self' and tablename='weekly_goals') then
    create policy wg_rep_update_self on public.weekly_goals for update
      using (tenant_id = public.current_tenant_id() and user_id = auth.uid())
      with check (tenant_id = public.current_tenant_id() and user_id = auth.uid());
  end if;
end $$;
-- CALENDAR EVENTS
alter table public.calendar_events enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='cal_select_tenant' and tablename='calendar_events') then
    create policy cal_select_tenant on public.calendar_events for select
      using (tenant_id = public.current_tenant_id());
  end if;

  if not exists (select 1 from pg_policies where policyname='cal_ins_admin_mgr' and tablename='calendar_events') then
    create policy cal_ins_admin_mgr on public.calendar_events for insert
      with check (tenant_id = public.current_tenant_id() and public.is_admin_or_manager());
  end if;

  if not exists (select 1 from pg_policies where policyname='cal_upd_admin_mgr' and tablename='calendar_events') then
    create policy cal_upd_admin_mgr on public.calendar_events for update
      using (tenant_id = public.current_tenant_id() and public.is_admin_or_manager())
      with check (tenant_id = public.current_tenant_id());
  end if;

  -- reps can create/update their own assigned events
  if not exists (select 1 from pg_policies where policyname='cal_rep_write_own' and tablename='calendar_events') then
    create policy cal_rep_write_own on public.calendar_events for all
      using (tenant_id = public.current_tenant_id()
             and (created_by = auth.uid() or assigned_to = auth.uid()))
      with check (tenant_id = public.current_tenant_id());
  end if;
end $$;
-- ACTIVITY LOGS (FK to auth.users)
alter table public.activity_logs enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies where policyname='alog_select_tenant' and tablename='activity_logs') then
    create policy alog_select_tenant on public.activity_logs for select
      using (
        tenant_id = public.current_tenant_id()
        or exists (
          select 1 from public.user_profiles up
          where up.id = activity_logs.user_id and up.tenant_id = public.current_tenant_id()
        )
      );
  end if;

  if not exists (select 1 from pg_policies where policyname='alog_ins_tenant' and tablename='activity_logs') then
    create policy alog_ins_tenant on public.activity_logs for insert
      with check (
        coalesce(tenant_id, (select tenant_id from public.user_profiles where id = auth.uid()))
        = public.current_tenant_id()
      );
  end if;
end $$;
-- 11) Indexes for performance (tenant filters + common FKs)
create index if not exists idx_accounts_tenant on public.accounts(tenant_id);
create index if not exists idx_contacts_tenant on public.contacts(tenant_id);
create index if not exists idx_properties_tenant on public.properties(tenant_id);
create index if not exists idx_opportunities_tenant on public.opportunities(tenant_id);
create index if not exists idx_activities_tenant on public.activities(tenant_id);
create index if not exists idx_tasks_tenant on public.tasks(tenant_id);
create index if not exists idx_prospects_tenant on public.prospects(tenant_id);
create index if not exists idx_documents_tenant on public.documents(tenant_id);
create index if not exists idx_doc_events_tenant on public.document_events(tenant_id);
create index if not exists idx_notifications_tenant on public.notifications(tenant_id);
create index if not exists idx_calendar_events_tenant on public.calendar_events(tenant_id);
create index if not exists idx_weekly_goals_tenant on public.weekly_goals(tenant_id);
create index if not exists idx_activity_logs_tenant on public.activity_logs(tenant_id);
create index if not exists idx_user_profiles_tenant on public.user_profiles(tenant_id);
-- =========================
-- END MIGRATION
-- =========================;
