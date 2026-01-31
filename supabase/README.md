Supabase Migration Policy
=========================

This repo uses the migrations in `supabase/migrations/` as the single source of truth.

Rules
-----
- Do not edit or delete existing migrations that have been applied to remote.
- Add new migrations for changes.
- If a migration is superseded, move it to `supabase/migrations_OLD/` (kept out of the active migration path).
- Keep migration filenames unique and time-ordered.
- Avoid duplicate version numbers.

Baseline
--------
- `20260201_baseline_schema.sql` represents a snapshot of the remote schema.
- It must remain in `supabase/migrations/` so local and remote history stay aligned.

Workflow
--------
1. Pull latest `origin/main`.
2. Create a new migration for any schema change.
3. Run `supabase migration list` to confirm alignment.
4. Run `supabase db diff` (fix any migration ordering issues if it fails).
5. Run `supabase db push` to apply to remote.

Notes
-----
- Backup migrations live under `supabase/migrations_OLD/` and are ignored by git.
