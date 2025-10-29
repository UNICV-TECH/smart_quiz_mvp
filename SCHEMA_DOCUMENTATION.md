# Supabase PostgreSQL Schema Documentation

## Overview
This document defines the database schema for the Smart Quiz application, documenting entity relationships and data flow through the test-taking sequence across three main screens: **Home Screen**, **Quiz Configuration Screen**, and **Exam Screen**.

---

## 1. Database Schema

### 1.1 User Table
Stores authenticated user information.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Purpose**: Manages user authentication and identity across the application.

---

### 1.2 Course Table
Represents academic courses available for quiz preparation.

```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_key TEXT UNIQUE NOT NULL,  -- e.g., 'psicologia', 'direito'
  title TEXT NOT NULL,               -- e.g., 'Psicologia', 'Direito'
  description TEXT,
  icon_key TEXT,                     -- Icon identifier for UI
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Purpose**: Defines the courses users can select for exam preparation.

**Relationships**:
- One course has many exams
- One course has many user exam attempts

---

### 1.3 Exam Table
Defines exam metadata and configuration.

```sql
CREATE TABLE exams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  total_available_questions INTEGER NOT NULL DEFAULT 0,
  time_limit_minutes INTEGER,       -- NULL = unlimited
  passing_score_percentage DECIMAL(5,2) DEFAULT 70.0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_exams_course_id ON exams(course_id);
CREATE INDEX idx_exams_active ON exams(is_active);
```

**Purpose**: Stores exam metadata used during quiz configuration to determine available question pools.

**Relationships**:
- Many exams belong to one course
- One exam has many questions
- One exam has many user attempts

---

### 1.4 Question Table
Stores individual exam questions.

```sql
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  enunciation TEXT NOT NULL,         -- Question text/prompt
  question_order INTEGER,            -- Optional ordering within exam
  difficulty_level TEXT CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
  points DECIMAL(5,2) DEFAULT 1.0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_questions_exam_id ON questions(exam_id);
CREATE INDEX idx_questions_active ON questions(is_active);
CREATE INDEX idx_questions_difficulty ON questions(difficulty_level);
```

**Purpose**: Contains the question text presented during exam taking.

**Relationships**:
- Many questions belong to one exam
- One question has many answer choices
- One question may have supporting text
- One question has many user responses

---

### 1.5 Answer Choice Table
Stores possible answers for multiple-choice questions.

```sql
CREATE TABLE answer_choices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  choice_key TEXT NOT NULL,          -- 'A', 'B', 'C', 'D', 'E'
  choice_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  choice_order INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_answer_choices_question_id ON answer_choices(question_id);
CREATE INDEX idx_answer_choices_correct ON answer_choices(is_correct);

-- Ensure unique choice keys per question
CREATE UNIQUE INDEX idx_answer_choice_unique ON answer_choices(question_id, choice_key);
```

**Purpose**: Provides multiple-choice alternatives displayed during question presentation.

**Relationships**:
- Many answer choices belong to one question
- One answer choice can be referenced by many user responses

---

### 1.6 Supporting Text Table
Stores supplementary materials like passages, images, or context for questions.

```sql
CREATE TABLE supporting_texts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('text', 'image', 'code', 'table')),
  content TEXT NOT NULL,             -- Text content or URL for images
  display_order INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_supporting_texts_question_id ON supporting_texts(question_id);
```

**Purpose**: Enhances questions with additional context, passages, diagrams, or reference material.

**Relationships**:
- Many supporting texts belong to one question

---

### 1.7 User Exam Attempt Table
Records each time a user takes an exam.

```sql
CREATE TABLE user_exam_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  question_count INTEGER NOT NULL,   -- Number of questions in this attempt
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  duration_seconds INTEGER,          -- Calculated from started_at to completed_at
  total_score DECIMAL(5,2),
  percentage_score DECIMAL(5,2),
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_exam_attempts_user_id ON user_exam_attempts(user_id);
CREATE INDEX idx_user_exam_attempts_exam_id ON user_exam_attempts(exam_id);
CREATE INDEX idx_user_exam_attempts_course_id ON user_exam_attempts(course_id);
CREATE INDEX idx_user_exam_attempts_status ON user_exam_attempts(status);
CREATE INDEX idx_user_exam_attempts_completed ON user_exam_attempts(completed_at);
```

**Purpose**: Tracks individual exam sessions including timing, score, and completion status.

**Relationships**:
- Many attempts belong to one user
- Many attempts belong to one exam
- Many attempts belong to one course
- One attempt has many user responses

---

### 1.8 User Response Table
Records individual answers submitted by users.

```sql
CREATE TABLE user_responses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  attempt_id UUID REFERENCES user_exam_attempts(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  answer_choice_id UUID REFERENCES answer_choices(id) ON DELETE SET NULL,
  selected_choice_key TEXT,          -- 'A', 'B', 'C', etc., or NULL if unanswered
  is_correct BOOLEAN,
  points_earned DECIMAL(5,2) DEFAULT 0,
  time_spent_seconds INTEGER,        -- Time spent on this question
  answered_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_responses_attempt_id ON user_responses(attempt_id);
CREATE INDEX idx_user_responses_question_id ON user_responses(question_id);
CREATE INDEX idx_user_responses_correct ON user_responses(is_correct);
```

**Purpose**: Captures user answers for scoring and performance analysis.

**Relationships**:
- Many responses belong to one attempt
- Many responses reference one question
- Many responses reference one answer choice

---

## 2. Entity Relationships Diagram (ERD)

```
users (1) ────── (M) user_exam_attempts (M) ────── (1) exams (M) ────── (1) courses
                        │
                        │ (1)
                        │
                        ▼ (M)
                   user_responses (M) ────── (1) questions (M) ────── (1) exams
                        │                           │
                        │                           │ (1)
                        │                           ▼ (M)
                        │                    answer_choices
                        │                           
                        │ (M)                       │ (1)
                        └────────────(1)────────────┘
                        
                                         questions (1) ────── (M) supporting_texts
```

---

## 3. Data Flow Through Test-Taking Sequence

### 3.1 Home Screen (Course Selection)

**Screen Purpose**: User selects a course to prepare for.

**Data Operations**: **READ ONLY**

**Queries Executed**:
```sql
-- Fetch all active courses for display
SELECT id, course_key, title, icon_key
FROM courses
WHERE is_active = TRUE
ORDER BY title;
```

**Data Displayed**:
- Course list with titles and icons
- User selects a course (stored in app state, not database yet)

**Screen State**: No database writes occur at this stage.

---

### 3.2 Quiz Configuration Screen (Question Count Selection)

**Screen Purpose**: User configures exam parameters (number of questions).

**Data Operations**: **READ ONLY**

**Queries Executed**:
```sql
-- Fetch exam metadata for selected course
SELECT e.id, e.title, e.total_available_questions, e.time_limit_minutes
FROM exams e
JOIN courses c ON e.course_id = c.id
WHERE c.course_key = $selected_course_key
  AND e.is_active = TRUE
LIMIT 1;

-- Verify sufficient questions are available
SELECT COUNT(*) as available_count
FROM questions
WHERE exam_id = $exam_id
  AND is_active = TRUE;
```

**Data Displayed**:
- Course name
- Available question counts (5, 10, 15, 20)
- Time estimates

**Screen State**: When user clicks "Iniciar", configuration is prepared for exam initialization.

---

### 3.3 Exam Screen (Question Presentation and Response)

**Screen Purpose**: Display questions, collect answers, track progress.

**Data Operations**: **READ during loading, WRITE on completion**

#### 3.3.1 Exam Initialization (READ)

**Queries Executed**:
```sql
-- Create exam attempt record
INSERT INTO user_exam_attempts (
  user_id, 
  exam_id, 
  course_id, 
  question_count, 
  started_at, 
  status
)
VALUES ($user_id, $exam_id, $course_id, $question_count, NOW(), 'in_progress')
RETURNING id;

-- Fetch random questions for the exam
SELECT 
  q.id,
  q.enunciation,
  q.difficulty_level,
  q.points
FROM questions q
WHERE q.exam_id = $exam_id
  AND q.is_active = TRUE
ORDER BY RANDOM()
LIMIT $question_count;

-- For each question, fetch answer choices
SELECT 
  ac.id,
  ac.choice_key,
  ac.choice_text,
  ac.is_correct,
  ac.choice_order
FROM answer_choices ac
WHERE ac.question_id = ANY($question_ids)
ORDER BY ac.question_id, ac.choice_order;

-- For each question, fetch supporting texts (if any)
SELECT 
  st.question_id,
  st.content_type,
  st.content,
  st.display_order
FROM supporting_texts st
WHERE st.question_id = ANY($question_ids)
ORDER BY st.question_id, st.display_order;
```

**Data Displayed**:
- Question enunciation
- Answer choices (A, B, C, D, E)
- Supporting text/images (if applicable)
- Progress indicator (e.g., Question 3 of 10)
- Navigation controls

#### 3.3.2 During Exam (LOCAL STATE)

**Screen State**: User responses stored locally in Flutter app state (`Map<int, String> selectedAnswers`).

**No Database Writes** until exam completion to optimize performance and allow offline capability.

#### 3.3.3 Exam Completion (WRITE)

**Triggered When**: User clicks "Finalizar" button.

**Queries Executed**:
```sql
-- Insert all user responses in batch
INSERT INTO user_responses (
  attempt_id,
  question_id,
  answer_choice_id,
  selected_choice_key,
  is_correct,
  points_earned,
  answered_at
)
VALUES
  ($attempt_id, $question_id_1, $answer_choice_id_1, 'A', TRUE, 1.0, NOW()),
  ($attempt_id, $question_id_2, $answer_choice_id_2, 'C', FALSE, 0.0, NOW()),
  ...;

-- Calculate score
SELECT 
  COUNT(*) as total_questions,
  SUM(CASE WHEN ur.is_correct THEN 1 ELSE 0 END) as correct_answers,
  SUM(ur.points_earned) as total_score
FROM user_responses ur
WHERE ur.attempt_id = $attempt_id;

-- Update exam attempt with results
UPDATE user_exam_attempts
SET 
  completed_at = NOW(),
  duration_seconds = EXTRACT(EPOCH FROM (NOW() - started_at)),
  total_score = $total_score,
  percentage_score = ($correct_answers::DECIMAL / $total_questions) * 100,
  status = 'completed'
WHERE id = $attempt_id;
```

---

### 3.4 Return to Home Screen (Completion Flow)

**Screen Purpose**: Display completion message and return to course selection.

**Data Operations**: **READ (for history)**

**Queries Executed** (if navigating to history view):
```sql
-- Fetch user's exam history for a course
SELECT 
  uea.id,
  uea.completed_at,
  uea.duration_seconds,
  uea.question_count,
  uea.percentage_score,
  COUNT(ur.id) as answered_count,
  SUM(CASE WHEN ur.is_correct THEN 1 ELSE 0 END) as correct_count
FROM user_exam_attempts uea
LEFT JOIN user_responses ur ON ur.attempt_id = uea.id
WHERE uea.user_id = $user_id
  AND uea.course_id = $course_id
  AND uea.status = 'completed'
GROUP BY uea.id
ORDER BY uea.completed_at DESC;
```

---

## 4. Entity Lifecycle Mapping

### 4.1 READ Operations (Data Retrieval)

| Screen | Entity | Purpose |
|--------|--------|---------|
| **Home Screen** | `courses` | Load available courses for selection |
| **Quiz Config** | `exams` | Fetch exam metadata (title, question count) |
| **Quiz Config** | `questions` | Verify available question count |
| **Exam Screen** | `questions` | Load question enunciations |
| **Exam Screen** | `answer_choices` | Load answer alternatives |
| **Exam Screen** | `supporting_texts` | Load supplementary materials (if any) |
| **History View** | `user_exam_attempts` | Display past exam results |
| **History View** | `user_responses` | Show detailed answer history |

### 4.2 WRITE Operations (Data Modification)

| Screen | Entity | Operation | Trigger |
|--------|--------|-----------|---------|
| **Exam Screen** (init) | `user_exam_attempts` | INSERT | When "Iniciar" clicked from Quiz Config |
| **Exam Screen** (completion) | `user_responses` | INSERT (batch) | When "Finalizar" clicked |
| **Exam Screen** (completion) | `user_exam_attempts` | UPDATE | After responses inserted |

---

## 5. Key Design Considerations

### 5.1 Performance Optimizations

1. **Batch Operations**: User responses inserted in single transaction on completion
2. **Indexing**: Foreign keys and frequently queried columns indexed
3. **Random Sampling**: `ORDER BY RANDOM()` used for question selection (consider pre-generated exam versions for scale)

### 5.2 Data Integrity

1. **Referential Integrity**: Foreign keys with appropriate CASCADE/SET NULL
2. **Unique Constraints**: Prevent duplicate choice keys per question
3. **Check Constraints**: Validate status values, difficulty levels, content types

### 5.3 Scalability

1. **Soft Deletes**: `is_active` flags instead of hard deletes
2. **Timestamps**: Track creation and updates for audit trails
3. **Partitioning Ready**: `user_exam_attempts` can be partitioned by date for growth

---

## 6. Migration Path

Since the application currently uses mock data, implement the schema in this order:

1. **Phase 1**: Create core tables (`users`, `courses`, `exams`, `questions`, `answer_choices`)
2. **Phase 2**: Add supporting tables (`supporting_texts`)
3. **Phase 3**: Add tracking tables (`user_exam_attempts`, `user_responses`)
4. **Phase 4**: Migrate Flutter repositories from mock data to Supabase queries
5. **Phase 5**: Add RLS (Row-Level Security) policies for multi-tenant data isolation

---

## 7. Current Implementation Status

**Status**: ❌ Schema **NOT IMPLEMENTED**

The application currently uses:
- **Mock data** in `lib/services/repositorie/question_repository.dart`
- **Hardcoded courses** in `lib/views/home.screen.dart`
- **Hardcoded questions** in `lib/views/exam_screen.dart`

**Next Steps**:
1. Create SQL migration scripts in `supabase/migrations/`
2. Implement repository pattern for database access
3. Replace mock data with Supabase queries
4. Add error handling and offline support
