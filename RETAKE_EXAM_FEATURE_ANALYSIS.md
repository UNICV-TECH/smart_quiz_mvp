# "Refazer Prova" Feature Analysis

## Overview
This document analyzes what is required to implement a "Refazer prova" (retake exam) button on the exam result screen, considering both the Flutter application flow and the Supabase database schema.

## Current State
- The exam result screen (`lib/views/exam_result_screen.dart`) displays summary metrics and a question-by-question breakdown but only offers a "Voltar ao início" navigation button.
- `ExamViewModel.finalize()` returns a `results` map with attempt metadata (`attemptId`, counts, scores) but **omits** the identifiers needed to relaunch the same exam (`userId`, `examId`, `courseId`, `questionCount`).
- Database tables already support multiple attempts:
  - `user_exam_attempts` records each attempt with status, timing, and score fields.
  - `user_responses` links responses to the corresponding attempt via `attempt_id`.

## Required Data Additions
To trigger a retake from the result screen, the navigation arguments for the `/exam` route must include:
- `userId`
- `examId`
- `courseId`
- `questionCount` (keep `totalQuestions` for display, but send an explicit `questionCount` argument)

Update `ExamViewModel.finalize()` (around line 194) to include the missing identifiers when returning `results`:
```dart
return {
  'attemptId': _attemptId,
  'userId': userId,
  'examId': examId,
  'courseId': courseId,
  'questionCount': questionCount,
  'totalQuestions': _examQuestions.length,
  'correctCount': correctCount,
  'totalScore': totalScore,
  'percentageScore': percentageScore,
  'durationSeconds': durationSeconds,
  'startedAt': _startedAt?.toIso8601String(),
  'completedAt': completedAt.toIso8601String(),
  'questionsBreakdown': questionsBreakdown,
};
```

## UI & Navigation Changes
Add a new button to the bottom action area in `ExamResultScreen`:
```dart
DefaultButtonOrange(
  texto: 'Refazer prova',
  largura: double.infinity,
  altura: 54,
  tipo: BotaoTipo.primario,
  onPressed: () {
    Navigator.pushReplacementNamed(
      context,
      '/exam',
      arguments: {
        'userId': widget.results['userId'],
        'examId': widget.results['examId'],
        'courseId': widget.results['courseId'],
        'questionCount': widget.results['questionCount'],
      },
    );
  },
);
```

**Important:** The `/exam` route defined in `lib/main.dart` requires all four identifiers. The button handler must validate their presence and types before attempting navigation to avoid runtime crashes.

## UI Layout Details
- Place "Refazer prova" above "Voltar ao início" inside the existing bottom sheet container.
- Both buttons should use `largura: double.infinity` and `altura: 54` to match the design system.
- Maintain a `SizedBox(height: 12)` spacer between the buttons.
- Use `BotaoTipo.primario` for the retake button, `BotaoTipo.secundario` for the home button, and fall back to `BotaoTipo.desabilitado` if arguments are missing.
- Keep the container padding at `EdgeInsets.fromLTRB(24, 16, 24, 32)` so the new layout aligns with the current visual design.

## Workflow After Changes
1. User completes an exam and lands on the result screen.
2. Tapping "Refazer prova" pushes the `/exam` route with the same exam parameters (validated via the results map).
3. `ExamViewModel.initialize()` runs again:
   - Creates a **new** record in `user_exam_attempts` (`status = 'in_progress'`).
   - Fetches questions and answer choices from Supabase.
4. When the retake is finished, `finalize()` writes responses to `user_responses`, updates the new attempt, and returns results.

## Database Considerations
- **No schema changes required.** Multiple attempts per user/exam are already supported through `user_exam_attempts`.
- Each retake produces a separate attempt record, preserving historical scores and durations.
- `user_responses` uses `attempt_id` to keep answers isolated per attempt.

## Optional Enhancements
- Show comparison to previous attempts (e.g., last score vs. current score).
- Enforce retake limits or cooldowns via query checks on `user_exam_attempts`.
- Adjust question-selection logic if a different pool or randomization strategy is desired for retakes.

## Implementation Checklist
- [ ] Add missing identifiers (`userId`, `examId`, `courseId`, `questionCount`) to the results map in `ExamViewModel.finalize()`.
- [ ] Insert "Refazer prova" button into `ExamResultScreen`, validate arguments, and wire navigation to `/exam`.
- [ ] Verify navigation arguments arrive correctly at `ExamScreen` and that a new attempt is created on Supabase.
- [ ] (Optional) Consider UX enhancements such as showing previous scores or retake restrictions.
