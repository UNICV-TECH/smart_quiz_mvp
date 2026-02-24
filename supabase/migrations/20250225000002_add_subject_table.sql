-- Migration: Add subject table (matéria) for Course > Subject > Category hierarchy
-- Subject sits between Course and QuestionCategory

-- 1. Create the subject table
CREATE TABLE IF NOT EXISTS public.subject (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  description text,
  id_course uuid NOT NULL REFERENCES public.course(id) ON DELETE CASCADE,
  is_active boolean DEFAULT true NOT NULL,
  created_at timestamptz DEFAULT NOW() NOT NULL,
  updated_at timestamptz DEFAULT NOW() NOT NULL
);

-- 2. Add id_subject column to question_category
ALTER TABLE public.question_category
  ADD COLUMN IF NOT EXISTS id_subject uuid REFERENCES public.subject(id) ON DELETE SET NULL;

-- 3. Add id_subject column to question
ALTER TABLE public.question
  ADD COLUMN IF NOT EXISTS id_subject uuid REFERENCES public.subject(id) ON DELETE SET NULL;

-- 4. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_subject_course ON public.subject(id_course);
CREATE INDEX IF NOT EXISTS idx_subject_active ON public.subject(is_active);
CREATE INDEX IF NOT EXISTS idx_question_category_subject ON public.question_category(id_subject);
CREATE INDEX IF NOT EXISTS idx_question_subject ON public.question(id_subject);

-- 5. RLS policies for subject
ALTER TABLE public.subject ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active subjects"
  ON public.subject FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can insert subjects"
  ON public.subject FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update subjects"
  ON public.subject FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

COMMENT ON TABLE public.subject IS 'Matérias vinculadas a cursos (ex: Direito Civil, Direito Penal)';
COMMENT ON COLUMN public.subject.id_course IS 'FK para o curso ao qual esta matéria pertence';
COMMENT ON COLUMN public.question_category.id_subject IS 'FK para a matéria à qual esta categoria pertence';
COMMENT ON COLUMN public.question.id_subject IS 'FK para a matéria à qual esta questão pertence';
