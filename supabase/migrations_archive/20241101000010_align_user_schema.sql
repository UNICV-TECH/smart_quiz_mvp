-- Align legacy "user" table with Supabase auth integration

-- 1. Rename legacy timestamp column
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user'
      AND column_name = 'update_at'
  ) THEN
    ALTER TABLE public."user" RENAME COLUMN update_at TO updated_at;
  END IF;
END $$;

-- 2. Ensure timestamps have defaults and are non-null
ALTER TABLE public."user"
  ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE public."user"
  ALTER COLUMN updated_at SET DEFAULT NOW();

UPDATE public."user"
SET created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, created_at, NOW());

ALTER TABLE public."user"
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

-- 3. Allow linking to Supabase auth users by dropping synthetic defaults
ALTER TABLE public."user"
  ALTER COLUMN id DROP DEFAULT;

-- 4. Maintain unique email constraint (recreate if missing)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE table_schema = 'public'
      AND table_name = 'user'
      AND constraint_type = 'UNIQUE'
      AND constraint_name = 'user_email_key'
  ) THEN
    ALTER TABLE public."user" ADD CONSTRAINT user_email_key UNIQUE (email);
  END IF;
END $$;
