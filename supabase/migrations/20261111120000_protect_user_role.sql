-- Impede que um usuário comum altere o próprio papel (role) ou status (is_active) direto pela API.
--
-- Problema: a policy "user_update_own" (20260707220000) libera UPDATE da própria linha de
-- public."user" sem restringir colunas, e authenticated tem GRANT ALL na tabela. Com a anon key
-- (pública, vai no build web) e o próprio JWT, qualquer aluno fazia
--   PATCH /rest/v1/user?id=eq.<seu id>  {"role":"admin"}
-- e passava a ter acesso às RPCs de admin (listar contas, trocar senha de terceiros, desativar contas).
-- O mesmo valia para o upsert do cadastro (POST com resolution=merge-duplicates) e para is_active.
--
-- Correção: trigger BEFORE INSERT/UPDATE que, quando quem executa é um papel da API (anon ou
-- authenticated), recusa role diferente de 'student' na criação e qualquer mudança de role/is_active
-- na atualização. Os caminhos legítimos continuam abertos porque não rodam como esses papéis:
--   - RPCs admin_update_user_role / admin_toggle_user_active: SECURITY DEFINER, dono postgres;
--   - trigger handle_new_user (signup): SECURITY DEFINER;
--   - service_role (Auth admin, scripts) e SQL editor do dashboard (postgres).
-- A função do trigger NÃO é SECURITY DEFINER de propósito: current_user precisa refletir quem chamou.

create or replace function public.protect_user_privileged_columns() returns trigger
  language plpgsql set search_path = public, pg_temp as $$
  begin
    if current_user not in ('anon', 'authenticated') then
      return new;
    end if;

    if tg_op = 'INSERT' then
      if new.role is distinct from 'student' or new.is_active is distinct from true then
        raise exception 'role and is_active can only be set by an admin'
          using errcode = '42501';
      end if;
    elsif new.role is distinct from old.role or new.is_active is distinct from old.is_active then
      raise exception 'role and is_active can only be changed by an admin'
        using errcode = '42501';
    end if;

    return new;
  end $$;

revoke all on function public.protect_user_privileged_columns() from public, anon, authenticated;

drop trigger if exists protect_user_privileged_columns on public."user";
create trigger protect_user_privileged_columns
  before insert or update on public."user"
  for each row execute function public.protect_user_privileged_columns();

-- Defense-in-depth: o baseline dá GRANT ALL; TRUNCATE não passa por RLS nem por trigger de linha.
-- O PostgREST não emite TRUNCATE, então hoje não é explorável pela API, mas não há motivo para o grant.
revoke truncate, references, trigger on public."user" from anon, authenticated;
