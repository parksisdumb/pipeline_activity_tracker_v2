-- 20250102165959_bootstrap_activity_enums.sql
-- Purpose: ensure required enums exist before earlier migrations attempt to ALTER them.
-- This is safe to run even if enums already exist.

DO $$
BEGIN
  -- activity_type
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'activity_type'
  ) THEN
    CREATE TYPE public.activity_type AS ENUM (
      'Phone Call',
      'Email',
      'Meeting',
      'Site Visit',
      'Proposal Sent',
      'Follow-up',
      'Assessment',
      'Contract Signed'
    );
  END IF;

  -- activity_outcome
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public'
      AND t.typname = 'activity_outcome'
  ) THEN
    CREATE TYPE public.activity_outcome AS ENUM (
      'Successful',
      'No Answer',
      'Callback Requested',
      'Not Interested',
      'Interested',
      'Proposal Requested',
      'Meeting Scheduled',
      'Contract Signed'
    );
  END IF;
END $$;
