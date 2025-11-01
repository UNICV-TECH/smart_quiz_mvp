-- Align course schema with Flutter data expectations
-- Adds missing columns, normalizes timestamps, and backfills data

-- 1. Rename legacy timestamp column if present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'course'
      AND column_name = 'update_at'
  ) THEN
    ALTER TABLE public.course RENAME COLUMN update_at TO updated_at;
  END IF;
END $$;

-- 2. Ensure key timestamp columns have defaults and non-null values
ALTER TABLE public.course
  ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE public.course
  ALTER COLUMN updated_at SET DEFAULT NOW();

UPDATE public.course
SET created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, created_at, NOW());

ALTER TABLE public.course
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

-- 3. Add modern naming columns expected by the app
ALTER TABLE public.course
  ADD COLUMN IF NOT EXISTS course_key text,
  ADD COLUMN IF NOT EXISTS title text,
  ADD COLUMN IF NOT EXISTS icon_key text;

-- 4. Backfill course_key, title, icon_key from legacy columns when available
UPDATE public.course
SET title = COALESCE(title, name),
    course_key = COALESCE(course_key,
      regexp_replace(
        COALESCE(title, name),
        '[^a-zA-Z0-9]+',
        '_',
        'g'
      )
      ),
    icon_key = COALESCE(icon_key, icon)
WHERE name IS NOT NULL;

-- Normalize course_key formatting after replacements
UPDATE public.course
SET course_key = LOWER(
      regexp_replace(
        regexp_replace(course_key, '_{2,}', '_', 'g'),
        '^_|_$',
        '',
        'g'
      )
    )
WHERE course_key IS NOT NULL;

-- 5. Keep name/icon in sync when new columns are filled
UPDATE public.course
SET name = COALESCE(title, name),
    icon = COALESCE(icon_key, icon)
WHERE title IS NOT NULL OR icon_key IS NOT NULL;

-- 6. Add helpful uniqueness constraints if absent
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.course'::regclass
      AND conname = 'course_course_key_key'
  ) THEN
    ALTER TABLE public.course
      ADD CONSTRAINT course_course_key_key UNIQUE (course_key);
  END IF;
END $$;
