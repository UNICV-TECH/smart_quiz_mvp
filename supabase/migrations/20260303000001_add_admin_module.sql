-- Migration: Add Admin Module
-- Adds admin functionality: user management, global content visibility, analytics
-- Reference: follows pattern from 20250204000001_add_teacher_module.sql

-- =============================================================================
-- 1. USER TABLE - Add is_active for soft delete
-- =============================================================================

ALTER TABLE public."user"
ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

CREATE INDEX IF NOT EXISTS idx_user_is_active ON public."user"(is_active);

-- =============================================================================
-- 2. ADMIN ANALYTICS VIEWS
-- =============================================================================

-- Platform-wide statistics
CREATE OR REPLACE VIEW public.admin_platform_stats AS
SELECT
  (SELECT COUNT(*) FROM public."user" WHERE is_active = true) AS total_users,
  (SELECT COUNT(*) FROM public."user" WHERE role = 'student' AND is_active = true) AS total_students,
  (SELECT COUNT(*) FROM public."user" WHERE role = 'teacher' AND is_active = true) AS total_teachers,
  (SELECT COUNT(*) FROM public."user" WHERE role = 'admin' AND is_active = true) AS total_admins,
  (SELECT COUNT(*) FROM public.question WHERE is_active = true) AS total_questions,
  (SELECT COUNT(*) FROM public.exam) AS total_exams,
  (SELECT COUNT(*) FROM public.exam_template WHERE is_active = true) AS total_templates,
  (SELECT COUNT(*) FROM public.course) AS total_courses,
  (SELECT COALESCE(AVG(uea.percentage_score), 0) FROM public.user_exam_attempts uea WHERE uea.status = 'completed') AS avg_score,
  (SELECT COUNT(*) FROM public.user_exam_attempts WHERE status = 'completed') AS total_attempts;

-- Per-course statistics
CREATE OR REPLACE VIEW public.admin_course_stats AS
SELECT
  c.id AS course_id,
  c.name AS course_name,
  COUNT(DISTINCT q.id) AS total_questions,
  COUNT(DISTINCT et.id) AS total_templates,
  COUNT(DISTINCT e.id) AS total_exams,
  COALESCE(AVG(uea.percentage_score), 0) AS avg_score,
  COUNT(DISTINCT CASE WHEN uea.percentage_score >= COALESCE(e.passing_score_percentage, 60) THEN uea.id END) AS total_passed,
  COUNT(DISTINCT uea.id) AS total_attempts
FROM public.course c
LEFT JOIN public.question q ON q.id_course = c.id AND q.is_active = true
LEFT JOIN public.exam_template et ON et.id_course = c.id AND et.is_active = true
LEFT JOIN public.exam e ON e.id_course = c.id
LEFT JOIN public.user_exam_attempts uea ON uea.exam_id = e.id AND uea.status = 'completed'
GROUP BY c.id, c.name
ORDER BY c.name;

-- Monthly activity (last 12 months)
CREATE OR REPLACE VIEW public.admin_monthly_activity AS
SELECT
  TO_CHAR(date_trunc('month', uea.started_at), 'YYYY-MM') AS month,
  COUNT(DISTINCT uea.id) AS total_attempts,
  COUNT(DISTINCT uea.user_id) AS active_users,
  COALESCE(AVG(uea.percentage_score), 0) AS avg_score
FROM public.user_exam_attempts uea
WHERE uea.started_at >= NOW() - INTERVAL '12 months'
  AND uea.status = 'completed'
GROUP BY date_trunc('month', uea.started_at)
ORDER BY month;

-- =============================================================================
-- 3. ADMIN RPC FUNCTIONS
-- =============================================================================

-- List all users with stats (admin only)
CREATE OR REPLACE FUNCTION admin_list_users(
  p_role text DEFAULT NULL,
  p_is_active boolean DEFAULT NULL,
  p_search text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  role text,
  is_active boolean,
  created_at timestamp,
  exam_count bigint,
  avg_score double precision
) AS $$
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
    u.id,
    COALESCE(u.first_name, '') AS name,
    u.email,
    u.role,
    u.is_active,
    u.created_at,
    COUNT(DISTINCT uea.id) AS exam_count,
    COALESCE(AVG(uea.percentage_score), 0) AS avg_score
  FROM public."user" u
  LEFT JOIN public.user_exam_attempts uea ON uea.user_id = u.id AND uea.status = 'completed'
  WHERE (p_role IS NULL OR u.role = p_role)
    AND (p_is_active IS NULL OR u.is_active = p_is_active)
    AND (p_search IS NULL OR u.email ILIKE '%' || p_search || '%' OR u.first_name ILIKE '%' || p_search || '%')
  GROUP BY u.id, u.first_name, u.email, u.role, u.is_active, u.created_at
  ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update user role (admin only, prevents self-demotion)
CREATE OR REPLACE FUNCTION admin_update_user_role(
  p_user_id uuid,
  p_new_role text
)
RETURNS void AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Toggle user active status (admin only, prevents self-deactivation)
CREATE OR REPLACE FUNCTION admin_toggle_user_active(
  p_user_id uuid,
  p_is_active boolean
)
RETURNS void AS $$
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

  UPDATE public."user"
  SET is_active = p_is_active, updated_at = NOW()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- List all questions globally (admin only)
CREATE OR REPLACE FUNCTION admin_list_questions(
  p_course_id uuid DEFAULT NULL,
  p_teacher_id uuid DEFAULT NULL,
  p_active_only boolean DEFAULT true
)
RETURNS TABLE (
  id uuid,
  enunciation text,
  difficulty_level text,
  points decimal,
  is_active boolean,
  course_name text,
  teacher_name text,
  teacher_email text,
  answer_count bigint,
  created_at timestamp
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 4. RLS POLICIES FOR ADMIN
-- =============================================================================

-- Admin can read all users
DROP POLICY IF EXISTS "Admins can read all users" ON public."user";
CREATE POLICY "Admins can read all users" ON public."user"
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public."user" u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- Admin can manage all exam templates
DROP POLICY IF EXISTS "Admins can manage all templates" ON public.exam_template;
CREATE POLICY "Admins can manage all templates" ON public.exam_template
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public."user" u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- Admin can manage all template questions
DROP POLICY IF EXISTS "Admins can manage all template questions" ON public.exam_template_question;
CREATE POLICY "Admins can manage all template questions" ON public.exam_template_question
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public."user" u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- Admin can manage all template categories
DROP POLICY IF EXISTS "Admins can manage all template categories" ON public.exam_template_category;
CREATE POLICY "Admins can manage all template categories" ON public.exam_template_category
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public."user" u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- =============================================================================
-- 5. DOCUMENTATION
-- =============================================================================

COMMENT ON FUNCTION admin_list_users IS 'Lists all users with exam stats, admin only';
COMMENT ON FUNCTION admin_update_user_role IS 'Updates user role, admin only, prevents self-demotion';
COMMENT ON FUNCTION admin_toggle_user_active IS 'Toggles user active status, admin only, prevents self-deactivation';
COMMENT ON FUNCTION admin_list_questions IS 'Lists all questions globally with teacher info, admin only';
COMMENT ON VIEW public.admin_platform_stats IS 'Platform-wide statistics for admin dashboard';
COMMENT ON VIEW public.admin_course_stats IS 'Per-course statistics for admin dashboard';
COMMENT ON VIEW public.admin_monthly_activity IS 'Monthly activity for admin charts';

-- =============================================================================
-- PROMOTE FIRST ADMIN
-- Run this manually in Supabase SQL Editor:
-- UPDATE public."user" SET role = 'admin' WHERE email = '<admin-email>';
-- =============================================================================
