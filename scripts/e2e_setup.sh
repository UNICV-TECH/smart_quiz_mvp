#!/usr/bin/env bash
# Seed determinístico para o integration_test E2E, contra o Supabase LOCAL.
# Cria um aluno de teste (login conhecido) e um curso "Curso E2E" com 6 questões ENADE
# (id_teacher NULL), cada uma com 4 alternativas — a correta tem conteúdo "CERTA" e as
# erradas "ERRADA A/B/C" — para o teste tocar por texto sem depender de ordem/shuffle.
#
# Login do aluno:  e2e@test.dev / pass1234
# Pré-requisito: `supabase start` rodando; jq, psql, curl no PATH.
set -uo pipefail
cd "$(dirname "$0")/.."

eval "$(supabase status -o env | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|DB_URL)=')"
API="$API_URL"; SR="$SERVICE_ROLE_KEY"; DB="$DB_URL"

echo "==> Criando aluno de teste (e2e@test.dev)"
curl -s -X POST "$API/auth/v1/admin/users" -H "apikey: $SR" -H "Authorization: Bearer $SR" \
  -H 'Content-Type: application/json' \
  -d '{"email":"e2e@test.dev","password":"pass1234","email_confirm":true}' >/dev/null
# o trigger handle_new_user cria public.user como student

echo "==> Semeando curso + questões + alternativas + textos de apoio"
CID=e2eccccc-0000-0000-0000-000000000000
psql "$DB" -q -v ON_ERROR_STOP=1 <<'SQL'
-- curso
insert into public.course(id,name,title,course_key,created_at,updated_at,is_active)
values ('e2eccccc-0000-0000-0000-000000000000','Curso E2E','Curso E2E','e2e',now(),now(),true)
on conflict (id) do nothing;

-- 6 questões ENADE (id_teacher NULL) + alternativas + texto de apoio
do $$
declare
  i int;
  qid uuid;
begin
  for i in 1..6 loop
    qid := ('e2e00000-0000-0000-0000-00000000000' || i)::uuid;
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
SQL

echo "==> Seed E2E pronto (aluno=e2e@test.dev / senha=pass1234, curso='Curso E2E', 6 questões)"
