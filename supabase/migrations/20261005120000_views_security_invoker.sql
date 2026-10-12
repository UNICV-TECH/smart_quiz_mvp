-- Close the 9 SECURITY DEFINER views flagged by the Supabase advisor (security_definer_view).
-- They ran as owner `postgres` (bypassing RLS) and the baseline granted ALL to `anon`, so the
-- public anon key could read student names, e-mails and scores without logging in.
--
-- Per-view decision:
--   - admin_* and teacher_*_stats: security_invoker = true. Admin/teacher already read the
--     underlying rows through RLS (is_teacher_or_admin), so dashboards keep working; a student
--     querying them only aggregates their own rows.
--   - ranking_*_view: security_invoker = true, but students cannot read other rows of
--     public."user" under RLS, so name/avatar now come from ranking_profiles(), a narrow
--     SECURITY DEFINER function exposing only id, first_name and avatar_url of users that have
--     points. Columns of the views are unchanged, so the app needs no change.
--   - teacher_student_responses: not used by the app and carries PII; security_invoker = true
--     and readable only by service_role.
--   - All views: anon loses every privilege; authenticated keeps SELECT only.

-- ---------------------------------------------------------------------------
-- 1. Public ranking profile (only what the ranking screen shows)
-- ---------------------------------------------------------------------------
create or replace function public.ranking_profiles()
  returns table (id uuid, first_name text, avatar_url text)
  language sql stable security definer set search_path = public, pg_temp
  as $$
    select u.id, u.first_name, u.avatar_url
    from public."user" u
    where exists (select 1 from public.user_gamification_points p where p.user_id = u.id)
  $$;

revoke all on function public.ranking_profiles() from public, anon;
grant execute on function public.ranking_profiles() to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. Rankings: same columns, invoker rights, profile via ranking_profiles()
-- ---------------------------------------------------------------------------
create or replace view public.ranking_global_view with (security_invoker = true) as
 select ugp.user_id,
    ugp.season_id,
    coalesce(u.first_name, 'Aluno'::text) as user_name,
    u.avatar_url,
    (sum(ugp.total_points))::numeric(8,2) as season_points,
    (count(ugp.id))::integer as total_attempts,
    (rank() over (partition by ugp.season_id order by (sum(ugp.total_points)) desc))::integer as rank_position
   from public.user_gamification_points ugp
     join public.ranking_profiles() u on u.id = ugp.user_id
  group by ugp.user_id, ugp.season_id, u.first_name, u.avatar_url;

create or replace view public.ranking_course_view with (security_invoker = true) as
 select ugp.user_id,
    ugp.season_id,
    ugp.course_id,
    coalesce(u.first_name, 'Aluno'::text) as user_name,
    u.avatar_url,
    c.name as course_name,
    (sum(ugp.total_points))::numeric(8,2) as season_points,
    (count(ugp.id))::integer as total_attempts,
    (rank() over (partition by ugp.season_id, ugp.course_id order by (sum(ugp.total_points)) desc))::integer as rank_position
   from public.user_gamification_points ugp
     join public.ranking_profiles() u on u.id = ugp.user_id
     join public.course c on c.id = ugp.course_id
  group by ugp.user_id, ugp.season_id, ugp.course_id, u.first_name, u.avatar_url, c.name;

create or replace view public.ranking_template_view with (security_invoker = true) as
 select ugp.user_id,
    ugp.season_id,
    ugp.exam_template_id,
    coalesce(et.name, 'Template removido'::text) as template_name,
    coalesce(u.first_name, 'Aluno'::text) as user_name,
    u.avatar_url,
    (sum(ugp.total_points))::numeric(8,2) as season_points,
    (count(ugp.id))::integer as total_attempts,
    (rank() over (partition by ugp.season_id, ugp.exam_template_id order by (sum(ugp.total_points)) desc))::integer as rank_position
   from public.user_gamification_points ugp
     join public.ranking_profiles() u on u.id = ugp.user_id
     left join public.exam_template et on et.id = ugp.exam_template_id
  where ugp.exam_template_id is not null
  group by ugp.user_id, ugp.season_id, ugp.exam_template_id, et.name, u.first_name, u.avatar_url;

-- ---------------------------------------------------------------------------
-- 3. Dashboards: invoker rights, RLS of the caller applies
-- ---------------------------------------------------------------------------
alter view public.admin_course_stats        set (security_invoker = true);
alter view public.admin_monthly_activity    set (security_invoker = true);
alter view public.admin_platform_stats      set (security_invoker = true);
alter view public.teacher_exam_stats        set (security_invoker = true);
alter view public.teacher_question_stats    set (security_invoker = true);
alter view public.teacher_student_responses set (security_invoker = true);

-- ---------------------------------------------------------------------------
-- 4. Grants: anon out of every view; authenticated read-only
-- ---------------------------------------------------------------------------
revoke all on
  public.admin_course_stats, public.admin_monthly_activity, public.admin_platform_stats,
  public.ranking_course_view, public.ranking_global_view, public.ranking_template_view,
  public.teacher_exam_stats, public.teacher_question_stats, public.teacher_student_responses
  from anon;

revoke insert, update, delete, truncate, references, trigger on
  public.admin_course_stats, public.admin_monthly_activity, public.admin_platform_stats,
  public.ranking_course_view, public.ranking_global_view, public.ranking_template_view,
  public.teacher_exam_stats, public.teacher_question_stats
  from authenticated;

revoke all on public.teacher_student_responses from authenticated;
