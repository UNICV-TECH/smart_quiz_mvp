import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/quiz_config_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/exam_view_model.dart';
import 'package:unicv_tech_mvp/models/course.dart';

class FakeExamDataSource implements ExamRemoteDataSource {
  FakeExamDataSource({
    required this.attemptId,
    List<Map<String, dynamic>>? questions,
    List<Map<String, dynamic>>? answerChoices,
    List<Map<String, dynamic>>? supportingTexts,
  })  : questions = questions ?? <Map<String, dynamic>>[],
        answerChoices = answerChoices ?? <Map<String, dynamic>>[],
        supportingTexts = supportingTexts ?? <Map<String, dynamic>>[];

  final String attemptId;
  List<Map<String, dynamic>> questions;
  List<Map<String, dynamic>> answerChoices;
  List<Map<String, dynamic>> supportingTexts;

  bool throwOnCreate = false;
  bool throwOnFetchQuestions = false;
  bool throwOnInsert = false;
  bool throwOnUpdate = false;

  Map<String, dynamic>? lastCreatePayload;
  List<Map<String, dynamic>> insertedResponses = [];
  Map<String, dynamic>? lastUpdatePayload;

  @override
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  }) async {
    if (throwOnCreate) {
      throw Exception('Database error');
    }

    lastCreatePayload = {
      'user_id': userId,
      'exam_id': examId,
      'course_id': courseId,
      'question_count': questionCount,
      'started_at': startedAt,
    };
    return attemptId;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions({
    required String examId,
    required String courseId,
  }) async {
    if (throwOnFetchQuestions) {
      throw Exception('Query failed');
    }
    return questions.map((q) => Map<String, dynamic>.from(q)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  ) async {
    return answerChoices
        .where((choice) => questionIds.contains(choice['question_id']))
        .map((choice) => Map<String, dynamic>.from(choice))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  ) async {
    return supportingTexts
        .where((text) => questionIds.contains(text['question_id']))
        .map((text) => Map<String, dynamic>.from(text))
        .toList();
  }

  @override
  Future<void> insertResponses(List<Map<String, dynamic>> responses) async {
    if (throwOnInsert) {
      throw Exception('Insert failed');
    }
    insertedResponses =
        responses.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  @override
  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  ) async {
    if (throwOnUpdate) {
      throw Exception('Update failed');
    }
    lastUpdatePayload = Map<String, dynamic>.from(updates);
  }
}

void main() {
  group('Complete Flow Integration Tests', () {
    group('Course Selection Flow', () {
      CourseSelectionViewModel createViewModel() =>
          CourseSelectionViewModel(loadDelay: Duration.zero);

      test('should load courses successfully', () async {
        final viewModel = createViewModel();

        expect(viewModel.isLoading, false);
        expect(viewModel.courses, isEmpty);

        await viewModel.loadCourses();

        expect(viewModel.isLoading, false);
        expect(viewModel.courses, isNotEmpty);
        expect(viewModel.courses.length, 8);
        expect(viewModel.errorMessage, isNull);
      });

      test('should select course and maintain selection state', () async {
        final viewModel = createViewModel();
        await viewModel.loadCourses();

        final course = viewModel.courses.first;
        viewModel.selectCourse(course.id);

        expect(viewModel.selectedCourseId, course.id);
        expect(viewModel.hasSelection, true);
        expect(viewModel.selectedCourse, isNotNull);
        expect(viewModel.selectedCourse!.id, course.id);
      });

      test('should handle course selection state changes correctly', () async {
        final viewModel = createViewModel();
        await viewModel.loadCourses();

        final course1 = viewModel.courses[0];
        final course2 = viewModel.courses[1];

        viewModel.selectCourse(course1.id);
        expect(viewModel.selectedCourseId, course1.id);

        viewModel.selectCourse(course2.id);
        expect(viewModel.selectedCourseId, course2.id);

        viewModel.clearSelection();
        expect(viewModel.selectedCourseId, isNull);
        expect(viewModel.hasSelection, false);
      });

      test('should handle loading state correctly', () async {
        final viewModel = CourseSelectionViewModel(
          loadDelay: const Duration(milliseconds: 1),
        );

        expect(viewModel.isLoading, false);

        final loadFuture = viewModel.loadCourses();
        expect(viewModel.isLoading, true);

        await loadFuture;
        expect(viewModel.isLoading, false);
      });

      test('should clear error message when selecting course', () async {
        final viewModel = createViewModel();
        await viewModel.loadCourses();

        viewModel.setError('Test error');
        expect(viewModel.errorMessage, isNotNull);

        viewModel.selectCourse(viewModel.courses.first.id);
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('Quiz Config Flow', () {
      late Course testCourse;
      late QuizConfigViewModel viewModel;

      setUp(() {
        testCourse = Course(
          id: 'test_course',
          courseKey: 'test',
          title: 'Test Course',
          iconKey: 'school_outlined',
          createdAt: DateTime.now(),
        );
        viewModel = QuizConfigViewModel(
          course: testCourse,
          metadataDelay: Duration.zero,
          startDelay: Duration.zero,
        );
      });

      test('should load exam metadata successfully', () async {
        expect(viewModel.isLoading, false);
        expect(viewModel.exam, isNull);

        await viewModel.loadExamMetadata();

        expect(viewModel.isLoading, false);
        expect(viewModel.exam, isNotNull);
        expect(viewModel.exam!.courseId, testCourse.id);
        expect(viewModel.errorMessage, isNull);
      });

      test('should handle question quantity selection', () {
        expect(viewModel.selectedQuantity, isNull);
        expect(viewModel.canStartQuiz, false);

        viewModel.selectQuantity('10');
        expect(viewModel.selectedQuantity, '10');
        expect(viewModel.canStartQuiz, false);

        viewModel.selectQuantity('15');
        expect(viewModel.selectedQuantity, '15');

        viewModel.clearSelection();
        expect(viewModel.selectedQuantity, isNull);
      });

      test('should enable quiz start only when exam loaded and quantity selected', () async {
        expect(viewModel.canStartQuiz, false);

        viewModel.selectQuantity('10');
        expect(viewModel.canStartQuiz, false);

        await viewModel.loadExamMetadata();
        expect(viewModel.canStartQuiz, true);
      });

      test('should start quiz with correct parameters', () async {
        await viewModel.loadExamMetadata();
        viewModel.selectQuantity('15');

        final result = await viewModel.startQuiz();

        expect(result, isNotNull);
        expect(result!['exam'], isNotNull);
        expect(result['questionCount'], 15);
        expect(result['course'].id, testCourse.id);
        expect(viewModel.successMessage, contains('15 questões'));
      });

      test('should handle loading state during exam metadata fetch', () async {
        final delayedViewModel = QuizConfigViewModel(
          course: testCourse,
          metadataDelay: const Duration(milliseconds: 1),
          startDelay: Duration.zero,
        );

        expect(delayedViewModel.isLoading, false);
        
        final loadFuture = delayedViewModel.loadExamMetadata();
        expect(delayedViewModel.isLoading, true);
        
        await loadFuture;
        expect(delayedViewModel.isLoading, false);
      });

      test('should clear feedback when selecting quantity', () async {
        await viewModel.loadExamMetadata();
        viewModel.selectQuantity('10');

        viewModel.setError('Test error');
        expect(viewModel.errorMessage, isNotNull);

        viewModel.selectQuantity('15');
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('Exam Screen Flow - Supabase Operations', () {
      const testUserId = 'test-user-123';
      const testExamId = 'test-exam-456';
      const testCourseId = 'test-course-789';
      const testQuestionCount = 5;

      ExamViewModel buildViewModel(
        FakeExamDataSource dataSource, {
        int questionCount = testQuestionCount,
      }) {
        return ExamViewModel(
          userId: testUserId,
          examId: testExamId,
          courseId: testCourseId,
          questionCount: questionCount,
          dataSource: dataSource,
        );
      }

      test('should create user_exam_attempts with correct data', () async {
        const attemptId = 'attempt-123';
        final dataSource = FakeExamDataSource(attemptId: attemptId);
        final examViewModel = buildViewModel(dataSource);

        await examViewModel.initialize();

        expect(examViewModel.attemptId, attemptId);
        final payload = dataSource.lastCreatePayload;
        expect(payload, isNotNull);
        expect(payload!['user_id'], testUserId);
        expect(payload['exam_id'], testExamId);
        expect(payload['course_id'], testCourseId);
        expect(payload['question_count'], testQuestionCount);
        expect(payload['started_at'], isA<DateTime>());
      });

      test('should load questions with answer choices and supporting texts', () async {
        final dataSource = FakeExamDataSource(
          attemptId: 'attempt-123',
          questions: [
            {
              'id': 'q1',
              'enunciation': 'Question 1?',
              'difficulty_level': 'medium',
              'points': 1.0,
            },
            {
              'id': 'q2',
              'enunciation': 'Question 2?',
              'difficulty_level': 'hard',
              'points': 2.0,
            },
          ],
          answerChoices: [
            {
              'id': 'ac1',
              'question_id': 'q1',
              'choice_key': 'A',
              'choice_text': 'Answer A',
              'is_correct': true,
              'choice_order': 1,
            },
            {
              'id': 'ac2',
              'question_id': 'q1',
              'choice_key': 'B',
              'choice_text': 'Answer B',
              'is_correct': false,
              'choice_order': 2,
            },
            {
              'id': 'ac3',
              'question_id': 'q2',
              'choice_key': 'A',
              'choice_text': 'Answer A for Q2',
              'is_correct': false,
              'choice_order': 1,
            },
          ],
          supportingTexts: [
            {
              'id': 'st1',
              'question_id': 'q1',
              'content': 'Supporting text for Q1',
              'content_type': 'text',
              'display_order': 1,
            },
          ],
        );

        final examViewModel = buildViewModel(dataSource, questionCount: 2);

        await examViewModel.initialize();

        expect(examViewModel.examQuestions.length, 2);
        expect(examViewModel.examQuestions[0].answerChoices.length, 2);
        expect(examViewModel.examQuestions[0].supportingTexts.length, 1);
        expect(examViewModel.examQuestions[1].answerChoices.length, 1);
        expect(examViewModel.error, isNull);
      });

      test('should handle answer selection correctly', () async {
        final dataSource = FakeExamDataSource(
          attemptId: 'attempt-123',
          questions: [
            {
              'id': 'q1',
              'enunciation': 'Question 1?',
              'difficulty_level': 'medium',
              'points': 1.0,
            },
          ],
        );
        final examViewModel = buildViewModel(dataSource, questionCount: 1);

        await examViewModel.initialize();

        expect(examViewModel.selectedAnswers, isEmpty);

        examViewModel.selectAnswer('q1', 'A');
        expect(examViewModel.selectedAnswers['q1'], 'A');

        examViewModel.selectAnswer('q1', 'B');
        expect(examViewModel.selectedAnswers['q1'], 'B');
      });

      test('should submit user_responses in batch and calculate score', () async {
        final dataSource = FakeExamDataSource(
          attemptId: 'attempt-123',
          questions: [
            {
              'id': 'q1',
              'enunciation': 'Question 1?',
              'difficulty_level': 'medium',
              'points': 1.0,
            },
            {
              'id': 'q2',
              'enunciation': 'Question 2?',
              'difficulty_level': 'hard',
              'points': 2.0,
            },
          ],
          answerChoices: [
            {
              'id': 'ac1',
              'question_id': 'q1',
              'choice_key': 'A',
              'choice_text': 'Answer A',
              'is_correct': true,
              'choice_order': 1,
            },
            {
              'id': 'ac2',
              'question_id': 'q2',
              'choice_key': 'A',
              'choice_text': 'Answer A for Q2',
              'is_correct': true,
              'choice_order': 1,
            },
          ],
        );
        final examViewModel = buildViewModel(dataSource, questionCount: 2);

        await examViewModel.initialize();

        examViewModel.selectAnswer('q1', 'A'); // Correct - 1 point
        examViewModel.selectAnswer('q2', 'A'); // Correct - 2 points

        final results = await examViewModel.finalize();

        expect(results['totalQuestions'], 2);
        expect(results['correctCount'], 2);
        expect(results['totalScore'], 3.0);
        expect(results['percentageScore'], 100.0);

        expect(dataSource.insertedResponses.length, 2);
        final submittedIds = dataSource.insertedResponses
            .map((response) => response['question_id'])
            .toSet();
        expect(submittedIds, {'q1', 'q2'});

        final update = dataSource.lastUpdatePayload;
        expect(update, isNotNull);
        expect(update!['status'], 'completed');
        expect(update['total_score'], 3.0);
        expect(update['percentage_score'], 100.0);
      });

      test('should update user_exam_attempts with timestamps and score on completion', () async {
        final dataSource = FakeExamDataSource(
          attemptId: 'attempt-123',
          questions: [
            {
              'id': 'q1',
              'enunciation': 'Question 1?',
              'difficulty_level': 'medium',
              'points': 1.0,
            },
          ],
          answerChoices: [
            {
              'id': 'ac1',
              'question_id': 'q1',
              'choice_key': 'A',
              'choice_text': 'Answer A',
              'is_correct': false,
              'choice_order': 1,
            },
          ],
        );
        final examViewModel = buildViewModel(dataSource, questionCount: 1);

        await examViewModel.initialize();
        examViewModel.selectAnswer('q1', 'A');

        final results = await examViewModel.finalize();

        expect(results['correctCount'], 0);
        expect(results['totalScore'], 0.0);

        final update = dataSource.lastUpdatePayload;
        expect(update, isNotNull);
        expect(update!['completed_at'], isNotNull);
        expect(update['duration_seconds'], isA<int>());
        expect(update['total_score'], 0.0);
        expect(update['percentage_score'], 0.0);
        expect(update['status'], 'completed');
      });
    });

    group('Error Handling Tests', () {
      test('CourseSelectionViewModel - should handle error state', () async {
        final viewModel =
            CourseSelectionViewModel(loadDelay: Duration.zero);

        viewModel.setError('Network error');

        expect(viewModel.errorMessage, 'Network error');
        expect(viewModel.isLoading, false);

        viewModel.clearError();
        expect(viewModel.errorMessage, isNull);
      });

      test('QuizConfigViewModel - should handle exam metadata load error', () async {
        final course = Course(
          id: 'test',
          courseKey: 'test',
          title: 'Test',
          iconKey: 'school_outlined',
          createdAt: DateTime.now(),
        );
        final viewModel = QuizConfigViewModel(
          course: course,
          metadataDelay: Duration.zero,
          startDelay: Duration.zero,
        );

        viewModel.setError('Failed to load exam');

        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.canStartQuiz, false);
      });

      test('ExamViewModel - should handle initialization error', () async {
        final dataSource = FakeExamDataSource(attemptId: 'attempt-123')
          ..throwOnCreate = true;
        final examViewModel = ExamViewModel(
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
          dataSource: dataSource,
        );

        await examViewModel.initialize();

        expect(examViewModel.error, isNotNull);
        expect(examViewModel.error, contains('Exception'));
        expect(examViewModel.examQuestions, isEmpty);
      });

      test('ExamViewModel - should handle question loading error', () async {
        final dataSource = FakeExamDataSource(attemptId: 'attempt-123')
          ..throwOnFetchQuestions = true;
        final examViewModel = ExamViewModel(
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
          dataSource: dataSource,
        );

        await examViewModel.initialize();

        expect(examViewModel.error, isNotNull);
        expect(examViewModel.examQuestions, isEmpty);
      });

      test('ExamViewModel - should handle finalization error when no attempt ID', () async {
        final examViewModel = ExamViewModel(
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
          dataSource: FakeExamDataSource(attemptId: 'attempt-123'),
        );

        expect(() => examViewModel.finalize(), throwsException);
      });
    });

    group('State Management Tests', () {
      test('CourseSelectionViewModel - notifies listeners on state changes', () async {
        final viewModel =
            CourseSelectionViewModel(loadDelay: Duration.zero);
        var notificationCount = 0;

        viewModel.addListener(() {
          notificationCount++;
        });

        await viewModel.loadCourses();
        expect(notificationCount, greaterThan(0));

        final previousCount = notificationCount;
        viewModel.selectCourse(viewModel.courses.first.id);
        expect(notificationCount, greaterThan(previousCount));
      });

      test('QuizConfigViewModel - notifies listeners on state changes', () async {
        final course = Course(
          id: 'test',
          courseKey: 'test',
          title: 'Test',
          iconKey: 'school_outlined',
          createdAt: DateTime.now(),
        );
        final viewModel = QuizConfigViewModel(
          course: course,
          metadataDelay: Duration.zero,
          startDelay: Duration.zero,
        );
        var notificationCount = 0;

        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.selectQuantity('10');
        expect(notificationCount, greaterThan(0));

        final previousCount = notificationCount;
        await viewModel.loadExamMetadata();
        expect(notificationCount, greaterThan(previousCount));
      });

      test('ExamViewModel - notifies listeners on answer selection', () {
        final examViewModel = ExamViewModel(
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
          dataSource: FakeExamDataSource(attemptId: 'attempt-123'),
        );

        var notificationCount = 0;
        examViewModel.addListener(() {
          notificationCount++;
        });

        examViewModel.selectAnswer('q1', 'A');
        expect(notificationCount, 1);

        examViewModel.selectAnswer('q2', 'B');
        expect(notificationCount, 2);
      });
    });

    group('Data Flow Validation Tests', () {
      test('should pass course data from HomeScreen to QuizConfig', () async {
        final viewModel =
            CourseSelectionViewModel(loadDelay: Duration.zero);
        await viewModel.loadCourses();

        final selectedCourse = viewModel.courses.first;
        viewModel.selectCourse(selectedCourse.id);

        expect(viewModel.selectedCourse, isNotNull);
        expect(viewModel.selectedCourse!.id, selectedCourse.id);
        expect(viewModel.selectedCourse!.title, selectedCourse.title);
      });

      test('should pass exam config from QuizConfig to ExamScreen', () async {
        final course = Course(
          id: 'test-course',
          courseKey: 'test',
          title: 'Test Course',
          iconKey: 'school_outlined',
          createdAt: DateTime.now(),
        );
        final quizConfigVM = QuizConfigViewModel(
          course: course,
          metadataDelay: Duration.zero,
          startDelay: Duration.zero,
        );

        await quizConfigVM.loadExamMetadata();
        quizConfigVM.selectQuantity('15');

        final result = await quizConfigVM.startQuiz();

        expect(result, isNotNull);
        expect(result!['questionCount'], 15);
        expect(result['exam'], isNotNull);
        expect(result['course'].id, course.id);
      });

      test('should maintain answer state throughout exam session', () {
        final examViewModel = ExamViewModel(
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
          dataSource: FakeExamDataSource(attemptId: 'attempt-123'),
        );

        examViewModel.selectAnswer('q1', 'A');
        examViewModel.selectAnswer('q2', 'B');
        examViewModel.selectAnswer('q3', 'C');

        expect(examViewModel.selectedAnswers.length, 3);
        expect(examViewModel.selectedAnswers['q1'], 'A');
        expect(examViewModel.selectedAnswers['q2'], 'B');
        expect(examViewModel.selectedAnswers['q3'], 'C');

        examViewModel.selectAnswer('q1', 'D');
        expect(examViewModel.selectedAnswers['q1'], 'D');
        expect(examViewModel.selectedAnswers.length, 3);
      });
    });
  });
}
