# Supabase PostgreSQL Schema Documentation

## Overview
This document defines the database schema for the Smart Quiz application, documenting entity relationships and data flow through the test-taking sequence across three main screens: **Home Screen**, **Quiz Configuration Screen**, and **Exam Screen**.

---

## 1. Database Schema

### 1.1 User Table
Stores authenticated user information linked to Supabase Auth.

```sql
CREATE TABLE public.user (
  id uuid NOT NULL,
  first_name text NOT NULL,
  surename text NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  email text NOT NULL,
  CONSTRAINT user_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
```

**Purpose**: Manages user authentication and identity across the application, directly linked to Supabase Auth users.

**Columns**:
- `id`: UUID primary key, references auth.users(id)
- `first_name`: User's first name
- `surename`: User's surname
- `created_at`: Creation timestamp (without time zone)
- `updated_at`: Last update timestamp (without time zone)
- `email`: User's email address

**Constraints**:
- Primary key on `id`
- Foreign key to `auth.users(id)`

---

### 1.2 Course Table
Represents academic courses available for quiz preparation.

```sql
CREATE TABLE public.course (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  name text NOT NULL UNIQUE,
  title text,
  course_key text UNIQUE,
  description text,
  icon text NOT NULL,
  icon_key text,
  is_active boolean NOT NULL DEFAULT TRUE,
  CONSTRAINT course_pkey PRIMARY KEY (id)
);
```

**Purpose**: Defines the courses users can select for exam preparation.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `updated_at`: Last update timestamp (without time zone)
- `name`: Legacy course name kept for backward compatibility (unique)
- `title`: Display name shown in the app
- `course_key`: Normalized identifier used across the app (unique)
- `description`: Short course summary for UI copy
- `icon`: Legacy icon identifier stored previously
- `icon_key`: Material icon identifier used by the Flutter UI
- `is_active`: Visibility flag for course selection

**Constraints**:
- Primary key on `id`
- Unique constraint on `name`

**Relationships**:
- One course has many questions
- One course has many exams

---

### 1.3 Question Table
Stores individual exam questions.

```sql
CREATE TABLE public.question (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  number smallint NOT NULL,
  statement text NOT NULL,
  idcourse uuid NOT NULL,
  CONSTRAINT question_pkey PRIMARY KEY (id),
  CONSTRAINT question_idcourse_fkey FOREIGN KEY (idcourse) REFERENCES public.course(id)
);
```

**Purpose**: Contains question text and metadata for each course.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `update_at`: Last update timestamp (without time zone)
- `number`: Question number (smallint)
- `statement`: Question text/prompt
- `idcourse`: Foreign key to course

**Constraints**:
- Primary key on `id`
- Foreign key `idcourse` references `course(id)`

**Relationships**:
- Many questions belong to one course
- One question has many answer choices
- One question can have many supporting texts (via junction table)
- One question can appear in many exams (via junction table)

---

### 1.4 Answer Choice Table
Stores possible answers for multiple-choice questions.

```sql
CREATE TABLE public.answerchoice (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  upload_at timestamp without time zone NOT NULL,
  letter text NOT NULL,
  content text NOT NULL,
  correctanswer boolean NOT NULL,
  idquestion uuid NOT NULL,
  CONSTRAINT answerchoice_pkey PRIMARY KEY (id),
  CONSTRAINT answerchoices_idquestion_fkey FOREIGN KEY (idquestion) REFERENCES public.question(id)
);
```

**Purpose**: Provides multiple-choice alternatives for each question.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `upload_at`: Upload timestamp (without time zone)
- `letter`: Choice letter identifier (A, B, C, D, E)
- `content`: Answer choice text
- `correctanswer`: Boolean flag indicating if this is the correct answer
- `idquestion`: Foreign key to question

**Constraints**:
- Primary key on `id`
- Foreign key `idquestion` references `question(id)`

**Relationships**:
- Many answer choices belong to one question

---

### 1.5 Supporting Text Table
Stores supplementary materials like passages, images, or context for questions.

```sql
CREATE TABLE public.supportingtext (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  content text NOT NULL,
  CONSTRAINT supportingtext_pkey PRIMARY KEY (id)
);
```

**Purpose**: Contains supplementary content that can be associated with questions.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `update_at`: Last update timestamp (without time zone)
- `content`: Supporting text content

**Constraints**:
- Primary key on `id`

**Relationships**:
- Many supporting texts can be linked to many questions (via junction table)

---

### 1.6 Question Supporting Text Junction Table
Links questions to their supporting texts.

```sql
CREATE TABLE public.questionsupportingtext (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  idquestion uuid NOT NULL DEFAULT gen_random_uuid(),
  idsupportingtext uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT questionsupportingtext_pkey PRIMARY KEY (id),
  CONSTRAINT questionsupportingtext_idsupportingtext_fkey FOREIGN KEY (idsupportingtext) REFERENCES public.supportingtext(id),
  CONSTRAINT questionsupportingtext_idquestion_fkey FOREIGN KEY (idquestion) REFERENCES public.question(id)
);
```

**Purpose**: Many-to-many relationship between questions and supporting texts.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `update_at`: Last update timestamp (without time zone)
- `idquestion`: Foreign key to question
- `idsupportingtext`: Foreign key to supporting text

**Constraints**:
- Primary key on `id`
- Foreign key `idquestion` references `question(id)`
- Foreign key `idsupportingtext` references `supportingtext(id)`

**Relationships**:
- Links questions to supporting texts in a many-to-many relationship

---

### 1.7 Exam Table
Records exam sessions taken by users.

```sql
CREATE TABLE public.exam (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  title text,
  description text,
  total_available_questions integer DEFAULT 0,
  question_count integer,
  time_limit_minutes integer,
  passing_score_percentage decimal(5,2) DEFAULT 70.0,
  is_active boolean DEFAULT TRUE,
  date_start timestamp without time zone NOT NULL DEFAULT NOW(),
  date_end timestamp without time zone NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
  is_completed boolean NOT NULL DEFAULT false,
  id_user uuid,
  id_course uuid NOT NULL,
  total_score decimal(5,2),
  percentage_score decimal(5,2),
  CONSTRAINT exam_pkey PRIMARY KEY (id),
  CONSTRAINT exam_id_course_fkey FOREIGN KEY (id_course) REFERENCES public.course(id),
  CONSTRAINT exam_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.user(id)
);
```

**Purpose**: Stores the canonical quiz definition exposed to learners, including metadata consumed by the Flutter app.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at` / `updated_at`: Lifecycle timestamps maintained automatically
- `title`: Optional display name for the quiz
- `description`: Optional blurb describing the quiz
- `total_available_questions`: Cached count of active questions for the linked course
- `question_count`: Legacy aggregate retained for backwards compatibility
- `time_limit_minutes`: Optional time limit for attempts (minutes)
- `passing_score_percentage`: Passing threshold (defaults to 70%)
- `is_active`: Visibility flag used by the app when listing available quizzes
- `date_start` / `date_end`: Legacy scheduling window kept for compatibility
- `is_completed`: Legacy completion marker
- `id_user`: Optional owner; nullable in the current architecture
- `id_course`: Foreign key to the associated course
- `total_score`, `percentage_score`: Legacy aggregate metrics retained for reporting

**Constraints**:
- Primary key on `id`
- Foreign key `id_user` references `user(id)`
- Foreign key `id_course` references `course(id)`

**Relationships**:
- Many exams belong to one course
- Attempts (`user_exam_attempts`) reference exams by `exam_id`
- Questions are associated via the course relationship or the legacy `examquestion` bridge

---

### 1.8 Exam Question Junction Table
Links exams to their questions.

```sql
CREATE TABLE public.examquestion (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp without time zone NOT NULL,
  update_at timestamp without time zone NOT NULL,
  id_exam uuid NOT NULL DEFAULT gen_random_uuid(),
  id_question uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT examquestion_pkey PRIMARY KEY (id),
  CONSTRAINT examquestion_id_exam_fkey FOREIGN KEY (id_exam) REFERENCES public.exam(id),
  CONSTRAINT examquestion_id_question_fkey FOREIGN KEY (id_question) REFERENCES public.question(id)
);
```

**Purpose**: Many-to-many relationship between exams and questions.

**Columns**:
- `id`: UUID primary key with default random generation
- `created_at`: Creation timestamp (without time zone)
- `update_at`: Last update timestamp (without time zone)
- `id_exam`: Foreign key to exam
- `id_question`: Foreign key to question

**Constraints**:
- Primary key on `id`
- Foreign key `id_exam` references `exam(id)`
- Foreign key `id_question` references `question(id)`

**Relationships**:
- Links exams to questions in a many-to-many relationship

---

## 2. Entity Relationships Diagram (ERD)

```
auth.users (1) ────── (1) user (1) ────── (M) exam (M) ────── (1) course
                                             │                    │
                                             │ (M)                │ (1)
                                             │                    │
                                             ▼ (1)                ▼ (M)
                                        examquestion          question (M) ────── (1) course
                                             │                    │
                                             │ (M)                │ (1)
                                             │                    │
                                             ▼ (1)                ▼ (M)
                                         question            answerchoice
                                             │
                                             │ (1)
                                             │
                                             ▼ (M)
                                   questionsupportingtext (M) ────── (1) supportingtext
```

---

## 3. Data Flow Through Test-Taking Sequence

### 3.1 Home Screen (Course Selection)

**Screen Purpose**: User selects a course to prepare for.

**Data Operations**: **READ ONLY**

**Queries Executed**:
```sql
-- Fetch all courses for display
SELECT id, name, icon
FROM course
ORDER BY name;
```

**Data Displayed**:
- Course list with names and icons
- User selects a course (stored in app state, not database yet)

**Screen State**: No database writes occur at this stage.

---

### 3.2 Quiz Configuration Screen (Question Count Selection)

**Screen Purpose**: User configures exam parameters (number of questions).

**Data Operations**: **READ ONLY**

**Queries Executed**:
```sql
-- Verify available questions for selected course
SELECT COUNT(*) as available_count
FROM question
WHERE idcourse = $selected_course_id;
```

**Data Displayed**:
- Course name
- Available question counts (5, 10, 15, 20)
- Time estimates

**Screen State**: When user clicks "Iniciar", configuration is prepared for exam initialization.

---

### 3.3 Exam Screen (Question Presentation and Response)

**Screen Purpose**: Display questions, collect answers, track progress.

**Data Operations**: **READ during loading, WRITE on start and completion**

#### 3.3.1 Exam Initialization (WRITE)

**Queries Executed**:
```sql
-- Create exam record
INSERT INTO exam (
  created_at,
  update_at,
  date_start,
  date_end,
  is_completed,
  id_user,
  id_course
)
VALUES (NOW(), NOW(), NOW(), NOW(), false, $user_id, $course_id)
RETURNING id;

-- Fetch random questions for the exam
SELECT 
  q.id,
  q.number,
  q.statement,
  q.idcourse
FROM question q
WHERE q.idcourse = $course_id
ORDER BY RANDOM()
LIMIT $question_count;

-- Link selected questions to exam
INSERT INTO examquestion (
  created_at,
  update_at,
  id_exam,
  id_question
)
VALUES 
  (NOW(), NOW(), $exam_id, $question_id_1),
  (NOW(), NOW(), $exam_id, $question_id_2),
  ...;

-- For each question, fetch answer choices
SELECT 
  ac.id,
  ac.letter,
  ac.content,
  ac.correctanswer,
  ac.idquestion
FROM answerchoice ac
WHERE ac.idquestion = ANY($question_ids)
ORDER BY ac.idquestion, ac.letter;

-- For each question, fetch supporting texts (if any)
SELECT 
  qst.idquestion,
  st.id,
  st.content
FROM questionsupportingtext qst
JOIN supportingtext st ON qst.idsupportingtext = st.id
WHERE qst.idquestion = ANY($question_ids);
```

**Data Displayed**:
- Question statement
- Answer choices (A, B, C, D, E)
- Supporting text (if applicable)
- Progress indicator (e.g., Question 3 of 10)
- Navigation controls

#### 3.3.2 During Exam (LOCAL STATE)

**Screen State**: User responses stored locally in Flutter app state (`Map<int, String> selectedAnswers`).

**No Database Writes** until exam completion to optimize performance and allow offline capability.

#### 3.3.3 Exam Completion (WRITE)

**Triggered When**: User clicks "Finalizar" button.

**Queries Executed**:
```sql
-- Update exam as completed
UPDATE exam
SET 
  update_at = NOW(),
  date_end = NOW(),
  is_completed = true
WHERE id = $exam_id;
```

**Note**: The current schema does not include a table for storing individual user responses to questions. User answers and scoring are calculated in the application layer based on locally stored responses compared against the `correctanswer` field in the `answerchoice` table.

---

### 3.4 Return to Home Screen (Completion Flow)

**Screen Purpose**: Display completion message and return to course selection.

**Data Operations**: **READ (for history)**

**Queries Executed** (if navigating to history view):
```sql
-- Fetch user's exam history for a course
SELECT 
  e.id,
  e.date_start,
  e.date_end,
  e.is_completed,
  c.name as course_name,
  COUNT(eq.id_question) as question_count
FROM exam e
JOIN course c ON e.id_course = c.id
LEFT JOIN examquestion eq ON eq.id_exam = e.id
WHERE e.id_user = $user_id
  AND e.id_course = $course_id
  AND e.is_completed = true
GROUP BY e.id, c.name
ORDER BY e.date_end DESC;
```

---

## 4. Entity Lifecycle Mapping

### 4.1 READ Operations (Data Retrieval)

| Screen | Entity | Purpose |
|--------|--------|---------|
| **Home Screen** | `course` | Load available courses for selection |
| **Quiz Config** | `question` | Verify available question count for course |
| **Exam Screen** | `question` | Load question statements |
| **Exam Screen** | `answerchoice` | Load answer alternatives |
| **Exam Screen** | `supportingtext` (via junction) | Load supplementary materials (if any) |
| **History View** | `exam` | Display past exam records |
| **History View** | `examquestion` | Show questions included in past exams |

### 4.2 WRITE Operations (Data Modification)

| Screen | Entity | Operation | Trigger |
|--------|--------|-----------|---------|
| **Exam Screen** (init) | `exam` | INSERT | When "Iniciar" clicked from Quiz Config |
| **Exam Screen** (init) | `examquestion` | INSERT (batch) | After exam created, link selected questions |
| **Exam Screen** (completion) | `exam` | UPDATE | When "Finalizar" clicked |

---

## 5. Key Design Considerations

### 5.1 Schema Characteristics

1. **UUID Keys**: All tables use UUID primary keys with `gen_random_uuid()` defaults
2. **Timestamp Fields**: All tables track `created_at` and update timestamps (`update_at` or `upload_at`)
3. **Timestamps Without Time Zone**: All timestamp columns are defined without time zone
4. **Junction Tables**: Many-to-many relationships implemented via `examquestion` and `questionsupportingtext`
5. **No Indexes**: The schema does not define any indexes beyond primary keys and foreign key constraints

### 5.2 Data Integrity

1. **Referential Integrity**: Foreign keys enforce relationships between tables
2. **Unique Constraints**: Course names must be unique
3. **Auth Integration**: User table links to Supabase `auth.users` table

### 5.3 Missing Features (Not in Current Schema)

The following elements mentioned in application requirements are **NOT** present in the actual SQL schema:

1. **User Response Tracking**: No table to store individual user answers to questions
2. **Scoring Fields**: No fields for points, scores, or percentages in exam table
3. **Question Metadata**: No difficulty level, question order, points, or is_active flags
4. **Exam Metadata**: No title, description, time limits, passing scores, or total question counts
5. **Answer Choice Ordering**: No explicit choice_order field
6. **Status Fields**: No status tracking (in_progress, completed, abandoned) beyond boolean `is_completed`
7. **Performance Fields**: No time tracking fields (duration_seconds, time_spent_seconds, answered_at)
8. **Soft Deletes**: No is_active flags for soft deletion
9. **Indexes**: No performance indexes defined on foreign keys or commonly queried columns
10. **Unique Constraints**: No unique constraint on answer choice letters per question

---

## 6. Migration Path

The current schema represents the baseline implementation. Future enhancements may include:

1. **Phase 1**: Add user response tracking table
2. **Phase 2**: Add scoring and performance tracking fields
3. **Phase 3**: Add question and exam metadata (difficulty, ordering, time limits)
4. **Phase 4**: Add status tracking and soft delete capabilities
5. **Phase 5**: Add performance indexes on foreign keys and commonly queried fields
6. **Phase 6**: Add RLS (Row-Level Security) policies for data isolation

---

## 7. Current Implementation Status

**Status**: ✅ Schema **PARTIALLY IMPLEMENTED**

The database schema exists in Supabase with the following tables:
- `user` (linked to auth.users)
- `course`
- `question`
- `answerchoice`
- `supportingtext`
- `questionsupportingtext`
- `exam`
- `examquestion`

The application currently uses:
- **Mock data** in `lib/services/repositorie/question_repository.dart`
- **Hardcoded courses** in `lib/views/home.screen.dart`

**Next Steps**:
1. Implement repository pattern for database access
2. Replace mock data with Supabase queries
3. Add error handling and offline support
4. Consider adding user response tracking table for detailed analytics
