-- Seed 36 additional psychology questions (Q5-Q40)
-- Total: 40 psychology questions (4 existing + 36 new)
-- Distribution: Basic Concepts (8), Cognitive (8), Developmental (6), Social (6), Clinical (4), Neuroscience (4)
-- Difficulty: Easy (12), Medium (18), Hard (10)

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
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'difficulty_level'
  ) INTO v_has_difficulty;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'points'
  ) INTO v_has_points;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'is_active'
  ) INTO v_has_is_active;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'created_at'
  ) INTO v_question_has_created_at;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'updated_at'
  ) INTO v_question_has_updated_at;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'question' 
      AND column_name = 'update_at'
  ) INTO v_question_has_update_at;
  
  SELECT column_name
  INTO v_question_text_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'question'
    AND column_name IN ('enunciation', 'statement', 'question_text')
  ORDER BY CASE column_name
             WHEN 'enunciation' THEN 1
             WHEN 'statement' THEN 2
             ELSE 3
           END
  LIMIT 1;
  
  SELECT column_name
  INTO v_question_course_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'question'
    AND column_name IN ('id_course', 'course_id', 'idcourse')
  ORDER BY CASE column_name
             WHEN 'id_course' THEN 1
             WHEN 'course_id' THEN 2
             ELSE 3
           END
  LIMIT 1;
  
  SELECT column_name
  INTO v_answerchoice_question_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'answerchoice'
    AND column_name IN ('id_question', 'question_id', 'idquestion')
  ORDER BY CASE column_name
             WHEN 'id_question' THEN 1
             WHEN 'question_id' THEN 2
             ELSE 3
           END
  LIMIT 1;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'answerchoice'
      AND column_name = 'created_at'
  ) INTO v_answerchoice_has_created_at;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'answerchoice'
      AND column_name = 'upload_at'
  ) INTO v_answerchoice_has_upload_at;
  
  IF v_question_text_column IS NULL OR v_question_course_column IS NULL THEN
    RAISE NOTICE 'Required question columns not found. Skipping seed.';
    RETURN;
  END IF;
  
  IF v_answerchoice_question_column IS NULL THEN
    RAISE NOTICE 'Required answerchoice column not found. Skipping seed.';
    RETURN;
  END IF;

  -- ============================================
  -- BASIC CONCEPTS (Q5-Q12)
  -- ============================================

  -- Question 5 (Easy): O que é a psicologia humanista?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é a psicologia humanista?', v_course_id);
  
  IF v_has_difficulty THEN
    v_question_columns := v_question_columns || ', difficulty_level';
    v_question_values := v_question_values || format(', %L', 'easy');
  END IF;
  
  IF v_has_points THEN
    v_question_columns := v_question_columns || ', points';
    v_question_values := v_question_values || format(', %L', 1.0);
  END IF;
  
  IF v_has_is_active THEN
    v_question_columns := v_question_columns || ', is_active';
    v_question_values := v_question_values || format(', %L', TRUE);
  END IF;
  
  IF v_question_has_created_at THEN
    v_question_columns := v_question_columns || ', created_at';
    v_question_values := v_question_values || ', NOW()';
  END IF;
  
  IF v_question_has_updated_at THEN
    v_question_columns := v_question_columns || ', updated_at';
    v_question_values := v_question_values || ', NOW()';
  ELSIF v_question_has_update_at THEN
    v_question_columns := v_question_columns || ', update_at';
    v_question_values := v_question_values || ', NOW()';
  END IF;
  
  v_insert_question_sql := format(
    'INSERT INTO public.question (%s) VALUES (%s) RETURNING id',
    v_question_columns,
    v_question_values
  );
  
  EXECUTE v_insert_question_sql INTO v_question_id;
  
  v_answerchoice_columns := format('letter, content, correctanswer, %I', v_answerchoice_question_column);
  IF v_answerchoice_has_created_at THEN
    v_answerchoice_columns := v_answerchoice_columns || ', created_at';
  END IF;
  IF v_answerchoice_has_upload_at THEN
    v_answerchoice_columns := v_answerchoice_columns || ', upload_at';
  END IF;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Abordagem que enfatiza o inconsciente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Abordagem que estuda apenas comportamentos observáveis', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Abordagem que enfatiza o potencial humano e crescimento pessoal', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Abordagem que foca apenas em processos cognitivos', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Abordagem que estuda apenas transtornos mentais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 6 (Easy): Qual abordagem teórica enfatiza o papel do inconsciente?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual abordagem teórica enfatiza o papel do inconsciente?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Behaviorismo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Psicanálise', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Humanismo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Cognitivismo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Gestalt', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 7 (Medium): O behaviorismo clássico estuda principalmente:
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O behaviorismo clássico estuda principalmente:', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Os sonhos e o inconsciente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Comportamentos observáveis e mensuráveis', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Processos mentais internos', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Experiências subjetivas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'A estrutura da consciência', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 8 (Easy): Qual método de pesquisa é mais usado em estudos qualitativos em psicologia?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual método de pesquisa é mais usado em estudos qualitativos em psicologia?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Experimentos controlados', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Entrevistas e observações', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Testes estatísticos', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Ressonância magnética', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Medicação controlada', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 9 (Medium): O que significa o termo "cognição" em psicologia?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que significa o termo "cognição" em psicologia?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Apenas a memória', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Apenas o raciocínio lógico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Processos mentais como pensar, perceber e lembrar', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Somente as emoções', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Comportamentos motores', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 10 (Medium): Quem desenvolveu a teoria das inteligências múltiplas?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Quem desenvolveu a teoria das inteligências múltiplas?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Jean Piaget', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Sigmund Freud', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Howard Gardner', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Lev Vygotsky', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Albert Bandura', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 11 (Easy): O que a psicologia social estuda primariamente?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que a psicologia social estuda primariamente?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Transtornos mentais individuais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Processos cerebrais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Como as pessoas influenciam e são influenciadas por outras', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Desenvolvimento infantil', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Memória e aprendizagem', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 12 (Medium): Qual a principal diferença entre psicólogo e psiquiatra?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual a principal diferença entre psicólogo e psiquiatra?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Psicólogos não podem atender pacientes', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Psiquiatras são médicos e podem prescrever medicamentos', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Psicólogos só trabalham com crianças', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Psiquiatras não fazem terapia', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Não há diferença entre os dois', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 8 Basic Concepts questions (Q5-Q12)';

  -- ============================================
  -- COGNITIVE PSYCHOLOGY (Q13-Q20)
  -- ============================================

  -- Question 13 (Easy): O que é memória de trabalho?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é memória de trabalho?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Memória de longo prazo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Sistema que mantém e manipula informações temporariamente', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Memória permanente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Memória inconsciente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Memória sensorial', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 14 (Easy): Qual tipo de memória armazena informações por apenas alguns segundos?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual tipo de memória armazena informações por apenas alguns segundos?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Memória de longo prazo', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Memória de trabalho', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Memória sensorial', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Memória episódica', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Memória semântica', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 15 (Medium): O que é atenção seletiva?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é atenção seletiva?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Prestar atenção em tudo simultaneamente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Focar em estímulos específicos enquanto ignora outros', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Perder a concentração facilmente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Ter déficit de atenção', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Memorizar informações selecionadas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 16 (Medium): Qual teoria explica como organizamos informações visuais em padrões?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual teoria explica como organizamos informações visuais em padrões?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Teoria Behaviorista', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Teoria da Gestalt', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Teoria Psicanalítica', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Teoria do Condicionamento', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Teoria Humanista', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 17 (Hard): O que são heurísticas em psicologia cognitiva?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que são heurísticas em psicologia cognitiva?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Testes de inteligência', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Transtornos cognitivos', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Atalhos mentais que facilitam tomada de decisões', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Memórias falsas', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Processos de aprendizagem formal', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 18 (Medium): O que é metacognição?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é metacognição?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Pensar rapidamente', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Pensar sobre o próprio pensamento', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Memória fotográfica', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Inteligência emocional', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Processamento automático', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 19 (Medium): Qual modelo descreve como processamos informações como um computador?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual modelo descreve como processamos informações como um computador?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Modelo Psicanalítico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Modelo de Processamento de Informações', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Modelo Comportamental', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Modelo Humanista', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Modelo Existencial', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 20 (Hard): O que é um esquema cognitivo?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é um esquema cognitivo?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Um tipo de transtorno mental', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Um teste psicológico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Estrutura mental que organiza conhecimento e experiências', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Uma técnica de memorização', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Um tipo de terapia', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 8 Cognitive Psychology questions (Q13-Q20)';

  -- ============================================
  -- DEVELOPMENTAL PSYCHOLOGY (Q21-Q26)
  -- ============================================

  -- Question 21 (Easy): Segundo Piaget, em qual estágio a criança desenvolve pensamento lógico?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Segundo Piaget, em qual estágio a criança desenvolve pensamento lógico?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Sensório-motor', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Pré-operacional', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Operações concretas', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Operações formais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Idade adulta', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 22 (Easy): O que é desenvolvimento cognitivo?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é desenvolvimento cognitivo?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'easy'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Crescimento físico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Mudanças nas capacidades mentais ao longo da vida', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Apenas a aprendizagem escolar', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Desenvolvimento motor', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Amadurecimento sexual', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 23 (Medium): Qual teórico enfatizou a importância da interação social no desenvolvimento?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'Qual teórico enfatizou a importância da interação social no desenvolvimento?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Sigmund Freud', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'B.F. Skinner', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Lev Vygotsky', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Ivan Pavlov', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Carl Jung', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 24 (Medium): O que caracteriza a adolescência segundo Erik Erikson?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que caracteriza a adolescência segundo Erik Erikson?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Busca por autonomia', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Busca por identidade', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Desenvolvimento motor', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Apego aos pais', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Pensamento concreto', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 25 (Hard): O que é "zona de desenvolvimento proximal" de Vygotsky?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que é "zona de desenvolvimento proximal" de Vygotsky?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'hard'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Área do cérebro em desenvolvimento', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Diferença entre o que a criança faz sozinha e com ajuda', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Estágio de desenvolvimento infantil', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Fase do desenvolvimento motor', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Período de desenvolvimento cerebral', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  -- Question 26 (Medium): O que estuda a psicologia do desenvolvimento?
  v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
  v_question_values := format('%L, %L', 'O que estuda a psicologia do desenvolvimento?', v_course_id);
  IF v_has_difficulty THEN v_question_columns := v_question_columns || ', difficulty_level'; v_question_values := v_question_values || format(', %L', 'medium'); END IF;
  IF v_has_points THEN v_question_columns := v_question_columns || ', points'; v_question_values := v_question_values || format(', %L', 1.0); END IF;
  IF v_has_is_active THEN v_question_columns := v_question_columns || ', is_active'; v_question_values := v_question_values || format(', %L', TRUE); END IF;
  IF v_question_has_created_at THEN v_question_columns := v_question_columns || ', created_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  IF v_question_has_updated_at THEN v_question_columns := v_question_columns || ', updated_at'; v_question_values := v_question_values || ', NOW()'; ELSIF v_question_has_update_at THEN v_question_columns := v_question_columns || ', update_at'; v_question_values := v_question_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.question (%s) VALUES (%s) RETURNING id', v_question_columns, v_question_values) INTO v_question_id;

  v_answerchoice_values := format('%L, %L, %s, %L', 'A', 'Apenas o desenvolvimento infantil', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'B', 'Apenas a velhice', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'C', 'Mudanças ao longo de toda a vida', 'TRUE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'D', 'Somente a adolescência', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  v_answerchoice_values := format('%L, %L, %s, %L', 'E', 'Apenas o desenvolvimento físico', 'FALSE', v_question_id);
  IF v_answerchoice_has_created_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  IF v_answerchoice_has_upload_at THEN v_answerchoice_values := v_answerchoice_values || ', NOW()'; END IF;
  EXECUTE format('INSERT INTO public.answerchoice (%s) VALUES (%s)', v_answerchoice_columns, v_answerchoice_values);

  RAISE NOTICE 'Successfully seeded 6 Developmental Psychology questions (Q21-Q26)';

  -- NOTE: Remaining questions (Q27-Q40) will be added in next migration due to file size
  -- Sections pending: Social Psychology (6), Clinical (4), Neuroscience (4)

END $$;
