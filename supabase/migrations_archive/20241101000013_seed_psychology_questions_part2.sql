-- Seed remaining 14 psychology questions (Q27-Q40)
-- Part 2: Social Psychology (6), Clinical Psychology (4), Neuroscience (4)

DO $$
DECLARE
  v_course_id uuid;
  v_question_id uuid;
  v_has_difficulty boolean;
  v_has_points boolean;
  v_has_is_active boolean;
  v_question_has_created_at boolean;
  v_question_has_updated_at boolean;
  v_question_has_update_at boolean;
  v_answerchoice_has_created_at boolean;
  v_answerchoice_has_upload_at boolean;
  v_question_text_column text;
  v_question_course_column text;
  v_answerchoice_question_column text;
  v_question_columns text;
  v_question_values text;
  v_insert_question_sql text;
  v_answerchoice_columns text;
  v_answerchoice_values text;
BEGIN
  SELECT id INTO v_course_id FROM public.course WHERE name = 'Psicologia';
  
  IF v_course_id IS NULL THEN
    RAISE NOTICE 'Psicologia course not found. Skipping question seed.';
    RETURN;
  END IF;
  
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'difficulty_level') INTO v_has_difficulty;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'points') INTO v_has_points;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'is_active') INTO v_has_is_active;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'created_at') INTO v_question_has_created_at;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'updated_at') INTO v_question_has_updated_at;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name = 'update_at') INTO v_question_has_update_at;
  
  SELECT column_name INTO v_question_text_column FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name IN ('enunciation', 'statement', 'question_text') ORDER BY CASE column_name WHEN 'enunciation' THEN 1 WHEN 'statement' THEN 2 ELSE 3 END LIMIT 1;
  SELECT column_name INTO v_question_course_column FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question' AND column_name IN ('id_course', 'course_id', 'idcourse') ORDER BY CASE column_name WHEN 'id_course' THEN 1 WHEN 'course_id' THEN 2 ELSE 3 END LIMIT 1;
  SELECT column_name INTO v_answerchoice_question_column FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'answerchoice' AND column_name IN ('id_question', 'question_id', 'idquestion') ORDER BY CASE column_name WHEN 'id_question' THEN 1 WHEN 'question_id' THEN 2 ELSE 3 END LIMIT 1;
  
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'answerchoice' AND column_name = 'created_at') INTO v_answerchoice_has_created_at;
  SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'answerchoice' AND column_name = 'upload_at') INTO v_answerchoice_has_upload_at;
  
  IF v_question_text_column IS NULL OR v_question_course_column IS NULL THEN RAISE NOTICE 'Required question columns not found.'; RETURN; END IF;
  IF v_answerchoice_question_column IS NULL THEN RAISE NOTICE 'Required answerchoice column not found.'; RETURN; END IF;

  -- ============================================
  -- SOCIAL PSYCHOLOGY (Q27-Q32)
  -- ============================================

  -- Question 27 (Easy)
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é conformidade social?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_columns := format('letter, content, correctanswer, %I', v_answerchoice_question_column);
  IF v_answerchoice_has_created_at THEN v_answerchoice_columns := v_answerchoice_columns || ', created_at'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_columns := v_answerchoice_columns || ', upload_at'; END IF;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Ser rebelde', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Mudar comportamento para se adequar ao grupo', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Liderar um grupo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Evitar pessoas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Ser individualista', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- ============================================
  -- SOCIAL PSYCHOLOGY (Q28-Q32) - Continued
  -- ============================================

  -- Question 28 (Easy): O que estuda a psicologia dos grupos?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que estuda a psicologia dos grupos?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Apenas indivíduos isolados', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Como as pessoas se comportam em grupos', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Somente famílias', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Apenas grandes multidões', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Personalidade individual', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 29 (Medium): O que é dissonância cognitiva?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é dissonância cognitiva?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Um tipo de transtorno', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Desconforto por ter crenças contraditórias', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Perda de memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Falta de atenção', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Dificuldade de aprendizagem', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 30 (Medium): O experimento de Milgram demonstrou:
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O experimento de Milgram demonstrou:', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Efeitos da memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Obediência à autoridade', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Desenvolvimento infantil', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Condicionamento clássico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Inteligência emocional', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 31 (Hard): O que é atribuição causal em psicologia social?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é atribuição causal em psicologia social?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Um tipo de terapia', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Um transtorno mental', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Processo de explicar causas de comportamentos', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Técnica de memorização', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Método de pesquisa', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 32 (Medium): O que são estereótipos?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que são estereótipos?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Tipos de personalidade', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Crenças generalizadas sobre grupos de pessoas', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Transtornos sociais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Comportamentos individuais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Técnicas de comunicação', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 6 Social Psychology questions (Q27-Q32)';

  -- ============================================
  -- CLINICAL PSYCHOLOGY (Q33-Q36)
  -- ============================================

  -- Question 33 (Easy): O que caracteriza um transtorno de ansiedade?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que caracteriza um transtorno de ansiedade?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Apenas tristeza profunda', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Medo e preocupação excessivos e persistentes', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Perda de memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Alucinações', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Euforia extrema', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 34 (Medium): Qual abordagem terapêutica foca em mudar padrões de pensamento?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual abordagem terapêutica foca em mudar padrões de pensamento?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Psicanálise', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Terapia Cognitivo-Comportamental (TCC)', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Terapia Humanista apenas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Hipnose', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Terapia familiar sistêmica', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 35 (Hard): O que é comorbidade em psicologia clínica?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é comorbidade em psicologia clínica?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Recuperação completa', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Presença de dois ou mais transtornos simultaneamente', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Resistência ao tratamento', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Tipo de medicação', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Fase inicial do tratamento', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 36 (Medium): O que avalia um teste psicológico projetivo?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que avalia um teste psicológico projetivo?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Apenas inteligência', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Apenas memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Aspectos inconscientes da personalidade', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Apenas habilidades motoras', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Somente conhecimento acadêmico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 4 Clinical Psychology questions (Q33-Q36)';

  -- ============================================
  -- NEUROSCIENCE & BIOLOGICAL PSYCHOLOGY (Q37-Q40)
  -- ============================================

  -- Question 37 (Easy): Qual estrutura cerebral é essencial para a memória?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual estrutura cerebral é essencial para a memória?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Cerebelo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Hipocampo', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Medula', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Ponte', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Bulbo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 38 (Medium): O que são neurotransmissores?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que são neurotransmissores?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Células nervosas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Substâncias químicas que transmitem sinais entre neurônios', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Partes do cérebro', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Hormônios apenas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Tipos de memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 39 (Medium): Qual neurotransmissor está associado ao prazer e recompensa?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual neurotransmissor está associado ao prazer e recompensa?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Serotonina', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Dopamina', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Acetilcolina', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'GABA', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Glutamato', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 40 (Hard): O que é neuroplasticidade?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é neuroplasticidade?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Doença cerebral', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Tipo de terapia', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Capacidade do cérebro de reorganizar conexões neurais', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Perda de neurônios', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Técnica de diagnóstico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 4 Neuroscience questions (Q37-Q40)';
  RAISE NOTICE '======================================';
  RAISE NOTICE 'TOTAL: 40 Psychology questions seeded';
  RAISE NOTICE '======================================';

END $$;
