-- =============================================================================
-- Migration: Update get_teacher_questions to support all-questions view
-- Description: Makes p_teacher_id optional, adds p_subject_id filter,
--              adds p_origin filter (enade/teacher), returns subject_name,
--              teacher_name and is_enade for display.
--              p_active_only accepts NULL to return all questions (active + inactive).
-- =============================================================================

-- Drop ALL old signatures to avoid ambiguity
DROP FUNCTION IF EXISTS get_teacher_questions(uuid, uuid, uuid, boolean);
DROP FUNCTION IF EXISTS get_teacher_questions(uuid, uuid, uuid, uuid, boolean);
DROP FUNCTION IF EXISTS get_teacher_questions(uuid, uuid, uuid, uuid, boolean, text);

CREATE OR REPLACE FUNCTION get_teacher_questions(
  p_teacher_id uuid DEFAULT NULL,
  p_course_id uuid DEFAULT NULL,
  p_category_id uuid DEFAULT NULL,
  p_subject_id uuid DEFAULT NULL,
  p_active_only boolean DEFAULT NULL,
  p_origin text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  enunciation text,
  difficulty_level text,
  points decimal,
  is_active boolean,
  is_enade boolean,
  category_name text,
  subject_name text,
  course_name text,
  teacher_name text,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_teacher_questions IS 'Retrieves questions with optional filters by teacher, course, category, subject, origin (enade/teacher), and active status. p_active_only=NULL returns all.';
