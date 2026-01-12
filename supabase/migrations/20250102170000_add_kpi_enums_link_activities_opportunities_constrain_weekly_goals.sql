-- Schema Analysis: Existing CRM system with activities, opportunities, and weekly_goals tables
-- Integration Type: Extension - Adding new enum values, foreign key relationship, and constraints
-- Dependencies: activities, opportunities, weekly_goals, activity_type, activity_outcome enums

-- =========================================================
-- Step 1: Add new enum values to existing activity_type enum (idempotent)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public' AND t.typname = 'activity_type'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_enum e
      JOIN pg_type t ON t.oid = e.enumtypid
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE n.nspname = 'public'
        AND t.typname = 'activity_type'
        AND e.enumlabel = 'Pop-in'
    ) THEN
      ALTER TYPE public.activity_type ADD VALUE IF NOT EXISTS 'Pop-in';
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM pg_enum e
      JOIN pg_type t ON t.oid = e.enumtypid
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE n.nspname = 'public'
        AND t.typname = 'activity_type'
        AND e.enumlabel = 'Decision Maker Conversation'
    ) THEN
      ALTER TYPE public.activity_type ADD VALUE 'Decision Maker Conversation';
    END IF;
  ELSE
    RAISE NOTICE 'Skipping: public.activity_type does not exist yet';
  END IF;
END $$;

-- =========================================================
-- Step 2: Add new enum value to existing activity_outcome enum (idempotent)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'public' AND t.typname = 'activity_outcome'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_enum e
      JOIN pg_type t ON t.oid = e.enumtypid
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE n.nspname = 'public'
        AND t.typname = 'activity_outcome'
        AND e.enumlabel = 'Assessment Completed'
    ) THEN
      ALTER TYPE public.activity_outcome ADD VALUE 'Assessment Completed';
    END IF;
  ELSE
    RAISE NOTICE 'Skipping: public.activity_outcome does not exist yet';
  END IF;
END $$;

-- =========================================================
-- Step 3: Add opportunity_id column to activities table (idempotent)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'activities'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'activities'
        AND column_name = 'opportunity_id'
    ) THEN
      ALTER TABLE public.activities
      ADD COLUMN opportunity_id UUID NULL;
    END IF;

    -- Add FK only if opportunities table exists AND FK not already present
    IF EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'opportunities'
    ) THEN
      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'activities_opportunity_id_fkey'
      ) THEN
        ALTER TABLE public.activities
        ADD CONSTRAINT activities_opportunity_id_fkey
        FOREIGN KEY (opportunity_id)
        REFERENCES public.opportunities(id)
        ON DELETE SET NULL;
      END IF;
    ELSE
      RAISE NOTICE 'Skipping FK: public.opportunities does not exist yet';
    END IF;

  ELSE
    RAISE NOTICE 'Skipping: public.activities does not exist yet';
  END IF;
END $$;

-- =========================================================
-- Step 4: Add indexes for performance optimization (idempotent)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema='public' AND table_name='activities'
  ) THEN
    -- activities(opportunity_id, activity_date DESC)
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_activities_opportunity_id_activity_date ON public.activities(opportunity_id, activity_date DESC)';

    -- activities(user_id, activity_date DESC)
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_activities_user_id_activity_date ON public.activities(user_id, activity_date DESC)';

    -- activities(follow_up_date)
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_activities_follow_up_date ON public.activities(follow_up_date)';
  END IF;
END $$;

-- =========================================================
-- Step 5: Handle duplicate resolution before applying KPI constraint
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema='public' AND table_name='weekly_goals'
  ) THEN

    -- Create temporary table to store consolidated data before updating
    CREATE TEMP TABLE weekly_goals_consolidated AS
    SELECT DISTINCT ON (user_id, week_start_date, new_goal_type)
        user_id,
        week_start_date,
        CASE
            WHEN goal_type IN ('calls', 'emails') THEN 'dm_conversations'
            WHEN goal_type = 'assessments' THEN 'assessments_booked'
            WHEN goal_type = 'proposals' THEN 'proposals_sent'
            WHEN goal_type = 'wins' THEN 'wins'
            WHEN goal_type = 'pop_ins' THEN 'pop_ins'
            WHEN goal_type = 'dm_conversations' THEN 'dm_conversations'
            WHEN goal_type = 'assessments_booked' THEN 'assessments_booked'
            WHEN goal_type = 'proposals_sent' THEN 'proposals_sent'
            ELSE 'dm_conversations'
        END as new_goal_type,
        (array_agg(id ORDER BY created_at))[1] as keep_id,
        SUM(target_value) OVER (
          PARTITION BY user_id, week_start_date,
            CASE
              WHEN goal_type IN ('calls', 'emails') THEN 'dm_conversations'
              WHEN goal_type = 'assessments' THEN 'assessments_booked'
              WHEN goal_type = 'proposals' THEN 'proposals_sent'
              WHEN goal_type = 'wins' THEN 'wins'
              WHEN goal_type = 'pop_ins' THEN 'pop_ins'
              WHEN goal_type = 'dm_conversations' THEN 'dm_conversations'
              WHEN goal_type = 'assessments_booked' THEN 'assessments_booked'
              WHEN goal_type = 'proposals_sent' THEN 'proposals_sent'
              ELSE 'dm_conversations'
            END
        ) as combined_target_value,
        SUM(current_value) OVER (
          PARTITION BY user_id, week_start_date,
            CASE
              WHEN goal_type IN ('calls', 'emails') THEN 'dm_conversations'
              WHEN goal_type = 'assessments' THEN 'assessments_booked'
              WHEN goal_type = 'proposals' THEN 'proposals_sent'
              WHEN goal_type = 'wins' THEN 'wins'
              WHEN goal_type = 'pop_ins' THEN 'pop_ins'
              WHEN goal_type = 'dm_conversations' THEN 'dm_conversations'
              WHEN goal_type = 'assessments_booked' THEN 'assessments_booked'
              WHEN goal_type = 'proposals_sent' THEN 'proposals_sent'
              ELSE 'dm_conversations'
            END
        ) as combined_current_value
    FROM public.weekly_goals
    GROUP BY user_id, week_start_date, goal_type, id, target_value, current_value, created_at;

    DELETE FROM public.weekly_goals;

    INSERT INTO public.weekly_goals (id, user_id, week_start_date, goal_type, target_value, current_value)
    SELECT
        keep_id,
        user_id,
        week_start_date,
        new_goal_type,
        combined_target_value,
        combined_current_value
    FROM weekly_goals_consolidated;

    RAISE NOTICE 'Successfully consolidated duplicate weekly goals records';
  ELSE
    RAISE NOTICE 'Skipping: public.weekly_goals does not exist yet';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error during weekly goals consolidation: %', SQLERRM;
    RAISE;
END $$;

-- =========================================================
-- Step 6: Add CHECK constraint to weekly_goals table (idempotent)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema='public' AND table_name='weekly_goals'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'check_weekly_goals_goal_type'
    ) THEN
      ALTER TABLE public.weekly_goals
      ADD CONSTRAINT check_weekly_goals_goal_type
      CHECK (goal_type IN ('pop_ins', 'dm_conversations', 'assessments_booked', 'proposals_sent', 'wins'));
    END IF;
  END IF;
END $$;

-- =========================================================
-- Step 7: Add sample activities (idempotent-ish + safe guards)
-- =========================================================
DO $$
DECLARE
    opportunity_id UUID;
    user_id UUID;
    tenant_id UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='activities') THEN
    RAISE NOTICE 'Skipping sample activities: public.activities does not exist';
    RETURN;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='opportunities') THEN
    RAISE NOTICE 'Skipping sample activities: public.opportunities does not exist';
    RETURN;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='user_profiles') THEN
    RAISE NOTICE 'Skipping sample activities: public.user_profiles does not exist';
    RETURN;
  END IF;

  -- ensure the enum labels exist before inserting sample rows
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname='public' AND t.typname='activity_type' AND e.enumlabel='Pop-in'
  ) THEN
    RAISE NOTICE 'Skipping sample activities: activity_type Pop-in not available';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname='public' AND t.typname='activity_type' AND e.enumlabel='Decision Maker Conversation'
  ) THEN
    RAISE NOTICE 'Skipping sample activities: activity_type Decision Maker Conversation not available';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname='public' AND t.typname='activity_outcome' AND e.enumlabel='Assessment Completed'
  ) THEN
    RAISE NOTICE 'Skipping sample activities: activity_outcome Assessment Completed not available';
    RETURN;
  END IF;

  SELECT id INTO opportunity_id FROM public.opportunities LIMIT 1;
  SELECT id INTO user_id FROM public.user_profiles LIMIT 1;

  IF opportunity_id IS NULL OR user_id IS NULL THEN
    RAISE NOTICE 'No existing opportunities or users found. Sample data not added.';
    RETURN;
  END IF;

  SELECT tenant_id INTO tenant_id FROM public.user_profiles WHERE id = user_id;

  IF tenant_id IS NULL THEN
    RAISE NOTICE 'No tenant_id found for sample user. Sample data not added.';
    RETURN;
  END IF;

  -- Pop-in sample (avoid duplicates by subject match)
  IF NOT EXISTS (
    SELECT 1
    FROM public.activities
    WHERE subject = 'Unexpected property visit - Assessment opportunity'
  ) THEN
    INSERT INTO public.activities (
      id, user_id, tenant_id, opportunity_id, activity_type, outcome,
      subject, activity_date, notes, description
    ) VALUES (
      gen_random_uuid(),
      user_id,
      tenant_id,
      opportunity_id,
      'Pop-in'::public.activity_type,
      'Assessment Completed'::public.activity_outcome,
      'Unexpected property visit - Assessment opportunity',
      NOW(),
      'Conducted impromptu assessment during pop-in visit. Property manager was very receptive.',
      'Pop-in visit that led to immediate assessment scheduling'
    );
  END IF;

  -- DM Conversation sample
  IF NOT EXISTS (
    SELECT 1
    FROM public.activities
    WHERE subject = 'Direct conversation with facility manager'
  ) THEN
    INSERT INTO public.activities (
      id, user_id, tenant_id, opportunity_id, activity_type, outcome,
      subject, activity_date, notes, description
    ) VALUES (
      gen_random_uuid(),
      user_id,
      tenant_id,
      opportunity_id,
      'Decision Maker Conversation'::public.activity_type,
      'Interested'::public.activity_outcome,
      'Direct conversation with facility manager',
      NOW() - INTERVAL '1 day',
      'Had productive conversation with the decision maker about roofing needs.',
      'Direct access to key decision maker resulted in positive interest'
    );
  END IF;

  RAISE NOTICE 'Sample activities added (if they did not already exist)';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error adding sample data: %', SQLERRM;
    RAISE;
END $$;

-- =========================================================
-- Step 8: Add comment for documentation (safe)
-- =========================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='activities' AND column_name='opportunity_id'
  ) THEN
    COMMENT ON COLUMN public.activities.opportunity_id IS 'Links activity to specific opportunity for better tracking and reporting';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'check_weekly_goals_goal_type'
  ) THEN
    COMMENT ON CONSTRAINT check_weekly_goals_goal_type ON public.weekly_goals IS 'Ensures weekly goals only use predefined KPI keys: pop_ins, dm_conversations, assessments_booked, proposals_sent, wins';
  END IF;
END $$;
