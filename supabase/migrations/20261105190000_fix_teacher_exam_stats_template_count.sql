-- teacher_exam_stats counted templates over the rows of `exam_template LEFT JOIN exam`, so a
-- template with N generated exams counted N times (teacher dashboard showed 6 templates for 2,
-- and "5 publicados" for 1). Count distinct template ids instead.
--
-- Templates are soft-deleted (is_active = false) and the teacher's template screen only lists
-- active ones, so the template counters now ignore deleted templates too (same rule as
-- admin_course_stats). Exam counters keep counting every exam, including exams generated from
-- templates deleted later: that history is real.
--
-- Same columns, names, order and types (bigint), so CREATE OR REPLACE keeps the grants from
-- 20261005120000. security_invoker is restated because CREATE OR REPLACE VIEW without WITH
-- resets the view options.
create or replace view public.teacher_exam_stats with (security_invoker = true) as
 select et.id_teacher,
    et.id_course,
    c.name as course_name,
    count(distinct et.id) filter (where et.is_active) as total_templates,
    count(distinct et.id) filter (where et.is_active and et.is_published) as published_templates,
    count(e.id) as total_exams_taken,
    avg(e.score) as avg_score,
    count(
        case
            when e.passed then 1
            else null::integer
        end) as total_passed
   from public.exam_template et
     join public.course c on et.id_course = c.id
     left join public.exam e on e.id_exam_template = et.id
  group by et.id_teacher, et.id_course, c.name;

comment on view public.teacher_exam_stats is 'Statistics about exam templates and results';
