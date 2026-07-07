-- Align schema with application expectations for exam attempts and responses

-- 1. Create user_exam_attempts table (idempotent)
CREATE TABLE IF NOT EXISTS public.user_exam_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  exam_id uuid NOT NULL,
  course_id uuid NOT NULL,
  question_count integer NOT NULL,
  started_at timestamp without time zone NOT NULL DEFAULT NOW(),
  completed_at timestamp without time zone,
  duration_seconds integer,
  total_score numeric(6,2),
  percentage_score numeric(5,2),
  status text NOT NULL DEFAULT 'in_progress',
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  CONSTRAINT user_exam_attempts_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.user (id) ON DELETE CASCADE,
  CONSTRAINT user_exam_attempts_exam_id_fkey FOREIGN KEY (exam_id)
    REFERENCES public.exam (id) ON DELETE CASCADE,
  CONSTRAINT user_exam_attempts_course_id_fkey FOREIGN KEY (course_id)
    REFERENCES public.course (id) ON DELETE CASCADE
);

-- Ensure indexes for frequent lookups
CREATE INDEX IF NOT EXISTS idx_user_exam_attempts_user
  ON public.user_exam_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_exam_attempts_exam
  ON public.user_exam_attempts(exam_id);
CREATE INDEX IF NOT EXISTS idx_user_exam_attempts_course
  ON public.user_exam_attempts(course_id);
CREATE INDEX IF NOT EXISTS idx_user_exam_attempts_status
  ON public.user_exam_attempts(status);

-- 2. Ensure user responses table matches expected structure
DO $$
DECLARE
  responses_table text;
BEGIN
  -- Determine current table name (legacy: userresponse, new: user_responses)
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'userresponse'
  ) THEN
    responses_table := 'userresponse';
  ELSIF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'user_responses'
  ) THEN
    responses_table := 'user_responses';
  END IF;

  IF responses_table IS NULL THEN
    -- Nothing to do if the table doesn't exist yet
    RETURN;
  END IF;

  -- Rename legacy columns when present
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = responses_table
      AND column_name = 'id_exam'
  ) THEN
    EXECUTE format('ALTER TABLE public.%I RENAME COLUMN id_exam TO exam_id;', responses_table);
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = responses_table
      AND column_name = 'id_question'
  ) THEN
    EXECUTE format('ALTER TABLE public.%I RENAME COLUMN id_question TO question_id;', responses_table);
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = responses_table
      AND column_name = 'id_answerchoice'
  ) THEN
    EXECUTE format('ALTER TABLE public.%I RENAME COLUMN id_answerchoice TO answer_choice_id;', responses_table);
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = responses_table
      AND column_name = 'selected_letter'
  ) THEN
    EXECUTE format('ALTER TABLE public.%I RENAME COLUMN selected_letter TO selected_choice_key;', responses_table);
  END IF;

  -- Ensure attempt_id column exists
  EXECUTE format(
    'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS attempt_id uuid;',
    responses_table
  );

  -- Ensure created_at column exists with default
  EXECUTE format(
    'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS created_at timestamp without time zone NOT NULL DEFAULT NOW();',
    responses_table
  );

  -- Rename table to snake_case plural if still legacy
  IF responses_table = 'userresponse' THEN
    ALTER TABLE public.userresponse RENAME TO user_responses;
    responses_table := 'user_responses';
  END IF;

  -- Add foreign keys (ignore if already present)
  BEGIN
    EXECUTE '
      ALTER TABLE public.' || responses_table || '
      ADD CONSTRAINT user_responses_attempt_id_fkey
      FOREIGN KEY (attempt_id)
      REFERENCES public.user_exam_attempts(id)
      ON DELETE CASCADE;';
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  BEGIN
    EXECUTE '
      ALTER TABLE public.' || responses_table || '
      ADD CONSTRAINT user_responses_question_id_fkey
      FOREIGN KEY (question_id)
      REFERENCES public.question(id)
      ON DELETE CASCADE;';
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  BEGIN
    EXECUTE '
      ALTER TABLE public.' || responses_table || '
      ADD CONSTRAINT user_responses_answer_choice_id_fkey
      FOREIGN KEY (answer_choice_id)
      REFERENCES public.answerchoice(id)
      ON DELETE SET NULL;';
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  BEGIN
    EXECUTE '
      ALTER TABLE public.' || responses_table || '
      ADD CONSTRAINT user_responses_exam_id_fkey
      FOREIGN KEY (exam_id)
      REFERENCES public.exam(id)
      ON DELETE CASCADE;';
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Add useful indexes
  EXECUTE '
    CREATE INDEX IF NOT EXISTS idx_user_responses_attempt
    ON public.' || responses_table || '(attempt_id);';

  EXECUTE '
    CREATE INDEX IF NOT EXISTS idx_user_responses_question
    ON public.' || responses_table || '(question_id);';

  EXECUTE '
    CREATE INDEX IF NOT EXISTS idx_user_responses_answer_choice
    ON public.' || responses_table || '(answer_choice_id);';

  EXECUTE '
    CREATE UNIQUE INDEX IF NOT EXISTS idx_user_responses_attempt_question
    ON public.' || responses_table || '(attempt_id, question_id);';

  -- Remove legacy composite index that no longer matches the schema
  IF EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public' AND indexname = 'idx_userresponse_unique'
  ) THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_userresponse_unique;';
  END IF;
END
$$;
