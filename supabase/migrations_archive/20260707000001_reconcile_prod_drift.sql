-- Reconciliação de drift: colunas presentes em produção (criadas manualmente via Dashboard SQL)
-- que nenhuma migration versionava. Confirmado via introspecção em 2026-07-07:
--   question.number        -> numeric, NOT NULL em prod, 260/260 preenchidas (valores 1-40)
--   question.question_text -> text, 253/260 preenchidas
--
-- IF NOT EXISTS torna idempotente: no-op em produção (colunas já existem), aplica em ambiente novo.
-- 'number' fica NULLABLE aqui de propósito: em ambiente novo os seeds de questão não preenchem
-- 'number', então um NOT NULL quebraria o `supabase db reset`. Produção permanece NOT NULL.

alter table public.question add column if not exists number numeric;
alter table public.question add column if not exists question_text text;
