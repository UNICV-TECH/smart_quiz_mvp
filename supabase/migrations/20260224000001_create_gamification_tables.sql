-- ============================================================
-- Gamification System — Smart Quiz
-- Tables, Views, RPC, RLS, Indexes, Seed
-- ============================================================

-- 1. Gamification Season
CREATE TABLE IF NOT EXISTS public.gamification_season (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  starts_at timestamp without time zone NOT NULL,
  ends_at timestamp without time zone NOT NULL,
  is_active boolean NOT NULL DEFAULT false,
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  CONSTRAINT gs_name_unique UNIQUE (name)
);

-- 2. User Gamification Points
CREATE TABLE IF NOT EXISTS public.user_gamification_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public."user"(id) ON DELETE CASCADE,
  season_id uuid NOT NULL REFERENCES public.gamification_season(id) ON DELETE CASCADE,
  attempt_id uuid NOT NULL REFERENCES public.user_exam_attempts(id) ON DELETE CASCADE,
  exam_id uuid NOT NULL,
  course_id uuid NOT NULL,
  exam_template_id uuid,
  question_count integer NOT NULL,
  correct_count integer NOT NULL,
  percentage_score numeric(5,2) NOT NULL,
  duration_seconds integer NOT NULL,
  base_points numeric(6,2) NOT NULL DEFAULT 0,
  time_bonus numeric(6,2) NOT NULL DEFAULT 0,
  total_points numeric(6,2) NOT NULL DEFAULT 0,
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  CONSTRAINT ugp_attempt_unique UNIQUE (attempt_id)
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_ugp_user ON public.user_gamification_points(user_id);
CREATE INDEX IF NOT EXISTS idx_ugp_season ON public.user_gamification_points(season_id);
CREATE INDEX IF NOT EXISTS idx_ugp_course ON public.user_gamification_points(course_id);
CREATE INDEX IF NOT EXISTS idx_ugp_exam ON public.user_gamification_points(exam_id);
CREATE INDEX IF NOT EXISTS idx_ugp_template ON public.user_gamification_points(exam_template_id);
CREATE INDEX IF NOT EXISTS idx_ugp_user_season ON public.user_gamification_points(user_id, season_id);
CREATE INDEX IF NOT EXISTS idx_ugp_user_exam ON public.user_gamification_points(user_id, exam_id, season_id);
CREATE INDEX IF NOT EXISTS idx_ugp_user_template ON public.user_gamification_points(user_id, exam_template_id, season_id);

-- 4. RPC: get_or_create_active_season
CREATE OR REPLACE FUNCTION public.get_or_create_active_season()
RETURNS public.gamification_season AS $$
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
  -- Try to find active season
  SELECT * INTO v_season FROM public.gamification_season WHERE is_active = true LIMIT 1;
  IF FOUND THEN RETURN v_season; END IF;

  -- Determine current semester
  IF v_month BETWEEN 2 AND 7 THEN
    v_semester := 1;
    v_starts_at := make_date(v_year, 2, 1);
    v_ends_at := make_date(v_year, 7, 31) + interval '23:59:59';
  ELSE
    v_semester := 2;
    v_starts_at := make_date(v_year, 8, 1);
    v_ends_at := make_date(v_year, 12, 31) + interval '23:59:59';
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Views

-- Global ranking view
CREATE OR REPLACE VIEW public.ranking_global_view AS
SELECT
  ugp.user_id,
  ugp.season_id,
  COALESCE(u.first_name, 'Aluno') AS user_name,
  u.avatar_url,
  SUM(ugp.total_points)::numeric(8,2) AS season_points,
  COUNT(ugp.id)::int AS total_attempts,
  RANK() OVER (
    PARTITION BY ugp.season_id
    ORDER BY SUM(ugp.total_points) DESC
  )::int AS rank_position
FROM public.user_gamification_points ugp
JOIN public."user" u ON u.id = ugp.user_id
GROUP BY ugp.user_id, ugp.season_id, u.first_name, u.avatar_url;

-- Course ranking view
CREATE OR REPLACE VIEW public.ranking_course_view AS
SELECT
  ugp.user_id,
  ugp.season_id,
  ugp.course_id,
  COALESCE(u.first_name, 'Aluno') AS user_name,
  u.avatar_url,
  c.name AS course_name,
  SUM(ugp.total_points)::numeric(8,2) AS season_points,
  COUNT(ugp.id)::int AS total_attempts,
  RANK() OVER (
    PARTITION BY ugp.season_id, ugp.course_id
    ORDER BY SUM(ugp.total_points) DESC
  )::int AS rank_position
FROM public.user_gamification_points ugp
JOIN public."user" u ON u.id = ugp.user_id
JOIN public.course c ON c.id = ugp.course_id
GROUP BY ugp.user_id, ugp.season_id, ugp.course_id, u.first_name, u.avatar_url, c.name;

-- Template ranking view
CREATE OR REPLACE VIEW public.ranking_template_view AS
SELECT
  ugp.user_id,
  ugp.season_id,
  ugp.exam_template_id,
  et.name AS template_name,
  COALESCE(u.first_name, 'Aluno') AS user_name,
  u.avatar_url,
  SUM(ugp.total_points)::numeric(8,2) AS season_points,
  COUNT(ugp.id)::int AS total_attempts,
  RANK() OVER (
    PARTITION BY ugp.season_id, ugp.exam_template_id
    ORDER BY SUM(ugp.total_points) DESC
  )::int AS rank_position
FROM public.user_gamification_points ugp
JOIN public."user" u ON u.id = ugp.user_id
JOIN public.exam_template et ON et.id = ugp.exam_template_id
WHERE ugp.exam_template_id IS NOT NULL
GROUP BY ugp.user_id, ugp.season_id, ugp.exam_template_id, et.name, u.first_name, u.avatar_url;

-- 6. RLS Policies

ALTER TABLE public.gamification_season ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_gamification_points ENABLE ROW LEVEL SECURITY;

-- Season: readable by all authenticated users
CREATE POLICY "gamification_season_select" ON public.gamification_season
  FOR SELECT TO authenticated USING (true);

-- Points: readable by all authenticated users
CREATE POLICY "ugp_select" ON public.user_gamification_points
  FOR SELECT TO authenticated USING (true);

-- Points: insert restricted to own user
CREATE POLICY "ugp_insert" ON public.user_gamification_points
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Grant execute on RPC to authenticated users
GRANT EXECUTE ON FUNCTION public.get_or_create_active_season() TO authenticated;

-- Grant select on views to authenticated users
GRANT SELECT ON public.ranking_global_view TO authenticated;
GRANT SELECT ON public.ranking_course_view TO authenticated;
GRANT SELECT ON public.ranking_template_view TO authenticated;

-- 7. Seed: Season 2026.1
INSERT INTO public.gamification_season (name, starts_at, ends_at, is_active)
VALUES ('2026.1', '2026-02-01 00:00:00', '2026-07-31 23:59:59', true)
ON CONFLICT (name) DO NOTHING;
