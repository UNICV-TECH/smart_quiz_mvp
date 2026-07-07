-- Habilita RLS + policies nas 9 tabelas que estavam expostas (RLS off + grants amplos a anon).
-- Fecha broken-access-control: a anon key e publica (vai no build web), entao sem RLS qualquer um
-- lia/escrevia tudo. Desenho baseado no mapeamento do acesso direto do cliente (ver plano).
--
-- Premissas verificadas no banco:
--   - Todas as 12 funcoes sao SECURITY DEFINER e as 9 views sao security_invoker=false -> bypassam
--     RLS. Logo o CRUD de teacher/admin (RPCs) e os dashboards (views) seguem funcionando.
--   - O app roda pos-login (authenticated); o unico ponto anon e o provisionamento de user no signup,
--     coberto pelo trigger handle_new_user abaixo.

-- ---------------------------------------------------------------------------
-- 1. Helpers SECURITY DEFINER (checam role sem reaplicar RLS -> evitam recursao)
-- ---------------------------------------------------------------------------
create or replace function public.is_admin() returns boolean
  language sql security definer stable set search_path = public, pg_temp
  as $$ select exists(select 1 from public."user" where id = auth.uid() and role = 'admin') $$;

create or replace function public.is_teacher_or_admin() returns boolean
  language sql security definer stable set search_path = public, pg_temp
  as $$ select exists(select 1 from public."user" where id = auth.uid() and role in ('teacher','admin')) $$;

revoke all on function public.is_admin() from public;
revoke all on function public.is_teacher_or_admin() from public;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_teacher_or_admin() to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Provisionamento de public."user" no signup (independe de RLS)
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user() returns trigger
  language plpgsql security definer set search_path = public, pg_temp as $$
  begin
    insert into public."user"(id, email, role, is_active, created_at, updated_at)
    values (new.id, new.email, 'student', true, now(), now())
    on conflict (id) do nothing;
    return new;
  end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 3. RLS + policies por tabela
-- ---------------------------------------------------------------------------

-- user: proprio registro + teacher/admin leem todos (teacher precisa ler alunos p/ joins)
drop policy if exists "Admins can read all users" on public."user";  -- legada, recursiva
alter table public."user" enable row level security;
create policy "user_select_own_or_staff" on public."user"
  for select to authenticated
  using (id = auth.uid() or public.is_teacher_or_admin());
create policy "user_insert_own" on public."user"
  for insert to authenticated
  with check (id = auth.uid());
create policy "user_update_own" on public."user"
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- course: catalogo lido por qualquer autenticado
alter table public.course enable row level security;
create policy "course_select_auth" on public.course
  for select to authenticated using (true);

-- exam: leitura por qualquer autenticado; escrita do proprio aluno (id_user)
alter table public.exam enable row level security;
create policy "exam_select_auth" on public.exam
  for select to authenticated using (true);
create policy "exam_insert_own" on public.exam
  for insert to authenticated with check (id_user = auth.uid());
create policy "exam_update_own" on public.exam
  for update to authenticated
  using (id_user = auth.uid()) with check (id_user = auth.uid());

-- question: leitura por qualquer autenticado; update direto so do proprio teacher (ou admin)
alter table public.question enable row level security;
create policy "question_select_auth" on public.question
  for select to authenticated using (true);
create policy "question_insert_teacher" on public.question
  for insert to authenticated
  with check (id_teacher = auth.uid() or public.is_admin());
create policy "question_update_teacher" on public.question
  for update to authenticated
  using (id_teacher = auth.uid() or public.is_admin())
  with check (id_teacher = auth.uid() or public.is_admin());

-- examquestion: leitura autenticada; insert escopado ao dono do exam
alter table public.examquestion enable row level security;
create policy "examquestion_select_auth" on public.examquestion
  for select to authenticated using (true);
create policy "examquestion_insert_own_exam" on public.examquestion
  for insert to authenticated
  with check (exists (select 1 from public.exam e
                      where e.id = examquestion.id_exam and e.id_user = auth.uid()));

-- answerchoice: leitura autenticada; escrita so via RPC SECURITY DEFINER
alter table public.answerchoice enable row level security;
create policy "answerchoice_select_auth" on public.answerchoice
  for select to authenticated using (true);

-- supportingtext: leitura autenticada; escrita so via RPC SECURITY DEFINER
alter table public.supportingtext enable row level security;
create policy "supportingtext_select_auth" on public.supportingtext
  for select to authenticated using (true);

-- user_responses: dono via attempt; teacher/admin tambem leem (fallback ao acesso direto)
alter table public.user_responses enable row level security;
create policy "user_responses_select_own_or_staff" on public.user_responses
  for select to authenticated
  using (public.is_teacher_or_admin()
         or exists (select 1 from public.user_exam_attempts a
                    where a.id = user_responses.attempt_id and a.user_id = auth.uid()));
create policy "user_responses_insert_own" on public.user_responses
  for insert to authenticated
  with check (exists (select 1 from public.user_exam_attempts a
                      where a.id = user_responses.attempt_id and a.user_id = auth.uid()));

-- user_exam_attempts: dono + teacher/admin (professor le tentativas de alunos direto)
alter table public.user_exam_attempts enable row level security;
create policy "attempts_select_own_or_staff" on public.user_exam_attempts
  for select to authenticated
  using (user_id = auth.uid() or public.is_teacher_or_admin());
create policy "attempts_insert_own" on public.user_exam_attempts
  for insert to authenticated with check (user_id = auth.uid());
create policy "attempts_update_own" on public.user_exam_attempts
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 4. Defense-in-depth: remover writes diretos do papel anon (RLS ja bloqueia)
-- ---------------------------------------------------------------------------
revoke insert, update, delete on
  public."user", public.course, public.exam, public.question, public.examquestion,
  public.answerchoice, public.supportingtext, public.user_responses, public.user_exam_attempts
  from anon;
