# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart Quiz - A Flutter quiz application for academic exam preparation (ENADE, OAB, etc.) built as an **extension project** for **Centro Universitario UniCV**. Uses Supabase for backend services (auth, database). The platform supports three user roles: **student**, **teacher**, and **admin**, each with dedicated modules and interfaces.

**Objective:** Provide a digital study tool where teachers create question banks, students take quizzes with immediate feedback and gamification, and admins oversee the platform.

**Target audience:** Exclusive use by UniCV students, teachers and administrators.

| Role | Description | Permissions |
|------|-------------|-------------|
| **student** | University student | Take quizzes, view rankings, history, profile |
| **teacher** | University teacher | All student permissions + create questions, build exams, dashboard |
| **admin** | System administrator | All teacher permissions + full management |

**Supported courses:** Psicologia, Direito, Medicina, Engenharia, Administracao (expandable).

## Commands

```bash
# Setup
flutter pub get

# Development
flutter run                              # Run on connected device/emulator
flutter run -d chrome                    # Run on Chrome (web)
flutter run --dart-define-from-file=.vscode/dev.json  # Run with local env vars

# Build
flutter build web --release              # Build for web (production uses --dart-define for secrets)
flutter build apk                        # Build Android APK
flutter build ios                        # Build iOS

# Quality
flutter analyze                          # Run static analysis
flutter test                             # Run all tests
flutter test test/integration_test.dart  # Run specific test file
flutter test --coverage                  # Run tests with coverage report

# Mock generation (if needed)
dart run build_runner build
```

## Architecture

**Pattern:** MVVM (Model-View-ViewModel) with Provider + ChangeNotifier for state management.

```
┌──────────────────────────────────────────────────────────┐
│                     PRESENTATION                         │
│  Views (Screens) ◄── ViewModels (ChangeNotifier) ◄── Components (Widgets) │
├──────────────────────────────────────────────────────────┤
│                  BUSINESS LOGIC                          │
│  Services (AuthService) │ Repositories (Interfaces) │ Calculator (Gamification) │
├──────────────────────────────────────────────────────────┤
│                     DATA LAYER                           │
│  Models (Dart POJOs) │ Supabase Repositories │ dotenv/.env (Config) │
├──────────────────────────────────────────────────────────┤
│                     BACKEND                              │
│  Supabase (PostgreSQL): Auth │ Database │ RLS │ Functions/Views │
└──────────────────────────────────────────────────────────┘
```

### Stack Tecnologica

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Flutter (Dart) | SDK >=3.1.0 <4.0.0 |
| Backend | Supabase (PostgreSQL + Auth) | Free tier |
| State Management | Provider + ChangeNotifier | ^6.1.5 |
| Font | Google Fonts (Poppins) | ^6.3.2 |
| CI/CD | GitHub Actions | Flutter 3.38.5 |
| Hosting | Vercel | Default domain |

### Directory Structure

```
smart_quiz_mvp/
├── .github/workflows/deploy.yml
├── assets/images/                      # Logo, medals (medal_iniciante.png, etc.)
├── lib/
│   ├── main.dart                       # Entry point, Supabase init, MultiProvider
│   ├── constants/
│   │   ├── app_strings.dart            # Centralized UI strings
│   │   └── supabase_options.dart       # URL & AnonKey (dotenv or --dart-define)
│   ├── models/                         # 14+ data models
│   ├── viewmodels/                     # Student ViewModels + ChangeNotifier
│   │   └── teacher/                    # Teacher-specific ViewModels
│   ├── views/                          # Student screens
│   │   └── teacher/                    # Teacher screens (10 screens)
│   ├── repositories/                   # Interface + Supabase implementations
│   │   └── auth/                       # Auth repository pattern
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── session_manager.dart
│   │   ├── gamification_calculator.dart
│   │   └── repositorie/               # Legacy repositories
│   ├── routes/app_routes.dart
│   ├── widgets/protected_route.dart
│   └── ui/
│       ├── theme/                      # app_color.dart, string_text.dart
│       └── components/                 # ~25 reusable components (default_*)
├── supabase/migrations/                # 18+ SQL migration files
├── test/
├── pubspec.yaml
└── docs/DOCUMENTACAO_COMPLETA.md
```

## Data Models (`lib/models/`)

| Model | File | Key Fields |
|-------|------|------------|
| `UserModel` | `user_model.dart` | id, name, email, role (student/teacher/admin), phone, avatarUrl, bio |
| `Course` | `course.dart` | id, courseKey, title, description, iconKey, isActive |
| `Question` | `question.dart` | id, enunciation, idCourse, difficultyLevel, points, idTeacher, idCategory, idSubject, answerChoices[], supportingTexts[] |
| `AnswerChoice` | `answer_choice.dart` | id, letter (A-E), content, correctAnswer, idQuestion |
| `SupportingText` | `supporting_text.dart` | id, idQuestion, contentType (text/image/code/table), content, displayOrder |
| `Exam` | `exam.dart` | id, idUser, idCourse, idExamTemplate, questionCount, timeLimitMinutes, passingScorePercentage, showCorrectAnswers, allowReview, attemptNumber, score, passed |
| `ExamTemplate` | `exam_template.dart` | id, name, idCourse, idTeacher, questionCount, passingScorePercentage, shuffleQuestions, shuffleChoices, isPublished, maxAttempts |
| `ExamTemplateQuestion` | `exam_template_question.dart` | id, idExamTemplate, idQuestion, questionOrder, pointsOverride |
| `ExamTemplateCategory` | `exam_template_category.dart` | id, idExamTemplate, idCategory, questionCount |
| `GamificationSeason` | `gamification_season.dart` | id, name (e.g. "2026.1"), startsAt, endsAt, isActive |
| `GamificationPoints` | `gamification_points.dart` | id, userId, seasonId, attemptId, basePoints, timeBonus, totalPoints, percentageScore |
| `GamificationLevel` | `gamification_level.dart` | Enum: iniciante(0-100), explorador(101-200), mestreDoConteudo(201-300), lendario(301+) |
| `RankingEntry` | `ranking_entry.dart` | userId, seasonId, userName, avatarUrl, seasonPoints, totalAttempts, rankPosition |
| `TeacherQuestion` | `teacher_question.dart` | Teacher view of questions with aggregated data |
| `TeacherStats` | `teacher_stats.dart` | TeacherQuestionStats, TeacherExamStats, TeacherDashboardStats |

## Repositories (`lib/repositories/`)

All repositories follow **Interface + Supabase Implementation** pattern, allowing mock substitution in tests.

### Authentication Repositories (`lib/repositories/auth/`)

| File | Description |
|------|-------------|
| `auth_repository.dart` | Abstract interface: signUp, signIn, signOut, resetPasswordForEmail, updatePassword |
| `supabase_auth_repository.dart` | Supabase implementation |
| `disabled_auth_repository.dart` | Stub for offline mode |
| `auth_repository_types.dart` | AuthRepositoryException, AuthRepositoryErrorCode |

### Data Repositories

| Interface | Implementation | Responsibility |
|-----------|---------------|----------------|
| `CourseRepository` | `SupabaseCourseRepository` | Course CRUD, available question count |
| `ExamRepository` | `SupabaseExamRepository` | Create exam, fetch random questions, save responses |
| `ExamAttemptRepository` | `SupabaseExamAttemptRepository` | Create/update attempts, fetch history |
| `QuestionRepository` | `SupabaseQuestionRepository` | Question CRUD (teacher module) |
| `TeacherRepository` | `SupabaseTeacherRepository` | Teacher RPCs: create/edit question, generate exam from template, stats |
| `GamificationRepository` | `SupabaseGamificationRepository` | Points, rankings, seasons, history |

### Dependency Injection

Repositories are registered in `MultiProvider` in `main.dart`. Supabase-dependent repositories are registered as **nullable** (`Repository?`) — when Supabase isn't configured, they return `null` and the UI handles gracefully.

## Services (`lib/services/`)

### AuthService (`auth_service.dart`)

| Method | Description |
|--------|-------------|
| `signUp(email, password, name)` | Create account, return if needs confirmation |
| `signIn(email, password)` | Authenticate and update SessionManager |
| `resetPasswordForEmail(email)` | Send recovery email |
| `updatePassword(newPassword)` | Change authenticated user's password |
| `signOut()` | Clear session and redirect |

### SessionManager (`session_manager.dart`)

- Listens to `onAuthStateChange` (signIn, signOut, tokenRefreshed, passwordRecovery)
- Fetches user role from `user` table after authentication
- Detects JWT expired / 401 / 403 errors and forces signOut
- Redirects to `/login` on session loss, to `/reset_password2` on recovery

### GamificationCalculator (`gamification_calculator.dart`)

Pure utility class for point calculation:

```
Base Points = correct_answers × multiplier
  - Up to 5 questions: 1.0 pt/correct
  - 6-10 questions: 1.25 pt/correct
  - 11+ questions: 1.50 pt/correct

Time Bonus = N questions (extra points)
  Conditions: >=70% correct AND completed in <=80% of normal time (2min/question)

Total = Base + Bonus
```

**"Best Score Only" policy:** Only improvements over previous best score are recorded (delta saved).

**Motivational messages:**
| Condition | Message |
|-----------|---------|
| Didn't improve | "Sua pontuacao anterior foi mantida. Tente superar!" |
| >=90% + bonus | "Incrivel! Performance perfeita!" |
| >=80% + bonus | "Excelente! Voce esta voando!" |
| >=70% | "Bom trabalho! Continue assim!" |
| >=50% | "Bom esforco! Pratique mais para melhorar!" |
| <50% | "Continue tentando! A pratica leva a perfeicao!" |

## ViewModels (`lib/viewmodels/`)

### Student ViewModels

| ViewModel | Screen(s) | Responsibility |
|-----------|-----------|----------------|
| `CourseSelectionViewModel` | HomeScreen | Load course list |
| `QuizConfigViewModel` | QuizConfigScreen | Configure question count, start quiz |
| `ExamViewModel` | ExamScreen | Manage exam state (questions, answers, navigation, finalization) |
| `ExamHistoryViewModel` | ExamHistoryScreen | Load attempt history by course |
| `ExamDetailViewModel` | ExamDetailScreen | Load specific attempt details |
| `ProfileViewModel` | ProfileScreen | Load/edit user data |
| `LoginViewModel` | LoginScreen | Login form state |
| `SignUpViewModel` | SignupScreen | Signup form state |
| `GamificationViewModel` | RankingScreen, ProfileScreen | Rankings, points, levels, seasons |

### Teacher ViewModels (`lib/viewmodels/teacher/`)

| ViewModel | Screen(s) | Responsibility |
|-----------|-----------|----------------|
| `QuestionListViewModel` | TeacherQuestionListScreen | List, filter, manage questions |
| `TeacherDashboardViewModel` | TeacherStatsScreen | Question and exam statistics |
| `ExamTemplateViewModel` | TeacherExamTemplatesScreen | Template CRUD |
| `TeacherExamTemplateViewModel` | Template form | Template creation/edit form state |
| `TeacherGamificationViewModel` | TeacherGamificationScreen | Student rankings per template |

## Screens & Navigation

### Route Map

```dart
// Student routes
'/splash'           → SplashScreen
'/welcome'          → WelcomeScreen
'/signup'           → SignupScreen
'/login'            → LoginScreen
'/reset_password'   → ResetPasswordScreen1
'/reset_password2'  → ResetPasswordScreen2
'/main'             → MainNavigationScreen (protected)
'/profile'          → ProfileScreen (protected)
'/help'             → HelpScreen (protected)
'/about'            → AboutScreen (protected)
'/exam'             → ExamScreen (protected, receives args)
'/quiz/config'      → QuizConfigScreenWrapper (protected, receives course)
'/exam/result'      → ExamResultScreen (protected, receives results)

// Teacher routes
'/teacher'                → TeacherMainScreen (protected)
'/teacher/home'           → TeacherMainScreen (protected)
'/teacher/create-question'→ TeacherScreenCreateQuestion (protected)
'/teacher/questions'      → TeacherQuestionListScreen (protected)
'/teacher/questions/edit' → TeacherEditQuestionScreen (protected, receives questionId)
'/teacher/templates'      → TeacherExamTemplatesScreen (protected)
'/teacher/stats'          → TeacherStatsScreen (protected)
```

### Student Navigation

`MainNavigationScreen` uses `IndexedStack` with 4 tabs via `CustomNavBar`:

| Index | Tab | Screen | Icon |
|-------|-----|--------|------|
| 0 | Inicio | HomeScreen (course selection) | home |
| 1 | Ranking | RankingScreen (3 sub-tabs) | emoji_events |
| 2 | Historico | ExamHistoryScreen | history |
| 3 | Perfil | ProfileScreen | person |

### Teacher Navigation

`TeacherMainScreen` uses `Row` with side menu (280px) + content:

| Index | Menu Item | Screen |
|-------|-----------|--------|
| 0 | Montar Provas | TeacherExamTemplatesScreen |
| 1 | Nova Questao (sub-item) | TeacherScreenCreateQuestion |
| 2 | Perfil | TeacherProfileScreen |
| 3 | Listar Questoes (sub-item) | TeacherQuestionListScreen |
| 4 | Dashboard | TeacherStatsScreen |
| 5 | Gamificacao | TeacherGamificationScreen |
| 6 | Materias (sub-item) | TeacherSubjectListScreen |
| 7 | Categorias (sub-item) | TeacherCategoryListScreen |

The "Criar Questoes" menu is an accordion that expands to reveal: Nova Questao, Listar Questoes, Materias, Categorias.

### Route Protection

`ProtectedRoute` widget checks authentication via `SessionManager`:
- Authenticated → render child screen
- Not authenticated → redirect to login

## Authentication Flows

### Signup Flow
```
SignupScreen → SignUpViewModel.signUp() → AuthService.signUp()
→ SupabaseAuthRepository.signUp()
  ├── Creates user in Supabase Auth
  ├── Upserts "user" table with role='student'
  └── Sends confirmation email
→ Redirects to LoginScreen
```

### Login Flow
```
LoginScreen → LoginViewModel.signIn() → AuthService.signIn()
→ SupabaseAuthRepository.signIn() → JWT session
→ SessionManager.setAuthenticatedUser()
  ├── Fetches role from "user" table
  └── notifyListeners()
→ Redirects: student → /main | teacher/admin → /teacher
```

### Password Recovery Flow
```
Step 1: ResetPasswordScreen1 → AuthService.resetPasswordForEmail(email) → Supabase sends email
Step 2: User clicks link → SessionManager detects passwordRecovery event
→ ResetPasswordScreen2 → AuthService.updatePassword(newPassword)
```

### Expired Session Handling
SessionManager detects: JWT expired, invalid token, HTTP 401/403 → forces signOut → redirects to `/login`

## Gamification System

### Levels

| Level | Label | Points Range | Medal |
|-------|-------|-------------|-------|
| 1 | Iniciante | 0 - 100 pts | `medal_iniciante.png` |
| 2 | Explorador | 101 - 200 pts | `medal_explorador.png` |
| 3 | Mestre do Conteudo | 201 - 300 pts | `medal_mestre.png` |
| 4 | Lendario | 301+ pts | `medal_lendario.png` |

### Point Calculation

| Questions in Exam | Points per Correct |
|-------------------|--------------------|
| 1-5 | 1.00 pt |
| 6-10 | 1.25 pts |
| 11+ | 1.50 pts |

**Time Bonus** = N questions (extra points), if: >=70% correct AND completed in <=80% of normal time (2 min/question).

**"Best Score Only":** Only score improvements are saved (delta: new_score - previous_best).

### Seasons

- Semester-based: 1st semester (Feb-Jul), 2nd semester (Aug-Dec)
- Named as "YYYY.S" (e.g., "2026.1")
- Auto-created by `get_or_create_active_season()`
- Points and rankings are isolated per season

### Rankings

| Scope | Description | SQL View |
|-------|-------------|----------|
| **Global** | All students, all exams | `ranking_global_view` |
| **Per Course** | Students who took exams for a specific course | `ranking_course_view` |
| **Per Exam** | Students who took a specific exam template | `ranking_template_view` |

All use `RANK() OVER (PARTITION BY ... ORDER BY SUM(total_points) DESC)`.

### Visual Feedback

- **ExamResultScreen:** Motivational card, point breakdown (base + time bonus), level progress bar, level-up animation (elasticOut)
- **ProfileScreen:** Medal, level, points, progress bar, season history
- **RankingScreen:** AvatarWithMedal, top 3 with gold/silver/bronze, user position pinned if outside top 50

## UI Components (`lib/ui/components/`)

~25 reusable components with `default_` prefix:

| Component | Description |
|-----------|-------------|
| `default_navbar.dart` | Student bottom navigation bar (4 tabs) |
| `default_navbar_teacher.dart` | Teacher navigation bar |
| `default_button_back/forward/arrow_back.dart` | Navigation buttons |
| `default_button_orange.dart` | Primary action button |
| `default_input.dart` | Standard text field |
| `default_password_input_47.dart` | Password field with visibility toggle |
| `default_input_select.dart` | Select/dropdown |
| `default_radio_group.dart` | Radio button group |
| `default_radio_question.dart` | Radio button for exam questions |
| `default_chekbox.dart` | Standard checkbox |
| `default_accordion.dart` | Accordion/collapsible |
| `default_scoreCard.dart` | Score card |
| `default_subject_card.dart` | Course/subject card |
| `default_user_data_card.dart` | User data card with avatar and medal |
| `default_user_profile_card.dart` | User profile card |
| `default_create_question.dart` | Question creation form |
| `default_create_question-statement.dart` | Statement editor |
| `default_exam_history_accordion.dart` | Exam history accordion |
| `default_question_navigation.dart` | Question navigation (progress indicator) |
| `default_feedback_dialog.dart` | Feedback dialog (success/error) |
| `default_inline_message.dart` | Inline message |
| `result_question_tile.dart` | Question tile in results (correct/incorrect) |
| `avatar_with_medal.dart` | Circular avatar with level medal overlay |

**Theme:**
- `lib/ui/theme/app_color.dart` — Color palette (institutional green)
- `lib/ui/theme/string_text.dart` — Text styles
- Material Design 3 with Poppins font

## Database Schema (Supabase)

### Entity-Relationship Diagram

```
auth.users (Supabase Auth)
      │ (same UUID)
      ▼
 ┌─────────┐
 │  "user"  │◄──────────────────────────────────────────┐
 └───┬──┬───┘                                           │
     │  │  ┌──────────┐     ┌───────────────────┐       │
     │  └──│  course   │◄────│ question_category │       │
     │     └──┬──┬──┬──┘     │ FK: id_subject    │       │
     │        │  │  │        └───────┬───────────┘       │
     │        │  │  ▼                │                   │
     │        │  │ ┌─────────┐      │                   │
     │        │  │ │ subject  │◄─────┘                   │
     │        │  │ └─────────┘                          │
     │        │  ▼                                      │
     │        │ ┌──────────────┐                        │
     │        │ │   question    │                       │
     │        │ │ FK: id_teacher├───────────────────────┘
     │        │ │ FK: id_categ. │
     │        │ └──┬────────┬──┘
     │        │    ▼        ▼
     │        │ answerchoice  supportingtext
     │        ▼
     │  ┌──────────────┐     exam_template_question
     │  │exam_template  │────exam_template_category
     │  └──────┬───────┘
     │         │
     │  ┌──────┴───────┐
     ├──│    exam       │
     │  └──────┬───────┘
     │         ├── examquestion ──── question
     │         ▼
     │  ┌──────────────────────┐
     ├──│ user_exam_attempts    │
     │  └──────────┬───────────┘
     │             ├── user_responses
     │             └── user_gamification_points
     │                          │
     │                 gamification_season
```

### Tables

#### `public."user"`
| Column | Type | Default | Notes |
|--------|------|---------|-------|
| id | uuid | gen_random_uuid() | PK, same as Supabase Auth UUID |
| email | text | | UNIQUE |
| first_name | text | | |
| surename | text | | Legacy typo (surname) |
| role | text | 'student' | CHECK: student/teacher/admin |
| phone, avatar_url, bio | text | NULL | |
| created_at, updated_at | timestamp | NOW() | |

**Indexes:** `idx_user_email`, `idx_user_role`

#### `public.course`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | UNIQUE, legacy |
| course_key | text | UNIQUE slug (e.g. 'psicologia') |
| title | text | Modern display name |
| icon_key | text | Modern icon |
| description | text | |
| is_active | boolean | Default TRUE |

**Seed data:** Psicologia, Direito, Medicina, Engenharia, Administracao

#### `public.subject`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | |
| id_course | uuid | FK → course ON DELETE CASCADE |
| is_active | boolean | Default true |

#### `public.question_category`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | UNIQUE(name, id_course) |
| id_course | uuid | FK → course ON DELETE CASCADE |
| id_subject | uuid | FK → subject ON DELETE SET NULL |
| is_active | boolean | Default true |

#### `public.question`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| enunciation | text | Question text |
| id_course | uuid | FK → course |
| difficulty_level | text | CHECK: easy/medium/hard |
| points | decimal(5,2) | Default 1.0 |
| is_active | boolean | Default TRUE |
| id_teacher | uuid | FK → "user" ON DELETE SET NULL |
| id_category | uuid | FK → question_category ON DELETE SET NULL |
| id_subject | uuid | FK → subject ON DELETE SET NULL |
| question_order | integer | |
| number | integer | Sequential per course |

**Indexes:** id_course, is_active, difficulty, teacher, category, subject

#### `public.answerchoice`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| letter | text | A, B, C, D, E |
| content | text | |
| correctanswer | boolean | |
| idquestion | uuid | FK → question (legacy naming, no underscore) |

**Constraints:** UNIQUE (idquestion, letter)

#### `public.supportingtext`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| id_question | uuid | FK → question ON DELETE CASCADE |
| content_type | text | CHECK: text/image/code/table |
| content | text | |
| display_order | integer | Default 1 |

#### `public.exam`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| id_user | uuid | FK → "user" |
| id_course | uuid | FK → course |
| id_exam_template | uuid | FK → exam_template ON DELETE SET NULL |
| question_count, time_limit_minutes | integer | |
| passing_score_percentage | decimal(5,2) | Default 70.0 |
| show_correct_answers, allow_review | boolean | Default true |
| attempt_number | integer | Default 1 |
| total_questions, correct_answers | integer | Result fields |
| score | decimal(5,2) | |
| passed | boolean | |
| is_completed | boolean | Default false |

#### `public.examquestion`
N:N between exam and question. UNIQUE (id_exam, id_question).

#### `public.user_exam_attempts`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| user_id | uuid | FK → "user" ON DELETE CASCADE |
| exam_id | uuid | FK → exam ON DELETE CASCADE |
| course_id | uuid | FK → course ON DELETE CASCADE |
| question_count | integer | |
| started_at | timestamp | Default NOW() |
| completed_at | timestamp | |
| duration_seconds | integer | |
| total_score | numeric(6,2) | |
| percentage_score | numeric(5,2) | |
| status | text | 'in_progress' or 'completed' |

#### `public.user_responses`
Originally `userresponse`, renamed in migration 006.
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| exam_id | uuid | FK → exam ON DELETE CASCADE |
| question_id | uuid | FK → question ON DELETE CASCADE |
| answer_choice_id | uuid | FK → answerchoice ON DELETE SET NULL |
| selected_choice_key | text | Selected letter |
| is_correct | boolean | |
| points_earned | decimal(5,2) | Default 0 |
| time_spent_seconds | integer | |
| attempt_id | uuid | FK → user_exam_attempts ON DELETE CASCADE |

**Constraint:** UNIQUE (attempt_id, question_id)

#### `public.exam_template`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | |
| id_course | uuid | FK → course ON DELETE CASCADE |
| id_teacher | uuid | FK → "user" ON DELETE CASCADE |
| time_limit_minutes | integer | NULL = no limit |
| question_count | integer | Default 10 |
| passing_score_percentage | decimal(5,2) | Default 60.0 |
| shuffle_questions, shuffle_choices | boolean | Default true |
| show_correct_answers, allow_review | boolean | Default true |
| max_attempts | integer | NULL = unlimited |
| is_published | boolean | Default false |
| is_active | boolean | Default true |

#### `public.exam_template_question`
| Column | Type | Notes |
|--------|------|-------|
| id_exam_template | uuid | FK → exam_template ON DELETE CASCADE |
| id_question | uuid | FK → question ON DELETE CASCADE |
| question_order | integer | Default 1 |
| points_override | decimal(5,2) | Overrides default points |

**Constraint:** UNIQUE (id_exam_template, id_question)

#### `public.exam_template_category`
| Column | Type | Notes |
|--------|------|-------|
| id_exam_template | uuid | FK → exam_template ON DELETE CASCADE |
| id_category | uuid | FK → question_category ON DELETE CASCADE |
| question_count | integer | Default 5. Questions to auto-select from this category |

**Constraint:** UNIQUE (id_exam_template, id_category)

#### `public.gamification_season`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | UNIQUE. E.g. "2026.1" |
| starts_at, ends_at | timestamp | |
| is_active | boolean | Default false |

#### `public.user_gamification_points`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| user_id | uuid | FK → "user" ON DELETE CASCADE |
| season_id | uuid | FK → gamification_season ON DELETE CASCADE |
| attempt_id | uuid | FK → user_exam_attempts ON DELETE CASCADE, UNIQUE |
| exam_id, course_id | uuid | |
| exam_template_id | uuid | Optional |
| question_count, correct_count | integer | |
| percentage_score | numeric(5,2) | |
| duration_seconds | integer | |
| base_points, time_bonus, total_points | numeric(6,2) | total_points may be delta only |

### Database Views

| View | Description |
|------|-------------|
| `ranking_global_view` | Global ranking by season. RANK() OVER (PARTITION BY season_id) |
| `ranking_course_view` | Ranking by course and season. Extra: course_id, course_name |
| `ranking_template_view` | Ranking by exam template and season. Extra: exam_template_id, template_name |
| `teacher_question_stats` | Question stats per teacher/course: total, active, categories, avg_points |
| `teacher_exam_stats` | Exam stats per teacher: templates, published, total taken, avg_score, passed |
| `teacher_student_responses` | Detailed student responses for teacher analysis |

### Stored Procedures / RPC Functions

| Function | Description |
|----------|-------------|
| `get_or_create_active_season()` | Returns active season or creates one based on current semester. SECURITY DEFINER |
| `create_teacher_question(p_teacher_id, p_course_id, p_category_id, p_enunciation, p_difficulty_level, p_points, p_supporting_texts, p_answer_choices)` | Atomically creates question + supporting texts + answer choices. Validates teacher role, assigns sequential number. SECURITY DEFINER |
| `update_teacher_question(p_question_id, p_teacher_id, ...)` | Atomically updates question. UPSERT of choices by (idquestion, letter). SECURITY DEFINER |
| `get_teacher_questions(p_teacher_id, p_course_id, p_category_id, p_active_only)` | Returns teacher's questions with choice/text counts. SECURITY DEFINER |
| `generate_exam_from_template(p_template_id, p_user_id)` | Creates exam + examquestion from template. Returns exam UUID. SECURITY DEFINER |
| `get_teacher_exam_responses(p_teacher_id, p_template_id, p_exam_id)` | Detailed student responses for teacher analysis. SECURITY DEFINER |
| `admin_list_users(...)` | Lists all users with stats (admin only) |
| `admin_update_user_role(...)` | Updates user roles (prevents self-demotion) |
| `admin_toggle_user_active(...)` | Soft delete users (prevents self-deactivation) |

### Row Level Security (RLS)

| Table | RLS Active | Policies |
|-------|-----------|----------|
| question_category | Yes | Teachers/admins: ALL; Public: SELECT where is_active=true |
| exam_template | Yes | Owner teacher: ALL; Public: SELECT where is_published=true AND is_active=true |
| exam_template_question | Yes | Only owner teacher: ALL |
| exam_template_category | Yes | Only owner teacher: ALL |
| subject | Yes | SELECT: is_active=true; INSERT/UPDATE: authenticated |
| gamification_season | Yes | SELECT: authenticated |
| user_gamification_points | Yes | SELECT: authenticated; INSERT: only auth.uid()=user_id |
| Other tables | No | No RLS configured |

### Schema Notes

**Legacy naming inconsistencies (preserved for compatibility):**
- `answerchoice.idquestion` — no underscore
- `answerchoice.upload_at` — different from standard `updated_at`
- `examquestion.update_at` — never renamed
- `user.surename` — typo of `surname`
- `user_responses` was originally `userresponse`, columns renamed in migration 006

**Extension:** `pgcrypto` for `gen_random_uuid()`

**Referential integrity:**
- `ON DELETE CASCADE`: exam_template_question, exam_template_category, user_exam_attempts, user_responses, user_gamification_points, subject, question_category
- `ON DELETE SET NULL`: user_responses.answer_choice_id, question.id_teacher, question.id_category, question.id_subject, exam.id_exam_template

## Environment Configuration

- Web: Uses `--dart-define` for SUPABASE_URL and SUPABASE_ANON_KEY (set in CI/deploy)
- Native: Loads from `assets/dotenv.env` file
- Config accessed via `lib/constants/supabase_options.dart`

### Local Setup

```bash
git clone git@github.com:UNICV-TECH/smart_quiz_mvp.git
cd smart_quiz_mvp
flutter pub get

# Create assets/dotenv.env with:
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key

flutter run -d chrome
```

### CI/CD Secrets (GitHub Settings > Secrets)

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Database Migrations

Located in `supabase/migrations/`. Apply in numerical order via Supabase CLI (`supabase db push`) or Dashboard SQL Editor.

Key migrations:
- `20250204000001` — Teacher module (roles, categories, templates)
- `20250225000001` — Teacher question update function
- `20250225000002` — Subject table
- `20260224000001` — Gamification tables & ranking views
- `20260303000001` — Admin module (analytics, user management)

## CI/CD

GitHub Actions workflow (`.github/workflows/deploy.yml`):

```
Trigger: push to main/develop | PR to main | manual (workflow_dispatch)

Job 1: ANALYZE → flutter analyze
Job 2: TEST (depends on analyze) → flutter test
Job 3: BUILD & DEPLOY (depends on test, main branch only)
  ├── flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  ├── git add build/web -f
  ├── git commit -m "chore: build web release [skip ci]"
  └── git push
```

- **Flutter version:** 3.38.5 (stable)
- **Hosting:** Vercel (default *.vercel.app domain)
- **Tests:** Basic unit tests with `flutter_test` + `mockito`

## Contribution Guide

### Git Workflow

```
main ──────────────────────────────►
   \                    /
    develop ────────────────────────►
       \          /         \     /
        feature/xxx         fix/xxx
```

### Commit Convention

```
feat: add teacher gamification screen
fix: correct score calculation for time bonus
chore: build web release [skip ci]
refactor: extract avatar component
docs: update API documentation
test: add unit tests for gamification calculator
```

### Code Standards

- **Architecture:** MVVM — don't mix business logic in Views
- **State Management:** Provider + ChangeNotifier — don't use setState for shared state
- **Repositories:** Always create abstract interface + Supabase implementation
- **Models:** Use `fromJson`/`toJson` factories, `copyWith` for immutability
- **UI Components:** Prefix with `default_`, keep in `lib/ui/components/`
- **Routes:** Register in `app_routes.dart`, protect with `ProtectedRoute`
- **File names:** snake_case | **Classes:** PascalCase | **Variables:** camelCase

### Adding a New Feature

1. **Model:** Create/edit in `lib/models/`
2. **Migration:** Create SQL in `supabase/migrations/` (name: `YYYYMMDDHHMMSS_description.sql`)
3. **Repository:** Create interface + implementation in `lib/repositories/`
4. **Register:** Add Provider in `main.dart`
5. **ViewModel:** Create in `lib/viewmodels/`
6. **View:** Create screen in `lib/views/`
7. **Route:** Register in `app_routes.dart`
8. **Test:** Write minimal unit tests

### Security Checklist (Pre-Commit)

- [ ] No `.env` file is staged
- [ ] No API key or token is hardcoded
- [ ] Database credentials are not exposed
- [ ] `.gitignore` includes: .env, node_modules/, dist/, .dart_tool/, build/
