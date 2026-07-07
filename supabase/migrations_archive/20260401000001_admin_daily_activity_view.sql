-- =============================================================================
-- Migration: Replace monthly activity view with daily activity (last 30 days)
-- =============================================================================

CREATE OR REPLACE VIEW public.admin_monthly_activity AS
SELECT
  TO_CHAR(uea.started_at::date, 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT uea.id) AS total_attempts,
  COUNT(DISTINCT uea.user_id) AS active_users,
  COALESCE(AVG(uea.percentage_score), 0) AS avg_score
FROM public.user_exam_attempts uea
WHERE uea.started_at >= NOW() - INTERVAL '30 days'
  AND uea.status = 'completed'
GROUP BY uea.started_at::date
ORDER BY month;
