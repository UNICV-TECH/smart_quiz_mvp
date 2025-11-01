-- Sample data seed for testing

-- Insert sample courses with adaptive column support
DO $$
DECLARE
  v_has_description boolean;
  v_has_is_active boolean;
  v_has_course_key boolean;
  v_has_title boolean;
  v_has_icon_key boolean;
  v_has_created_at boolean;
  v_has_updated_at boolean;
  v_has_update_at boolean;
  v_insert_columns text;
  v_values text;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'description'
  ) INTO v_has_description;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'is_active'
  ) INTO v_has_is_active;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'course_key'
  ) INTO v_has_course_key;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'title'
  ) INTO v_has_title;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'icon_key'
  ) INTO v_has_icon_key;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'created_at'
  ) INTO v_has_created_at;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'updated_at'
  ) INTO v_has_updated_at;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'course' 
      AND column_name = 'update_at'
  ) INTO v_has_update_at;

  IF v_has_course_key AND v_has_title AND v_has_icon_key THEN
    EXECUTE $sql$
      INSERT INTO public.course (
        course_key,
        title,
        name,
        icon_key,
        icon,
        description,
        is_active,
        created_at,
        updated_at
      )
      VALUES
        ('psicologia', 'Psicologia', 'Psicologia', 'psychology_outlined', 'psychology', 'Curso de Psicologia', TRUE, NOW(), NOW()),
        ('direito', 'Direito', 'Direito', 'gavel_outlined', 'law', 'Curso de Direito', TRUE, NOW(), NOW()),
        ('medicina', 'Medicina', 'Medicina', 'medical_services_outlined', 'medical', 'Curso de Medicina', TRUE, NOW(), NOW()),
        ('engenharia', 'Engenharia', 'Engenharia', 'engineering_outlined', 'engineering', 'Curso de Engenharia', TRUE, NOW(), NOW()),
        ('administracao', 'Administração', 'Administração', 'business_center_outlined', 'business', 'Curso de Administração', TRUE, NOW(), NOW())
      ON CONFLICT (name) DO UPDATE
      SET
        title = EXCLUDED.title,
        course_key = EXCLUDED.course_key,
        icon_key = EXCLUDED.icon_key,
        icon = EXCLUDED.icon,
        description = EXCLUDED.description,
        is_active = EXCLUDED.is_active,
        updated_at = NOW();
    $sql$;
  ELSIF v_has_description AND v_has_is_active THEN
    v_insert_columns := 'name, icon, description, is_active';
    v_values := '        (''Psicologia'', ''psychology'', ''Curso de Psicologia'', TRUE';

    IF v_has_created_at THEN
      v_insert_columns := v_insert_columns || ', created_at';
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at THEN
      v_insert_columns := v_insert_columns || ', updated_at';
      v_values := v_values || ', NOW()';
    ELSIF v_has_update_at THEN
      v_insert_columns := v_insert_columns || ', update_at';
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Direito'', ''law'', ''Curso de Direito'', TRUE';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Medicina'', ''medical'', ''Curso de Medicina'', TRUE';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Engenharia'', ''engineering'', ''Curso de Engenharia'', TRUE';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Administração'', ''business'', ''Curso de Administração'', TRUE';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || ')';

    EXECUTE format(
      'INSERT INTO public.course (%s) VALUES %s ON CONFLICT (name) DO NOTHING',
      v_insert_columns,
      v_values
    );
  ELSE
    v_insert_columns := 'name, icon';
    v_values := '        (''Psicologia'', ''psychology''';

    IF v_has_created_at THEN
      v_insert_columns := v_insert_columns || ', created_at';
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at THEN
      v_insert_columns := v_insert_columns || ', updated_at';
      v_values := v_values || ', NOW()';
    ELSIF v_has_update_at THEN
      v_insert_columns := v_insert_columns || ', update_at';
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Direito'', ''law''';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Medicina'', ''medical''';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Engenharia'', ''engineering''';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || '),
        (''Administração'', ''business''';

    IF v_has_created_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    IF v_has_updated_at OR v_has_update_at THEN
      v_values := v_values || ', NOW()';
    END IF;

    v_values := v_values || ')';

    EXECUTE format(
      'INSERT INTO public.course (%s) VALUES %s ON CONFLICT (name) DO NOTHING',
      v_insert_columns,
      v_values
    );
  END IF;

  IF v_has_created_at THEN
    UPDATE public.course
    SET created_at = COALESCE(created_at, NOW())
    WHERE created_at IS NULL;
  END IF;

  IF v_has_updated_at THEN
    UPDATE public.course
    SET updated_at = COALESCE(updated_at, NOW())
    WHERE updated_at IS NULL;
  END IF;

  IF v_has_update_at THEN
    UPDATE public.course
    SET update_at = COALESCE(update_at, NOW())
    WHERE update_at IS NULL;
  END IF;
END $$;



-- Insert sample questions for Psicologia
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
  -- Get psicologia course id
  SELECT id INTO v_course_id FROM public.course WHERE name = 'Psicologia';
  
  -- Check if new columns exist in question table
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
    RAISE NOTICE 'Skipping question seed: required question columns not found.';
    RETURN;
  END IF;
  
  IF v_answerchoice_question_column IS NULL THEN
    RAISE NOTICE 'Skipping question seed: required answerchoice column not found.';
    RETURN;
  END IF;
  
  IF v_course_id IS NOT NULL THEN
    -- Question 1
    v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
    v_question_values := format('%L, %L', 'Qual é o principal objeto de estudo da Psicologia?', v_course_id);
    
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

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'A',
      'O comportamento humano e os processos mentais',
      'TRUE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'B',
      'Apenas os transtornos mentais',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'C',
      'Somente o cérebro humano',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'D',
      'A sociedade e suas instituições',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'E',
      'Os aspectos biológicos do corpo',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );
    
    -- Question 2
    v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
    v_question_values := format('%L, %L', 'Quem é considerado o "pai da psicanálise"?', v_course_id);
    
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

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'A',
      'Carl Jung',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'B',
      'Sigmund Freud',
      'TRUE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'C',
      'B.F. Skinner',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'D',
      'Jean Piaget',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'E',
      'Wilhelm Wundt',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );
    
    -- Question 3
    v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
    v_question_values := format('%L, %L', 'O condicionamento clássico foi descoberto por:', v_course_id);
    
    IF v_has_difficulty THEN
      v_question_columns := v_question_columns || ', difficulty_level';
      v_question_values := v_question_values || format(', %L', 'medium');
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

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'A',
      'John Watson',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'B',
      'Ivan Pavlov',
      'TRUE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'C',
      'Edward Thorndike',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'D',
      'Albert Bandura',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'E',
      'Carl Rogers',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );
    
    -- Question 4
    v_question_columns := format('%I, %I', v_question_text_column, v_question_course_column);
    v_question_values := format('%L, %L', 'Uma Empresa De E-Commerce Percebeu Que Muitos Usuários Abandonam Seus Carrinhos Antes De Finalizar A Compra. Ao Analisar O Fluxo De Navegação, Identificou Que O Formulário De Cadastro Era Muito Longo E Desnecessariamente Complexo. A Equipe De Design Foi Acionada Para Propor Melhorias, Considerando Os Princípios De UX (User Experience). Com Base Na Situação Descrita, Qual Ação De UX E-Mais Adequada Para Reduzir O Abandono Do Carrinho E Melhorar A Experiência Do Usuário?', v_course_id);
    
    IF v_has_difficulty THEN
      v_question_columns := v_question_columns || ', difficulty_level';
      v_question_values := v_question_values || format(', %L', 'medium');
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

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'A',
      'Aumentar A Quantidade De Campos Obrigatórios No Formulário, Garantindo Que Todos Os Dados Do Cliente Sejam Coletados.',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'B',
      'Implementar Uma Barra De Progresso No Checkout E Reduzir Os Campos Obrigatórios Apenas Ao Essencial Para A Compra.',
      'TRUE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'C',
      'Substituir O Formulário Por Um Texto Explicativo Detalhado Sobre Os Termos De Uso E Política De Privacidade.',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'D',
      'Incluir Pop-Ups Durante O Checkout Com Promoções De Outros Produtos, Para Estimular Novas Compras.',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );

    v_answerchoice_values := format(
      '%L, %L, %s, %L',
      'E',
      'Exigir Que O Usuário Crie Uma Conta Completa Antes De Acessar O Carrinho De Compras.',
      'FALSE',
      v_question_id
    );
    IF v_answerchoice_has_created_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    IF v_answerchoice_has_upload_at THEN
      v_answerchoice_values := v_answerchoice_values || ', NOW()';
    END IF;
    EXECUTE format(
      'INSERT INTO public.answerchoice (%s) VALUES (%s)',
      v_answerchoice_columns,
      v_answerchoice_values
    );
  END IF;
END $$;
