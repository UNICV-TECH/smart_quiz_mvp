-- Migration: Add Teacher Module
-- This migration adds support for teacher functionality as per the flowchart
-- IMPORTANT: Reviewed and fixed to avoid conflicts with existing schema

-- =============================================================================
-- 1. USER ROLES - Differentiate between student and teacher
-- =============================================================================

-- Add role column to user table (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user'
      AND column_name = 'role'
  ) THEN
    ALTER TABLE public."user" ADD COLUMN role text NOT NULL DEFAULT 'student';
    ALTER TABLE public."user" ADD CONSTRAINT user_role_check CHECK (role IN ('student', 'teacher', 'admin'));
  END IF;
END $$;

-- Add profile fields for teacher (if not exists)
ALTER TABLE public."user"
ADD COLUMN IF NOT EXISTS phone text,
ADD COLUMN IF NOT EXISTS avatar_url text,
ADD COLUMN IF NOT EXISTS bio text;

-- Create index for role-based queries
CREATE INDEX IF NOT EXISTS idx_user_role ON public."user"(role);

-- =============================================================================
-- 2. QUESTION CATEGORIES - Organize questions by category
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.question_category (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  name text NOT NULL,
  description text,
  id_course uuid NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT question_category_pkey PRIMARY KEY (id),
  CONSTRAINT question_category_id_course_fkey FOREIGN KEY (id_course) REFERENCES public.course(id) ON DELETE CASCADE,
  CONSTRAINT question_category_unique_name_course UNIQUE (name, id_course)
);

CREATE INDEX IF NOT EXISTS idx_question_category_course ON public.question_category(id_course);

-- =============================================================================
-- 3. ENHANCE QUESTION TABLE - Add teacher ownership and category
-- NOTE: difficulty_level, points, is_active already exist from migration 20240101000002
-- =============================================================================

-- Add teacher who created the question (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question'
      AND column_name = 'id_teacher'
  ) THEN
    ALTER TABLE public.question ADD COLUMN id_teacher uuid;
    ALTER TABLE public.question ADD CONSTRAINT question_id_teacher_fkey
      FOREIGN KEY (id_teacher) REFERENCES public."user"(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add category reference (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question'
      AND column_name = 'id_category'
  ) THEN
    ALTER TABLE public.question ADD COLUMN id_category uuid;
    ALTER TABLE public.question ADD CONSTRAINT question_id_category_fkey
      FOREIGN KEY (id_category) REFERENCES public.question_category(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add question_order if not exists (for display ordering)
ALTER TABLE public.question
ADD COLUMN IF NOT EXISTS question_order integer;

CREATE INDEX IF NOT EXISTS idx_question_teacher ON public.question(id_teacher);
CREATE INDEX IF NOT EXISTS idx_question_category ON public.question(id_category);

-- =============================================================================
-- 4. EXAM TEMPLATES - Teachers create exam templates
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.exam_template (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  name text NOT NULL,
  description text,
  id_course uuid NOT NULL,
  id_teacher uuid NOT NULL,
  -- Exam configuration
  time_limit_minutes integer, -- NULL means no time limit
  question_count integer NOT NULL DEFAULT 10,
  passing_score_percentage decimal(5,2) DEFAULT 60.0, -- Using same name as existing exam table
  shuffle_questions boolean NOT NULL DEFAULT true,
  shuffle_choices boolean NOT NULL DEFAULT true,
  show_correct_answers boolean NOT NULL DEFAULT true, -- Show after submission
  allow_review boolean NOT NULL DEFAULT true, -- Allow review after submission
  max_attempts integer DEFAULT 1, -- NULL means unlimited
  -- Status
  is_published boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT exam_template_pkey PRIMARY KEY (id),
  CONSTRAINT exam_template_id_course_fkey FOREIGN KEY (id_course) REFERENCES public.course(id) ON DELETE CASCADE,
  CONSTRAINT exam_template_id_teacher_fkey FOREIGN KEY (id_teacher) REFERENCES public."user"(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_exam_template_course ON public.exam_template(id_course);
CREATE INDEX IF NOT EXISTS idx_exam_template_teacher ON public.exam_template(id_teacher);
CREATE INDEX IF NOT EXISTS idx_exam_template_published ON public.exam_template(is_published);

-- =============================================================================
-- 5. EXAM TEMPLATE QUESTIONS - Questions included in a template
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.exam_template_question (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  id_exam_template uuid NOT NULL,
  id_question uuid NOT NULL,
  question_order integer NOT NULL DEFAULT 1,
  points_override decimal(5,2), -- Override question default points
  CONSTRAINT exam_template_question_pkey PRIMARY KEY (id),
  CONSTRAINT exam_template_question_template_fkey FOREIGN KEY (id_exam_template) REFERENCES public.exam_template(id) ON DELETE CASCADE,
  CONSTRAINT exam_template_question_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id) ON DELETE CASCADE,
  CONSTRAINT exam_template_question_unique UNIQUE (id_exam_template, id_question)
);

CREATE INDEX IF NOT EXISTS idx_exam_template_question_template ON public.exam_template_question(id_exam_template);

-- =============================================================================
-- 6. EXAM TEMPLATE CATEGORIES - Auto-select questions from categories
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.exam_template_category (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  id_exam_template uuid NOT NULL,
  id_category uuid NOT NULL,
  question_count integer NOT NULL DEFAULT 5, -- How many questions to pick from this category
  CONSTRAINT exam_template_category_pkey PRIMARY KEY (id),
  CONSTRAINT exam_template_category_template_fkey FOREIGN KEY (id_exam_template) REFERENCES public.exam_template(id) ON DELETE CASCADE,
  CONSTRAINT exam_template_category_category_fkey FOREIGN KEY (id_category) REFERENCES public.question_category(id) ON DELETE CASCADE,
  CONSTRAINT exam_template_category_unique UNIQUE (id_exam_template, id_category)
);

-- =============================================================================
-- 7. ENHANCE EXAM TABLE - Link to template
-- NOTE: time_limit_minutes and passing_score_percentage already exist from migration 20241101000008
-- =============================================================================

-- Add template reference (exam generated from template)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'exam'
      AND column_name = 'id_exam_template'
  ) THEN
    ALTER TABLE public.exam ADD COLUMN id_exam_template uuid;
    ALTER TABLE public.exam ADD CONSTRAINT exam_id_exam_template_fkey
      FOREIGN KEY (id_exam_template) REFERENCES public.exam_template(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add additional exam fields (if not exists)
ALTER TABLE public.exam
ADD COLUMN IF NOT EXISTS show_correct_answers boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS allow_review boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS attempt_number integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS total_questions integer,
ADD COLUMN IF NOT EXISTS correct_answers integer,
ADD COLUMN IF NOT EXISTS score decimal(5,2),
ADD COLUMN IF NOT EXISTS passed boolean;

CREATE INDEX IF NOT EXISTS idx_exam_template ON public.exam(id_exam_template);

-- =============================================================================
-- 8. TEACHER STATISTICS VIEWS - For dashboard
-- =============================================================================

CREATE OR REPLACE VIEW public.teacher_question_stats AS
SELECT
  q.id_teacher,
  q.id_course,
  c.name as course_name,
  COUNT(q.id) as total_questions,
  COUNT(CASE WHEN q.is_active THEN 1 END) as active_questions,
  COUNT(DISTINCT q.id_category) as categories_used,
  AVG(q.points) as avg_points
FROM public.question q
JOIN public.course c ON q.id_course = c.id
WHERE q.id_teacher IS NOT NULL
GROUP BY q.id_teacher, q.id_course, c.name;

CREATE OR REPLACE VIEW public.teacher_exam_stats AS
SELECT
  et.id_teacher,
  et.id_course,
  c.name as course_name,
  COUNT(et.id) as total_templates,
  COUNT(CASE WHEN et.is_published THEN 1 END) as published_templates,
  COUNT(e.id) as total_exams_taken,
  AVG(e.score) as avg_score,
  COUNT(CASE WHEN e.passed THEN 1 END) as total_passed
FROM public.exam_template et
JOIN public.course c ON et.id_course = c.id
LEFT JOIN public.exam e ON e.id_exam_template = et.id
GROUP BY et.id_teacher, et.id_course, c.name;

-- View for teachers to see student responses on their exams
CREATE OR REPLACE VIEW public.teacher_student_responses AS
SELECT
  et.id_teacher,
  et.id as template_id,
  et.name as template_name,
  c.name as course_name,
  e.id as exam_id,
  u.id as student_id,
  u.email as student_email,
  u.first_name as student_first_name,
  u.surename as student_surname,
  uea.id as attempt_id,
  uea.question_count,
  uea.started_at,
  uea.completed_at,
  uea.duration_seconds,
  uea.total_score,
  uea.percentage_score,
  uea.status as attempt_status,
  (
    SELECT COUNT(*)
    FROM public.user_responses ur
    WHERE ur.attempt_id = uea.id AND ur.is_correct = true
  ) as correct_answers,
  (
    SELECT COUNT(*)
    FROM public.user_responses ur
    WHERE ur.attempt_id = uea.id AND ur.is_correct = false
  ) as wrong_answers
FROM public.exam_template et
JOIN public.course c ON et.id_course = c.id
JOIN public.exam e ON e.id_exam_template = et.id
JOIN public.user_exam_attempts uea ON uea.exam_id = e.id
JOIN public."user" u ON u.id = uea.user_id;

-- =============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on new tables
ALTER TABLE public.question_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_template ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_template_question ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_template_category ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for idempotency)
DROP POLICY IF EXISTS "Teachers can manage their course categories" ON public.question_category;
DROP POLICY IF EXISTS "Everyone can view active categories" ON public.question_category;
DROP POLICY IF EXISTS "Teachers can manage their templates" ON public.exam_template;
DROP POLICY IF EXISTS "Students can view published templates" ON public.exam_template;
DROP POLICY IF EXISTS "Teachers can manage template questions" ON public.exam_template_question;
DROP POLICY IF EXISTS "Teachers can manage template categories" ON public.exam_template_category;

-- Question Category policies
CREATE POLICY "Teachers can manage their course categories" ON public.question_category
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public."user" u
      WHERE u.id = auth.uid()
      AND u.role IN ('teacher', 'admin')
    )
  );

CREATE POLICY "Everyone can view active categories" ON public.question_category
  FOR SELECT USING (is_active = true);

-- Exam Template policies
CREATE POLICY "Teachers can manage their templates" ON public.exam_template
  FOR ALL USING (id_teacher = auth.uid());

CREATE POLICY "Students can view published templates" ON public.exam_template
  FOR SELECT USING (is_published = true AND is_active = true);

-- Exam Template Question policies
CREATE POLICY "Teachers can manage template questions" ON public.exam_template_question
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.exam_template et
      WHERE et.id = id_exam_template
      AND et.id_teacher = auth.uid()
    )
  );

-- Exam Template Category policies
CREATE POLICY "Teachers can manage template categories" ON public.exam_template_category
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.exam_template et
      WHERE et.id = id_exam_template
      AND et.id_teacher = auth.uid()
    )
  );

-- =============================================================================
-- 10. HELPER FUNCTIONS
-- =============================================================================

-- Function to get questions for a teacher (includes supporting text count)
CREATE OR REPLACE FUNCTION get_teacher_questions(
  p_teacher_id uuid,
  p_course_id uuid DEFAULT NULL,
  p_category_id uuid DEFAULT NULL,
  p_active_only boolean DEFAULT true
)
RETURNS TABLE (
  id uuid,
  enunciation text,
  difficulty_level text,
  points decimal,
  is_active boolean,
  category_name text,
  course_name text,
  answer_count bigint,
  supporting_text_count bigint,
  created_at timestamp
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    q.id,
    q.enunciation,
    q.difficulty_level,
    q.points,
    q.is_active,
    qc.name as category_name,
    c.name as course_name,
    COUNT(DISTINCT ac.id) as answer_count,
    COUNT(DISTINCT st.id) as supporting_text_count,
    q.created_at
  FROM public.question q
  LEFT JOIN public.question_category qc ON q.id_category = qc.id
  JOIN public.course c ON q.id_course = c.id
  LEFT JOIN public.answerchoice ac ON ac.idquestion = q.id
  LEFT JOIN public.supportingtext st ON st.id_question = q.id
  WHERE q.id_teacher = p_teacher_id
    AND (p_course_id IS NULL OR q.id_course = p_course_id)
    AND (p_category_id IS NULL OR q.id_category = p_category_id)
    AND (NOT p_active_only OR q.is_active = true)
  GROUP BY q.id, q.enunciation, q.difficulty_level, q.points, q.is_active, qc.name, c.name, q.created_at
  ORDER BY q.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate exam from template
CREATE OR REPLACE FUNCTION generate_exam_from_template(
  p_template_id uuid,
  p_user_id uuid
)
RETURNS uuid AS $$
DECLARE
  v_exam_id uuid;
  v_template record;
  v_question record;
  v_order integer := 1;
BEGIN
  -- Get template configuration
  SELECT * INTO v_template FROM public.exam_template WHERE id = p_template_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Template not found';
  END IF;

  IF NOT v_template.is_published THEN
    RAISE EXCEPTION 'Template is not published';
  END IF;

  IF NOT v_template.is_active THEN
    RAISE EXCEPTION 'Template is not active';
  END IF;

  -- Create the exam (using updated_at as per migration 20241101000008)
  INSERT INTO public.exam (
    id_user, id_course, id_exam_template,
    date_start, date_end, is_completed,
    time_limit_minutes, passing_score_percentage, show_correct_answers, allow_review,
    total_questions, attempt_number,
    created_at, updated_at
  ) VALUES (
    p_user_id, v_template.id_course, p_template_id,
    NOW(), NOW() + (COALESCE(v_template.time_limit_minutes, 180) || ' minutes')::interval, false,
    v_template.time_limit_minutes, v_template.passing_score_percentage,
    v_template.show_correct_answers, v_template.allow_review,
    v_template.question_count, 1,
    NOW(), NOW()
  ) RETURNING id INTO v_exam_id;

  -- Add questions from template (direct questions)
  FOR v_question IN
    SELECT etq.id_question, etq.question_order
    FROM public.exam_template_question etq
    WHERE etq.id_exam_template = p_template_id
    ORDER BY etq.question_order
  LOOP
    INSERT INTO public.examquestion (id_exam, id_question, question_order, created_at, update_at)
    VALUES (v_exam_id, v_question.id_question, v_order, NOW(), NOW());
    v_order := v_order + 1;
  END LOOP;

  RETURN v_exam_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create a complete question with supporting texts and answer choices
CREATE OR REPLACE FUNCTION create_teacher_question(
  p_teacher_id uuid,
  p_course_id uuid,
  p_category_id uuid DEFAULT NULL,
  p_enunciation text DEFAULT '',
  p_difficulty_level text DEFAULT 'medium',
  p_points decimal DEFAULT 1.0,
  p_supporting_texts jsonb DEFAULT '[]'::jsonb,
  p_answer_choices jsonb DEFAULT '[]'::jsonb
)
RETURNS uuid AS $$
DECLARE
  v_question_id uuid;
  v_supporting_text jsonb;
  v_answer_choice jsonb;
  v_order integer := 1;
BEGIN
  -- Validate teacher role
  IF NOT EXISTS (
    SELECT 1 FROM public."user"
    WHERE id = p_teacher_id AND role IN ('teacher', 'admin')
  ) THEN
    RAISE EXCEPTION 'User is not a teacher or admin';
  END IF;

  -- Create the question
  INSERT INTO public.question (
    id_course, id_teacher, id_category,
    enunciation, difficulty_level, points, is_active,
    created_at, updated_at
  ) VALUES (
    p_course_id, p_teacher_id, p_category_id,
    p_enunciation, p_difficulty_level, p_points, true,
    NOW(), NOW()
  ) RETURNING id INTO v_question_id;

  -- Insert supporting texts
  v_order := 1;
  FOR v_supporting_text IN SELECT * FROM jsonb_array_elements(p_supporting_texts)
  LOOP
    INSERT INTO public.supportingtext (
      id_question, content_type, content, display_order, created_at
    ) VALUES (
      v_question_id,
      COALESCE(v_supporting_text->>'content_type', 'text'),
      COALESCE(v_supporting_text->>'content', ''),
      COALESCE((v_supporting_text->>'display_order')::integer, v_order),
      NOW()
    );
    v_order := v_order + 1;
  END LOOP;

  -- Insert answer choices
  v_order := 1;
  FOR v_answer_choice IN SELECT * FROM jsonb_array_elements(p_answer_choices)
  LOOP
    INSERT INTO public.answerchoice (
      idquestion, letter, content, correctanswer, created_at, upload_at
    ) VALUES (
      v_question_id,
      COALESCE(v_answer_choice->>'letter', chr(64 + v_order)),  -- A, B, C, D, E
      COALESCE(v_answer_choice->>'content', ''),
      COALESCE((v_answer_choice->>'is_correct')::boolean, false),
      NOW(), NOW()
    );
    v_order := v_order + 1;
  END LOOP;

  RETURN v_question_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get detailed student responses for a teacher's exam
CREATE OR REPLACE FUNCTION get_teacher_exam_responses(
  p_teacher_id uuid,
  p_template_id uuid DEFAULT NULL,
  p_exam_id uuid DEFAULT NULL
)
RETURNS TABLE (
  template_id uuid,
  template_name text,
  exam_id uuid,
  student_id uuid,
  student_email text,
  student_name text,
  attempt_id uuid,
  question_id uuid,
  question_enunciation text,
  selected_choice_key text,
  correct_choice_key text,
  is_correct boolean,
  points_earned decimal,
  answered_at timestamp
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    et.id as template_id,
    et.name as template_name,
    e.id as exam_id,
    u.id as student_id,
    u.email as student_email,
    COALESCE(u.first_name || ' ' || u.surename, u.email) as student_name,
    uea.id as attempt_id,
    q.id as question_id,
    q.enunciation as question_enunciation,
    ur.selected_choice_key,
    (SELECT ac.letter FROM public.answerchoice ac WHERE ac.idquestion = q.id AND ac.correctanswer = true LIMIT 1) as correct_choice_key,
    ur.is_correct,
    ur.points_earned,
    ur.answered_at
  FROM public.exam_template et
  JOIN public.exam e ON e.id_exam_template = et.id
  JOIN public.user_exam_attempts uea ON uea.exam_id = e.id
  JOIN public."user" u ON u.id = uea.user_id
  JOIN public.user_responses ur ON ur.attempt_id = uea.id
  JOIN public.question q ON q.id = ur.question_id
  WHERE et.id_teacher = p_teacher_id
    AND (p_template_id IS NULL OR et.id = p_template_id)
    AND (p_exam_id IS NULL OR e.id = p_exam_id)
  ORDER BY et.name, u.email, ur.answered_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 11. COMMENTS FOR DOCUMENTATION
-- =============================================================================

COMMENT ON TABLE public.question_category IS 'Categories for organizing questions by topic/subject';
COMMENT ON TABLE public.exam_template IS 'Exam templates created by teachers';
COMMENT ON TABLE public.exam_template_question IS 'Questions assigned to exam templates';
COMMENT ON TABLE public.exam_template_category IS 'Categories to auto-select questions from';
COMMENT ON FUNCTION generate_exam_from_template IS 'Generates a new exam instance from a template for a student';
COMMENT ON FUNCTION create_teacher_question IS 'Creates a complete question with supporting texts and answer choices';
COMMENT ON FUNCTION get_teacher_questions IS 'Retrieves all questions created by a teacher with filters';
COMMENT ON FUNCTION get_teacher_exam_responses IS 'Retrieves detailed student responses for teacher analysis';
COMMENT ON VIEW public.teacher_question_stats IS 'Statistics about questions created by teachers';
COMMENT ON VIEW public.teacher_exam_stats IS 'Statistics about exam templates and results';
COMMENT ON VIEW public.teacher_student_responses IS 'Summary of student attempts on teacher exams';
COMMENT ON COLUMN public."user".role IS 'User role: student, teacher, or admin';
COMMENT ON COLUMN public.question.id_teacher IS 'Reference to teacher who created this question';
COMMENT ON COLUMN public.question.id_category IS 'Reference to question category';
