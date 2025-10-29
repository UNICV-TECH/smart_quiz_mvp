-- Create indexes for performance optimization

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON public.user(email);

-- Course table indexes
CREATE INDEX IF NOT EXISTS idx_course_name ON public.course(name);

-- Only create is_active index if column exists (added in migration 002)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'course' 
    AND column_name = 'is_active'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_course_is_active ON public.course(is_active);
  END IF;
END $$;

-- Exam table indexes
CREATE INDEX IF NOT EXISTS idx_exam_id_user ON public.exam(id_user);
CREATE INDEX IF NOT EXISTS idx_exam_id_course ON public.exam(id_course);
CREATE INDEX IF NOT EXISTS idx_exam_is_completed ON public.exam(is_completed);
CREATE INDEX IF NOT EXISTS idx_exam_date_end ON public.exam(date_end);
CREATE INDEX IF NOT EXISTS idx_exam_user_course ON public.exam(id_user, id_course);

-- Question table indexes
CREATE INDEX IF NOT EXISTS idx_question_id_course ON public.question(id_course);

-- Only create these indexes if the columns exist (added in migration 002)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'question' 
    AND column_name = 'is_active'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_question_is_active ON public.question(is_active);
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'question' 
    AND column_name = 'difficulty_level'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_question_difficulty ON public.question(difficulty_level);
  END IF;
END $$;

-- ExamQuestion table indexes
CREATE INDEX IF NOT EXISTS idx_examquestion_id_exam ON public.examquestion(id_exam);
CREATE INDEX IF NOT EXISTS idx_examquestion_id_question ON public.examquestion(id_question);
CREATE UNIQUE INDEX IF NOT EXISTS idx_examquestion_unique ON public.examquestion(id_exam, id_question);

-- AnswerChoice table indexes
CREATE INDEX IF NOT EXISTS idx_answerchoice_idquestion ON public.answerchoice(idquestion);
CREATE INDEX IF NOT EXISTS idx_answerchoice_correctanswer ON public.answerchoice(correctanswer);
CREATE UNIQUE INDEX IF NOT EXISTS idx_answerchoice_unique ON public.answerchoice(idquestion, letter);

-- UserResponse table indexes
CREATE INDEX IF NOT EXISTS idx_userresponse_id_exam ON public.userresponse(id_exam);
CREATE INDEX IF NOT EXISTS idx_userresponse_id_question ON public.userresponse(id_question);
CREATE INDEX IF NOT EXISTS idx_userresponse_is_correct ON public.userresponse(is_correct);
CREATE INDEX IF NOT EXISTS idx_userresponse_id_answerchoice ON public.userresponse(id_answerchoice);
CREATE UNIQUE INDEX IF NOT EXISTS idx_userresponse_unique ON public.userresponse(id_exam, id_question);

-- SupportingText table indexes
CREATE INDEX IF NOT EXISTS idx_supportingtext_id_question ON public.supportingtext(id_question);
CREATE INDEX IF NOT EXISTS idx_supportingtext_display_order ON public.supportingtext(id_question, display_order);
