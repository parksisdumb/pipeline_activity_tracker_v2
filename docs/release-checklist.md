# Release checklist (Supabase + Git)

Use this when you are ready to push schema changes and app updates.

## Pre-flight

- `supabase status` is running locally.
- `supabase migration list` shows Local == Remote.
- `supabase db reset` succeeds locally.

## Database

1) If remote changed outside migrations:
   - `supabase db pull`
   - `supabase db reset`
2) Generate migrations for new local changes:
   - `supabase db diff -f <name>` or `supabase migration new <name>`
3) Verify migrations apply cleanly:
   - `supabase db reset`
4) Push migrations to remote:
   - `supabase db push`

## App + Git

1) Run app checks as needed (tests/build/lint).
2) Commit app changes + migration files.
3) Push git changes.

## Post-push

- Re-run `supabase migration list` to confirm alignment.
- Spot check the app against the remote project if needed.
