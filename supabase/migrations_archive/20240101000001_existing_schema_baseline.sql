-- Baseline: Existing schema (safe to run, will skip if tables exist)
-- This matches your current database structure exactly

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.user (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  email text NOT NULL UNIQUE,
  first_name text,
  surename text,
  CONSTRAINT user_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.course (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  name text NOT NULL UNIQUE,
  icon text NOT NULL,
  CONSTRAINT course_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.exam (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  date_start timestamp without time zone NOT NULL,
  date_end timestamp without time zone NOT NULL,
  is_completed boolean NOT NULL DEFAULT false,
  id_user uuid NOT NULL DEFAULT gen_random_uuid(),
  id_course uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT exam_pkey PRIMARY KEY (id),
  CONSTRAINT exam_id_course_fkey FOREIGN KEY (id_course) REFERENCES public.course(id),
  CONSTRAINT exam_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.user(id)
);

CREATE TABLE IF NOT EXISTS public.question (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  enunciation text NOT NULL,
  id_course uuid NOT NULL,
  CONSTRAINT question_pkey PRIMARY KEY (id),
  CONSTRAINT question_id_course_fkey FOREIGN KEY (id_course) REFERENCES public.course(id)
);

CREATE TABLE IF NOT EXISTS public.examquestion (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  id_exam uuid NOT NULL DEFAULT gen_random_uuid(),
  id_question uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT examquestion_pkey PRIMARY KEY (id),
  CONSTRAINT examquestion_id_exam_fkey FOREIGN KEY (id_exam) REFERENCES public.exam(id),
  CONSTRAINT examquestion_id_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id)
);

CREATE TABLE IF NOT EXISTS public.answerchoice (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  upload_at timestamp without time zone NOT NULL,
  letter text NOT NULL,
  content text NOT NULL,
  correctanswer boolean NOT NULL,
  idquestion uuid NOT NULL,
  CONSTRAINT answerchoice_pkey PRIMARY KEY (id),
  CONSTRAINT answerchoices_idquestion_fkey FOREIGN KEY (idquestion) REFERENCES public.question(id)
);
