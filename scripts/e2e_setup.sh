#!/usr/bin/env bash
# Seed determinístico para os integration_test E2E, contra o Supabase LOCAL.
# Cria contas de teste (aluno/professor/admin) e um curso "Curso E2E" com 12 questões
# ENADE (id_teacher NULL), cada uma com 4 alternativas — a correta tem conteúdo "CERTA"
# e as erradas "ERRADA A/B/C" — para os testes tocarem por texto sem depender de shuffle.
# São 12 questões para permitir simulados de 5 e de 10 questões.
#
# Contas (todas senha=pass1234):
#   aluno:     e2e@test.dev       (role student, first_name "AlunoE2E")
#   professor: e2e-prof@test.dev  (role teacher)
#   admin:     e2e-admin@test.dev (role admin)
# Pré-requisito: `supabase start` rodando; jq, psql, curl no PATH.
set -uo pipefail
cd "$(dirname "$0")/.."

eval "$(supabase status -o env | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|DB_URL)=')"
API="$API_URL"; SR="$SERVICE_ROLE_KEY"; DB="$DB_URL"

criar_usuario() {
  # $1 = email
  curl -s -X POST "$API/auth/v1/admin/users" -H "apikey: $SR" -H "Authorization: Bearer $SR" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"pass1234\",\"email_confirm\":true}" >/dev/null
}

echo "==> Criando contas de teste (aluno / professor / admin / alvo)"
criar_usuario 'e2e@test.dev'        # trigger handle_new_user cria public.user como student
criar_usuario 'e2e-prof@test.dev'
criar_usuario 'e2e-admin@test.dev'
criar_usuario 'e2e-target@test.dev' # alvo descartavel p/ testes de admin (mudar role)

echo "==> Ajustando papéis/nome + semeando curso, questões e alternativas"
psql "$DB" -q -v ON_ERROR_STOP=1 <<'SQL'
-- Papéis e nome (o trigger cria todos como student por padrão).
update public."user" u set first_name = 'AlunoE2E'
  from auth.users a where a.id = u.id and a.email = 'e2e@test.dev';
update public."user" u set role = 'teacher'
  from auth.users a where a.id = u.id and a.email = 'e2e-prof@test.dev';
update public."user" u set role = 'admin'
  from auth.users a where a.id = u.id and a.email = 'e2e-admin@test.dev';
update public."user" u set first_name = 'AlvoE2E'
  from auth.users a where a.id = u.id and a.email = 'e2e-target@test.dev';

-- Curso
insert into public.course(id,name,title,course_key,created_at,updated_at,is_active)
values ('e2eccccc-0000-0000-0000-000000000000','Curso E2E','Curso E2E','e2e',now(),now(),true)
on conflict (id) do nothing;

-- Template de prova em RASCUNHO do professor (para o E2E de publicar).
insert into public.exam_template(
  id,name,description,id_course,id_teacher,question_count,
  passing_score_percentage,is_published,is_active,created_at,updated_at)
values (
  'e2eddddd-0000-0000-0000-000000000000','Template C E2E','Rascunho para publicar no E2E',
  'e2eccccc-0000-0000-0000-000000000000',
  (select id from auth.users where email = 'e2e-prof@test.dev'),
  5, 60.0, false, true, now(), now())
on conflict (id) do nothing;

-- 12 questões ENADE (id_teacher NULL) + alternativas + texto de apoio.
do $$
declare
  i int;
  qid uuid;
begin
  for i in 1..12 loop
    qid := ('e2e00000-0000-0000-0000-' || lpad(i::text, 12, '0'))::uuid;
    insert into public.question(id,enunciation,id_course,is_active,number,created_at,updated_at,id_teacher)
      values (qid, 'Questão E2E número ' || i || '. Qual a alternativa correta?',
              'e2eccccc-0000-0000-0000-000000000000', true, i, now(), now(), null)
      on conflict (id) do nothing;
    insert into public.supportingtext(id,id_question,content,content_type,display_order,created_at)
      values (gen_random_uuid(), qid, 'Texto de apoio da questão ' || i || '.', 'text', 1, now());
    insert into public.answerchoice(id,letter,content,correctanswer,idquestion,created_at,upload_at) values
      (gen_random_uuid(),'A','CERTA',    true,  qid, now(), now()),
      (gen_random_uuid(),'B','ERRADA A', false, qid, now(), now()),
      (gen_random_uuid(),'C','ERRADA B', false, qid, now(), now()),
      (gen_random_uuid(),'D','ERRADA C', false, qid, now(), now());
  end loop;
end $$;

-- Template PUBLICADO "Prova E2E" (5 questoes) do professor E2E, para testar o
-- best-score-only "de verdade" (comparacao de pontos por exam_template_id).
-- shuffle desligado -> ordem deterministica; questoes 1..5 ligadas ao template.
insert into public.exam_template(
  id, created_at, updated_at, name, id_course, id_teacher,
  question_count, passing_score_percentage,
  shuffle_questions, shuffle_choices, show_correct_answers, allow_review,
  is_published, is_active)
select 'e2e11111-1111-1111-1111-111111111111', now(), now(), 'Prova E2E',
       'e2eccccc-0000-0000-0000-000000000000', a.id,
       5, 70, false, false, true, true, true, true
from auth.users a where a.email = 'e2e-prof@test.dev'
on conflict (id) do nothing;

insert into public.exam_template_question(id, created_at, id_exam_template, id_question, question_order)
select gen_random_uuid(), now(), 'e2e11111-1111-1111-1111-111111111111',
       ('e2e00000-0000-0000-0000-' || lpad(i::text, 12, '0'))::uuid, i
from generate_series(1,5) as i
where not exists (
  select 1 from public.exam_template_question
  where id_exam_template = 'e2e11111-1111-1111-1111-111111111111'
);
SQL

echo "==> Seed E2E pronto (aluno/professor/admin, curso='Curso E2E', 12 questões)"
