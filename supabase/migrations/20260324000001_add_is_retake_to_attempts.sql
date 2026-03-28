-- Add is_retake flag to user_exam_attempts
-- Allows the UI to display whether an attempt was a retake
ALTER TABLE public.user_exam_attempts
  ADD COLUMN IF NOT EXISTS is_retake boolean NOT NULL DEFAULT false;
