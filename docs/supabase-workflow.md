# Supabase Local and Remote Workflow

This project develops against the local Supabase stack and later pushes migrations to the linked
remote project. The remote link is stored in `supabase/.temp/project-ref` (local-only; do not
commit). The `supabase/config.toml` `project_id` is just a local container name and does not need
to match the remote project ref.

## Daily local workflow

1) Start or confirm local services:
   - `supabase start`
   - `supabase status`

2) Make schema changes locally (SQL or via Studio):
   - Use migrations to record every schema change.

3) Verify migrations apply cleanly:
   - `supabase db reset` (rebuilds local DB and replays migrations)

## Creating migrations

Pick one approach and stick to it:

- Manual SQL:
  - `supabase migration new <name>`
  - Edit the new file in `supabase/migrations/`

- Diff-based (after changing the local DB):
  - `supabase db diff -f <name>`

Always commit migration files to git.

## Sync from remote (if it changed outside migrations)

If someone applied changes in the Supabase dashboard or another branch:
- `supabase db pull` to generate a migration that captures remote changes.
- `supabase db reset` to re-apply locally.

## Push to remote

When ready to deploy DB changes:
1) Ensure local is clean and consistent:
   - `supabase db reset`
   - `supabase migration list` shows Local == Remote
2) Push migrations to the linked remote:
   - `supabase db push`
3) Push git changes (migrations + app code).

## Quick checks

- Linked project ref: `supabase/.temp/project-ref`
- Verify linked remote: `supabase projects list`
