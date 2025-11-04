-- Align exam table with application expectations
-- Adds metadata columns, normalizes timestamps, and relaxes legacy constraints

-- 1. Rename legacy update column when present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'exam'
      AND column_name = 'update_at'
  ) THEN
    ALTER TABLE public.exam RENAME COLUMN update_at TO updated_at;
  END IF;
END $$;

-- 2. Ensure timestamp defaults and non-null safety
ALTER TABLE public.exam
  ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE public.exam
  ALTER COLUMN updated_at SET DEFAULT NOW();

UPDATE public.exam
SET created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, created_at, NOW());

ALTER TABLE public.exam
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

-- 3. Relax legacy defaults that generated orphaned references
ALTER TABLE public.exam
  ALTER COLUMN id_course DROP DEFAULT;

ALTER TABLE public.exam
  ALTER COLUMN id_user DROP DEFAULT;

ALTER TABLE public.exam
  ALTER COLUMN id_user DROP NOT NULL;

-- Provide sensible defaults for existing scheduling columns
ALTER TABLE public.exam
  ALTER COLUMN date_start SET DEFAULT NOW();

ALTER TABLE public.exam
  ALTER COLUMN date_end SET DEFAULT (NOW() + INTERVAL '30 days');

-- 4. Add modern metadata columns used by the Flutter app
ALTER TABLE public.exam
  ADD COLUMN IF NOT EXISTS title text,
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS total_available_questions integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS time_limit_minutes integer,
  ADD COLUMN IF NOT EXISTS passing_score_percentage decimal(5,2) DEFAULT 70.0,
  ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT TRUE;

-- Backfill new metadata with sane defaults
UPDATE public.exam
SET total_available_questions = COALESCE(total_available_questions, 0),
    passing_score_percentage = COALESCE(passing_score_percentage, 70.0),
    is_active = COALESCE(is_active, TRUE);
