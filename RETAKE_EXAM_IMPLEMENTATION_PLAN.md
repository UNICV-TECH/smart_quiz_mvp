# Retake Exam Feature Implementation Plan

## Objective
Document the concrete steps required to deliver a reliable "Refazer prova" (retake exam) experience, covering ViewModel updates, UI changes, safety checks, documentation fixes, and validation tasks.

## Tasks

### 1. Update `ExamViewModel.finalize()`
- **File:** `lib/viewmodels/exam_view_model.dart`
- **Changes:**
  - Extend the results map to include `userId`, `examId`, `courseId`, and an explicit `questionCount` key.
  - Preserve existing metrics (`totalQuestions`, `correctCount`, etc.) so downstream consumers remain unaffected.
- **Outcome:** Result payload contains every identifier needed to launch a retake without additional lookups.

### 2. Add "Refazer prova" Button to Result Screen
- **File:** `lib/views/exam_result_screen.dart`
- **Changes:**
  - Insert a primary `DefaultButtonOrange` labeled "Refazer prova" above the existing "Voltar ao início" control.
  - Use `BotaoTipo.primario` for the retake button and `BotaoTipo.secundario` for the home button.
  - Maintain 12px vertical spacing within the bottom sheet container (`EdgeInsets.fromLTRB(24, 16, 24, 32)`).
- **Outcome:** Users see a clear action to retake immediately while retaining the option to exit to the main navigation.

### 3. Implement Safe Retake Handler
- **File:** `lib/views/exam_result_screen.dart`
- **Changes:**
  - Add `_canRetake()` helper that validates presence of `userId`, `examId`, `courseId`, and `questionCount` in `widget.results`.
  - Add `_handleRetake()` that casts the values, shows a SnackBar on missing data, and executes `Navigator.pushReplacementNamed('/exam', arguments: {...})`.
  - Disable the button (`BotaoTipo.desabilitado`) when `_canRetake()` is false.
- **Outcome:** Prevents runtime crashes from malformed payloads and guarantees the exam screen receives a fully typed argument map.

### 4. Fix Documentation Enum Typo
- **File:** `RETAKE_EXAM_FEATURE_ANALYSIS.md`
- **Changes:** Replace the nonexistent `BotaoTipo.principal` with `BotaoTipo.primario` in the provided code snippet.
- **Outcome:** Documentation aligns with actual enum definition in `lib/ui/components/default_button_orange.dart`.

### 5. Expand Documentation Guidance
- **File:** `RETAKE_EXAM_FEATURE_ANALYSIS.md`
- **Changes:**
  - Add a note explaining that `/exam` route expects all four identifiers and the button handler must validate them before navigation.
  - Document the intended button arrangement (primary retake button on top, secondary home button beneath, full width, 54px height).
- **Outcome:** Future contributors have clear UI and data requirements when iterating on the feature.

### 6. Add Retake Flow Integration Test
- **File:** `test/retake_exam_flow_test.dart` (new)
- **Test Steps:**
  1. Instantiate `ExamViewModel` with stubbed data source.
  2. Complete the exam (`finalize()`), verifying the results map contains all required identifiers.
  3. Simulate tapping the retake button and ensure a new attempt launches with identical identifiers but a fresh `attemptId`.
  4. Complete the second attempt and confirm historical data is preserved.
- **Outcome:** Automated regression coverage for retake logic and navigation payload integrity.

### 7. Static Analysis & Unit Tests
- **Commands:**
  - `flutter analyze`
  - `flutter test`
- **Outcome:** Confirms the codebase builds cleanly and all tests (including the new integration test) pass.

### 8. Manual Supabase Verification
- **Steps:**
  1. Run the app, finish an exam, and note the `attempt_id` created in `user_exam_attempts`.
  2. Tap "Refazer prova" and verify a new row appears with the same `user_id`, `exam_id`, `course_id`, status `in_progress`, and a new `started_at` timestamp.
  3. Complete the retake and confirm both attempts are stored with distinct response sets in `user_responses`.
- **Outcome:** Ensures backend data integrity and validates end-to-end user experience.

## Recommended Execution Order
1. Task 1 – ensure payload correctness.
2. Task 2 – introduce the UI changes.
3. Task 3 – harden navigation safety.
4. Task 7 – run `flutter analyze` early to confirm no regressions.
5. Tasks 4 & 5 – fix and enhance documentation.
6. Task 8 – manual validation of Supabase writes.
7. Task 6 – add automated coverage.
8. Rerun Task 7 commands after code/test updates.

## Risks & Mitigations
- **Multiple active attempts:** Supabase schema already supports concurrent `in_progress` attempts; no mitigation required beyond documentation.
- **Shuffled questions:** Current logic shuffles only when the pool exceeds the configured question count; retakes may differ by design.
- **User exits mid-retake:** Using `pushReplacementNamed` removes the result screen from the stack, avoiding duplicate entries when navigating back.
