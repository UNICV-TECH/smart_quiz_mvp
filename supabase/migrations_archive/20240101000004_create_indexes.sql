-- Create indexes for performance optimization

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON public.user(email);

-- Course table indexes
CREATE INDEX IF NOT EXISTS idx_course_name ON public.course(name);

-- Only create is_active index if column exists (added in migration 002)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'course' 
    AND column_name = 'is_active'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_course_is_active ON public.course(is_active);
  END IF;
END $$;

-- Exam table indexes (column-aware)
DO $$
DECLARE
  exam_user_column text;
  exam_course_column text;
  exam_user_idx_name text;
  exam_course_idx_name text;
  exam_user_course_idx_name text;
BEGIN
  SELECT column_name
  INTO exam_user_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'exam'
    AND column_name IN ('id_user', 'user_id', 'iduser')
  ORDER BY CASE column_name
             WHEN 'id_user' THEN 1
             WHEN 'user_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF exam_user_column IS NOT NULL THEN
    exam_user_idx_name := CASE exam_user_column
      WHEN 'id_user' THEN 'idx_exam_id_user'
      WHEN 'user_id' THEN 'idx_exam_user_id'
      ELSE 'idx_exam_iduser'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.exam(%I)',
      exam_user_idx_name,
      exam_user_column
    );
  END IF;

  SELECT column_name
  INTO exam_course_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'exam'
    AND column_name IN ('id_course', 'course_id', 'idcourse')
  ORDER BY CASE column_name
             WHEN 'id_course' THEN 1
             WHEN 'course_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF exam_course_column IS NOT NULL THEN
    exam_course_idx_name := CASE exam_course_column
      WHEN 'id_course' THEN 'idx_exam_id_course'
      WHEN 'course_id' THEN 'idx_exam_course_id'
      ELSE 'idx_exam_idcourse'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.exam(%I)',
      exam_course_idx_name,
      exam_course_column
    );
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'exam'
      AND column_name = 'is_completed'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_exam_is_completed ON public.exam(is_completed);
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'exam'
      AND column_name = 'date_end'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_exam_date_end ON public.exam(date_end);
  END IF;

  IF exam_user_column IS NOT NULL AND exam_course_column IS NOT NULL THEN
    IF exam_user_column = 'id_user' AND exam_course_column = 'id_course' THEN
      exam_user_course_idx_name := 'idx_exam_user_course';
    ELSE
      exam_user_course_idx_name := format('idx_exam_%s_%s', exam_user_column, exam_course_column);
    END IF;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.exam(%I, %I)',
      exam_user_course_idx_name,
      exam_user_column,
      exam_course_column
    );
  END IF;
END $$;

-- Question table indexes
DO $$
DECLARE
  question_course_column text;
  question_course_idx_name text;
BEGIN
  SELECT column_name
  INTO question_course_column
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

  IF question_course_column IS NOT NULL THEN
    question_course_idx_name := CASE question_course_column
      WHEN 'id_course' THEN 'idx_question_id_course'
      WHEN 'course_id' THEN 'idx_question_course_id'
      ELSE 'idx_question_idcourse'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.question(%I)',
      question_course_idx_name,
      question_course_column
    );
  END IF;
END $$;

-- Only create these indexes if the columns exist (added in migration 002)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'question' 
    AND column_name = 'is_active'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_question_is_active ON public.question(is_active);
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'question' 
    AND column_name = 'difficulty_level'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_question_difficulty ON public.question(difficulty_level);
  END IF;
END $$;

-- ExamQuestion table indexes (column-aware)
DO $$
DECLARE
  examquestion_exam_column text;
  examquestion_question_column text;
  examquestion_exam_idx_name text;
  examquestion_question_idx_name text;
  examquestion_unique_idx_name text;
BEGIN
  SELECT column_name
  INTO examquestion_exam_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'examquestion'
    AND column_name IN ('id_exam', 'exam_id', 'idexam')
  ORDER BY CASE column_name
             WHEN 'id_exam' THEN 1
             WHEN 'exam_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF examquestion_exam_column IS NOT NULL THEN
    examquestion_exam_idx_name := CASE examquestion_exam_column
      WHEN 'id_exam' THEN 'idx_examquestion_id_exam'
      WHEN 'exam_id' THEN 'idx_examquestion_exam_id'
      ELSE 'idx_examquestion_idexam'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.examquestion(%I)',
      examquestion_exam_idx_name,
      examquestion_exam_column
    );
  END IF;

  SELECT column_name
  INTO examquestion_question_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'examquestion'
    AND column_name IN ('id_question', 'question_id', 'idquestion')
  ORDER BY CASE column_name
             WHEN 'id_question' THEN 1
             WHEN 'question_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF examquestion_question_column IS NOT NULL THEN
    examquestion_question_idx_name := CASE examquestion_question_column
      WHEN 'id_question' THEN 'idx_examquestion_id_question'
      WHEN 'question_id' THEN 'idx_examquestion_question_id'
      ELSE 'idx_examquestion_idquestion'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.examquestion(%I)',
      examquestion_question_idx_name,
      examquestion_question_column
    );
  END IF;

  IF examquestion_exam_column IS NOT NULL AND examquestion_question_column IS NOT NULL THEN
    IF examquestion_exam_column = 'id_exam' AND examquestion_question_column = 'id_question' THEN
      examquestion_unique_idx_name := 'idx_examquestion_unique';
    ELSE
      examquestion_unique_idx_name := format(
        'idx_examquestion_%s_%s',
        examquestion_exam_column,
        examquestion_question_column
      );
    END IF;

    EXECUTE format(
      'CREATE UNIQUE INDEX IF NOT EXISTS %I ON public.examquestion(%I, %I)',
      examquestion_unique_idx_name,
      examquestion_exam_column,
      examquestion_question_column
    );
  END IF;
END $$;

-- AnswerChoice table indexes (column-aware)
DO $$
DECLARE
  answerchoice_question_column text;
  answerchoice_question_idx_name text;
  answerchoice_unique_idx_name text;
BEGIN
  SELECT column_name
  INTO answerchoice_question_column
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

  IF answerchoice_question_column IS NOT NULL THEN
    answerchoice_question_idx_name := CASE answerchoice_question_column
      WHEN 'id_question' THEN 'idx_answerchoice_id_question'
      WHEN 'question_id' THEN 'idx_answerchoice_question_id'
      ELSE 'idx_answerchoice_idquestion'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.answerchoice(%I)',
      answerchoice_question_idx_name,
      answerchoice_question_column
    );

    IF EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'answerchoice'
        AND column_name = 'letter'
    ) THEN
      IF answerchoice_question_column = 'idquestion' THEN
        answerchoice_unique_idx_name := 'idx_answerchoice_unique';
      ELSE
        answerchoice_unique_idx_name := format(
          'idx_answerchoice_%s_letter',
          answerchoice_question_column
        );
      END IF;

      EXECUTE format(
        'CREATE UNIQUE INDEX IF NOT EXISTS %I ON public.answerchoice(%I, letter)',
        answerchoice_unique_idx_name,
        answerchoice_question_column
      );
    END IF;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'answerchoice'
      AND column_name = 'correctanswer'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_answerchoice_correctanswer ON public.answerchoice(correctanswer);
  END IF;
END $$;

-- UserResponse table indexes (column-aware)
DO $$
DECLARE
  userresponse_exam_column text;
  userresponse_question_column text;
  userresponse_answerchoice_column text;
  userresponse_exam_idx_name text;
  userresponse_question_idx_name text;
  userresponse_answerchoice_idx_name text;
  userresponse_unique_idx_name text;
BEGIN
  SELECT column_name
  INTO userresponse_exam_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'userresponse'
    AND column_name IN ('id_exam', 'exam_id', 'idexam')
  ORDER BY CASE column_name
             WHEN 'id_exam' THEN 1
             WHEN 'exam_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF userresponse_exam_column IS NOT NULL THEN
    userresponse_exam_idx_name := CASE userresponse_exam_column
      WHEN 'id_exam' THEN 'idx_userresponse_id_exam'
      WHEN 'exam_id' THEN 'idx_userresponse_exam_id'
      ELSE 'idx_userresponse_idexam'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.userresponse(%I)',
      userresponse_exam_idx_name,
      userresponse_exam_column
    );
  END IF;

  SELECT column_name
  INTO userresponse_question_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'userresponse'
    AND column_name IN ('id_question', 'question_id', 'idquestion')
  ORDER BY CASE column_name
             WHEN 'id_question' THEN 1
             WHEN 'question_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF userresponse_question_column IS NOT NULL THEN
    userresponse_question_idx_name := CASE userresponse_question_column
      WHEN 'id_question' THEN 'idx_userresponse_id_question'
      WHEN 'question_id' THEN 'idx_userresponse_question_id'
      ELSE 'idx_userresponse_idquestion'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.userresponse(%I)',
      userresponse_question_idx_name,
      userresponse_question_column
    );
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'userresponse'
      AND column_name = 'is_correct'
  ) THEN
    CREATE INDEX IF NOT EXISTS idx_userresponse_is_correct ON public.userresponse(is_correct);
  END IF;

  SELECT column_name
  INTO userresponse_answerchoice_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'userresponse'
    AND column_name IN ('id_answerchoice', 'answerchoice_id', 'idanswerchoice')
  ORDER BY CASE column_name
             WHEN 'id_answerchoice' THEN 1
             WHEN 'answerchoice_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF userresponse_answerchoice_column IS NOT NULL THEN
    userresponse_answerchoice_idx_name := CASE userresponse_answerchoice_column
      WHEN 'id_answerchoice' THEN 'idx_userresponse_id_answerchoice'
      WHEN 'answerchoice_id' THEN 'idx_userresponse_answerchoice_id'
      ELSE 'idx_userresponse_idanswerchoice'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.userresponse(%I)',
      userresponse_answerchoice_idx_name,
      userresponse_answerchoice_column
    );
  END IF;

  IF userresponse_exam_column IS NOT NULL AND userresponse_question_column IS NOT NULL THEN
    IF userresponse_exam_column = 'id_exam' AND userresponse_question_column = 'id_question' THEN
      userresponse_unique_idx_name := 'idx_userresponse_unique';
    ELSE
      userresponse_unique_idx_name := format(
        'idx_userresponse_%s_%s',
        userresponse_exam_column,
        userresponse_question_column
      );
    END IF;

    EXECUTE format(
      'CREATE UNIQUE INDEX IF NOT EXISTS %I ON public.userresponse(%I, %I)',
      userresponse_unique_idx_name,
      userresponse_exam_column,
      userresponse_question_column
    );
  END IF;
END $$;

-- SupportingText table indexes (column-aware)
DO $$
DECLARE
  supportingtext_question_column text;
  supportingtext_question_idx_name text;
  has_display_order boolean;
  supportingtext_display_idx_name text;
BEGIN
  SELECT column_name
  INTO supportingtext_question_column
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'supportingtext'
    AND column_name IN ('id_question', 'question_id', 'idquestion')
  ORDER BY CASE column_name
             WHEN 'id_question' THEN 1
             WHEN 'question_id' THEN 2
             ELSE 3
           END
  LIMIT 1;

  IF supportingtext_question_column IS NOT NULL THEN
    supportingtext_question_idx_name := CASE supportingtext_question_column
      WHEN 'id_question' THEN 'idx_supportingtext_id_question'
      WHEN 'question_id' THEN 'idx_supportingtext_question_id'
      ELSE 'idx_supportingtext_idquestion'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.supportingtext(%I)',
      supportingtext_question_idx_name,
      supportingtext_question_column
    );
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'supportingtext'
      AND column_name = 'display_order'
  ) INTO has_display_order;

  IF supportingtext_question_column IS NOT NULL AND has_display_order THEN
    supportingtext_display_idx_name := CASE supportingtext_question_column
      WHEN 'id_question' THEN 'idx_supportingtext_display_order'
      WHEN 'question_id' THEN 'idx_supportingtext_display_order_question_id'
      ELSE 'idx_supportingtext_display_order_idquestion'
    END;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.supportingtext(%I, display_order)',
      supportingtext_display_idx_name,
      supportingtext_question_column
    );
  END IF;
END $$;
