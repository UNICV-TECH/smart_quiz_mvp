-- Add missing columns to existing tables
-- These columns are needed per SCHEMA_DOCUMENTATION.md

-- Add columns to course table
ALTER TABLE public.course 
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT TRUE;

-- Add columns to exam table
ALTER TABLE public.exam 
  ADD COLUMN IF NOT EXISTS question_count integer,
  ADD COLUMN IF NOT EXISTS total_score decimal(5,2),
  ADD COLUMN IF NOT EXISTS percentage_score decimal(5,2);

-- Add columns to question table
ALTER TABLE public.question
  ADD COLUMN IF NOT EXISTS difficulty_level text,
  ADD COLUMN IF NOT EXISTS points decimal(5,2) DEFAULT 1.0,
  ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT TRUE;

-- Add check constraint separately (can't be added with IF NOT EXISTS)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'question_difficulty_level_check'
  ) THEN
    ALTER TABLE public.question 
    ADD CONSTRAINT question_difficulty_level_check 
    CHECK (difficulty_level IN ('easy', 'medium', 'hard'));
  END IF;
END $$;

-- Add question_order to examquestion
ALTER TABLE public.examquestion
  ADD COLUMN IF NOT EXISTS question_order integer;
