-- Create new tables that don't exist yet

-- Create userresponse table
CREATE TABLE IF NOT EXISTS public.userresponse (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  id_exam uuid NOT NULL,
  id_question uuid NOT NULL,
  id_answerchoice uuid,
  selected_letter text,
  is_correct boolean,
  points_earned decimal(5,2) DEFAULT 0,
  time_spent_seconds integer,
  answered_at timestamp without time zone,
  CONSTRAINT userresponse_pkey PRIMARY KEY (id),
  CONSTRAINT userresponse_id_exam_fkey FOREIGN KEY (id_exam) REFERENCES public.exam(id) ON DELETE CASCADE,
  CONSTRAINT userresponse_id_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id) ON DELETE CASCADE,
  CONSTRAINT userresponse_id_answerchoice_fkey FOREIGN KEY (id_answerchoice) REFERENCES public.answerchoice(id) ON DELETE SET NULL
);

-- Create supportingtext table
CREATE TABLE IF NOT EXISTS public.supportingtext (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  id_question uuid NOT NULL,
  content_type text NOT NULL CHECK (content_type IN ('text', 'image', 'code', 'table')),
  content text NOT NULL,
  display_order integer DEFAULT 1,
  CONSTRAINT supportingtext_pkey PRIMARY KEY (id),
  CONSTRAINT supportingtext_id_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id) ON DELETE CASCADE
);
