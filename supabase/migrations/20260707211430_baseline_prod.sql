

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."admin_list_questions"("p_course_id" "uuid" DEFAULT NULL::"uuid", "p_teacher_id" "uuid" DEFAULT NULL::"uuid", "p_active_only" boolean DEFAULT true) RETURNS TABLE("id" "uuid", "enunciation" "text", "difficulty_level" "text", "points" numeric, "is_active" boolean, "course_name" "text", "teacher_name" "text", "teacher_email" "text", "answer_count" bigint, "created_at" timestamp without time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  BEGIN
    -- Validate caller is admin
    IF NOT EXISTS (
      SELECT 1 FROM public."user"
      WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
    ) THEN
      RAISE EXCEPTION 'Access denied: admin role required';
    END IF;

    RETURN QUERY
    SELECT
      q.id,
      q.enunciation,
      q.difficulty_level,
      q.points,
      q.is_active,
      c.name AS course_name,
      COALESCE(t.first_name, '') AS teacher_name,
      t.email AS teacher_email,
      COUNT(DISTINCT ac.id) AS answer_count,
      q.created_at
    FROM public.question q
    JOIN public.course c ON q.id_course = c.id
    LEFT JOIN public."user" t ON q.id_teacher = t.id
    LEFT JOIN public.answerchoice ac ON ac.idquestion = q.id
    WHERE (p_course_id IS NULL OR q.id_course = p_course_id)
      AND (p_teacher_id IS NULL OR q.id_teacher = p_teacher_id)
      AND (NOT p_active_only OR q.is_active = true)
    GROUP BY q.id, q.enunciation, q.difficulty_level, q.points, q.is_active, c.name, t.first_name, t.email, q.created_at
    ORDER BY q.created_at DESC;
  END;
  $$;


ALTER FUNCTION "public"."admin_list_questions"("p_course_id" "uuid", "p_teacher_id" "uuid", "p_active_only" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_list_users"("p_role" "text" DEFAULT NULL::"text", "p_is_active" boolean DEFAULT NULL::boolean, "p_search" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "name" "text", "email" "text", "role" "text", "is_active" boolean, "created_at" timestamp without time zone, "exam_count" bigint, "avg_score" double precision)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM public."user"
      WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
    ) THEN
      RAISE EXCEPTION 'Access denied: admin role required';
    END IF;

    RETURN QUERY
    SELECT
      u.id,
      COALESCE(u.first_name, '') AS name,
      u.email,
      u.role,
      u.is_active,
      u.created_at,
      COUNT(DISTINCT uea.id) AS exam_count,
      COALESCE(AVG(uea.percentage_score), 0)::double precision AS avg_score
    FROM public."user" u
    LEFT JOIN public.user_exam_attempts uea ON uea.user_id = u.id AND uea.status = 'completed'
    WHERE (p_role IS NULL OR u.role = p_role)
      AND (p_is_active IS NULL OR u.is_active = p_is_active)
      AND (p_search IS NULL OR u.email ILIKE '%' || p_search || '%' OR u.first_name ILIKE '%' || p_search || '%')
    GROUP BY u.id, u.first_name, u.email, u.role, u.is_active, u.created_at
    ORDER BY u.created_at DESC;
  END;
  $$;


ALTER FUNCTION "public"."admin_list_users"("p_role" "text", "p_is_active" boolean, "p_search" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Validate caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM public."user"
    WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  -- Prevent self-deactivation
  IF p_user_id = auth.uid() AND p_is_active = false THEN
    RAISE EXCEPTION 'Cannot deactivate your own account';
  END IF;

  -- Update public.user table
  UPDATE public."user"
  SET is_active = p_is_active, updated_at = NOW()
  WHERE id = p_user_id;

  -- Ban or unban in Supabase Auth
  IF p_is_active = false THEN
    -- Ban user by setting banned_until to far future
    UPDATE auth.users
    SET banned_until = '2999-12-31 23:59:59+00'::timestamptz,
        updated_at = NOW()
    WHERE id = p_user_id;
  ELSE
    -- Unban user by clearing banned_until
    UPDATE auth.users
    SET banned_until = NULL,
        updated_at = NOW()
    WHERE id = p_user_id;
  END IF;
END;
$$;


ALTER FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) IS 'Toggles user active status and bans/unbans in Supabase Auth. Admin only, prevents self-deactivation.';



CREATE OR REPLACE FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Validate caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM public."user"
    WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  -- Prevent changing own password through this function
  IF p_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Use the regular password change for your own account';
  END IF;

  -- Validate password minimum length
  IF LENGTH(p_new_password) < 6 THEN
    RAISE EXCEPTION 'Password must be at least 6 characters';
  END IF;

  -- Validate target user exists
  IF NOT EXISTS (SELECT 1 FROM public."user" WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Update password in auth.users using bcrypt
  UPDATE auth.users
  SET
    encrypted_password = crypt(p_new_password, gen_salt('bf')),
    updated_at = NOW()
  WHERE id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Failed to update password: auth user not found';
  END IF;
END;
$$;


ALTER FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") IS 'Allows admin to directly set a new password for any user. Uses bcrypt hashing via pgcrypto.';



CREATE OR REPLACE FUNCTION "public"."admin_update_user_role"("p_user_id" "uuid", "p_new_role" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  BEGIN
    -- Validate caller is admin
    IF NOT EXISTS (
      SELECT 1 FROM public."user"
      WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
    ) THEN
      RAISE EXCEPTION 'Access denied: admin role required';
    END IF;

    -- Prevent self-demotion
    IF p_user_id = auth.uid() THEN
      RAISE EXCEPTION 'Cannot change your own role';
    END IF;

    -- Validate role value
    IF p_new_role NOT IN ('student', 'teacher', 'admin') THEN
      RAISE EXCEPTION 'Invalid role: %', p_new_role;
    END IF;

    UPDATE public."user"
    SET role = p_new_role, updated_at = NOW()
    WHERE id = p_user_id;
  END;
  $$;


ALTER FUNCTION "public"."admin_update_user_role"("p_user_id" "uuid", "p_new_role" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid" DEFAULT NULL::"uuid", "p_enunciation" "text" DEFAULT ''::"text", "p_difficulty_level" "text" DEFAULT 'medium'::"text", "p_points" numeric DEFAULT 1.0, "p_supporting_texts" "jsonb" DEFAULT '[]'::"jsonb", "p_answer_choices" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_question_id uuid;
  v_supporting_text jsonb;
  v_answer_choice jsonb;
  v_order integer := 1;
  v_next_number integer;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public."user"
    WHERE id = p_teacher_id AND role IN ('teacher', 'admin')
  ) THEN
    RAISE EXCEPTION 'User is not a teacher or admin';
  END IF;

  SELECT COALESCE(MAX(number), 0) + 1 INTO v_next_number
  FROM public.question
  WHERE id_course = p_course_id;

  INSERT INTO public.question (
    id_course, id_teacher, id_category,
    enunciation, difficulty_level, points, is_active,
    number, created_at, updated_at
  ) VALUES (
    p_course_id, p_teacher_id, p_category_id,
    p_enunciation, p_difficulty_level, p_points, true,
    v_next_number, NOW(), NOW()
  ) RETURNING id INTO v_question_id;

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

  v_order := 1;
  FOR v_answer_choice IN SELECT * FROM jsonb_array_elements(p_answer_choices)
  LOOP
    INSERT INTO public.answerchoice (
      idquestion, letter, content, correctanswer, created_at, upload_at
    ) VALUES (
      v_question_id,
      COALESCE(v_answer_choice->>'letter', chr(64 + v_order)),
      COALESCE(v_answer_choice->>'content', ''),
      COALESCE((v_answer_choice->>'is_correct')::boolean, false),
      NOW(), NOW()
    );
    v_order := v_order + 1;
  END LOOP;

  RETURN v_question_id;
END;
$$;


ALTER FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") IS 'Creates a complete question with supporting texts and answer choices';



CREATE OR REPLACE FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_subject_id" "uuid" DEFAULT NULL::"uuid", "p_category_id" "uuid" DEFAULT NULL::"uuid", "p_enunciation" "text" DEFAULT ''::"text", "p_difficulty_level" "text" DEFAULT 'medium'::"text", "p_points" numeric DEFAULT 1.0, "p_supporting_texts" "jsonb" DEFAULT '[]'::"jsonb", "p_answer_choices" "jsonb" DEFAULT '[]'::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  DECLARE
    v_question_id uuid;
    v_supporting_text jsonb;
    v_answer_choice jsonb;
    v_order integer := 1;
    v_next_number integer;
  BEGIN
    -- Validate teacher role
    IF NOT EXISTS (
      SELECT 1 FROM public."user"
      WHERE id = p_teacher_id AND role IN ('teacher', 'admin')
    ) THEN
      RAISE EXCEPTION 'User is not a teacher or admin';
    END IF;

    -- Calculate next question number for the course
    SELECT COALESCE(MAX(number), 0) + 1 INTO v_next_number
    FROM public.question
    WHERE id_course = p_course_id;

    -- Create the question
    INSERT INTO public.question (
      id_course, id_teacher, id_subject, id_category,
      enunciation, difficulty_level, points, is_active,
      number, created_at, updated_at
    ) VALUES (
      p_course_id, p_teacher_id, p_subject_id, p_category_id,
      p_enunciation, p_difficulty_level, p_points, true,
      v_next_number, NOW(), NOW()
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
    FOR v_answer_choice IN SELECT * FROM jsonb_array_elements(p_answer_choices)
    LOOP
      INSERT INTO public.answerchoice (
        idquestion, letter, content, correctanswer, created_at, upload_at
      ) VALUES (
        v_question_id,
        v_answer_choice->>'letter',
        COALESCE(v_answer_choice->>'content', ''),
        COALESCE((v_answer_choice->>'is_correct')::boolean, false),
        NOW(), NOW()
      );
    END LOOP;

    RETURN v_question_id;
  END;
  $$;


ALTER FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") IS 'Generates a new exam instance from a template for a student';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."gamification_season" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "starts_at" timestamp without time zone NOT NULL,
    "ends_at" timestamp without time zone NOT NULL,
    "is_active" boolean DEFAULT false NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."gamification_season" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_active_season"() RETURNS "public"."gamification_season"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  v_season public.gamification_season;
  v_now timestamp := NOW();
  v_year integer := EXTRACT(YEAR FROM v_now);
  v_month integer := EXTRACT(MONTH FROM v_now);
  v_semester integer;
  v_name text;
  v_starts_at timestamp;
  v_ends_at timestamp;
BEGIN
  -- Advisory lock to prevent concurrent creation
  PERFORM pg_advisory_xact_lock(hashtext('gamification_season_create'));

  -- Try to find active season
  SELECT * INTO v_season FROM public.gamification_season WHERE is_active = true LIMIT 1;
  IF FOUND THEN RETURN v_season; END IF;

  -- Determine current semester (January belongs to previous year's sem 2)
  IF v_month BETWEEN 2 AND 7 THEN
    v_semester := 1;
    v_starts_at := make_date(v_year, 2, 1);
    v_ends_at := make_date(v_year, 8, 1) - interval '1 second';
  ELSIF v_month = 1 THEN
    v_semester := 2;
    v_year := v_year - 1;
    v_starts_at := make_date(v_year, 8, 1);
    v_ends_at := make_date(v_year + 1, 1, 1) - interval '1 second';
  ELSE
    v_semester := 2;
    v_starts_at := make_date(v_year, 8, 1);
    v_ends_at := make_date(v_year + 1, 1, 1) - interval '1 second';
  END IF;
  v_name := v_year || '.' || v_semester;

  -- Deactivate any previously active season
  UPDATE public.gamification_season SET is_active = false WHERE is_active = true;

  -- Create with ON CONFLICT (name is unique)
  INSERT INTO public.gamification_season (name, starts_at, ends_at, is_active)
  VALUES (v_name, v_starts_at, v_ends_at, true)
  ON CONFLICT (name) DO UPDATE SET is_active = true
  RETURNING * INTO v_season;

  RETURN v_season;
END;
$$;


ALTER FUNCTION "public"."get_or_create_active_season"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid" DEFAULT NULL::"uuid", "p_exam_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("template_id" "uuid", "template_name" "text", "exam_id" "uuid", "student_id" "uuid", "student_email" "text", "student_name" "text", "attempt_id" "uuid", "question_id" "uuid", "question_enunciation" "text", "selected_choice_key" "text", "correct_choice_key" "text", "is_correct" boolean, "points_earned" numeric, "answered_at" timestamp without time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid", "p_exam_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid", "p_exam_id" "uuid") IS 'Retrieves detailed student responses for teacher analysis';



CREATE OR REPLACE FUNCTION "public"."get_teacher_questions"("p_teacher_id" "uuid" DEFAULT NULL::"uuid", "p_course_id" "uuid" DEFAULT NULL::"uuid", "p_category_id" "uuid" DEFAULT NULL::"uuid", "p_subject_id" "uuid" DEFAULT NULL::"uuid", "p_active_only" boolean DEFAULT NULL::boolean, "p_origin" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "enunciation" "text", "difficulty_level" "text", "points" numeric, "is_active" boolean, "is_enade" boolean, "category_name" "text", "subject_name" "text", "course_name" "text", "teacher_name" "text", "answer_count" bigint, "supporting_text_count" bigint, "created_at" timestamp without time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  BEGIN
    RETURN QUERY
    SELECT
      q.id,
      q.enunciation,
      q.difficulty_level,
      q.points,
      q.is_active,
      (q.id_teacher IS NULL) as is_enade,
      qc.name as category_name,
      s.name as subject_name,
      c.name as course_name,
      COALESCE(u.first_name || ' ' || u.surename, u.first_name, 'Desconhecido') as teacher_name,
      COUNT(DISTINCT ac.id) as answer_count,
      COUNT(DISTINCT st.id) as supporting_text_count,
      q.created_at
    FROM public.question q
    LEFT JOIN public.question_category qc ON q.id_category = qc.id
    LEFT JOIN public.subject s ON q.id_subject = s.id
    JOIN public.course c ON q.id_course = c.id
    LEFT JOIN public."user" u ON q.id_teacher = u.id
    LEFT JOIN public.answerchoice ac ON ac.idquestion = q.id
    LEFT JOIN public.supportingtext st ON st.id_question = q.id
    WHERE (p_teacher_id IS NULL OR q.id_teacher = p_teacher_id)
      AND (p_course_id IS NULL OR q.id_course = p_course_id)
      AND (p_category_id IS NULL OR q.id_category = p_category_id)
      AND (p_subject_id IS NULL OR q.id_subject = p_subject_id)
      AND (p_active_only IS NULL OR q.is_active = p_active_only)
      AND (
        p_origin IS NULL
        OR (p_origin = 'enade' AND q.id_teacher IS NULL)
        OR (p_origin = 'teacher' AND q.id_teacher IS NOT NULL)
      )
    GROUP BY q.id, q.enunciation, q.difficulty_level, q.points, q.is_active,
             qc.name, s.name, c.name, u.first_name, u.surename, q.created_at
    ORDER BY q.created_at DESC;
  END;
  $$;


ALTER FUNCTION "public"."get_teacher_questions"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_subject_id" "uuid", "p_active_only" boolean, "p_origin" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_teacher_question"("p_question_id" "uuid", "p_teacher_id" "uuid", "p_subject_id" "uuid" DEFAULT NULL::"uuid", "p_category_id" "uuid" DEFAULT NULL::"uuid", "p_enunciation" "text" DEFAULT NULL::"text", "p_difficulty_level" "text" DEFAULT NULL::"text", "p_points" numeric DEFAULT NULL::numeric, "p_supporting_texts" "jsonb" DEFAULT NULL::"jsonb", "p_answer_choices" "jsonb" DEFAULT NULL::"jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  DECLARE
    v_existing_question record;
    v_supporting_text jsonb;
    v_answer_choice jsonb;
    v_order integer;
  BEGIN
    SELECT id, id_teacher INTO v_existing_question
    FROM public.question
    WHERE id = p_question_id AND is_active = true;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Question not found or inactive';
    END IF;

    IF v_existing_question.id_teacher != p_teacher_id THEN
      RAISE EXCEPTION 'Question does not belong to this teacher';
    END IF;

    UPDATE public.question
    SET
      id_subject = COALESCE(p_subject_id, id_subject),
      id_category = COALESCE(p_category_id, id_category),
      enunciation = COALESCE(p_enunciation, enunciation),
      difficulty_level = COALESCE(p_difficulty_level, difficulty_level),
      points = COALESCE(p_points, points),
      updated_at = NOW()
    WHERE id = p_question_id;

    IF p_supporting_texts IS NOT NULL THEN
      DELETE FROM public.supportingtext WHERE id_question = p_question_id;

      v_order := 1;
      FOR v_supporting_text IN SELECT * FROM jsonb_array_elements(p_supporting_texts)
      LOOP
        INSERT INTO public.supportingtext (
          id_question, content_type, content, display_order, created_at
        ) VALUES (
          p_question_id,
          COALESCE(v_supporting_text->>'content_type', 'text'),
          COALESCE(v_supporting_text->>'content', ''),
          COALESCE((v_supporting_text->>'display_order')::integer, v_order),
          NOW()
        );
        v_order := v_order + 1;
      END LOOP;
    END IF;

    IF p_answer_choices IS NOT NULL THEN
      DELETE FROM public.answerchoice
      WHERE idquestion = p_question_id
        AND letter NOT IN (
          SELECT ac->>'letter'
          FROM jsonb_array_elements(p_answer_choices) AS ac
          WHERE ac->>'letter' IS NOT NULL
        );

      FOR v_answer_choice IN SELECT * FROM jsonb_array_elements(p_answer_choices)
      LOOP
        INSERT INTO public.answerchoice (
          idquestion, letter, content, correctanswer, created_at, upload_at
        ) VALUES (
          p_question_id,
          v_answer_choice->>'letter',
          COALESCE(v_answer_choice->>'content', ''),
          COALESCE((v_answer_choice->>'is_correct')::boolean, false),
          NOW(), NOW()
        )
        ON CONFLICT (idquestion, letter)
        DO UPDATE SET
          content = EXCLUDED.content,
          correctanswer = EXCLUDED.correctanswer,
          upload_at = NOW();
      END LOOP;
    END IF;
  END;
  $$;


ALTER FUNCTION "public"."update_teacher_question"("p_question_id" "uuid", "p_teacher_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."course" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "icon" "text",
    "description" "text",
    "is_active" boolean DEFAULT true,
    "course_key" "text",
    "title" "text",
    "icon_key" "text"
);


ALTER TABLE "public"."course" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."exam" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "date_start" timestamp without time zone DEFAULT "now"() NOT NULL,
    "date_end" timestamp without time zone DEFAULT ("now"() + '30 days'::interval) NOT NULL,
    "is_completed" boolean DEFAULT false NOT NULL,
    "id_user" "uuid",
    "id_course" "uuid" NOT NULL,
    "question_count" integer,
    "total_score" numeric(5,2),
    "percentage_score" numeric(5,2),
    "title" "text",
    "description" "text",
    "total_available_questions" integer DEFAULT 0,
    "time_limit_minutes" integer,
    "passing_score_percentage" numeric(5,2) DEFAULT 70.0,
    "is_active" boolean DEFAULT true,
    "id_exam_template" "uuid",
    "show_correct_answers" boolean DEFAULT true,
    "allow_review" boolean DEFAULT true,
    "attempt_number" integer DEFAULT 1,
    "total_questions" integer,
    "correct_answers" integer,
    "score" numeric(5,2),
    "passed" boolean
);


ALTER TABLE "public"."exam" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."exam_template" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "id_course" "uuid" NOT NULL,
    "id_teacher" "uuid" NOT NULL,
    "time_limit_minutes" integer,
    "question_count" integer DEFAULT 10 NOT NULL,
    "passing_score_percentage" numeric(5,2) DEFAULT 60.0,
    "shuffle_questions" boolean DEFAULT true NOT NULL,
    "shuffle_choices" boolean DEFAULT true NOT NULL,
    "show_correct_answers" boolean DEFAULT true NOT NULL,
    "allow_review" boolean DEFAULT true NOT NULL,
    "max_attempts" integer DEFAULT 1,
    "is_published" boolean DEFAULT false NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."exam_template" OWNER TO "postgres";


COMMENT ON TABLE "public"."exam_template" IS 'Exam templates created by teachers';



CREATE TABLE IF NOT EXISTS "public"."question" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "enunciation" "text" NOT NULL,
    "id_course" "uuid" NOT NULL,
    "difficulty_level" "text",
    "points" numeric(5,2) DEFAULT 1.0,
    "is_active" boolean DEFAULT true,
    "number" numeric NOT NULL,
    "question_text" "text",
    "id_teacher" "uuid",
    "id_category" "uuid",
    "question_order" integer,
    "id_subject" "uuid",
    CONSTRAINT "question_difficulty_level_check" CHECK (("difficulty_level" = ANY (ARRAY['easy'::"text", 'medium'::"text", 'hard'::"text"])))
);


ALTER TABLE "public"."question" OWNER TO "postgres";


COMMENT ON COLUMN "public"."question"."id_teacher" IS 'Reference to teacher who created this question';



COMMENT ON COLUMN "public"."question"."id_category" IS 'Reference to question category';



CREATE TABLE IF NOT EXISTS "public"."user_exam_attempts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "exam_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "question_count" integer NOT NULL,
    "started_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp without time zone,
    "duration_seconds" integer,
    "total_score" numeric(6,2),
    "percentage_score" numeric(5,2),
    "status" "text" DEFAULT 'in_progress'::"text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "is_retake" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."user_exam_attempts" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."admin_course_stats" AS
 SELECT "c"."id" AS "course_id",
    "c"."name" AS "course_name",
    "count"(DISTINCT "q"."id") AS "total_questions",
    "count"(DISTINCT "et"."id") AS "total_templates",
    "count"(DISTINCT "e"."id") AS "total_exams",
    COALESCE("avg"("uea"."percentage_score"), (0)::numeric) AS "avg_score",
    "count"(DISTINCT
        CASE
            WHEN ("uea"."percentage_score" >= COALESCE("e"."passing_score_percentage", (60)::numeric)) THEN "uea"."id"
            ELSE NULL::"uuid"
        END) AS "total_passed",
    "count"(DISTINCT "uea"."id") AS "total_attempts"
   FROM (((("public"."course" "c"
     LEFT JOIN "public"."question" "q" ON ((("q"."id_course" = "c"."id") AND ("q"."is_active" = true))))
     LEFT JOIN "public"."exam_template" "et" ON ((("et"."id_course" = "c"."id") AND ("et"."is_active" = true))))
     LEFT JOIN "public"."exam" "e" ON (("e"."id_course" = "c"."id")))
     LEFT JOIN "public"."user_exam_attempts" "uea" ON ((("uea"."exam_id" = "e"."id") AND ("uea"."status" = 'completed'::"text"))))
  GROUP BY "c"."id", "c"."name"
  ORDER BY "c"."name";


ALTER VIEW "public"."admin_course_stats" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."admin_monthly_activity" AS
 SELECT "to_char"((("started_at")::"date")::timestamp with time zone, 'YYYY-MM-DD'::"text") AS "month",
    "count"(DISTINCT "id") AS "total_attempts",
    "count"(DISTINCT "user_id") AS "active_users",
    COALESCE("avg"("percentage_score"), (0)::numeric) AS "avg_score"
   FROM "public"."user_exam_attempts" "uea"
  WHERE (("started_at" >= ("now"() - '30 days'::interval)) AND ("status" = 'completed'::"text"))
  GROUP BY (("started_at")::"date")
  ORDER BY ("to_char"((("started_at")::"date")::timestamp with time zone, 'YYYY-MM-DD'::"text"));


ALTER VIEW "public"."admin_monthly_activity" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "email" "text" NOT NULL,
    "first_name" "text",
    "surename" "text",
    "role" "text" DEFAULT 'student'::"text" NOT NULL,
    "phone" "text",
    "avatar_url" "text",
    "bio" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    CONSTRAINT "user_role_check" CHECK (("role" = ANY (ARRAY['student'::"text", 'teacher'::"text", 'admin'::"text"])))
);


ALTER TABLE "public"."user" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user"."role" IS 'User role: student, teacher, or admin';



CREATE OR REPLACE VIEW "public"."admin_platform_stats" AS
 SELECT ( SELECT "count"(*) AS "count"
           FROM "public"."user"
          WHERE ("user"."is_active" = true)) AS "total_users",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user"
          WHERE (("user"."role" = 'student'::"text") AND ("user"."is_active" = true))) AS "total_students",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user"
          WHERE (("user"."role" = 'teacher'::"text") AND ("user"."is_active" = true))) AS "total_teachers",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user"
          WHERE (("user"."role" = 'admin'::"text") AND ("user"."is_active" = true))) AS "total_admins",
    ( SELECT "count"(*) AS "count"
           FROM "public"."question"
          WHERE ("question"."is_active" = true)) AS "total_questions",
    ( SELECT "count"(*) AS "count"
           FROM "public"."exam") AS "total_exams",
    ( SELECT "count"(*) AS "count"
           FROM "public"."exam_template"
          WHERE ("exam_template"."is_active" = true)) AS "total_templates",
    ( SELECT "count"(*) AS "count"
           FROM "public"."course") AS "total_courses",
    ( SELECT COALESCE("avg"("uea"."percentage_score"), (0)::numeric) AS "coalesce"
           FROM "public"."user_exam_attempts" "uea"
          WHERE ("uea"."status" = 'completed'::"text")) AS "avg_score",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user_exam_attempts"
          WHERE ("user_exam_attempts"."status" = 'completed'::"text")) AS "total_attempts";


ALTER VIEW "public"."admin_platform_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."answerchoice" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "upload_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "letter" "text" NOT NULL,
    "content" "text" NOT NULL,
    "correctanswer" boolean NOT NULL,
    "idquestion" "uuid" NOT NULL
);


ALTER TABLE "public"."answerchoice" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."exam_template_category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id_exam_template" "uuid" NOT NULL,
    "id_category" "uuid" NOT NULL,
    "question_count" integer DEFAULT 5 NOT NULL
);


ALTER TABLE "public"."exam_template_category" OWNER TO "postgres";


COMMENT ON TABLE "public"."exam_template_category" IS 'Categories to auto-select questions from';



CREATE TABLE IF NOT EXISTS "public"."exam_template_question" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id_exam_template" "uuid" NOT NULL,
    "id_question" "uuid" NOT NULL,
    "question_order" integer DEFAULT 1 NOT NULL,
    "points_override" numeric(5,2)
);


ALTER TABLE "public"."exam_template_question" OWNER TO "postgres";


COMMENT ON TABLE "public"."exam_template_question" IS 'Questions assigned to exam templates';



CREATE TABLE IF NOT EXISTS "public"."examquestion" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone NOT NULL,
    "update_at" timestamp without time zone NOT NULL,
    "id_exam" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_question" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "question_order" integer
);


ALTER TABLE "public"."examquestion" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."question_category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "id_course" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "id_subject" "uuid"
);


ALTER TABLE "public"."question_category" OWNER TO "postgres";


COMMENT ON TABLE "public"."question_category" IS 'Categories for organizing questions by topic/subject';



CREATE TABLE IF NOT EXISTS "public"."user_gamification_points" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "season_id" "uuid" NOT NULL,
    "attempt_id" "uuid" NOT NULL,
    "exam_id" "uuid" NOT NULL,
    "course_id" "uuid" NOT NULL,
    "exam_template_id" "uuid",
    "question_count" integer NOT NULL,
    "correct_count" integer NOT NULL,
    "percentage_score" numeric(5,2) NOT NULL,
    "duration_seconds" integer NOT NULL,
    "base_points" numeric(6,2) DEFAULT 0 NOT NULL,
    "time_bonus" numeric(6,2) DEFAULT 0 NOT NULL,
    "total_points" numeric(6,2) DEFAULT 0 NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_gamification_points" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."ranking_course_view" AS
 SELECT "ugp"."user_id",
    "ugp"."season_id",
    "ugp"."course_id",
    COALESCE("u"."first_name", 'Aluno'::"text") AS "user_name",
    "u"."avatar_url",
    "c"."name" AS "course_name",
    ("sum"("ugp"."total_points"))::numeric(8,2) AS "season_points",
    ("count"("ugp"."id"))::integer AS "total_attempts",
    ("rank"() OVER (PARTITION BY "ugp"."season_id", "ugp"."course_id" ORDER BY ("sum"("ugp"."total_points")) DESC))::integer AS "rank_position"
   FROM (("public"."user_gamification_points" "ugp"
     JOIN "public"."user" "u" ON (("u"."id" = "ugp"."user_id")))
     JOIN "public"."course" "c" ON (("c"."id" = "ugp"."course_id")))
  GROUP BY "ugp"."user_id", "ugp"."season_id", "ugp"."course_id", "u"."first_name", "u"."avatar_url", "c"."name";


ALTER VIEW "public"."ranking_course_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."ranking_global_view" AS
 SELECT "ugp"."user_id",
    "ugp"."season_id",
    COALESCE("u"."first_name", 'Aluno'::"text") AS "user_name",
    "u"."avatar_url",
    ("sum"("ugp"."total_points"))::numeric(8,2) AS "season_points",
    ("count"("ugp"."id"))::integer AS "total_attempts",
    ("rank"() OVER (PARTITION BY "ugp"."season_id" ORDER BY ("sum"("ugp"."total_points")) DESC))::integer AS "rank_position"
   FROM ("public"."user_gamification_points" "ugp"
     JOIN "public"."user" "u" ON (("u"."id" = "ugp"."user_id")))
  GROUP BY "ugp"."user_id", "ugp"."season_id", "u"."first_name", "u"."avatar_url";


ALTER VIEW "public"."ranking_global_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."ranking_template_view" AS
 SELECT "ugp"."user_id",
    "ugp"."season_id",
    "ugp"."exam_template_id",
    COALESCE("et"."name", 'Template removido'::"text") AS "template_name",
    COALESCE("u"."first_name", 'Aluno'::"text") AS "user_name",
    "u"."avatar_url",
    ("sum"("ugp"."total_points"))::numeric(8,2) AS "season_points",
    ("count"("ugp"."id"))::integer AS "total_attempts",
    ("rank"() OVER (PARTITION BY "ugp"."season_id", "ugp"."exam_template_id" ORDER BY ("sum"("ugp"."total_points")) DESC))::integer AS "rank_position"
   FROM (("public"."user_gamification_points" "ugp"
     JOIN "public"."user" "u" ON (("u"."id" = "ugp"."user_id")))
     LEFT JOIN "public"."exam_template" "et" ON (("et"."id" = "ugp"."exam_template_id")))
  WHERE ("ugp"."exam_template_id" IS NOT NULL)
  GROUP BY "ugp"."user_id", "ugp"."season_id", "ugp"."exam_template_id", "et"."name", "u"."first_name", "u"."avatar_url";


ALTER VIEW "public"."ranking_template_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subject" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "id_course" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."subject" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."supportingtext" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id_question" "uuid" NOT NULL,
    "content_type" "text",
    "content" "text" NOT NULL,
    "display_order" integer DEFAULT 1,
    CONSTRAINT "supportingtext_content_type_check" CHECK (("content_type" = ANY (ARRAY['text'::"text", 'image'::"text", 'code'::"text", 'table'::"text"])))
);


ALTER TABLE "public"."supportingtext" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."teacher_exam_stats" AS
 SELECT "et"."id_teacher",
    "et"."id_course",
    "c"."name" AS "course_name",
    "count"("et"."id") AS "total_templates",
    "count"(
        CASE
            WHEN "et"."is_published" THEN 1
            ELSE NULL::integer
        END) AS "published_templates",
    "count"("e"."id") AS "total_exams_taken",
    "avg"("e"."score") AS "avg_score",
    "count"(
        CASE
            WHEN "e"."passed" THEN 1
            ELSE NULL::integer
        END) AS "total_passed"
   FROM (("public"."exam_template" "et"
     JOIN "public"."course" "c" ON (("et"."id_course" = "c"."id")))
     LEFT JOIN "public"."exam" "e" ON (("e"."id_exam_template" = "et"."id")))
  GROUP BY "et"."id_teacher", "et"."id_course", "c"."name";


ALTER VIEW "public"."teacher_exam_stats" OWNER TO "postgres";


COMMENT ON VIEW "public"."teacher_exam_stats" IS 'Statistics about exam templates and results';



CREATE OR REPLACE VIEW "public"."teacher_question_stats" AS
 SELECT "q"."id_teacher",
    "q"."id_course",
    "c"."name" AS "course_name",
    "count"("q"."id") AS "total_questions",
    "count"(
        CASE
            WHEN "q"."is_active" THEN 1
            ELSE NULL::integer
        END) AS "active_questions",
    "count"(DISTINCT "q"."id_category") AS "categories_used",
    "avg"("q"."points") AS "avg_points"
   FROM ("public"."question" "q"
     JOIN "public"."course" "c" ON (("q"."id_course" = "c"."id")))
  WHERE ("q"."id_teacher" IS NOT NULL)
  GROUP BY "q"."id_teacher", "q"."id_course", "c"."name";


ALTER VIEW "public"."teacher_question_stats" OWNER TO "postgres";


COMMENT ON VIEW "public"."teacher_question_stats" IS 'Statistics about questions created by teachers';



CREATE TABLE IF NOT EXISTS "public"."user_responses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "exam_id" "uuid" NOT NULL,
    "question_id" "uuid" NOT NULL,
    "answer_choice_id" "uuid",
    "selected_choice_key" "text",
    "is_correct" boolean,
    "points_earned" numeric(5,2) DEFAULT 0,
    "time_spent_seconds" integer,
    "answered_at" timestamp without time zone,
    "attempt_id" "uuid"
);


ALTER TABLE "public"."user_responses" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."teacher_student_responses" AS
 SELECT "et"."id_teacher",
    "et"."id" AS "template_id",
    "et"."name" AS "template_name",
    "c"."name" AS "course_name",
    "e"."id" AS "exam_id",
    "u"."id" AS "student_id",
    "u"."email" AS "student_email",
    "u"."first_name" AS "student_first_name",
    "u"."surename" AS "student_surname",
    "uea"."id" AS "attempt_id",
    "uea"."question_count",
    "uea"."started_at",
    "uea"."completed_at",
    "uea"."duration_seconds",
    "uea"."total_score",
    "uea"."percentage_score",
    "uea"."status" AS "attempt_status",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user_responses" "ur"
          WHERE (("ur"."attempt_id" = "uea"."id") AND ("ur"."is_correct" = true))) AS "correct_answers",
    ( SELECT "count"(*) AS "count"
           FROM "public"."user_responses" "ur"
          WHERE (("ur"."attempt_id" = "uea"."id") AND ("ur"."is_correct" = false))) AS "wrong_answers"
   FROM (((("public"."exam_template" "et"
     JOIN "public"."course" "c" ON (("et"."id_course" = "c"."id")))
     JOIN "public"."exam" "e" ON (("e"."id_exam_template" = "et"."id")))
     JOIN "public"."user_exam_attempts" "uea" ON (("uea"."exam_id" = "e"."id")))
     JOIN "public"."user" "u" ON (("u"."id" = "uea"."user_id")));


ALTER VIEW "public"."teacher_student_responses" OWNER TO "postgres";


COMMENT ON VIEW "public"."teacher_student_responses" IS 'Summary of student attempts on teacher exams';



ALTER TABLE ONLY "public"."answerchoice"
    ADD CONSTRAINT "answerchoice_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."course"
    ADD CONSTRAINT "course_course_key_key" UNIQUE ("course_key");



ALTER TABLE ONLY "public"."course"
    ADD CONSTRAINT "course_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."course"
    ADD CONSTRAINT "course_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exam"
    ADD CONSTRAINT "exam_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exam_template_category"
    ADD CONSTRAINT "exam_template_category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exam_template_category"
    ADD CONSTRAINT "exam_template_category_unique" UNIQUE ("id_exam_template", "id_category");



ALTER TABLE ONLY "public"."exam_template"
    ADD CONSTRAINT "exam_template_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exam_template_question"
    ADD CONSTRAINT "exam_template_question_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exam_template_question"
    ADD CONSTRAINT "exam_template_question_unique" UNIQUE ("id_exam_template", "id_question");



ALTER TABLE ONLY "public"."examquestion"
    ADD CONSTRAINT "examquestion_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."gamification_season"
    ADD CONSTRAINT "gamification_season_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."gamification_season"
    ADD CONSTRAINT "gs_name_unique" UNIQUE ("name");



ALTER TABLE ONLY "public"."question_category"
    ADD CONSTRAINT "question_category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."question_category"
    ADD CONSTRAINT "question_category_unique_name_course" UNIQUE ("name", "id_course");



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subject"
    ADD CONSTRAINT "subject_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."supportingtext"
    ADD CONSTRAINT "supportingtext_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_gamification_points"
    ADD CONSTRAINT "ugp_attempt_unique" UNIQUE ("attempt_id");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."user_exam_attempts"
    ADD CONSTRAINT "user_exam_attempts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_gamification_points"
    ADD CONSTRAINT "user_gamification_points_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "userresponse_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_answerchoice_correctanswer" ON "public"."answerchoice" USING "btree" ("correctanswer");



CREATE INDEX "idx_answerchoice_idquestion" ON "public"."answerchoice" USING "btree" ("idquestion");



CREATE UNIQUE INDEX "idx_answerchoice_unique" ON "public"."answerchoice" USING "btree" ("idquestion", "letter");



CREATE INDEX "idx_course_is_active" ON "public"."course" USING "btree" ("is_active");



CREATE INDEX "idx_course_name" ON "public"."course" USING "btree" ("name");



CREATE INDEX "idx_exam_date_end" ON "public"."exam" USING "btree" ("date_end");



CREATE INDEX "idx_exam_id_course" ON "public"."exam" USING "btree" ("id_course");



CREATE INDEX "idx_exam_id_user" ON "public"."exam" USING "btree" ("id_user");



CREATE INDEX "idx_exam_is_completed" ON "public"."exam" USING "btree" ("is_completed");



CREATE INDEX "idx_exam_template" ON "public"."exam" USING "btree" ("id_exam_template");



CREATE INDEX "idx_exam_template_course" ON "public"."exam_template" USING "btree" ("id_course");



CREATE INDEX "idx_exam_template_published" ON "public"."exam_template" USING "btree" ("is_published");



CREATE INDEX "idx_exam_template_question_template" ON "public"."exam_template_question" USING "btree" ("id_exam_template");



CREATE INDEX "idx_exam_template_teacher" ON "public"."exam_template" USING "btree" ("id_teacher");



CREATE INDEX "idx_exam_user_course" ON "public"."exam" USING "btree" ("id_user", "id_course");



CREATE INDEX "idx_examquestion_id_exam" ON "public"."examquestion" USING "btree" ("id_exam");



CREATE INDEX "idx_examquestion_id_question" ON "public"."examquestion" USING "btree" ("id_question");



CREATE UNIQUE INDEX "idx_examquestion_unique" ON "public"."examquestion" USING "btree" ("id_exam", "id_question");



CREATE INDEX "idx_question_category" ON "public"."question" USING "btree" ("id_category");



CREATE INDEX "idx_question_category_course" ON "public"."question_category" USING "btree" ("id_course");



CREATE INDEX "idx_question_category_subject" ON "public"."question_category" USING "btree" ("id_subject");



CREATE INDEX "idx_question_difficulty" ON "public"."question" USING "btree" ("difficulty_level");



CREATE INDEX "idx_question_id_course" ON "public"."question" USING "btree" ("id_course");



CREATE INDEX "idx_question_is_active" ON "public"."question" USING "btree" ("is_active");



CREATE INDEX "idx_question_subject" ON "public"."question" USING "btree" ("id_subject");



CREATE INDEX "idx_question_teacher" ON "public"."question" USING "btree" ("id_teacher");



CREATE INDEX "idx_subject_active" ON "public"."subject" USING "btree" ("is_active");



CREATE INDEX "idx_subject_course" ON "public"."subject" USING "btree" ("id_course");



CREATE INDEX "idx_supportingtext_display_order" ON "public"."supportingtext" USING "btree" ("id_question", "display_order");



CREATE INDEX "idx_supportingtext_id_question" ON "public"."supportingtext" USING "btree" ("id_question");



CREATE INDEX "idx_ugp_course" ON "public"."user_gamification_points" USING "btree" ("course_id");



CREATE INDEX "idx_ugp_exam" ON "public"."user_gamification_points" USING "btree" ("exam_id");



CREATE INDEX "idx_ugp_season" ON "public"."user_gamification_points" USING "btree" ("season_id");



CREATE INDEX "idx_ugp_template" ON "public"."user_gamification_points" USING "btree" ("exam_template_id");



CREATE INDEX "idx_ugp_user" ON "public"."user_gamification_points" USING "btree" ("user_id");



CREATE INDEX "idx_ugp_user_exam" ON "public"."user_gamification_points" USING "btree" ("user_id", "exam_id", "season_id");



CREATE INDEX "idx_ugp_user_season" ON "public"."user_gamification_points" USING "btree" ("user_id", "season_id");



CREATE INDEX "idx_ugp_user_template" ON "public"."user_gamification_points" USING "btree" ("user_id", "exam_template_id", "season_id");



CREATE INDEX "idx_user_email" ON "public"."user" USING "btree" ("email");



CREATE INDEX "idx_user_exam_attempts_course" ON "public"."user_exam_attempts" USING "btree" ("course_id");



CREATE INDEX "idx_user_exam_attempts_exam" ON "public"."user_exam_attempts" USING "btree" ("exam_id");



CREATE INDEX "idx_user_exam_attempts_status" ON "public"."user_exam_attempts" USING "btree" ("status");



CREATE INDEX "idx_user_exam_attempts_user" ON "public"."user_exam_attempts" USING "btree" ("user_id");



CREATE INDEX "idx_user_is_active" ON "public"."user" USING "btree" ("is_active");



CREATE INDEX "idx_user_responses_answer_choice" ON "public"."user_responses" USING "btree" ("answer_choice_id");



CREATE INDEX "idx_user_responses_attempt" ON "public"."user_responses" USING "btree" ("attempt_id");



CREATE UNIQUE INDEX "idx_user_responses_attempt_question" ON "public"."user_responses" USING "btree" ("attempt_id", "question_id");



CREATE INDEX "idx_user_responses_question" ON "public"."user_responses" USING "btree" ("question_id");



CREATE INDEX "idx_user_role" ON "public"."user" USING "btree" ("role");



CREATE INDEX "idx_userresponse_id_answerchoice" ON "public"."user_responses" USING "btree" ("answer_choice_id");



CREATE INDEX "idx_userresponse_id_exam" ON "public"."user_responses" USING "btree" ("exam_id");



CREATE INDEX "idx_userresponse_id_question" ON "public"."user_responses" USING "btree" ("question_id");



CREATE INDEX "idx_userresponse_is_correct" ON "public"."user_responses" USING "btree" ("is_correct");



ALTER TABLE ONLY "public"."answerchoice"
    ADD CONSTRAINT "answerchoices_idquestion_fkey" FOREIGN KEY ("idquestion") REFERENCES "public"."question"("id");



ALTER TABLE ONLY "public"."exam"
    ADD CONSTRAINT "exam_id_course_fkey" FOREIGN KEY ("id_course") REFERENCES "public"."course"("id");



ALTER TABLE ONLY "public"."exam"
    ADD CONSTRAINT "exam_id_exam_template_fkey" FOREIGN KEY ("id_exam_template") REFERENCES "public"."exam_template"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."exam"
    ADD CONSTRAINT "exam_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("id");



ALTER TABLE ONLY "public"."exam_template_category"
    ADD CONSTRAINT "exam_template_category_category_fkey" FOREIGN KEY ("id_category") REFERENCES "public"."question_category"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exam_template_category"
    ADD CONSTRAINT "exam_template_category_template_fkey" FOREIGN KEY ("id_exam_template") REFERENCES "public"."exam_template"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exam_template"
    ADD CONSTRAINT "exam_template_id_course_fkey" FOREIGN KEY ("id_course") REFERENCES "public"."course"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exam_template"
    ADD CONSTRAINT "exam_template_id_teacher_fkey" FOREIGN KEY ("id_teacher") REFERENCES "public"."user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exam_template_question"
    ADD CONSTRAINT "exam_template_question_question_fkey" FOREIGN KEY ("id_question") REFERENCES "public"."question"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exam_template_question"
    ADD CONSTRAINT "exam_template_question_template_fkey" FOREIGN KEY ("id_exam_template") REFERENCES "public"."exam_template"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."examquestion"
    ADD CONSTRAINT "examquestion_id_exam_fkey" FOREIGN KEY ("id_exam") REFERENCES "public"."exam"("id");



ALTER TABLE ONLY "public"."examquestion"
    ADD CONSTRAINT "examquestion_id_question_fkey" FOREIGN KEY ("id_question") REFERENCES "public"."question"("id");



ALTER TABLE ONLY "public"."question_category"
    ADD CONSTRAINT "question_category_id_course_fkey" FOREIGN KEY ("id_course") REFERENCES "public"."course"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."question_category"
    ADD CONSTRAINT "question_category_id_subject_fkey" FOREIGN KEY ("id_subject") REFERENCES "public"."subject"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_id_category_fkey" FOREIGN KEY ("id_category") REFERENCES "public"."question_category"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_id_course_fkey" FOREIGN KEY ("id_course") REFERENCES "public"."course"("id");



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_id_subject_fkey" FOREIGN KEY ("id_subject") REFERENCES "public"."subject"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_id_teacher_fkey" FOREIGN KEY ("id_teacher") REFERENCES "public"."user"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."subject"
    ADD CONSTRAINT "subject_id_course_fkey" FOREIGN KEY ("id_course") REFERENCES "public"."course"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."supportingtext"
    ADD CONSTRAINT "supportingtext_id_question_fkey" FOREIGN KEY ("id_question") REFERENCES "public"."question"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_exam_attempts"
    ADD CONSTRAINT "user_exam_attempts_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."course"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_exam_attempts"
    ADD CONSTRAINT "user_exam_attempts_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "public"."exam"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_exam_attempts"
    ADD CONSTRAINT "user_exam_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_gamification_points"
    ADD CONSTRAINT "user_gamification_points_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "public"."user_exam_attempts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_gamification_points"
    ADD CONSTRAINT "user_gamification_points_season_id_fkey" FOREIGN KEY ("season_id") REFERENCES "public"."gamification_season"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_gamification_points"
    ADD CONSTRAINT "user_gamification_points_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "user_responses_answer_choice_id_fkey" FOREIGN KEY ("answer_choice_id") REFERENCES "public"."answerchoice"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "user_responses_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "public"."user_exam_attempts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "user_responses_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "public"."exam"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "user_responses_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."question"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "userresponse_id_answerchoice_fkey" FOREIGN KEY ("answer_choice_id") REFERENCES "public"."answerchoice"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "userresponse_id_exam_fkey" FOREIGN KEY ("exam_id") REFERENCES "public"."exam"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responses"
    ADD CONSTRAINT "userresponse_id_question_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."question"("id") ON DELETE CASCADE;



CREATE POLICY "Admins can manage all template categories" ON "public"."exam_template_category" USING ((EXISTS ( SELECT 1
   FROM "public"."user" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can manage all template questions" ON "public"."exam_template_question" USING ((EXISTS ( SELECT 1
   FROM "public"."user" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can manage all templates" ON "public"."exam_template" USING ((EXISTS ( SELECT 1
   FROM "public"."user" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can read all users" ON "public"."user" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'admin'::"text")))));



CREATE POLICY "Anyone can read active subjects" ON "public"."subject" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Authenticated users can insert subjects" ON "public"."subject" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can update subjects" ON "public"."subject" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Everyone can view active categories" ON "public"."question_category" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Students can view published templates" ON "public"."exam_template" FOR SELECT USING ((("is_published" = true) AND ("is_active" = true)));



CREATE POLICY "Teachers can manage template categories" ON "public"."exam_template_category" USING ((EXISTS ( SELECT 1
   FROM "public"."exam_template" "et"
  WHERE (("et"."id" = "exam_template_category"."id_exam_template") AND ("et"."id_teacher" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage template questions" ON "public"."exam_template_question" USING ((EXISTS ( SELECT 1
   FROM "public"."exam_template" "et"
  WHERE (("et"."id" = "exam_template_question"."id_exam_template") AND ("et"."id_teacher" = "auth"."uid"())))));



CREATE POLICY "Teachers can manage their course categories" ON "public"."question_category" USING ((EXISTS ( SELECT 1
   FROM "public"."user" "u"
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = ANY (ARRAY['teacher'::"text", 'admin'::"text"]))))));



CREATE POLICY "Teachers can manage their templates" ON "public"."exam_template" USING (("id_teacher" = "auth"."uid"()));



ALTER TABLE "public"."exam_template" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."exam_template_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."exam_template_question" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."gamification_season" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "gamification_season_select" ON "public"."gamification_season" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."question_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subject" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "ugp_deny_delete" ON "public"."user_gamification_points" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "ugp_deny_update" ON "public"."user_gamification_points" FOR UPDATE TO "authenticated" USING (false);



CREATE POLICY "ugp_insert" ON "public"."user_gamification_points" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "ugp_select" ON "public"."user_gamification_points" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."user_gamification_points" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."admin_list_questions"("p_course_id" "uuid", "p_teacher_id" "uuid", "p_active_only" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."admin_list_questions"("p_course_id" "uuid", "p_teacher_id" "uuid", "p_active_only" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_list_questions"("p_course_id" "uuid", "p_teacher_id" "uuid", "p_active_only" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_list_users"("p_role" "text", "p_is_active" boolean, "p_search" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_list_users"("p_role" "text", "p_is_active" boolean, "p_search" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_list_users"("p_role" "text", "p_is_active" boolean, "p_search" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_toggle_user_active"("p_user_id" "uuid", "p_is_active" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_password"("p_user_id" "uuid", "p_new_password" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_update_user_role"("p_user_id" "uuid", "p_new_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_role"("p_user_id" "uuid", "p_new_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_role"("p_user_id" "uuid", "p_new_role" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_teacher_question"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_exam_from_template"("p_template_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."gamification_season" TO "anon";
GRANT ALL ON TABLE "public"."gamification_season" TO "authenticated";
GRANT ALL ON TABLE "public"."gamification_season" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_active_season"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_active_season"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_active_season"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid", "p_exam_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid", "p_exam_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_teacher_exam_responses"("p_teacher_id" "uuid", "p_template_id" "uuid", "p_exam_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_teacher_questions"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_subject_id" "uuid", "p_active_only" boolean, "p_origin" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_teacher_questions"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_subject_id" "uuid", "p_active_only" boolean, "p_origin" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_teacher_questions"("p_teacher_id" "uuid", "p_course_id" "uuid", "p_category_id" "uuid", "p_subject_id" "uuid", "p_active_only" boolean, "p_origin" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_teacher_question"("p_question_id" "uuid", "p_teacher_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_teacher_question"("p_question_id" "uuid", "p_teacher_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_teacher_question"("p_question_id" "uuid", "p_teacher_id" "uuid", "p_subject_id" "uuid", "p_category_id" "uuid", "p_enunciation" "text", "p_difficulty_level" "text", "p_points" numeric, "p_supporting_texts" "jsonb", "p_answer_choices" "jsonb") TO "service_role";


















GRANT ALL ON TABLE "public"."course" TO "anon";
GRANT ALL ON TABLE "public"."course" TO "authenticated";
GRANT ALL ON TABLE "public"."course" TO "service_role";



GRANT ALL ON TABLE "public"."exam" TO "anon";
GRANT ALL ON TABLE "public"."exam" TO "authenticated";
GRANT ALL ON TABLE "public"."exam" TO "service_role";



GRANT ALL ON TABLE "public"."exam_template" TO "anon";
GRANT ALL ON TABLE "public"."exam_template" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_template" TO "service_role";



GRANT ALL ON TABLE "public"."question" TO "anon";
GRANT ALL ON TABLE "public"."question" TO "authenticated";
GRANT ALL ON TABLE "public"."question" TO "service_role";



GRANT ALL ON TABLE "public"."user_exam_attempts" TO "anon";
GRANT ALL ON TABLE "public"."user_exam_attempts" TO "authenticated";
GRANT ALL ON TABLE "public"."user_exam_attempts" TO "service_role";



GRANT ALL ON TABLE "public"."admin_course_stats" TO "anon";
GRANT ALL ON TABLE "public"."admin_course_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_course_stats" TO "service_role";



GRANT ALL ON TABLE "public"."admin_monthly_activity" TO "anon";
GRANT ALL ON TABLE "public"."admin_monthly_activity" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_monthly_activity" TO "service_role";



GRANT ALL ON TABLE "public"."user" TO "anon";
GRANT ALL ON TABLE "public"."user" TO "authenticated";
GRANT ALL ON TABLE "public"."user" TO "service_role";



GRANT ALL ON TABLE "public"."admin_platform_stats" TO "anon";
GRANT ALL ON TABLE "public"."admin_platform_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_platform_stats" TO "service_role";



GRANT ALL ON TABLE "public"."answerchoice" TO "anon";
GRANT ALL ON TABLE "public"."answerchoice" TO "authenticated";
GRANT ALL ON TABLE "public"."answerchoice" TO "service_role";



GRANT ALL ON TABLE "public"."exam_template_category" TO "anon";
GRANT ALL ON TABLE "public"."exam_template_category" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_template_category" TO "service_role";



GRANT ALL ON TABLE "public"."exam_template_question" TO "anon";
GRANT ALL ON TABLE "public"."exam_template_question" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_template_question" TO "service_role";



GRANT ALL ON TABLE "public"."examquestion" TO "anon";
GRANT ALL ON TABLE "public"."examquestion" TO "authenticated";
GRANT ALL ON TABLE "public"."examquestion" TO "service_role";



GRANT ALL ON TABLE "public"."question_category" TO "anon";
GRANT ALL ON TABLE "public"."question_category" TO "authenticated";
GRANT ALL ON TABLE "public"."question_category" TO "service_role";



GRANT ALL ON TABLE "public"."user_gamification_points" TO "anon";
GRANT ALL ON TABLE "public"."user_gamification_points" TO "authenticated";
GRANT ALL ON TABLE "public"."user_gamification_points" TO "service_role";



GRANT ALL ON TABLE "public"."ranking_course_view" TO "anon";
GRANT ALL ON TABLE "public"."ranking_course_view" TO "authenticated";
GRANT ALL ON TABLE "public"."ranking_course_view" TO "service_role";



GRANT ALL ON TABLE "public"."ranking_global_view" TO "anon";
GRANT ALL ON TABLE "public"."ranking_global_view" TO "authenticated";
GRANT ALL ON TABLE "public"."ranking_global_view" TO "service_role";



GRANT ALL ON TABLE "public"."ranking_template_view" TO "anon";
GRANT ALL ON TABLE "public"."ranking_template_view" TO "authenticated";
GRANT ALL ON TABLE "public"."ranking_template_view" TO "service_role";



GRANT ALL ON TABLE "public"."subject" TO "anon";
GRANT ALL ON TABLE "public"."subject" TO "authenticated";
GRANT ALL ON TABLE "public"."subject" TO "service_role";



GRANT ALL ON TABLE "public"."supportingtext" TO "anon";
GRANT ALL ON TABLE "public"."supportingtext" TO "authenticated";
GRANT ALL ON TABLE "public"."supportingtext" TO "service_role";



GRANT ALL ON TABLE "public"."teacher_exam_stats" TO "anon";
GRANT ALL ON TABLE "public"."teacher_exam_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher_exam_stats" TO "service_role";



GRANT ALL ON TABLE "public"."teacher_question_stats" TO "anon";
GRANT ALL ON TABLE "public"."teacher_question_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher_question_stats" TO "service_role";



GRANT ALL ON TABLE "public"."user_responses" TO "anon";
GRANT ALL ON TABLE "public"."user_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."user_responses" TO "service_role";



GRANT ALL ON TABLE "public"."teacher_student_responses" TO "anon";
GRANT ALL ON TABLE "public"."teacher_student_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher_student_responses" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























drop extension if exists "pg_net";


