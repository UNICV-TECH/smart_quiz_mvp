-- Seed exam metadata for existing courses
-- Creates one active exam per course when none exists

DO $$
DECLARE
  rec RECORD;
  v_title text;
  v_description text;
  v_total_questions integer;
BEGIN
  FOR rec IN
    SELECT
      id,
      COALESCE(title, name) AS course_title
    FROM public.course
  LOOP
    -- Skip if an exam already exists for this course
    IF EXISTS (
      SELECT 1 FROM public.exam WHERE id_course = rec.id
    ) THEN
      CONTINUE;
    END IF;

    SELECT COUNT(*)
    INTO v_total_questions
    FROM public.question
    WHERE id_course = rec.id;

    v_title := format('Simulado de %s', COALESCE(rec.course_title, 'Curso'));
    v_description := format('Simulado de preparação para o curso de %s.', COALESCE(rec.course_title, ''));

    INSERT INTO public.exam (
      id_course,
      title,
      description,
      total_available_questions,
      question_count,
      time_limit_minutes,
      passing_score_percentage,
      is_active,
      date_start,
      date_end,
      is_completed,
      total_score,
      percentage_score,
      id_user
    )
    VALUES (
      rec.id,
      v_title,
      v_description,
      COALESCE(v_total_questions, 0),
      COALESCE(v_total_questions, 0),
      60,
      70.0,
      TRUE,
      NOW(),
      NOW() + INTERVAL '30 days',
      FALSE,
      NULL,
      NULL,
      NULL
    );
  END LOOP;
END $$;
