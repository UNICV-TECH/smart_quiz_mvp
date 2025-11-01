-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.answerchoice (
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
CREATE TABLE public.course (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamp without time zone NOT NULL,
update_at timestamp without time zone NOT NULL,
name text NOT NULL UNIQUE,
icon text NOT NULL,
CONSTRAINT course_pkey PRIMARY KEY (id)
);
CREATE TABLE public.exam (
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
CREATE TABLE public.examquestion (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamp without time zone NOT NULL,
update_at timestamp without time zone NOT NULL,
id_exam uuid NOT NULL DEFAULT gen_random_uuid(),
id_question uuid NOT NULL DEFAULT gen_random_uuid(),
CONSTRAINT examquestion_pkey PRIMARY KEY (id),
CONSTRAINT examquestion_id_exam_fkey FOREIGN KEY (id_exam) REFERENCES public.exam(id),
CONSTRAINT examquestion_id_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id)
);
CREATE TABLE public.question (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamp without time zone NOT NULL,
update_at timestamp without time zone NOT NULL,
number smallint NOT NULL,
statement text NOT NULL,
idcourse uuid NOT NULL,
CONSTRAINT question_pkey PRIMARY KEY (id),
CONSTRAINT question_idcourse_fkey FOREIGN KEY (idcourse) REFERENCES public.course(id)
);
CREATE TABLE public.questionsupportingtext (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamp without time zone NOT NULL,
update_at timestamp without time zone NOT NULL,
idquestion uuid NOT NULL DEFAULT gen_random_uuid(),
idsupportingtext uuid NOT NULL DEFAULT gen_random_uuid(),
CONSTRAINT questionsupportingtext_pkey PRIMARY KEY (id),
CONSTRAINT questionsupportingtext_idsupportingtext_fkey FOREIGN KEY (idsupportingtext) REFERENCES public.supportingtext(id),
CONSTRAINT questionsupportingtext_idquestion_fkey FOREIGN KEY (idquestion) REFERENCES public.question(id)
);
CREATE TABLE public.supportingtext (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamp without time zone NOT NULL,
update_at timestamp without time zone NOT NULL,
content text NOT NULL,
CONSTRAINT supportingtext_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user (
id uuid NOT NULL,
first_name text NOT NULL,
surename text NOT NULL,
created_at timestamp without time zone NOT NULL,
updated_at timestamp without time zone NOT NULL,
email text NOT NULL,
CONSTRAINT user_pkey PRIMARY KEY (id),
CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
