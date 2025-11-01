# Psychology Questions Database Seeding Plan

## Executive Summary

Create a new migration file to add 36 additional psychology questions to the existing 4, totaling 40 comprehensive psychology questions for the Smart Quiz MVP application.

---

## Current State

### Existing Data
- **File**: `supabase/migrations/20240101000005_seed_sample_data.sql`
- **Current Psychology Questions**: 4
- **Question Structure**: 
  - Multiple choice with 5 options (A-E)
  - One correct answer per question
  - Difficulty levels: easy, medium, hard
  - Linked to Psychology course via `idcourse`

### Database Schema
```sql
question (
  id uuid,
  created_at timestamp,
  updated_at timestamp,
  number smallint,
  statement text,
  idcourse uuid,
  difficulty_level text,
  points decimal,
  is_active boolean
)

answerchoice (
  id uuid,
  created_at timestamp,
  upload_at timestamp,
  letter text,
  content text,
  correctanswer boolean,
  idquestion uuid
)
```

---

## Implementation Strategy

### Option Selected: Option 1 - New Migration File

**File**: `supabase/migrations/20241101000012_seed_psychology_questions.sql`

**Rationale**:
- ✅ Preserves migration history
- ✅ Follows database migration best practices
- ✅ Easy rollback capability
- ✅ Separates existing from new data
- ✅ No conflicts with already-applied migrations

---

## Question Distribution Plan

### Total Questions: 40
- **Existing**: 4 questions (Questions 1-4)
- **New**: 36 questions (Questions 5-40)

### Topic Coverage

| Category | Count | Question Range | Description |
|----------|-------|----------------|-------------|
| **Basic Concepts** | 8 | Q5-Q12 | Psychology fundamentals, history, schools of thought |
| **Cognitive Psychology** | 8 | Q13-Q20 | Memory, perception, attention, thinking processes |
| **Developmental Psychology** | 6 | Q21-Q26 | Child development, lifespan, developmental stages |
| **Social Psychology** | 6 | Q27-Q32 | Groups, influence, attitudes, social behavior |
| **Clinical Psychology** | 4 | Q33-Q36 | Disorders, therapy approaches, assessment |
| **Neuroscience & Biological** | 4 | Q37-Q40 | Brain structure, neurotransmitters, biological basis |

### Difficulty Distribution

| Difficulty | Count | Percentage | Target Range |
|-----------|-------|------------|--------------|
| **Easy** | 12 | 30% | Q5, Q6, Q8, Q11, Q13, Q14, Q21, Q22, Q27, Q28, Q33, Q37 |
| **Medium** | 18 | 45% | Q7, Q9, Q10, Q12, Q15, Q16, Q18, Q19, Q23, Q24, Q26, Q29, Q30, Q32, Q34, Q36, Q38, Q39 |
| **Hard** | 10 | 25% | Q17, Q20, Q25, Q31, Q35, Q40 (+ 4 more distributed) |

---

## Sample Question Content

### Basic Concepts (Q5-Q12)

**Q5** (Easy): O que é a psicologia humanista?
- A) Abordagem que enfatiza o inconsciente
- B) Abordagem que estuda apenas comportamentos observáveis
- C) **Abordagem que enfatiza o potencial humano e crescimento pessoal** ✓
- D) Abordagem que foca apenas em processos cognitivos
- E) Abordagem que estuda apenas transtornos mentais

**Q6** (Easy): Qual abordagem teórica enfatiza o papel do inconsciente?
- A) Behaviorismo
- B) **Psicanálise** ✓
- C) Humanismo
- D) Cognitivismo
- E) Gestalt

**Q7** (Medium): O behaviorismo clássico estuda principalmente:
- A) Os sonhos e o inconsciente
- B) **Comportamentos observáveis e mensuráveis** ✓
- C) Processos mentais internos
- D) Experiências subjetivas
- E) A estrutura da consciência

**Q8** (Easy): Qual método de pesquisa é mais usado em estudos qualitativos em psicologia?
- A) Experimentos controlados
- B) **Entrevistas e observações** ✓
- C) Testes estatísticos
- D) Ressonância magnética
- E) Medicação controlada

**Q9** (Medium): O que significa o termo "cognição" em psicologia?
- A) Apenas a memória
- B) Apenas o raciocínio lógico
- C) **Processos mentais como pensar, perceber e lembrar** ✓
- D) Somente as emoções
- E) Comportamentos motores

**Q10** (Medium): Quem desenvolveu a teoria das inteligências múltiplas?
- A) Jean Piaget
- B) Sigmund Freud
- C) **Howard Gardner** ✓
- D) Lev Vygotsky
- E) Albert Bandura

**Q11** (Easy): O que a psicologia social estuda primariamente?
- A) Transtornos mentais individuais
- B) Processos cerebrais
- C) **Como as pessoas influenciam e são influenciadas por outras** ✓
- D) Desenvolvimento infantil
- E) Memória e aprendizagem

**Q12** (Medium): Qual a principal diferença entre psicólogo e psiquiatra?
- A) Psicólogos não podem atender pacientes
- B) **Psiquiatras são médicos e podem prescrever medicamentos** ✓
- C) Psicólogos só trabalham com crianças
- D) Psiquiatras não fazem terapia
- E) Não há diferença entre os dois

### Cognitive Psychology (Q13-Q20)

**Q13** (Easy): O que é memória de trabalho?
- A) Memória de longo prazo
- B) **Sistema que mantém e manipula informações temporariamente** ✓
- C) Memória permanente
- D) Memória inconsciente
- E) Memória sensorial

**Q14** (Easy): Qual tipo de memória armazena informações por apenas alguns segundos?
- A) Memória de longo prazo
- B) Memória de trabalho
- C) **Memória sensorial** ✓
- D) Memória episódica
- E) Memória semântica

**Q15** (Medium): O que é atenção seletiva?
- A) Prestar atenção em tudo simultaneamente
- B) **Focar em estímulos específicos enquanto ignora outros** ✓
- C) Perder a concentração facilmente
- D) Ter déficit de atenção
- E) Memorizar informações selecionadas

**Q16** (Medium): Qual teoria explica como organizamos informações visuais em padrões?
- A) Teoria Behaviorista
- B) **Teoria da Gestalt** ✓
- C) Teoria Psicanalítica
- D) Teoria do Condicionamento
- E) Teoria Humanista

**Q17** (Hard): O que são heurísticas em psicologia cognitiva?
- A) Testes de inteligência
- B) Transtornos cognitivos
- C) **Atalhos mentais que facilitam tomada de decisões** ✓
- D) Memórias falsas
- E) Processos de aprendizagem formal

**Q18** (Medium): O que é metacognição?
- A) Pensar rapidamente
- B) **Pensar sobre o próprio pensamento** ✓
- C) Memória fotográfica
- D) Inteligência emocional
- E) Processamento automático

**Q19** (Medium): Qual modelo descreve como processamos informações como um computador?
- A) Modelo Psicanalítico
- B) **Modelo de Processamento de Informações** ✓
- C) Modelo Comportamental
- D) Modelo Humanista
- E) Modelo Existencial

**Q20** (Hard): O que é um esquema cognitivo?
- A) Um tipo de transtorno mental
- B) Um teste psicológico
- C) **Estrutura mental que organiza conhecimento e experiências** ✓
- D) Uma técnica de memorização
- E) Um tipo de terapia

### Developmental Psychology (Q21-Q26)

**Q21** (Easy): Segundo Piaget, em qual estágio a criança desenvolve pensamento lógico?
- A) Sensório-motor
- B) Pré-operacional
- C) **Operações concretas** ✓
- D) Primeiro ano de vida
- E) Idade adulta

**Q22** (Easy): O que é desenvolvimento cognitivo?
- A) Crescimento físico
- B) **Mudanças nas capacidades mentais ao longo da vida** ✓
- C) Apenas a aprendizagem escolar
- D) Desenvolvimento motor
- E) Amadurecimento sexual

**Q23** (Medium): Qual teórico enfatizou a importância da interação social no desenvolvimento?
- A) Sigmund Freud
- B) B.F. Skinner
- C) **Lev Vygotsky** ✓
- D) Ivan Pavlov
- E) Carl Jung

**Q24** (Medium): O que caracteriza a adolescência segundo Erik Erikson?
- A) Busca por autonomia
- B) **Busca por identidade** ✓
- C) Desenvolvimento motor
- D) Apego aos pais
- E) Pensamento concreto

**Q25** (Hard): O que é "zona de desenvolvimento proximal" de Vygotsky?
- A) Área do cérebro em desenvolvimento
- B) **Diferença entre o que a criança faz sozinha e com ajuda** ✓
- C) Estágio de desenvolvimento infantil
- D) Fase do desenvolvimento motor
- E) Período de desenvolvimento cerebral

**Q26** (Medium): O que estuda a psicologia do desenvolvimento?
- A) Apenas o desenvolvimento infantil
- B) Apenas a velhice
- C) **Mudanças ao longo de toda a vida** ✓
- D) Somente a adolescência
- E) Apenas o desenvolvimento físico

### Social Psychology (Q27-Q32)

**Q27** (Easy): O que é conformidade social?
- A) Ser rebelde
- B) **Mudar comportamento para se adequar ao grupo** ✓
- C) Liderar um grupo
- D) Evitar pessoas
- E) Ser individualista

**Q28** (Easy): O que estuda a psicologia dos grupos?
- A) Apenas indivíduos isolados
- B) **Como as pessoas se comportam em grupos** ✓
- C) Somente famílias
- D) Apenas grandes multidões
- E) Personalidade individual

**Q29** (Medium): O que é dissonância cognitiva?
- A) Um tipo de transtorno
- B) **Desconforto por ter crenças contraditórias** ✓
- C) Perda de memória
- D) Falta de atenção
- E) Dificuldade de aprendizagem

**Q30** (Medium): O experimento de Milgram demonstrou:
- A) Efeitos da memória
- B) **Obediência à autoridade** ✓
- C) Desenvolvimento infantil
- D) Condicionamento clássico
- E) Inteligência emocional

**Q31** (Hard): O que é atribuição causal em psicologia social?
- A) Um tipo de terapia
- B) Um transtorno mental
- C) **Processo de explicar causas de comportamentos** ✓
- D) Técnica de memorização
- E) Método de pesquisa

**Q32** (Medium): O que são estereótipos?
- A) Tipos de personalidade
- B) **Crenças generalizadas sobre grupos de pessoas** ✓
- C) Transtornos sociais
- D) Comportamentos individuais
- E) Técnicas de comunicação

### Clinical Psychology (Q33-Q36)

**Q33** (Easy): O que caracteriza um transtorno de ansiedade?
- A) Apenas tristeza profunda
- B) **Medo e preocupação excessivos e persistentes** ✓
- C) Perda de memória
- D) Alucinações
- E) Euforia extrema

**Q34** (Medium): Qual abordagem terapêutica foca em mudar padrões de pensamento?
- A) Psicanálise
- B) **Terapia Cognitivo-Comportamental (TCC)** ✓
- C) Terapia Humanista apenas
- D) Hipnose
- E) Terapia familiar sistêmica

**Q35** (Hard): O que é comorbidade em psicologia clínica?
- A) Recuperação completa
- B) **Presença de dois ou mais transtornos simultaneamente** ✓
- C) Resistência ao tratamento
- D) Tipo de medicação
- E) Fase inicial do tratamento

**Q36** (Medium): O que avalia um teste psicológico projetivo?
- A) Apenas inteligência
- B) Apenas memória
- C) **Aspectos inconscientes da personalidade** ✓
- D) Apenas habilidades motoras
- E) Somente conhecimento acadêmico

### Neuroscience & Biological Psychology (Q37-Q40)

**Q37** (Easy): Qual estrutura cerebral é essencial para a memória?
- A) Cerebelo
- B) **Hipocampo** ✓
- C) Medula
- D) Ponte
- E) Bulbo

**Q38** (Medium): O que são neurotransmissores?
- A) Células nervosas
- B) **Substâncias químicas que transmitem sinais entre neurônios** ✓
- C) Partes do cérebro
- D) Hormônios apenas
- E) Tipos de memória

**Q39** (Medium): Qual neurotransmissor está associado ao prazer e recompensa?
- A) Serotonina
- B) **Dopamina** ✓
- C) Acetilcolina
- D) GABA
- E) Glutamato

**Q40** (Hard): O que é neuroplasticidade?
- A) Doença cerebral
- B) Tipo de terapia
- C) **Capacidade do cérebro de reorganizar conexões neurais** ✓
- D) Perda de neurônios
- E) Técnica de diagnóstico

---

## Migration File Structure

### File Name
```
20241101000012_seed_psychology_questions.sql
```

### File Template Structure

```sql
-- Seed 36 additional psychology questions (Q5-Q40)
-- Total: 40 psychology questions (4 existing + 36 new)

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
  
  IF v_course_id IS NULL THEN
    RAISE NOTICE 'Psicologia course not found. Skipping question seed.';
    RETURN;
  END IF;
  
  -- Detect schema columns (same as existing seed file)
  -- [Column detection code...]
  
  -- Question 5 through Question 40
  -- Each following the same pattern as existing questions
  
END $$;
```

---

## Quality Assurance Checklist

### Pre-Implementation
- [ ] Review existing 4 questions for consistency
- [ ] Verify course "Psicologia" exists in database
- [ ] Confirm schema columns match expectations
- [ ] Prepare 36 question texts in Portuguese

### During Implementation
- [ ] All 36 questions have exactly 5 answer choices (A-E)
- [ ] Each question has exactly one correct answer
- [ ] Difficulty distribution: 12 easy, 18 medium, 10 hard
- [ ] Questions cover all 6 topic categories
- [ ] Portuguese grammar and spelling checked
- [ ] No duplicate question content
- [ ] SQL syntax validated (no quotes/escaping errors)

### Post-Implementation
- [ ] Migration file runs without errors
- [ ] Total question count = 40 for Psychology course
- [ ] All foreign key references valid
- [ ] Answer choices link correctly to questions
- [ ] Can fetch random questions for exam generation
- [ ] Test exam creation with 5, 10, 15, 20 questions

---

## Testing Strategy

### Local Testing (Recommended)

```bash
# 1. Apply migration to local Supabase
cd /path/to/smart_quiz_mvp
supabase db reset --local
supabase migration up

# 2. Verify question count
supabase db query --local "
  SELECT COUNT(*) as total_questions 
  FROM question 
  WHERE idcourse = (SELECT id FROM course WHERE name = 'Psicologia');
"
# Expected output: 40

# 3. Verify difficulty distribution
supabase db query --local "
  SELECT difficulty_level, COUNT(*) 
  FROM question 
  WHERE idcourse = (SELECT id FROM course WHERE name = 'Psicologia')
  GROUP BY difficulty_level;
"
# Expected: easy=12, medium=18, hard=10

# 4. Verify answer choices
supabase db query --local "
  SELECT q.id, COUNT(ac.id) as choice_count
  FROM question q
  LEFT JOIN answerchoice ac ON ac.idquestion = q.id
  WHERE q.idcourse = (SELECT id FROM course WHERE name = 'Psicologia')
  GROUP BY q.id
  HAVING COUNT(ac.id) != 5;
"
# Expected: 0 rows (all questions should have exactly 5 choices)

# 5. Test exam generation
supabase db query --local "
  SELECT q.statement
  FROM question q
  WHERE q.idcourse = (SELECT id FROM course WHERE name = 'Psicologia')
  ORDER BY RANDOM()
  LIMIT 10;
"
```

### Production Deployment

```bash
# 1. Backup production database first
supabase db dump --remote > backup_before_questions.sql

# 2. Apply migration
supabase db push

# 3. Run same verification queries as local testing

# 4. Test app functionality
# - Open app
# - Select Psychology course
# - Configure exam (10 questions)
# - Verify 10 random questions load
# - Complete exam
# - Check results
```

---

## Implementation Timeline

| Phase | Task | Duration | Status |
|-------|------|----------|--------|
| **1** | Generate 36 question contents | 1.5 hours | ⏳ Pending |
| **2** | Create SQL migration file | 30 mins | ⏳ Pending |
| **3** | Local testing & validation | 20 mins | ⏳ Pending |
| **4** | Review & adjustments | 15 mins | ⏳ Pending |
| **5** | Production deployment | 10 mins | ⏳ Pending |
| **6** | Production verification | 15 mins | ⏳ Pending |
| **Total** | | ~3 hours | |

---

## Rollback Plan

If issues occur after deployment:

### Quick Rollback
```sql
-- Delete all questions added by this migration
DELETE FROM answerchoice 
WHERE idquestion IN (
  SELECT id FROM question 
  WHERE idcourse = (SELECT id FROM course WHERE name = 'Psicologia')
  AND created_at >= '[MIGRATION_TIMESTAMP]'
);

DELETE FROM question 
WHERE idcourse = (SELECT id FROM course WHERE name = 'Psicologia')
AND created_at >= '[MIGRATION_TIMESTAMP]';
```

### Full Rollback
```bash
# Restore from backup
supabase db restore backup_before_questions.sql
```

---

## Success Criteria

✅ **Must Have**:
1. Exactly 40 psychology questions in database
2. All questions have 5 answer choices
3. Each question has exactly 1 correct answer
4. Questions cover 6 topic categories
5. Migration runs without errors
6. App can generate exams successfully

✅ **Nice to Have**:
1. Questions vary in complexity
2. Questions suitable for university-level students
3. Portuguese grammar is correct and clear
4. Questions test conceptual understanding, not just memorization

---

## Next Steps

1. **Immediate**: Generate the full migration file with all 36 questions
2. **After Generation**: Review question quality and difficulty
3. **Testing**: Apply migration to local Supabase instance
4. **Validation**: Run all QA checks
5. **Deployment**: Apply to production database
6. **Monitoring**: Verify app functionality with new questions

---

## References

- Existing migration: `supabase/migrations/20240101000005_seed_sample_data.sql`
- Schema documentation: `SCHEMA_DOCUMENTATION.md`
- Database alignment migrations: `20241101000007-20241101000011`
- Supabase CLI docs: https://supabase.com/docs/guides/cli

---

**Document Version**: 1.0  
**Created**: November 1, 2024  
**Status**: Ready for Implementation
