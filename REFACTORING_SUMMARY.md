# Exam Screen Refactoring Summary

## Overview
Refactored `exam_screen.dart` to implement MVVM architecture pattern using `ExamViewModel` for managing exam data flow from Supabase database.

## Changes Made

### 1. Created `ExamViewModel` (`lib/viewmodels/exam_view_model.dart`)

**Responsibilities:**
- Load questions, answer choices, and supporting texts from Supabase on initialization
- Create user exam attempt record
- Manage local response state during exam (Map<String, String> where key is question UUID)
- Batch insert user responses on finalization
- Calculate score and update attempt completion

**Key Methods:**
- `initialize()`: Creates attempt and loads questions from Supabase
- `selectAnswer(questionId, choiceKey)`: Updates local state for user selections
- `finalize()`: Batch inserts responses, calculates score, updates attempt status

**Data Flow:**
```
1. Create user_exam_attempts record (status: 'in_progress')
2. Load questions from questions table (filtered by exam_id, is_active)
3. Shuffle questions client-side and take requested count
4. Load answer_choices for each question
5. Load supporting_texts for each question
6. User selects answers (stored locally in Map<String, String>)
7. On finalization:
   - Batch insert all responses to user_responses table
   - Calculate correct count and total score
   - Update user_exam_attempts (completed_at, duration_seconds, scores, status: 'completed')
```

### 2. Extended Models (`lib/models/exam_history.dart`)

Added new model classes to existing exam_history.dart file (preserving original ExamHistory models):
- `Question`: Question entity with UUID id, enunciation, difficulty_level, points
- `AnswerChoice`: Answer choice entity with UUID id, question_id, choice_key, choice_text, is_correct, choice_order
- `SupportingText`: Supporting text entity with UUID id, question_id, content_type, content, display_order
- `ExamQuestion`: Composite model containing question + list of answer choices + list of supporting texts

**Key Model Details:**
- All IDs are UUIDs (String type)
- Models include `fromJson` factory constructors for Supabase response parsing
- Schema follows SCHEMA_DOCUMENTATION.md exactly

### 3. Refactored `ExamScreen` (`lib/views/exam_screen.dart`)

**Key Changes:**
- Now accepts `userId`, `examId`, `courseId`, `questionCount` as constructor parameters (all String except questionCount)
- Uses `Provider` to consume `ExamViewModel`
- Shows loading state while fetching questions (CircularProgressIndicator)
- Shows error state if loading fails (with error message and back button)
- Shows empty state if no questions available
- Renders questions dynamically from ViewModel data (ExamQuestion list)
- Updates navigation to track answered questions by UUID (converts to index for UI)
- Calls `viewModel.finalize()` on exam completion
- Shows success feedback with score and navigates back

**UI States:**
- Loading: Shows CircularProgressIndicator centered in gradient background
- Error: Shows error icon, message, and back button
- Empty: Shows "no questions available" message
- Loaded: Shows exam interface with questions, answers, navigation

**Question Navigation Fix:**
The navigation component expects Set<int> (question numbers), so we convert UUID-based answered questions:
```dart
answeredQuestions: viewModel.selectedAnswers.keys
  .map((qId) {
    final index = viewModel.examQuestions.indexWhere((eq) => eq.question.id == qId);
    return index + 1;
  })
  .where((index) => index > 0)
  .toSet()
```

### 4. Updated `QuizConfigScreen` (`lib/views/QuizConfig_screen.dart`)

Modified `_startQuiz()` method to navigate to `/exam` route with required arguments:
```dart
Navigator.pushNamed(context, '/exam', arguments: {
  'userId': 'REPLACE_WITH_ACTUAL_USER_ID',  // Must be UUID
  'examId': widget.course['examId'] ?? 'REPLACE_WITH_EXAM_ID',  // Must be UUID
  'courseId': widget.course['courseId'] ?? widget.course['id'],  // Must be UUID
  'questionCount': int.parse(_selectedQuantity!),  // int (5, 10, 15, 20)
});
```

**Note:** These are placeholder values. Real implementation needs:
- `userId`: Get from authenticated user context (Supabase auth)
- `examId`: Get from exams table query using course_id
- `courseId`: Get from courses table (UUID primary key)

### 5. Updated Main App (`lib/main.dart`)

Added `/exam` route with `ChangeNotifierProvider` wrapping `ExamViewModel`:
```dart
'/exam': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  if (args == null) {
    return const Scaffold(
      body: Center(child: Text('Missing exam arguments')),
    );
  }
  return ChangeNotifierProvider(
    create: (context) => ExamViewModel(
      supabase: Supabase.instance.client,
      userId: args['userId'] as String,
      examId: args['examId'] as String,
      courseId: args['courseId'] as String,
      questionCount: args['questionCount'] as int,
    ),
    child: ExamScreen(
      userId: args['userId'] as String,
      examId: args['examId'] as String,
      courseId: args['courseId'] as String,
      questionCount: args['questionCount'] as int,
    ),
  );
}
```

## Database Schema Alignment

All database operations follow the schema documented in SCHEMA_DOCUMENTATION.md:

### Table Structures Used:

**questions table:**
- id: UUID (PRIMARY KEY)
- exam_id: UUID (FOREIGN KEY → exams.id)
- enunciation: TEXT (question text)
- difficulty_level: TEXT ('easy', 'medium', 'hard')
- points: DECIMAL(5,2) DEFAULT 1.0
- is_active: BOOLEAN DEFAULT TRUE

**answer_choices table:**
- id: UUID (PRIMARY KEY)
- question_id: UUID (FOREIGN KEY → questions.id)
- choice_key: TEXT ('A', 'B', 'C', 'D', 'E')
- choice_text: TEXT
- is_correct: BOOLEAN DEFAULT FALSE
- choice_order: INTEGER

**supporting_texts table:**
- id: UUID (PRIMARY KEY)
- question_id: UUID (FOREIGN KEY → questions.id)
- content_type: TEXT ('text', 'image', 'code', 'table')
- content: TEXT
- display_order: INTEGER DEFAULT 1

**user_exam_attempts table:**
- id: UUID (PRIMARY KEY)
- user_id: UUID (FOREIGN KEY → users.id)
- exam_id: UUID (FOREIGN KEY → exams.id)
- course_id: UUID (FOREIGN KEY → courses.id)
- question_count: INTEGER
- started_at: TIMESTAMP WITH TIME ZONE
- completed_at: TIMESTAMP WITH TIME ZONE (NULL until completed)
- duration_seconds: INTEGER
- total_score: DECIMAL(5,2)
- percentage_score: DECIMAL(5,2)
- status: TEXT ('in_progress', 'completed', 'abandoned')

**user_responses table:**
- id: UUID (PRIMARY KEY)
- attempt_id: UUID (FOREIGN KEY → user_exam_attempts.id)
- question_id: UUID (FOREIGN KEY → questions.id)
- answer_choice_id: UUID (FOREIGN KEY → answer_choices.id, NULL if unanswered)
- selected_choice_key: TEXT ('A', 'B', 'C', etc., NULL if unanswered)
- is_correct: BOOLEAN
- points_earned: DECIMAL(5,2) DEFAULT 0
- answered_at: TIMESTAMP WITH TIME ZONE

## Database Operations

### READ Operations (Initialization)

**1. Create Attempt:**
```dart
await _supabase.from('user_exam_attempts').insert({
  'user_id': userId,              // UUID
  'exam_id': examId,              // UUID
  'course_id': courseId,          // UUID
  'question_count': questionCount,
  'started_at': DateTime.now().toIso8601String(),
  'status': 'in_progress',
}).select('id').single();
```

**2. Load Questions:**
```dart
await _supabase
  .from('questions')
  .select('id, enunciation, difficulty_level, points')
  .eq('exam_id', examId)
  .eq('is_active', true);
// Then shuffle client-side and take(questionCount)
```

**3. Load Answer Choices:**
```dart
await _supabase
  .from('answer_choices')
  .select('*')
  .inFilter('question_id', questionIds)  // UUID list
  .order('choice_order');
```

**4. Load Supporting Texts:**
```dart
await _supabase
  .from('supporting_texts')
  .select('*')
  .inFilter('question_id', questionIds)  // UUID list
  .order('display_order');
```

### WRITE Operations (Finalization)

**1. Batch Insert Responses:**
```dart
await _supabase.from('user_responses').insert([
  {
    'attempt_id': attemptId,            // UUID
    'question_id': questionId,          // UUID
    'answer_choice_id': answerChoiceId, // UUID or NULL
    'selected_choice_key': 'A',         // or NULL
    'is_correct': true,
    'points_earned': 1.0,
    'answered_at': DateTime.now().toIso8601String(),
  },
  // ... more responses
]);
```

**2. Update Attempt:**
```dart
await _supabase.from('user_exam_attempts').update({
  'completed_at': DateTime.now().toIso8601String(),
  'duration_seconds': durationInSeconds,
  'total_score': totalScore,
  'percentage_score': (correctCount / totalQuestions) * 100,
  'status': 'completed',
}).eq('id', attemptId);  // UUID
```

## Score Calculation Logic

Implemented exactly as specified in schema:
```dart
correctCount = sum(is_correct == true)
totalScore = sum(points_earned)
percentageScore = (correctCount / totalQuestions) * 100
durationSeconds = completed_at - started_at (in seconds)
```

## Success Feedback

On successful finalization:
- Shows SnackBar: "Simulado finalizado! Você acertou X de Y questões."
- Returns Map with: totalQuestions, correctCount, totalScore, percentageScore
- Navigates back to previous screen with results

## Error Handling

- Try-catch blocks around all async operations
- Errors stored in `_error` property (String?)
- UI shows error state with message and back button
- Failed operations logged with `debugPrint` and `debugPrintStack`
- Rethrows exceptions in `finalize()` for caller to handle

## Key Implementation Notes

1. **UUID vs int**: Schema uses UUID for all IDs, not integers. Models and queries use String type.

2. **Question Randomization**: Done client-side with `.shuffle()` instead of database `ORDER BY RANDOM()` for better cross-database compatibility.

3. **Answer Choice Mapping**: UI shows choices by index (A, B, C...) but stores choice_key and choice_id in database.

4. **Supporting Text Rendering**: Currently only handles 'text' type. Image/code/table types show empty widget (can be extended).

5. **Question Navigation**: Converts UUID-based selection tracking to integer question numbers for UI component.

6. **Null Safety**: All nullable fields properly handled with null-conditional operators.

## Testing Recommendations

1. **Unit Tests for ExamViewModel:**
   - Mock Supabase client responses
   - Test `initialize()` with various question counts
   - Test `selectAnswer()` state updates
   - Test `finalize()` score calculation edge cases (all correct, all wrong, some unanswered)

2. **Widget Tests for ExamScreen:**
   - Test loading state rendering
   - Test error state rendering with error message
   - Test empty state rendering
   - Test question navigation between questions
   - Test answer selection updates

3. **Integration Tests:**
   - End-to-end exam flow with test Supabase instance
   - Verify batch insert performance with 20 questions
   - Test offline behavior (should fail gracefully)
   - Verify UUID format in all database operations

## Next Steps

### 1. Replace Placeholder IDs in QuizConfigScreen

Get actual authenticated user:
```dart
final userId = Supabase.instance.client.auth.currentUser?.id;
if (userId == null) {
  // Handle unauthenticated state
  return;
}
```

### 2. Load Exam ID from Database

Before navigating to exam:
```dart
final examResponse = await Supabase.instance.client
  .from('exams')
  .select('id')
  .eq('course_id', courseId)
  .eq('is_active', true)
  .single();

final examId = examResponse['id'] as String;
```

### 3. Create Database Migration

Create tables following SCHEMA_DOCUMENTATION.md:
- Run Phase 1-3 migrations
- Add sample data for testing
- Verify foreign key constraints
- Test indexes performance

### 4. Add Course/Exam Loading

HomeScreen should query:
```dart
final courses = await Supabase.instance.client
  .from('courses')
  .select('id, course_key, title, icon_key')
  .eq('is_active', true)
  .order('title');
```

### 5. Implement Timer Support

- Add timer to ExamViewModel
- Track time_spent_seconds per question
- Enforce time_limit_minutes from exams table
- Show countdown UI component

### 6. Enhance Error Recovery

- Add retry button on error state
- Consider offline caching with local SQLite
- Implement optimistic UI updates
- Add connectivity checking

### 7. Improve Supporting Text Rendering

Handle all content types:
- text: Formatted text box (done)
- image: Image.network with URL from content field
- code: Syntax-highlighted code block
- table: Formatted table widget

### 8. Add Question Review

After completion:
- Show review screen with all questions
- Highlight correct/incorrect answers
- Show explanations (add explanation field to questions table)
- Allow navigation to specific questions

## Database Schema Dependencies

This implementation requires these tables to exist in Supabase:
- `users` (created by Supabase Auth)
- `courses`
- `exams`
- `questions`
- `answer_choices`
- `supporting_texts`
- `user_exam_attempts`
- `user_responses`

All tables must follow the exact schema in SCHEMA_DOCUMENTATION.md, including:
- UUID primary keys
- Foreign key constraints
- Check constraints on enums
- Indexes on frequently queried columns
- Timestamps with time zones

## Migration Commands

Create these migrations in order:

```sql
-- Phase 1: Core tables
CREATE TABLE courses (...);
CREATE TABLE exams (...);
CREATE TABLE questions (...);
CREATE TABLE answer_choices (...);

-- Phase 2: Supporting tables
CREATE TABLE supporting_texts (...);

-- Phase 3: Tracking tables
CREATE TABLE user_exam_attempts (...);
CREATE TABLE user_responses (...);
```

See SCHEMA_DOCUMENTATION.md section 6 for complete migration SQL.
