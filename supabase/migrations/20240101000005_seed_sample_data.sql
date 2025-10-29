-- Sample data seed for testing

-- Insert sample courses
-- Check if columns exist before inserting
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'course' 
    AND column_name = 'description'
  ) THEN
    -- Insert with new columns
    INSERT INTO public.course (name, icon, description, is_active) 
    VALUES
      ('Psicologia', 'psychology', 'Curso de Psicologia', TRUE),
      ('Direito', 'law', 'Curso de Direito', TRUE),
      ('Medicina', 'medical', 'Curso de Medicina', TRUE),
      ('Engenharia', 'engineering', 'Curso de Engenharia', TRUE),
      ('Administração', 'business', 'Curso de Administração', TRUE)
    ON CONFLICT (name) DO NOTHING;
  ELSE
    -- Insert with original columns only
    INSERT INTO public.course (name, icon) 
    VALUES
      ('Psicologia', 'psychology'),
      ('Direito', 'law'),
      ('Medicina', 'medical'),
      ('Engenharia', 'engineering'),
      ('Administração', 'business')
    ON CONFLICT (name) DO NOTHING;
  END IF;
END $$;

-- Insert sample questions for Psicologia
DO $$
DECLARE
  v_course_id uuid;
  v_question_id uuid;
  v_has_new_cols boolean;
BEGIN
  -- Get psicologia course id
  SELECT id INTO v_course_id FROM public.course WHERE name = 'Psicologia';
  
  -- Check if new columns exist in question table
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'question' 
    AND column_name = 'difficulty_level'
  ) INTO v_has_new_cols;
  
  IF v_course_id IS NOT NULL THEN
    -- Question 1
    IF v_has_new_cols THEN
      INSERT INTO public.question (enunciation, difficulty_level, points, is_active, id_course)
      VALUES ('Qual é o principal objeto de estudo da Psicologia?', 'easy', 1.0, TRUE, v_course_id)
      RETURNING id INTO v_question_id;
    ELSE
      INSERT INTO public.question (enunciation, id_course)
      VALUES ('Qual é o principal objeto de estudo da Psicologia?', v_course_id)
      RETURNING id INTO v_question_id;
    END IF;
    
    INSERT INTO public.answerchoice (letter, content, correctanswer, idquestion) VALUES
    ('A', 'O comportamento humano e os processos mentais', TRUE, v_question_id),
    ('B', 'Apenas os transtornos mentais', FALSE, v_question_id),
    ('C', 'Somente o cérebro humano', FALSE, v_question_id),
    ('D', 'A sociedade e suas instituições', FALSE, v_question_id),
    ('E', 'Os aspectos biológicos do corpo', FALSE, v_question_id);
    
    -- Question 2
    IF v_has_new_cols THEN
      INSERT INTO public.question (enunciation, difficulty_level, points, is_active, id_course)
      VALUES ('Quem é considerado o "pai da psicanálise"?', 'easy', 1.0, TRUE, v_course_id)
      RETURNING id INTO v_question_id;
    ELSE
      INSERT INTO public.question (enunciation, id_course)
      VALUES ('Quem é considerado o "pai da psicanálise"?', v_course_id)
      RETURNING id INTO v_question_id;
    END IF;
    
    INSERT INTO public.answerchoice (letter, content, correctanswer, idquestion) VALUES
    ('A', 'Carl Jung', FALSE, v_question_id),
    ('B', 'Sigmund Freud', TRUE, v_question_id),
    ('C', 'B.F. Skinner', FALSE, v_question_id),
    ('D', 'Jean Piaget', FALSE, v_question_id),
    ('E', 'Wilhelm Wundt', FALSE, v_question_id);
    
    -- Question 3
    IF v_has_new_cols THEN
      INSERT INTO public.question (enunciation, difficulty_level, points, is_active, id_course)
      VALUES ('O condicionamento clássico foi descoberto por:', 'medium', 1.0, TRUE, v_course_id)
      RETURNING id INTO v_question_id;
    ELSE
      INSERT INTO public.question (enunciation, id_course)
      VALUES ('O condicionamento clássico foi descoberto por:', v_course_id)
      RETURNING id INTO v_question_id;
    END IF;
    
    INSERT INTO public.answerchoice (letter, content, correctanswer, idquestion) VALUES
    ('A', 'John Watson', FALSE, v_question_id),
    ('B', 'Ivan Pavlov', TRUE, v_question_id),
    ('C', 'Edward Thorndike', FALSE, v_question_id),
    ('D', 'Albert Bandura', FALSE, v_question_id),
    ('E', 'Carl Rogers', FALSE, v_question_id);
    
    -- Question 4
    IF v_has_new_cols THEN
      INSERT INTO public.question (enunciation, difficulty_level, points, is_active, id_course)
      VALUES ('Uma Empresa De E-Commerce Percebeu Que Muitos Usuários Abandonam Seus Carrinhos Antes De Finalizar A Compra. Ao Analisar O Fluxo De Navegação, Identificou Que O Formulário De Cadastro Era Muito Longo E Desnecessariamente Complexo. A Equipe De Design Foi Acionada Para Propor Melhorias, Considerando Os Princípios De UX (User Experience). Com Base Na Situação Descrita, Qual Ação De UX E-Mais Adequada Para Reduzir O Abandono Do Carrinho E Melhorar A Experiência Do Usuário?', 'medium', 1.0, TRUE, v_course_id)
      RETURNING id INTO v_question_id;
    ELSE
      INSERT INTO public.question (enunciation, id_course)
      VALUES ('Uma Empresa De E-Commerce Percebeu Que Muitos Usuários Abandonam Seus Carrinhos Antes De Finalizar A Compra. Ao Analisar O Fluxo De Navegação, Identificou Que O Formulário De Cadastro Era Muito Longo E Desnecessariamente Complexo. A Equipe De Design Foi Acionada Para Propor Melhorias, Considerando Os Princípios De UX (User Experience). Com Base Na Situação Descrita, Qual Ação De UX E-Mais Adequada Para Reduzir O Abandono Do Carrinho E Melhorar A Experiência Do Usuário?', v_course_id)
      RETURNING id INTO v_question_id;
    END IF;
    
    INSERT INTO public.answerchoice (letter, content, correctanswer, idquestion) VALUES
    ('A', 'Aumentar A Quantidade De Campos Obrigatórios No Formulário, Garantindo Que Todos Os Dados Do Cliente Sejam Coletados.', FALSE, v_question_id),
    ('B', 'Implementar Uma Barra De Progresso No Checkout E Reduzir Os Campos Obrigatórios Apenas Ao Essencial Para A Compra.', TRUE, v_question_id),
    ('C', 'Substituir O Formulário Por Um Texto Explicativo Detalhado Sobre Os Termos De Uso E Política De Privacidade.', FALSE, v_question_id),
    ('D', 'Incluir Pop-Ups Durante O Checkout Com Promoções De Outros Produtos, Para Estimular Novas Compras.', FALSE, v_question_id),
    ('E', 'Exigir Que O Usuário Crie Uma Conta Completa Antes De Acessar O Carrinho De Compras.', FALSE, v_question_id);
  END IF;
END $$;
