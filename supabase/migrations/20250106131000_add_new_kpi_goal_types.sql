-- Location: supabase/migrations/20250106131000_add_new_kpi_goal_types.sql
-- Schema Analysis: Extending existing goals system to support additional KPI types  
-- Integration Type: Extension - Adding new goal types to existing system
-- Dependencies: existing weekly_goals table, existing goal_type constraints

-- CRITICAL FIX: Drop the specific constraint that's causing the violation
-- Based on the error "check_weekly_goals_goal_type", this is the exact constraint name
DO $$
BEGIN
    -- Step 1: Drop the existing check constraint that's blocking the new values
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_schema = 'public' 
        AND constraint_name = 'check_weekly_goals_goal_type'
    ) THEN
        ALTER TABLE public.weekly_goals DROP CONSTRAINT check_weekly_goals_goal_type;
        RAISE NOTICE 'Dropped existing check_weekly_goals_goal_type constraint';
    END IF;

    -- Step 2: Also try alternative constraint name patterns
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_schema = 'public' 
        AND constraint_name LIKE '%goal_type%'
    ) THEN
        -- Drop any other goal_type related constraints
        ALTER TABLE public.weekly_goals DROP CONSTRAINT IF EXISTS weekly_goals_goal_type_check;
        ALTER TABLE public.weekly_goals DROP CONSTRAINT IF EXISTS weekly_goals_goal_type_constraint; 
        RAISE NOTICE 'Dropped additional goal type constraints';
    END IF;
END $$;

-- Step 3: Create new check constraint with all goal types including the new ones
DO $$
BEGIN
    -- Add new comprehensive check constraint that includes all goal types
    ALTER TABLE public.weekly_goals ADD CONSTRAINT check_weekly_goals_goal_type 
        CHECK (goal_type IN (
            'pop_ins',
            'dm_conversations',
            'assessments_booked', 
            'proposals_sent',
            'wins',
            'phone_calls_made',
            'emails_sent',
            'follow_ups_completed'
        ));
    RAISE NOTICE 'Added updated check constraint with new KPI types';
END $$;

-- Step 4: Handle enum type creation/extension if it exists
DO $$
BEGIN
    -- Try to extend existing enum with new types
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'kpi_type') THEN
        -- Add new values to existing enum if they don't already exist
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'phone_calls_made' AND enumtypid = 'public.kpi_type'::regtype) THEN
            ALTER TYPE public.kpi_type ADD VALUE 'phone_calls_made';
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'emails_sent' AND enumtypid = 'public.kpi_type'::regtype) THEN
            ALTER TYPE public.kpi_type ADD VALUE 'emails_sent';
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'follow_ups_completed' AND enumtypid = 'public.kpi_type'::regtype) THEN
            ALTER TYPE public.kpi_type ADD VALUE 'follow_ups_completed';
        END IF;
        
        RAISE NOTICE 'Extended existing kpi_type enum with new values';
    ELSE
        RAISE NOTICE 'No kpi_type enum found, using check constraint approach';
    END IF;
EXCEPTION
    WHEN undefined_object THEN
        RAISE NOTICE 'kpi_type enum does not exist, using check constraint only';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error handling enum: %, continuing with check constraint', SQLERRM;
END $$;

-- Step 5: Add sample goals for the new KPI types (AFTER constraint fix)
DO $$
DECLARE
    existing_user_id UUID;
    current_week_start DATE;
BEGIN
    -- Get current week start (Sunday)  
    current_week_start := date_trunc('week', CURRENT_DATE);
    
    -- Get an existing user ID from user_profiles if available
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    -- If we have an existing user, add sample goals for the new KPI types
    IF existing_user_id IS NOT NULL THEN
        -- Check if weekly_goals table exists before inserting
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'weekly_goals') THEN
            -- Insert goals for new KPI types for demonstration
            -- FIXED: Use correct column name 'week_start_date' and ensure constraint allows new values
            INSERT INTO public.weekly_goals (user_id, week_start_date, goal_type, target_value, current_value)
            VALUES 
                (existing_user_id, current_week_start, 'phone_calls_made', 20, 0),
                (existing_user_id, current_week_start, 'emails_sent', 15, 0),
                (existing_user_id, current_week_start, 'follow_ups_completed', 10, 0)
            ON CONFLICT (user_id, week_start_date, goal_type) DO NOTHING; -- Avoid duplicates
            
            RAISE NOTICE 'Added sample goals for new KPI types for user %', existing_user_id;
        ELSE
            RAISE NOTICE 'weekly_goals table not found';
        END IF;
    ELSE
        RAISE NOTICE 'No existing users found. New KPI types are ready for use when users are created.';
    END IF;
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Check constraint violation: %, the constraint may still need updating', SQLERRM;
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %, check user_profiles table', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error in sample data: %', SQLERRM;
END $$;

-- Step 6: Final validation
DO $$
BEGIN
    -- Verify the constraint was updated successfully
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_schema = 'public' 
        AND constraint_name = 'check_weekly_goals_goal_type'
    ) THEN
        RAISE NOTICE 'SUCCESS: Updated check constraint is in place';
    ELSE
        RAISE NOTICE 'WARNING: No check constraint found, table may use enum or different constraint name';
    END IF;
    
    RAISE NOTICE 'Migration completed: Added phone_calls_made, emails_sent, and follow_ups_completed KPI types';
    RAISE NOTICE 'Frontend components can now use these new goal types in weekly goals tracking';
END $$;