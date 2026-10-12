#!/usr/bin/env bash
# Harness de regressao de RLS: valida que os fluxos reais do app continuam funcionando
# (e que acesso cruzado/anon fica bloqueado) apos habilitar Row Level Security.
#
# Bate na MESMA API que o app Flutter usa (PostgREST + GoTrue) contra o Supabase LOCAL,
# com JWTs reais de student/teacher/anon. NAO toca em producao.
#
# Pre-requisitos: `supabase start` rodando; jq, psql, curl no PATH.
# Uso:  scripts/test_rls.sh [caminho_da_migration_rls.sql]
#   - Se a migration RLS ja estiver em supabase/migrations/, rode sem argumento
#     (o `db reset` a aplica). Senao, passe o arquivo para aplicar por cima do baseline.
set -uo pipefail
cd "$(dirname "$0")/.."

RLS_SQL="${1:-}"

# --- env local ---
eval "$(supabase status -o env | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|DB_URL)=')"
API="$API_URL"; ANON="$ANON_KEY"; SR="$SERVICE_ROLE_KEY"; DB="$DB_URL"

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  PASS  %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL  %s\n' "$1"; }
eq()   { [ "$2" = "$3" ] && ok "$1 (=$2)" || bad "$1 (obtido=$2 esperado=$3)"; }
ge()   { [ "$2" -ge "$3" ] 2>/dev/null && ok "$1 (=$2 >= $3)" || bad "$1 (obtido=$2 esperado>=$3)"; }

# --- REST helpers (mesma interface do app) ---
sel()      { curl -s -H "apikey: $ANON" -H "Authorization: Bearer $1" "$API/rest/v1/$2" | jq 'if type=="array" then length else -1 end'; }
sel_anon() { curl -s -H "apikey: $ANON" "$API/rest/v1/$1" | jq 'if type=="array" then length else -1 end'; }
ins()      { curl -s -o /dev/null -w '%{http_code}' -X POST -H "apikey: $ANON" -H "Authorization: Bearer $1" \
                  -H 'Content-Type: application/json' -H 'Prefer: return=minimal' "$API/rest/v1/$2" -d "$3"; }
val()      { curl -s -H "apikey: $ANON" -H "Authorization: Bearer $1" "$API/rest/v1/$2" | jq -r "$3"; }
rpc()      { curl -s -o /dev/null -w '%{http_code}' -X POST -H "apikey: $ANON" ${2:+-H "Authorization: Bearer $2"} \
                  -H 'Content-Type: application/json' "$API/rest/v1/rpc/$1" -d '{}'; }
nested_ac(){ curl -s -H "apikey: $ANON" -H "Authorization: Bearer $1" \
                  "$API/rest/v1/question?select=id,answerchoice(id)&id=eq.$2" | jq '.[0].answerchoice | length'; }

echo "==> Reset do banco LOCAL + baseline"
supabase db reset --local >/dev/null 2>&1
if [ -n "$RLS_SQL" ]; then
  echo "==> Aplicando migration RLS: $RLS_SQL"
  psql "$DB" -v ON_ERROR_STOP=1 -q -f "$RLS_SQL" || { echo "ERRO ao aplicar RLS"; exit 2; }
fi

echo "==> Criando usuarios reais via Auth admin (trigger cria public.user como student)"
mkuser() { curl -s -X POST "$API/auth/v1/admin/users" -H "apikey: $SR" -H "Authorization: Bearer $SR" \
                -H 'Content-Type: application/json' \
                -d "{\"email\":\"$1\",\"password\":\"pass1234\",\"email_confirm\":true}" | jq -r '.id'; }
S1=$(mkuser s1@test.dev); S2=$(mkuser s2@test.dev); T1=$(mkuser t1@test.dev); A1=$(mkuser a1@test.dev)
psql "$DB" -q -c "update public.\"user\" set role='teacher' where id='$T1';"
psql "$DB" -q -c "update public.\"user\" set role='admin' where id='$A1';"

echo "==> Checando trigger de provisionamento (public.user criado no signup)"
PROV=$(psql "$DB" -tAc "select count(*) from public.\"user\" where id in ('$S1','$S2','$T1');")
eq "trigger handle_new_user provisionou 3 users" "$PROV" "3"
psql "$DB" -q -c "update public.\"user\" set first_name='Aluno1' where id='$S1'; update public.\"user\" set first_name='Aluno2' where id='$S2';"

echo "==> Seed de conteudo (dono = student1)"
CID=cccccccc-cccc-cccc-cccc-cccccccccccc
Q1=a1111111-1111-1111-1111-111111111111
Q2=a2222222-2222-2222-2222-222222222222
E1=e1111111-1111-1111-1111-111111111111
AT1=a7777777-7777-7777-7777-777777777777
AT2=a8888888-8888-8888-8888-888888888888
E2=e2222222-2222-2222-2222-222222222222
TPL=f1111111-1111-1111-1111-111111111111
SEA=5ea50000-0000-0000-0000-000000000001
psql "$DB" -q -v ON_ERROR_STOP=1 <<SQL
insert into public.course(id,name,created_at,updated_at,is_active) values ('$CID','Curso X',now(),now(),true) on conflict do nothing;
insert into public.question(id,enunciation,id_course,is_active,number,created_at,updated_at,id_teacher) values
 ('$Q1','Enunciado ENADE','$CID',true,1,now(),now(),null),
 ('a2222222-2222-2222-2222-222222222222','Enunciado teacher','$CID',true,2,now(),now(),'$T1') on conflict do nothing;
insert into public.answerchoice(id,letter,content,correctanswer,idquestion,created_at,upload_at) values
 (gen_random_uuid(),'A','A',true,'$Q1',now(),now()),(gen_random_uuid(),'B','B',false,'$Q1',now(),now());
insert into public.supportingtext(id,id_question,content,content_type,display_order,created_at) values
 (gen_random_uuid(),'$Q1','apoio','text',1,now());
insert into public.exam(id,created_at,updated_at,date_start,date_end,is_completed,id_user,id_course) values
 ('$E1',now(),now(),now(),now(),false,'$S1','$CID') on conflict do nothing;
insert into public.examquestion(id,created_at,update_at,id_exam,id_question) values (gen_random_uuid(),now(),now(),'$E1','$Q1');
insert into public.user_exam_attempts(id,user_id,exam_id,course_id,question_count,started_at,status,created_at,updated_at,is_retake) values
 ('$AT1','$S1','$E1','$CID',1,now(),'completed',now(),now(),false) on conflict do nothing;
insert into public.user_responses(id,created_at,exam_id,question_id,attempt_id) values
 (gen_random_uuid(),now(),'$E1','$Q1','$AT1');
-- gamificacao + template publicado do teacher1 (alimenta as 9 views)
insert into public.exam_template(id,name,id_course,id_teacher,is_published,is_active) values
 ('$TPL','Simulado T1','$CID','$T1',true,true);
update public.exam set id_exam_template='$TPL', score=80, passed=true where id='$E1';
insert into public.exam(id,id_user,id_course,id_exam_template) values ('$E2','$S2','$CID','$TPL');
insert into public.user_exam_attempts(id,user_id,exam_id,course_id,question_count,started_at,status,created_at,updated_at,is_retake) values
 ('$AT2','$S2','$E2','$CID',1,now(),'completed',now(),now(),false);
insert into public.gamification_season(id,name,starts_at,ends_at,is_active) values
 ('$SEA','2026.2',now()-interval '1 day',now()+interval '90 days',true);
insert into public.user_gamification_points(user_id,season_id,attempt_id,exam_id,course_id,exam_template_id,question_count,correct_count,percentage_score,duration_seconds,base_points,total_points) values
 ('$S1','$SEA','$AT1','$E1','$CID','$TPL',1,1,100,60,1,1),
 ('$S2','$SEA','$AT2','$E2','$CID','$TPL',1,0,0,60,0,0.5);
SQL

echo "==> Login (JWT real)"
signin() { curl -s -X POST "$API/auth/v1/token?grant_type=password" -H "apikey: $ANON" \
                -H 'Content-Type: application/json' -d "{\"email\":\"$1\",\"password\":\"pass1234\"}" | jq -r '.access_token'; }
JS1=$(signin s1@test.dev); JS2=$(signin s2@test.dev); JT1=$(signin t1@test.dev); JA1=$(signin a1@test.dev)

echo ""
echo "### FLUXO DO ALUNO (student1) — deve funcionar como antes"
ge "lista cursos"                       "$(sel "$JS1" 'course?select=*')" 1
ge "carrega questoes (is_active)"       "$(sel "$JS1" 'question?select=*&is_active=eq.true')" 2
ge "questao com alternativas aninhadas" "$(nested_ac "$JS1" "$Q1")" 2
ge "carrega supportingtext"             "$(sel "$JS1" 'supportingtext?select=*')" 1
ge "carrega exam"                       "$(sel "$JS1" 'exam?select=*')" 1
eq "le a PROPRIA tentativa"             "$(sel "$JS1" "user_exam_attempts?user_id=eq.$S1&status=eq.completed")" 1
eq "le as PROPRIAS respostas"           "$(sel "$JS1" "user_responses?attempt_id=eq.$AT1")" 1
eq "le o PROPRIO user"                  "$(sel "$JS1" "user?id=eq.$S1")" 1
eq "NAO le user de outro"               "$(sel "$JS1" "user?id=eq.$S2")" 0
W1=$(ins "$JS1" 'user_responses' "{\"exam_id\":\"$E1\",\"question_id\":\"$Q2\",\"attempt_id\":\"$AT1\"}")
eq "insere resposta na PROPRIA tentativa" "$W1" 201
W2=$(ins "$JS1" 'user_exam_attempts' "{\"user_id\":\"$S1\",\"exam_id\":\"$E1\",\"course_id\":\"$CID\",\"question_count\":1,\"status\":\"in_progress\"}")
eq "inicia PROPRIA tentativa" "$W2" 201

echo ""
echo "### ISOLAMENTO (student2 nao acessa dados do student1)"
eq "student2 nao ve tentativa alheia"   "$(sel "$JS2" "user_exam_attempts?user_id=eq.$S1")" 0
eq "student2 nao ve respostas alheias"  "$(sel "$JS2" 'user_responses?select=*')" 0
ge "student2 ainda le conteudo (questoes)" "$(sel "$JS2" 'question?select=*')" 2
BLK=$(ins "$JS2" 'user_responses' "{\"exam_id\":\"$E1\",\"question_id\":\"$Q2\",\"attempt_id\":\"$AT1\"}")
[ "$BLK" != "201" ] && ok "student2 BLOQUEADO de escrever na tentativa alheia (http $BLK)" || bad "student2 conseguiu escrever na tentativa alheia (201!)"
SPOOF=$(ins "$JS2" 'user_exam_attempts' "{\"user_id\":\"$S1\",\"exam_id\":\"$E1\",\"course_id\":\"$CID\",\"question_count\":1,\"status\":\"in_progress\"}")
[ "$SPOOF" != "201" ] && ok "student2 BLOQUEADO de spoofar user_id (http $SPOOF)" || bad "student2 conseguiu spoofar user_id (201!)"

echo ""
echo "### FLUXO DO PROFESSOR (teacher1) — le dados de alunos"
ge "professor le todos os users"        "$(sel "$JT1" 'user?select=*')" 3
ge "professor le tentativas de alunos"  "$(sel "$JT1" 'user_exam_attempts?select=*')" 1

echo ""
echo "### ANON (sem login) — tudo bloqueado"
eq "anon nao le questoes" "$(sel_anon 'question?select=*')" 0
eq "anon nao le users"    "$(sel_anon 'user?select=*')" 0
eq "anon nao le cursos"   "$(sel_anon 'course?select=*')" 0


echo ""
echo "### VIEWS — anon sem acesso (antes: SECURITY DEFINER + GRANT ALL a anon)"
for v in teacher_student_responses ranking_global_view ranking_course_view ranking_template_view \
         teacher_exam_stats teacher_question_stats admin_platform_stats admin_course_stats admin_monthly_activity; do
  eq "anon nao le $v (permission denied)" "$(sel_anon "$v?select=*")" -1
done
R=$(rpc ranking_profiles)
[ "$R" != "200" ] && ok "anon nao executa rpc ranking_profiles (http $R)" || bad "anon executou rpc ranking_profiles (200!)"

echo ""
echo "### VIEWS — rankings seguem funcionando para aluno (nome/avatar via ranking_profiles)"
eq "aluno ve ranking global com os 2 alunos"   "$(sel "$JS1" "ranking_global_view?season_id=eq.$SEA")" 2
eq "aluno ve ranking do curso com os 2 alunos" "$(sel "$JS1" "ranking_course_view?season_id=eq.$SEA&course_id=eq.$CID")" 2
eq "aluno ve ranking do template com os 2"     "$(sel "$JS1" "ranking_template_view?season_id=eq.$SEA&exam_template_id=eq.$TPL")" 2
eq "ranking traz nome do outro aluno"          "$(val "$JS1" "ranking_global_view?season_id=eq.$SEA&user_id=eq.$S2" '.[0].user_name')" Aluno2
eq "rank_position do aluno1 = 1"               "$(val "$JS1" "ranking_global_view?season_id=eq.$SEA&user_id=eq.$S1" '.[0].rank_position')" 1
eq "ranking_profiles nao expoe email"          "$(curl -s -X POST -H "apikey: $ANON" -H "Authorization: Bearer $JS1" -H 'Content-Type: application/json' "$API/rest/v1/rpc/ranking_profiles" -d '{}' | jq -r '[.[] | has("email")] | any')" false

echo ""
echo "### VIEWS — teacher_student_responses fechada (nao usada pelo app; PII)"
eq "aluno nao le teacher_student_responses"     "$(sel "$JS1" 'teacher_student_responses?select=*')" -1
eq "professor nao le teacher_student_responses" "$(sel "$JT1" 'teacher_student_responses?select=*')" -1

echo ""
echo "### VIEWS — estatisticas de professor e admin (security_invoker, via RLS)"
ge "professor le teacher_exam_stats dele"     "$(sel "$JT1" "teacher_exam_stats?id_teacher=eq.$T1")" 1
ge "professor le teacher_question_stats dele" "$(sel "$JT1" "teacher_question_stats?id_teacher=eq.$T1")" 1
eq "admin_platform_stats (admin) conta 4 users"  "$(val "$JA1" 'admin_platform_stats?select=total_users' '.[0].total_users')" 4
ge "admin le admin_course_stats"              "$(sel "$JA1" 'admin_course_stats?select=*')" 1
eq "admin_monthly_activity (admin) ve 2 users ativos" "$(val "$JA1" 'admin_monthly_activity?select=active_users' '.[0].active_users')" 2
eq "aluno em admin_platform_stats so conta a si" "$(val "$JS1" 'admin_platform_stats?select=total_users' '.[0].total_users')" 1

echo ""
echo "============================================"
printf 'RESULTADO: \033[32m%d PASS\033[0m / \033[31m%d FAIL\033[0m\n' "$PASS" "$FAIL"
echo "============================================"
[ "$FAIL" -eq 0 ]
