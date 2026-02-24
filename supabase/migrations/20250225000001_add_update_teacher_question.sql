-- Migration: Add update_teacher_question function
-- Allows teachers to update a complete question (enunciation, answer choices, supporting texts)
-- in a single atomic transaction

CREATE OR REPLACE FUNCTION update_teacher_question(
  p_question_id uuid,
  p_teacher_id uuid,
  p_subject_id uuid DEFAULT NULL,
  p_category_id uuid DEFAULT NULL,
  p_enunciation text DEFAULT NULL,
  p_difficulty_level text DEFAULT NULL,
  p_points decimal DEFAULT NULL,
  p_supporting_texts jsonb DEFAULT NULL,
  p_answer_choices jsonb DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_existing_question record;
  v_supporting_text jsonb;
  v_answer_choice jsonb;
  v_order integer;
BEGIN
  -- Validate that the question exists and belongs to the teacher
  SELECT id, id_teacher INTO v_existing_question
  FROM public.question
  WHERE id = p_question_id AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Question not found or inactive';
  END IF;

  IF v_existing_question.id_teacher != p_teacher_id THEN
    RAISE EXCEPTION 'Question does not belong to this teacher';
  END IF;

  -- Update question fields (only non-null params)
  UPDATE public.question
  SET
    id_subject = COALESCE(p_subject_id, id_subject),
    id_category = COALESCE(p_category_id, id_category),
    enunciation = COALESCE(p_enunciation, enunciation),
    difficulty_level = COALESCE(p_difficulty_level, difficulty_level),
    points = COALESCE(p_points, points),
    updated_at = NOW()
  WHERE id = p_question_id;

  -- Update supporting texts: delete and recreate
  -- (supportingtext has no FK from other tables, safe to replace)
  IF p_supporting_texts IS NOT NULL THEN
    DELETE FROM public.supportingtext WHERE id_question = p_question_id;

    v_order := 1;
    FOR v_supporting_text IN SELECT * FROM jsonb_array_elements(p_supporting_texts)
    LOOP
      INSERT INTO public.supportingtext (
        id_question, content_type, content, display_order, created_at
      ) VALUES (
        p_question_id,
        COALESCE(v_supporting_text->>'content_type', 'text'),
        COALESCE(v_supporting_text->>'content', ''),
        COALESCE((v_supporting_text->>'display_order')::integer, v_order),
        NOW()
      );
      v_order := v_order + 1;
    END LOOP;
  END IF;

  -- Update answer choices: UPSERT by (idquestion, letter) to preserve IDs
  -- This avoids breaking user_responses foreign keys
  IF p_answer_choices IS NOT NULL THEN
    -- First, delete answer choices whose letters are no longer present
    DELETE FROM public.answerchoice
    WHERE idquestion = p_question_id
      AND letter NOT IN (
        SELECT ac->>'letter'
        FROM jsonb_array_elements(p_answer_choices) AS ac
        WHERE ac->>'letter' IS NOT NULL
      );

    -- UPSERT each answer choice
    FOR v_answer_choice IN SELECT * FROM jsonb_array_elements(p_answer_choices)
    LOOP
      INSERT INTO public.answerchoice (
        idquestion, letter, content, correctanswer, created_at, upload_at
      ) VALUES (
        p_question_id,
        v_answer_choice->>'letter',
        COALESCE(v_answer_choice->>'content', ''),
        COALESCE((v_answer_choice->>'is_correct')::boolean, false),
        NOW(), NOW()
      )
      ON CONFLICT (idquestion, letter)
      DO UPDATE SET
        content = EXCLUDED.content,
        correctanswer = EXCLUDED.correctanswer,
        upload_at = NOW();
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_teacher_question IS 'Updates a complete question with supporting texts and answer choices atomically';
