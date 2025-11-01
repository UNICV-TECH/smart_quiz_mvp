# Quiz Mounting Enhancement Roadmap

> **Document Purpose**: Strategic enhancement plan for improving quiz question selection, loading, and user experience in the Smart Quiz MVP application.
>
> **Last Updated**: November 1, 2025  
> **Status**: Planning Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [Enhancement Categories](#enhancement-categories)
4. [Implementation Roadmap](#implementation-roadmap)
5. [Technical Specifications](#technical-specifications)
6. [Success Metrics](#success-metrics)

---

## Executive Summary

### Current State
The quiz mounting process fetches all questions for a course, shuffles them in-memory, and selects the requested count. While functional, this approach has limitations in performance, user experience, and question quality distribution.

### Goals
- **Performance**: Reduce question load time by 50%
- **Quality**: Ensure balanced difficulty distribution
- **Reliability**: Implement robust error handling and offline support
- **Experience**: Add progress saving and resume capabilities

### Impact
These enhancements will improve user satisfaction, reduce abandonment rates, and provide a more professional exam experience.

---

## Current Architecture Analysis

### Question Selection Flow

```
QuizConfigScreen
    ↓ (User selects count)
ExamScreen.initState()
    ↓
ExamViewModel.initialize()
    ↓
├─→ _createAttempt() [WRITE to user_exam_attempts]
└─→ _loadQuestions()
    ├─→ fetchQuestions(courseId) [Fetch ALL active questions]
    ├─→ shuffle() [In-memory randomization]
    ├─→ take(questionCount) [Select subset]
    ├─→ fetchAnswerChoices(questionIds) [Batch fetch]
    └─→ fetchSupportingTexts(questionIds) [Batch fetch]
```

### Key Files
- **lib/viewmodels/exam_view_model.dart:64-107** - Question loading logic
- **lib/viewmodels/exam_view_model.dart:283-320** - Database query implementation
- **lib/views/exam_screen.dart:36-42** - Screen initialization
- **lib/views/QuizConfig_screen.dart:42-101** - Navigation trigger

### Current Limitations

| Issue | Impact | Severity |
|-------|--------|----------|
| Fetches ALL questions before selection | Slow for large question banks | High |
| No difficulty distribution guarantee | Unbalanced quiz difficulty | Medium |
| No question history tracking | Repetitive questions across attempts | Medium |
| All-or-nothing loading | Poor perceived performance | High |
| Attempt created before load succeeds | Orphaned attempts on failure | Low |
| No progress auto-save | Lost work on app crash | High |
| No offline support | Requires constant connectivity | Medium |

---

## Enhancement Categories

### 1. Database Query Optimization

#### 1.1 Add Indexes
**Impact**: High | **Effort**: Low | **Priority**: P0

**File**: `supabase/migrations/20241102000001_add_question_indexes.sql`

```sql
-- Composite index for question selection
CREATE INDEX idx_question_course_active_created 
ON question(id_course, is_active, created_at);

-- Index for answer choice lookups
CREATE INDEX idx_answerchoice_question 
ON answerchoice(idquestion);

-- Index for supporting text lookups
CREATE INDEX idx_supportingtext_question 
ON supportingtext(id_question);
```

**Expected Improvement**: 60-80% faster query times for question fetch

#### 1.2 Database-Level Randomization
**Impact**: Medium | **Effort**: Low | **Priority**: P1

**File**: `lib/viewmodels/exam_view_model.dart`

```dart
// Current approach (line 283-295)
Future<List<Map<String, dynamic>>> fetchQuestions({
  required String examId,
  required String courseId,
}) async {
  // Fetches ALL, then shuffles in-memory
}

// Enhanced approach
Future<List<Map<String, dynamic>>> fetchQuestions({
  required String examId,
  required String courseId,
  required int limit,
}) async {
  final response = await _client
    .from('question')
    .select('*')
    .eq('id_course', courseId)
    .eq('is_active', true)
    .order('random()') // PostgreSQL RANDOM()
    .limit(limit);
  
  return response as List<Map<String, dynamic>>;
}
```

**Expected Improvement**: Eliminate in-memory processing for large datasets

#### 1.3 Query Result Caching
**Impact**: Low | **Effort**: Low | **Priority**: P2

```dart
class QuestionCacheService {
  final Map<String, CachedQuestionPool> _cache = {};
  
  Future<List<Question>> getCachedQuestions(String courseId) async {
    if (_cache.containsKey(courseId) && !_cache[courseId]!.isExpired) {
      return _cache[courseId]!.questions;
    }
    
    final questions = await _repository.fetchQuestions(courseId);
    _cache[courseId] = CachedQuestionPool(
      questions: questions,
      cachedAt: DateTime.now(),
    );
    
    return questions;
  }
}
```

---

### 2. Question Selection Strategy

#### 2.1 Difficulty-Based Distribution
**Impact**: High | **Effort**: Medium | **Priority**: P1

**File**: `lib/services/question_selection_service.dart` (NEW)

```dart
class QuestionSelectionService {
  /// Selects questions ensuring balanced difficulty distribution
  /// Default: 40% easy, 40% medium, 20% hard
  Future<List<Question>> selectQuestions({
    required String courseId,
    required int count,
    DifficultyDistribution? distribution,
  }) async {
    final allQuestions = await _repository.fetchQuestions(courseId);
    
    final byDifficulty = _groupByDifficulty(allQuestions);
    
    final dist = distribution ?? DifficultyDistribution.balanced();
    final easyCount = (count * dist.easyPercentage).round();
    final mediumCount = (count * dist.mediumPercentage).round();
    final hardCount = count - easyCount - mediumCount;
    
    final selected = <Question>[];
    selected.addAll(_selectRandom(byDifficulty['easy'], easyCount));
    selected.addAll(_selectRandom(byDifficulty['medium'], mediumCount));
    selected.addAll(_selectRandom(byDifficulty['hard'], hardCount));
    
    return selected..shuffle(); // Final shuffle for order
  }
  
  Map<String, List<Question>> _groupByDifficulty(List<Question> questions) {
    return {
      'easy': questions.where((q) => q.difficultyLevel == 'easy').toList(),
      'medium': questions.where((q) => q.difficultyLevel == 'medium').toList(),
      'hard': questions.where((q) => q.difficultyLevel == 'hard').toList(),
    };
  }
  
  List<Question> _selectRandom(List<Question>? pool, int count) {
    if (pool == null || pool.isEmpty) return [];
    pool.shuffle();
    return pool.take(count).toList();
  }
}

class DifficultyDistribution {
  final double easyPercentage;
  final double mediumPercentage;
  final double hardPercentage;
  
  const DifficultyDistribution({
    required this.easyPercentage,
    required this.mediumPercentage,
    required this.hardPercentage,
  });
  
  factory DifficultyDistribution.balanced() => 
    const DifficultyDistribution(
      easyPercentage: 0.4,
      mediumPercentage: 0.4,
      hardPercentage: 0.2,
    );
}
```

**Testing Requirements**:
```dart
// test/services/question_selection_service_test.dart
test('ensures minimum difficulty distribution', () {
  final questions = await service.selectQuestions(
    courseId: 'test',
    count: 10,
  );
  
  final easy = questions.where((q) => q.difficultyLevel == 'easy').length;
  final medium = questions.where((q) => q.difficultyLevel == 'medium').length;
  final hard = questions.where((q) => q.difficultyLevel == 'hard').length;
  
  expect(easy, greaterThanOrEqualTo(3)); // At least 30%
  expect(medium, greaterThanOrEqualTo(3)); // At least 30%
  expect(hard, greaterThanOrEqualTo(1)); // At least 10%
});
```

#### 2.2 Question History Tracking
**Impact**: Medium | **Effort**: High | **Priority**: P2

**Schema Enhancement**: `supabase/migrations/20241102000002_add_question_history.sql`

```sql
CREATE TABLE user_question_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES question(id) ON DELETE CASCADE,
  times_seen integer NOT NULL DEFAULT 1,
  times_correct integer NOT NULL DEFAULT 0,
  times_incorrect integer NOT NULL DEFAULT 0,
  last_seen_at timestamp without time zone NOT NULL DEFAULT NOW(),
  avg_time_seconds integer,
  created_at timestamp without time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp without time zone NOT NULL DEFAULT NOW(),
  CONSTRAINT user_question_history_unique UNIQUE(user_id, question_id)
);

CREATE INDEX idx_user_question_history_user ON user_question_history(user_id);
CREATE INDEX idx_user_question_history_last_seen ON user_question_history(user_id, last_seen_at);
```

**Service Implementation**:
```dart
class QuestionHistoryService {
  Future<List<Question>> selectWithHistoryAwareness({
    required String userId,
    required String courseId,
    required int count,
  }) async {
    // Fetch history for this user/course
    final history = await _fetchUserHistory(userId, courseId);
    
    // Get all questions
    final allQuestions = await _repository.fetchQuestions(courseId);
    
    // Prioritize questions:
    // 1. Never seen
    // 2. Seen long ago
    // 3. Previously incorrect
    final weighted = _calculateWeights(allQuestions, history);
    
    return _weightedSelection(weighted, count);
  }
  
  Future<void> recordQuestionExposure({
    required String userId,
    required String questionId,
    required bool wasCorrect,
    required int timeSpentSeconds,
  }) async {
    await _client.rpc('upsert_question_history', params: {
      'p_user_id': userId,
      'p_question_id': questionId,
      'p_was_correct': wasCorrect,
      'p_time_spent': timeSpentSeconds,
    });
  }
}
```

**Database Function**:
```sql
CREATE OR REPLACE FUNCTION upsert_question_history(
  p_user_id uuid,
  p_question_id uuid,
  p_was_correct boolean,
  p_time_spent integer
)
RETURNS void AS $$
BEGIN
  INSERT INTO user_question_history (
    user_id, question_id, times_seen, 
    times_correct, times_incorrect,
    avg_time_seconds, last_seen_at
  )
  VALUES (
    p_user_id, p_question_id, 1,
    CASE WHEN p_was_correct THEN 1 ELSE 0 END,
    CASE WHEN p_was_correct THEN 0 ELSE 1 END,
    p_time_spent, NOW()
  )
  ON CONFLICT (user_id, question_id) DO UPDATE SET
    times_seen = user_question_history.times_seen + 1,
    times_correct = user_question_history.times_correct + 
      CASE WHEN p_was_correct THEN 1 ELSE 0 END,
    times_incorrect = user_question_history.times_incorrect + 
      CASE WHEN p_was_correct THEN 0 ELSE 1 END,
    avg_time_seconds = (
      COALESCE(user_question_history.avg_time_seconds, 0) * user_question_history.times_seen + 
      p_time_spent
    ) / (user_question_history.times_seen + 1),
    last_seen_at = NOW(),
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;
```

#### 2.3 Insufficient Questions Validation
**Impact**: Medium | **Effort**: Low | **Priority**: P1

**File**: `lib/viewmodels/exam_view_model.dart:64`

```dart
Future<void> _loadQuestions() async {
  final List<Map<String, dynamic>> allQuestionsData =
      await _dataSource.fetchQuestions(examId: examId, courseId: courseId);

  // ADD VALIDATION
  if (allQuestionsData.length < questionCount) {
    throw InsufficientQuestionsException(
      available: allQuestionsData.length,
      requested: questionCount,
      courseId: courseId,
    );
  }

  if (allQuestionsData.length > questionCount) {
    allQuestionsData.shuffle();
  }
  
  // ... rest of method
}
```

**Exception Definition**: `lib/models/exceptions.dart` (NEW)

```dart
class InsufficientQuestionsException implements Exception {
  final int available;
  final int requested;
  final String courseId;

  InsufficientQuestionsException({
    required this.available,
    required this.requested,
    required this.courseId,
  });

  @override
  String toString() =>
      'Apenas $available questões disponíveis. '
      'Solicitadas: $requested questões.';
}
```

**UI Handling**: `lib/views/exam_screen.dart:71`

```dart
if (viewModel.error != null && viewModel.examQuestions.isEmpty) {
  final isInsufficientQuestions = 
      viewModel.error!.contains('disponíveis');
  
  return Scaffold(
    body: Container(
      // ... decoration
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isInsufficientQuestions 
                ? Icons.inventory_outlined 
                : Icons.error_outline,
              size: 64,
              color: AppColors.primaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              isInsufficientQuestions
                ? 'Questões insuficientes'
                : 'Erro ao carregar o exame',
              // ... style
            ),
            // ... error message and back button
          ],
        ),
      ),
    ),
  );
}
```

---

### 3. Performance & Loading Experience

#### 3.1 Progressive Loading
**Impact**: High | **Effort**: Medium | **Priority**: P1

**File**: `lib/viewmodels/exam_view_model.dart`

```dart
class ExamViewModel extends ChangeNotifier {
  // Add new state
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  
  static const int _initialBatchSize = 3;
  
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _createAttempt();
      await _loadQuestionsProgressive(); // NEW
      _error = null;
    } catch (err, stack) {
      _error = err.toString();
      debugPrint('Failed to initialize exam: $err');
      debugPrintStack(stackTrace: stack);
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadQuestionsProgressive() async {
    // Fetch all question IDs first (lightweight)
    final allQuestionIds = await _dataSource.fetchQuestionIds(
      examId: examId,
      courseId: courseId,
    );
    
    if (allQuestionIds.length > questionCount) {
      allQuestionIds.shuffle();
    }
    final selectedIds = allQuestionIds.take(questionCount).toList();
    
    // Load first batch immediately
    final initialIds = selectedIds.take(_initialBatchSize).toList();
    await _loadQuestionBatch(initialIds);
    
    // Load remaining in background
    final remainingIds = selectedIds.skip(_initialBatchSize).toList();
    _loadQuestionBatchBackground(remainingIds);
  }
  
  Future<void> _loadQuestionBatch(List<String> questionIds) async {
    final questionsData = await _dataSource.fetchQuestionsByIds(questionIds);
    final answerChoicesData = await _dataSource.fetchAnswerChoices(questionIds);
    final supportingTextsData = await _dataSource.fetchSupportingTexts(questionIds);
    
    _examQuestions.addAll(_buildExamQuestions(
      questionsData,
      answerChoicesData,
      supportingTextsData,
    ));
    
    notifyListeners();
  }
  
  Future<void> _loadQuestionBatchBackground(List<String> questionIds) async {
    _isLoadingMore = true;
    notifyListeners();
    
    // Load in smaller chunks
    const chunkSize = 5;
    for (var i = 0; i < questionIds.length; i += chunkSize) {
      final chunk = questionIds.skip(i).take(chunkSize).toList();
      await _loadQuestionBatch(chunk);
    }
    
    _isLoadingMore = false;
    notifyListeners();
  }
}
```

**Data Source Enhancement**:
```dart
abstract class ExamRemoteDataSource {
  // Add lightweight ID-only fetch
  Future<List<String>> fetchQuestionIds({
    required String examId,
    required String courseId,
  });
  
  // Add fetch by specific IDs
  Future<List<Map<String, dynamic>>> fetchQuestionsByIds(
    List<String> questionIds,
  );
  
  // ... existing methods
}

class SupabaseExamDataSource implements ExamRemoteDataSource {
  @override
  Future<List<String>> fetchQuestionIds({
    required String examId,
    required String courseId,
  }) async {
    final response = await _client
        .from('question')
        .select('id')
        .eq('id_course', courseId)
        .eq('is_active', true);
    
    return (response as List).map((r) => r['id'] as String).toList();
  }
  
  @override
  Future<List<Map<String, dynamic>>> fetchQuestionsByIds(
    List<String> questionIds,
  ) async {
    final response = await _client
        .from('question')
        .select('id, enunciation, difficulty_level, points, is_active, created_at, updated_at')
        .inFilter('id', questionIds);
    
    // ... normalization logic
    return mapped;
  }
}
```

#### 3.2 Prefetch on Config Screen
**Impact**: Medium | **Effort**: Medium | **Priority**: P2

**File**: `lib/views/QuizConfig_screen.dart:30-34`

```dart
class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String? _selectedQuantity;
  bool _isLoading = false;
  int _navBarIndex = 0;
  
  // ADD PREFETCH STATE
  bool _isPrefetching = false;
  Future<List<String>>? _prefetchedQuestionIds;

  void _onQuantitySelected(String quantity) {
    setState(() {
      _selectedQuantity = quantity;
    });
    
    // START PREFETCH
    _prefetchQuestions(int.parse(quantity));
  }
  
  Future<void> _prefetchQuestions(int count) async {
    if (!SupabaseOptions.isConfigured) return;
    
    setState(() {
      _isPrefetching = true;
    });
    
    try {
      final client = Supabase.instance.client;
      final courseId = 
        (widget.course['courseId'] ?? widget.course['id']) as String?;
      
      if (courseId == null) return;
      
      // Fetch question IDs in background
      _prefetchedQuestionIds = client
        .from('question')
        .select('id')
        .eq('id_course', courseId)
        .eq('is_active', true)
        .then((response) => 
          (response as List).map((r) => r['id'] as String).toList()
        );
      
      await _prefetchedQuestionIds; // Wait to complete
      
      debugPrint('Prefetched question IDs for $count questions');
    } catch (error) {
      debugPrint('Prefetch failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrefetching = false;
        });
      }
    }
  }
  
  void _startQuiz() async {
    // ... existing validation
    
    // Pass prefetched IDs to exam screen
    await Navigator.pushNamed(
      context,
      '/exam',
      arguments: {
        'userId': user.id,
        'examId': examId,
        'courseId': courseId,
        'questionCount': int.parse(_selectedQuantity!),
        'prefetchedQuestionIds': await _prefetchedQuestionIds, // NEW
      },
    );
  }
}
```

#### 3.3 Skeleton Screens
**Impact**: Low | **Effort**: Low | **Priority**: P3

**File**: `lib/ui/components/question_skeleton.dart` (NEW)

```dart
class QuestionSkeleton extends StatelessWidget {
  const QuestionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question title skeleton
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Enunciation skeleton
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          
          // Answer choices skeleton
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
```

Add `shimmer: ^3.0.0` to `pubspec.yaml`

---

### 4. Attempt Management Improvements

#### 4.1 Transactional Attempt Creation
**Impact**: Medium | **Effort**: Low | **Priority**: P1

**File**: `lib/viewmodels/exam_view_model.dart:38-51`

```dart
// CURRENT (PROBLEMATIC)
Future<void> initialize() async {
  _setLoading(true);
  try {
    await _createAttempt(); // ❌ Created before questions load
    await _loadQuestions();  // If this fails, attempt is orphaned
    _error = null;
  } catch (err, stack) {
    _error = err.toString();
    debugPrint('Failed to initialize exam: $err');
    debugPrintStack(stackTrace: stack);
  } finally {
    _setLoading(false);
  }
}

// ENHANCED (TRANSACTIONAL)
Future<void> initialize() async {
  _setLoading(true);
  try {
    // Load questions FIRST
    await _loadQuestions();
    
    // Only create attempt if questions loaded successfully
    await _createAttempt();
    
    _error = null;
  } catch (err, stack) {
    _error = err.toString();
    debugPrint('Failed to initialize exam: $err');
    debugPrintStack(stackTrace: stack);
    rethrow;
  } finally {
    _setLoading(false);
  }
}
```

#### 4.2 Attempt Status States
**Impact**: High | **Effort**: Medium | **Priority**: P1

**Schema Enhancement**: `supabase/migrations/20241102000003_add_attempt_status.sql`

```sql
-- Add status enum
CREATE TYPE attempt_status AS ENUM (
  'initializing',
  'in_progress',
  'paused',
  'completed',
  'abandoned'
);

-- Add status column to user_exam_attempts
ALTER TABLE user_exam_attempts 
  ADD COLUMN IF NOT EXISTS status_v2 attempt_status DEFAULT 'initializing';

-- Migrate existing data
UPDATE user_exam_attempts 
SET status_v2 = CASE 
  WHEN status = 'completed' THEN 'completed'::attempt_status
  WHEN status = 'in_progress' THEN 'in_progress'::attempt_status
  ELSE 'abandoned'::attempt_status
END;

-- Drop old status column and rename
ALTER TABLE user_exam_attempts DROP COLUMN status;
ALTER TABLE user_exam_attempts RENAME COLUMN status_v2 TO status;
```

#### 4.3 Auto-Save Progress
**Impact**: High | **Effort**: Medium | **Priority**: P1

**Schema Enhancement**: `supabase/migrations/20241102000004_add_attempt_snapshots.sql`

```sql
CREATE TABLE attempt_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id uuid NOT NULL REFERENCES user_exam_attempts(id) ON DELETE CASCADE,
  current_question_index integer NOT NULL,
  selected_answers jsonb NOT NULL DEFAULT '{}'::jsonb,
  flagged_questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  time_per_question jsonb NOT NULL DEFAULT '{}'::jsonb,
  saved_at timestamp without time zone NOT NULL DEFAULT NOW(),
  CONSTRAINT attempt_snapshots_attempt_id_key UNIQUE(attempt_id)
);

CREATE INDEX idx_attempt_snapshots_attempt ON attempt_snapshots(attempt_id);
```

**ViewModel Enhancement**:
```dart
class ExamViewModel extends ChangeNotifier {
  Timer? _autoSaveTimer;
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
  
  Future<void> initialize() async {
    // ... existing initialization
    
    // Start auto-save timer
    _startAutoSave();
  }
  
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveSnapshot(),
    );
  }
  
  Future<void> _saveSnapshot() async {
    if (_attemptId == null) return;
    
    try {
      await _dataSource.saveSnapshot(
        attemptId: _attemptId!,
        currentQuestionIndex: _currentQuestionIndex,
        selectedAnswers: _selectedAnswers,
        flaggedQuestions: _flaggedQuestions.toList(),
        timePerQuestion: _timePerQuestion,
      );
      
      debugPrint('Progress auto-saved');
    } catch (e) {
      debugPrint('Auto-save failed: $e');
      // Don't throw - silent failure is acceptable for auto-save
    }
  }
}
```

#### 4.4 Resume Incomplete Attempts
**Impact**: Medium | **Effort**: High | **Priority**: P2

**Detection Service**: `lib/services/attempt_resume_service.dart` (NEW)

```dart
class AttemptResumeService {
  final SupabaseClient _client;
  
  AttemptResumeService(this._client);
  
  /// Checks if user has incomplete attempt for this course
  Future<UserExamAttempt?> findIncompleteAttempt({
    required String userId,
    required String courseId,
  }) async {
    final response = await _client
        .from('user_exam_attempts')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .inFilter('status', ['initializing', 'in_progress', 'paused'])
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response == null) return null;
    
    return UserExamAttempt.fromJson(response);
  }
}
```

---

### 5. Code Architecture Refactoring

#### 5.1 Separate Repositories from ViewModels
**Impact**: High | **Effort**: High | **Priority**: P2

**Target Architecture**:
```
View (exam_screen.dart)
  ↓ observes
ViewModel (exam_view_model.dart) - UI state + business logic
  ↓ uses
Services (question_selection_service.dart, attempt_manager.dart)
  ↓ uses
Repositories (exam_repository.dart) - data access only
  ↓ uses
Data Sources (supabase_exam_data_source.dart) - raw API calls
```

**New Repository**: `lib/repositories/exam_repository.dart` (REFACTORED)

```dart
/// Pure data access layer - no business logic
abstract class ExamRepository {
  Future<List<Question>> fetchQuestions(String courseId);
  Future<List<String>> fetchQuestionIds(String courseId);
  Future<List<Question>> fetchQuestionsByIds(List<String> questionIds);
  Future<List<AnswerChoice>> fetchAnswerChoices(List<String> questionIds);
  Future<List<SupportingText>> fetchSupportingTexts(List<String> questionIds);
}

class SupabaseExamRepository implements ExamRepository {
  final SupabaseClient _client;
  
  SupabaseExamRepository(this._client);

  @override
  Future<List<Question>> fetchQuestions(String courseId) async {
    final response = await _client
        .from('question')
        .select('id, enunciation, difficulty_level, points, is_active, created_at, updated_at')
        .eq('id_course', courseId)
        .eq('is_active', true)
        .order('created_at');
    
    return (response as List)
        .map((json) => Question.fromJson(json))
        .toList();
  }
  
  // ... other methods
}
```

**New Service**: `lib/services/attempt_manager.dart` (NEW)

```dart
/// Manages exam attempt lifecycle
class AttemptManager {
  final SupabaseClient _client;
  
  AttemptManager(this._client);

  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  }) async {
    await _ensureUserRecord(userId);

    final response = await _client
        .from('user_exam_attempts')
        .insert({
          'user_id': userId,
          'exam_id': examId,
          'course_id': courseId,
          'question_count': questionCount,
          'started_at': DateTime.now().toIso8601String(),
          'status': 'in_progress',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> saveProgress({
    required String attemptId,
    required int currentQuestionIndex,
    required Map<String, String> selectedAnswers,
  }) async {
    await _client.from('attempt_snapshots').upsert({
      'attempt_id': attemptId,
      'current_question_index': currentQuestionIndex,
      'selected_answers': selectedAnswers,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> finalizeAttempt({
    required String attemptId,
    required double totalScore,
    required double percentageScore,
    required int durationSeconds,
  }) async {
    await _client.from('user_exam_attempts').update({
      'completed_at': DateTime.now().toIso8601String(),
      'duration_seconds': durationSeconds,
      'total_score': totalScore,
      'percentage_score': percentageScore,
      'status': 'completed',
    }).eq('id', attemptId);
  }

  Future<void> _ensureUserRecord(String userId) async {
    // ... existing implementation
  }
}
```

---

### 6. User Experience Enhancements

#### 6.1 Question Flagging
**Impact**: Medium | **Effort**: Low | **Priority**: P3

**ViewModel Enhancement**:
```dart
class ExamViewModel extends ChangeNotifier {
  final Set<String> _flaggedQuestions = {};
  
  Set<String> get flaggedQuestions => _flaggedQuestions;
  
  void toggleFlag(String questionId) {
    if (_flaggedQuestions.contains(questionId)) {
      _flaggedQuestions.remove(questionId);
    } else {
      _flaggedQuestions.add(questionId);
    }
    
    notifyListeners();
  }
  
  bool isFlagged(String questionId) => _flaggedQuestions.contains(questionId);
}
```

**UI Component**: `lib/views/exam_screen.dart`

```dart
// Add flag button in question area
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildQuestionTitle(currentQuestionIndex + 1),
    IconButton(
      icon: Icon(
        viewModel.isFlagged(currentExamQuestion.question.id)
            ? Icons.flag
            : Icons.flag_outlined,
        color: viewModel.isFlagged(currentExamQuestion.question.id)
            ? AppColors.orange
            : AppColors.primaryDark,
      ),
      onPressed: () {
        viewModel.toggleFlag(currentExamQuestion.question.id);
      },
      tooltip: 'Marcar para revisão',
    ),
  ],
),
```

#### 6.2 Time Warnings
**Impact**: Low | **Effort**: Low | **Priority**: P3

**ViewModel Enhancement**:
```dart
class ExamViewModel extends ChangeNotifier {
  Timer? _examTimer;
  int _elapsedSeconds = 0;
  int? _timeLimitSeconds;
  
  int get elapsedSeconds => _elapsedSeconds;
  int? get remainingSeconds => _timeLimitSeconds != null 
      ? _timeLimitSeconds! - _elapsedSeconds 
      : null;
  
  bool get isLowOnTime => remainingSeconds != null && remainingSeconds! < 300; // 5 min
  
  void _startExamTimer() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      
      if (remainingSeconds != null && remainingSeconds! <= 0) {
        _examTimer?.cancel();
        finalize(); // Auto-submit
      }
    });
  }
  
  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }
}
```

---

## Implementation Roadmap

### Phase 1: Quick Wins (Week 1-2)
**Goal**: Immediate performance improvements with minimal risk

| Task | Priority | Effort | Impact | Files |
|------|----------|--------|--------|-------|
| Add database indexes | P0 | 1h | High | `migrations/20241102000001_add_question_indexes.sql` |
| Add insufficient questions validation | P1 | 2h | Medium | `exam_view_model.dart`, `exceptions.dart` |
| Implement retry logic for network failures | P1 | 3h | Medium | `exam_view_model.dart` |
| Add error tracking | P1 | 2h | Low | `analytics_service.dart` |

**Success Criteria**:
- ✅ Query performance improvement measured (target: 50%+ faster)
- ✅ Zero crashes from insufficient questions
- ✅ Network failures auto-recover within 3 retries

---

### Phase 2: Core Enhancements (Week 3-5)
**Goal**: Balanced question selection and auto-save functionality

| Task | Priority | Effort | Impact | Files |
|------|----------|--------|--------|-------|
| Create QuestionSelectionService | P1 | 8h | High | `services/question_selection_service.dart` |
| Implement difficulty-based distribution | P1 | 6h | High | `question_selection_service.dart` |
| Add attempt status states | P1 | 4h | Medium | `migrations/...`, `models/user_exam_attempt.dart` |
| Implement auto-save progress | P1 | 12h | High | `migrations/...`, `attempt_manager.dart`, `exam_view_model.dart` |
| Progressive loading (first 3 questions) | P1 | 10h | High | `exam_view_model.dart`, `exam_screen.dart` |
| Unit tests for selection logic | P1 | 8h | High | `test/services/question_selection_service_test.dart` |

**Success Criteria**:
- ✅ All quizzes have 40/40/20 difficulty distribution
- ✅ Progress auto-saved every 30 seconds
- ✅ First 3 questions display within 2 seconds
- ✅ 90%+ test coverage for selection service

---

### Phase 3: Advanced Features (Week 6-9)
**Goal**: Resume capability and architecture refactoring

| Task | Priority | Effort | Impact | Files |
|------|----------|--------|--------|-------|
| Separate repositories from ViewModels | P2 | 16h | High | `repositories/exam_repository.dart`, `services/attempt_manager.dart` |
| Implement resume incomplete attempts | P2 | 12h | Medium | `services/attempt_resume_service.dart`, `quiz_config_screen.dart` |
| Add question history tracking | P2 | 10h | Medium | `migrations/...`, `services/question_history_service.dart` |
| Database-level randomization | P1 | 4h | Medium | `exam_view_model.dart` |
| Prefetch on config screen | P2 | 8h | Medium | `quiz_config_screen.dart`, `exam_view_model.dart` |
| Integration tests | P2 | 12h | High | `test/integration/exam_flow_test.dart` |

**Success Criteria**:
- ✅ Users can resume interrupted exams
- ✅ Architecture follows clean separation of concerns
- ✅ Question selection considers user history
- ✅ End-to-end tests pass reliably

---

### Phase 4: Polish (Week 10-12)
**Goal**: Enhanced UX and production readiness

| Task | Priority | Effort | Impact | Files |
|------|----------|--------|--------|-------|
| Question flagging for review | P3 | 6h | Medium | `exam_view_model.dart`, `exam_screen.dart` |
| Time warnings | P3 | 4h | Low | `exam_view_model.dart`, `exam_screen.dart` |
| Skeleton screens | P3 | 4h | Low | `ui/components/question_skeleton.dart` |
| Analytics integration | P3 | 6h | Low | `services/analytics_service.dart` |
| Offline support (basic caching) | P3 | 12h | Medium | TBD |

**Success Criteria**:
- ✅ Users can flag questions during exam
- ✅ Time warnings appear at 5 min and 1 min remaining
- ✅ Analytics tracking all key events
- ✅ Basic offline exam capability

---

## Success Metrics

### Performance Metrics
| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Question load time | ~3-5s | <2s | Time from initState to first question display |
| Progressive load (first 3) | N/A | <1s | Time to display first 3 questions |
| Database query time | ~1-2s | <500ms | Time for fetchQuestions() call |
| Auto-save latency | N/A | <100ms | Time to persist snapshot |

### Quality Metrics
| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Difficulty distribution | Random | 40/40/20 | % easy/medium/hard in selected questions |
| Question repetition rate | Unknown | <30% | % questions repeated within 5 attempts |
| Crash rate (insufficient questions) | Unknown | 0% | Crashes per 1000 quiz starts |
| Auto-save success rate | N/A | >99% | Successful saves / total attempts |

### User Experience Metrics
| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Quiz abandonment rate | Unknown | <20% | % users who start but don't finish |
| Resume adoption rate | N/A | >60% | % users who resume vs restart |
| Time-to-first-interaction | ~5s | <3s | Time from config to first answerable question |

---

## Appendix

### A. Database Schema Changes Summary

**New Tables**:
- `user_question_history` - Track user exposure and performance per question
- `attempt_snapshots` - Store progress snapshots for resume capability

**Modified Tables**:
- `user_exam_attempts` - Add `status` enum column

**New Indexes**:
- `idx_question_course_active_created` on `question(id_course, is_active, created_at)`
- `idx_answerchoice_question` on `answerchoice(idquestion)`
- `idx_supportingtext_question` on `supportingtext(id_question)`
- `idx_user_question_history_user` on `user_question_history(user_id)`
- `idx_attempt_snapshots_attempt` on `attempt_snapshots(attempt_id)`

### B. File Structure Changes

**New Files**:
```
lib/
  services/
    question_selection_service.dart
    attempt_manager.dart
    attempt_resume_service.dart
    question_history_service.dart
    analytics_service.dart
  repositories/
    exam_repository.dart (refactored from view_model)
  models/
    exceptions.dart
    attempt_snapshot.dart
  ui/
    components/
      question_skeleton.dart

test/
  services/
    question_selection_service_test.dart
  integration/
    exam_flow_test.dart

supabase/migrations/
  20241102000001_add_question_indexes.sql
  20241102000002_add_question_history.sql
  20241102000003_add_attempt_status.sql
  20241102000004_add_attempt_snapshots.sql
```

### C. Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  shimmer: ^3.0.0  # For skeleton screens
  
dev_dependencies:
  mocktail: ^1.0.0  # For mocking in tests
  integration_test:  # For integration tests
    sdk: flutter
```

---

## Conclusion

This roadmap provides a comprehensive plan for enhancing the quiz mounting process from initial loading to advanced features like resume capability and adaptive question selection. The phased approach ensures stability while delivering incremental value.

**Estimated Total Effort**: ~160 hours (4-6 weeks with 1-2 developers)

**Priority Summary**:
- **P0 (Must Have)**: Database indexes, validation - 3 hours
- **P1 (Should Have)**: Selection service, auto-save, progressive loading - 48 hours
- **P2 (Nice to Have)**: Architecture refactor, resume, history - 62 hours
- **P3 (Optional)**: Polish features - 40 hours

**Next Steps**:
1. Review and approve roadmap with stakeholders
2. Set up feature flag infrastructure
3. Create detailed tickets for Phase 1 tasks
4. Begin with database indexes and validation (quick wins)

---

*Document maintained by: Development Team*  
*Review schedule: After each phase completion*  
*Feedback: Submit issues to project repository*
