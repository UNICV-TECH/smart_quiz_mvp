# Quiz Config Refactor Documentation

## Overview
Refactored `QuizConfig_screen.dart` to use a proper MVVM architecture with `QuizConfigViewModel` for fetching exam metadata, validating available question counts from Supabase, and implementing navigation to `exam_screen` with proper initialization of `user_exam_attempts` records.

## Changes Made

### 1. New Files Created

#### `lib/models/exam.dart`
- **Purpose**: Database models matching the Supabase schema
- **Models**:
  - `Exam`: Complete exam metadata (id, title, description, total_available_questions, time_limit_minutes, etc.)
  - `Question`: Question entity with enunciation, difficulty_level, points, etc.
  - `AnswerChoice`: Answer choice entity with choice_key, choice_text, is_correct, etc.
  - `SupportingText`: Supporting text/media for questions
  - `UserExamAttempt`: Records user's exam attempt (status, scores, duration, etc.)
  - `UserResponse`: Records user's answer to a specific question

All models include:
- `fromJson()` factory constructors for Supabase data
- `toJson()` methods for serialization
- Proper DateTime handling
- Null safety

#### `lib/models/course.dart`
- **Purpose**: Course model matching the Supabase schema
- **Model**:
  - `Course`: Course entity with course_key, title, description, icon_key, is_active, etc.

#### `lib/services/repositorie/exam_repository.dart`
- **Purpose**: Repository abstraction for exam-related operations
- **Key Classes**:
  - `ExamRepository` (abstract): Interface for exam operations
  - `ExamMetadata`: Lightweight model for exam metadata (id, title, description, totalQuestions)
  - `ExamQuestion`: Wrapper combining Question with its AnswerChoices and SupportingTexts
  - `SupabaseExamRepository`: Supabase implementation of ExamRepository

- **Key Methods**:
  - `getExamMetadata(courseId)`: Fetch exam metadata using `total_available_questions` field
  - `getAvailableQuestionCount(examId)`: Get count of active questions
  - `createExamAttempt()`: Create a new user_exam_attempts record
  - `fetchExamQuestions()`: Fetch questions with their choices and supporting texts

**Schema Alignment**:
- Uses `total_available_questions` from exams table (not counting questions)
- Fetches questions directly without requiring SQL function
- Properly maps all database fields

#### `lib/services/repositorie/mock_exam_repository.dart`
- **Purpose**: Mock implementation for development/testing when Supabase is not configured
- Implements all `ExamRepository` methods with simulated data and delays
- Uses proper model classes from `lib/models/exam.dart`

#### `lib/viewmodels/quiz_config_view_model.dart`
- **Purpose**: ViewModel for QuizConfigScreen following MVVM pattern
- **State Management**: Uses `ChangeNotifier` with Provider
- **Key Properties**:
  - `isLoading`: Loading state indicator
  - `error`: Error message if any
  - `examMetadata`: Loaded exam metadata

- **Key Methods**:
  - `loadExamMetadata(courseId)`: Load exam metadata from repository
  - `validateQuestionCount(requestedCount)`: Validate if requested count is available
  - `getMaxQuestions()`: Get maximum available questions
  - `getAvailableOptions()`: Get valid question count options (5, 10, 15, 20)
  - `createExamAttempt()`: Create exam attempt and return attemptId

#### `lib/views/quiz_config_screen_wrapper.dart`
- **Purpose**: Wrapper to provide `QuizConfigViewModel` to `QuizConfigScreen`
- Automatically selects between `SupabaseExamRepository` and `MockExamRepository` based on Supabase configuration

#### `database_functions.sql`
- **Purpose**: Optional SQL function for Supabase to fetch random questions
- Function `get_random_questions(p_exam_id, p_limit)` returns random active questions for an exam
- **Note**: Repository works without this function (uses direct queries)

### 2. Modified Files

#### `lib/views/QuizConfig_screen.dart`
**Changes**:
- Now consumes `QuizConfigViewModel` via Provider
- Loads exam metadata on initialization
- Validates question count against available questions from database
- Creates `user_exam_attempts` record before navigation
- Displays loading states, errors with retry option
- Dynamically generates available question options based on `total_available_questions`
- Navigates to `ExamScreen` with `attemptId`, `examId`, and `questionCount` parameters

**Key Features**:
- Error handling with user-friendly messages
- Loading indicators during async operations
- Validation before exam initialization
- Integration with Supabase auth for user identification

#### `lib/views/exam_screen.dart`
**Changes**:
- Added constructor parameters:
  - `attemptId`: ID of the user_exam_attempts record
  - `examId`: ID of the exam
  - `questionCount`: Number of questions for this attempt
- These parameters enable future integration with the repository layer

### 3. Database Schema Alignment

#### Schema Version
Aligned with **SCHEMA_DOCUMENTATION.md** which defines:

**Tables Used**:
1. **courses**: `course_key`, `title`, `description`, `icon_key`, `is_active`
2. **exams**: `id`, `course_id`, `title`, `description`, `total_available_questions`, `time_limit_minutes`, `passing_score_percentage`, `is_active`
3. **questions**: `id`, `exam_id`, `enunciation`, `question_order`, `difficulty_level`, `points`, `is_active`
4. **answer_choices**: `id`, `question_id`, `choice_key`, `choice_text`, `is_correct`, `choice_order`
5. **supporting_texts**: `id`, `question_id`, `content_type`, `content`, `display_order`
6. **user_exam_attempts**: Records each exam attempt with:
   - `user_id`: Who is taking the exam
   - `exam_id`: Which exam
   - `course_id`: Which course
   - `question_count`: Number of questions in this attempt
   - `status`: 'in_progress', 'completed', or 'abandoned'
   - `started_at`: Timestamp when exam started
   - `completed_at`, `duration_seconds`, `total_score`, `percentage_score`: Filled on completion
7. **user_responses**: Captures user answers with:
   - `attempt_id`: Links to user_exam_attempts
   - `question_id`, `answer_choice_id`, `selected_choice_key`
   - `is_correct`, `points_earned`, `time_spent_seconds`

#### Key Schema Features
- **total_available_questions**: Field in exams table stores pre-computed question count
- **UUIDs**: All IDs are UUIDs, not integers
- **Timestamps**: All `created_at`/`updated_at` fields are `TIMESTAMP WITH TIME ZONE`
- **Status tracking**: user_exam_attempts has status enum: 'in_progress', 'completed', 'abandoned'

#### Workflow
1. User selects course → navigates to QuizConfigScreen
2. QuizConfigScreen loads exam metadata (including `total_available_questions`)
3. User selects question count (validated against `total_available_questions`)
4. User clicks "Iniciar" → creates `user_exam_attempts` record with status='in_progress'
5. Navigation to ExamScreen with `attemptId`, `examId`, `questionCount`
6. ExamScreen can fetch questions and track progress using `attemptId`
7. On completion: insert `user_responses`, update `user_exam_attempts` with scores and status='completed'

## Architecture Benefits

### MVVM Pattern
- **Separation of Concerns**: Business logic in ViewModel, UI in View
- **Testability**: ViewModels can be unit tested independently
- **Reusability**: Repository layer can be reused across different ViewModels

### Repository Pattern
- **Abstraction**: UI doesn't know about Supabase specifics
- **Flexibility**: Easy to switch between mock and real implementations
- **Offline Support**: Can implement caching layer in repository

### Provider State Management
- **Reactive UI**: UI automatically updates when ViewModel state changes
- **Clean Code**: No manual setState calls in business logic
- **Dependency Injection**: Easy to provide dependencies to ViewModels

### Proper Models
- **Type Safety**: Dart models match database schema exactly
- **Validation**: fromJson constructors handle null safety
- **Serialization**: toJson methods for sending data back to Supabase
- **Maintainability**: Changes to schema reflected in models

## Usage

### Navigating to QuizConfigScreen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QuizConfigScreenWrapper(
      course: {
        'id': 'course-uuid',
        'title': 'Course Name',
      },
    ),
  ),
);
```

The wrapper automatically provides the ViewModel with the appropriate repository.

### Testing with Mock Data

When Supabase is not configured (missing .env credentials), the app automatically uses `MockExamRepository` which provides:
- Mock exam metadata (20 questions available)
- Simulated network delays
- Mock question data with proper model structure

## Future Enhancements

1. **ExamScreen Integration**: 
   - Fetch actual questions using `attemptId` and `examId`
   - Display real question data from Supabase
   - Track user responses linked to `attemptId`

2. **Response Submission**:
   - Save user responses to `user_responses` table
   - Calculate scores based on correct answers
   - Update `user_exam_attempts` with completion data (status='completed', scores, duration)

3. **Offline Support**:
   - Cache questions locally
   - Queue response submissions
   - Sync when online

4. **Analytics**:
   - Track time spent per question
   - Identify difficult questions
   - Provide performance insights

5. **Random Sampling**:
   - Implement true random question selection (currently sequential)
   - Option: Use database function or client-side shuffling

## Database Setup Requirements

### Required Steps
1. Ensure all tables are created per SCHEMA_DOCUMENTATION.md
2. Set up RLS (Row-Level Security) policies:
   - Authenticated users can read from `exams`, `questions`, `answer_choices`, `supporting_texts`
   - Authenticated users can insert into `user_exam_attempts`
   - Users can only read/update their own `user_exam_attempts` records
3. Optional: Execute `database_functions.sql` in Supabase SQL Editor for random sampling

### Indexes
All required indexes are defined in SCHEMA_DOCUMENTATION.md:
- Foreign key indexes for performance
- `is_active` indexes for filtering
- Completion date indexes for history queries

## Dependencies

All dependencies are already configured in `pubspec.yaml`:
- `provider`: State management
- `supabase_flutter`: Database and auth
- `flutter_dotenv`: Environment configuration

## Model Mapping Reference

| Database Table | Dart Model | Location |
|----------------|------------|----------|
| `courses` | `Course` | `lib/models/course.dart` |
| `exams` | `Exam` | `lib/models/exam.dart` |
| `questions` | `Question` | `lib/models/exam.dart` |
| `answer_choices` | `AnswerChoice` | `lib/models/exam.dart` |
| `supporting_texts` | `SupportingText` | `lib/models/exam.dart` |
| `user_exam_attempts` | `UserExamAttempt` | `lib/models/exam.dart` |
| `user_responses` | `UserResponse` | `lib/models/exam.dart` |

All models follow the exact schema from SCHEMA_DOCUMENTATION.md including:
- Field names (snake_case in DB, camelCase in Dart)
- Data types (UUID → String, DECIMAL → double, TIMESTAMP → DateTime)
- Nullable fields properly marked with `?`
- DateTime parsing for all timestamp fields
