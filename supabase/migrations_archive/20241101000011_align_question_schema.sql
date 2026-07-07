-- Normalize question table timestamps and columns

-- 1. Rename legacy update column when present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question'
      AND column_name = 'update_at'
  ) THEN
    ALTER TABLE public.question RENAME COLUMN update_at TO updated_at;
  END IF;
END $$;

-- 2. Ensure timestamps have defaults and non-null constraints
ALTER TABLE public.question
  ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE public.question
  ALTER COLUMN updated_at SET DEFAULT NOW();

UPDATE public.question
SET created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, created_at, NOW());

ALTER TABLE public.question
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;
