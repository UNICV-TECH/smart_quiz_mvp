import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/quiz_config_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/exam_view_model.dart';
import 'package:unicv_tech_mvp/models/course.dart';
import 'package:unicv_tech_mvp/models/exam.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'integration_test.mocks.dart';

void main() {
  group('Complete Flow Integration Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
    });

    group('Course Selection Flow', () {
      test('should load courses successfully', () async {
        final viewModel = CourseSelectionViewModel();

        expect(viewModel.isLoading, false);
        expect(viewModel.courses, isEmpty);

        await viewModel.loadCourses();

        expect(viewModel.isLoading, false);
        expect(viewModel.courses, isNotEmpty);
        expect(viewModel.courses.length, 8);
        expect(viewModel.errorMessage, isNull);
      });

      test('should select course and maintain selection state', () async {
        final viewModel = CourseSelectionViewModel();
        await viewModel.loadCourses();

        final course = viewModel.courses.first;
        viewModel.selectCourse(course.id);

        expect(viewModel.selectedCourseId, course.id);
        expect(viewModel.hasSelection, true);
        expect(viewModel.selectedCourse, isNotNull);
        expect(viewModel.selectedCourse!.id, course.id);
      });

      test('should handle course selection state changes correctly', () async {
        final viewModel = CourseSelectionViewModel();
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
        final viewModel = CourseSelectionViewModel();
        
        expect(viewModel.isLoading, false);
        
        final loadFuture = viewModel.loadCourses();
        expect(viewModel.isLoading, true);
        
        await loadFuture;
        expect(viewModel.isLoading, false);
      });

      test('should clear error message when selecting course', () async {
        final viewModel = CourseSelectionViewModel();
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
        viewModel = QuizConfigViewModel(course: testCourse);
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
        expect(viewModel.canStartQuiz, false); // Still false because exam not loaded

        viewModel.selectQuantity('15');
        expect(viewModel.selectedQuantity, '15');

        viewModel.clearSelection();
        expect(viewModel.selectedQuantity, isNull);
      });

      test('should enable quiz start only when exam loaded and quantity selected', () async {
        expect(viewModel.canStartQuiz, false);

        viewModel.selectQuantity('10');
        expect(viewModel.canStartQuiz, false); // No exam loaded

        await viewModel.loadExamMetadata();
        expect(viewModel.canStartQuiz, true); // Both conditions met
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
        expect(viewModel.isLoading, false);
        
        final loadFuture = viewModel.loadExamMetadata();
        expect(viewModel.isLoading, true);
        
        await loadFuture;
        expect(viewModel.isLoading, false);
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
      late ExamViewModel examViewModel;
      const testUserId = 'test-user-123';
      const testExamId = 'test-exam-456';
      const testCourseId = 'test-course-789';
      const testQuestionCount = 5;

      setUp(() {
        mockSupabase = MockSupabaseClient();
        mockQueryBuilder = MockSupabaseQueryBuilder();
        mockFilterBuilder = MockPostgrestFilterBuilder();

        examViewModel = ExamViewModel(
          supabase: mockSupabase,
          userId: testUserId,
          examId: testExamId,
          courseId: testCourseId,
          questionCount: testQuestionCount,
        );
      });

      test('should create user_exam_attempts with correct data', () async {
        final attemptId = 'attempt-123';
        final attemptResponse = {
          'id': attemptId,
          'user_id': testUserId,
          'exam_id': testExamId,
          'course_id': testCourseId,
          'question_count': testQuestionCount,
          'status': 'in_progress',
        };

        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => attemptResponse);

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.execute()).thenAnswer((_) async => []);

        when(mockSupabase.from('answer_choices')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order(any)).thenReturn(mockQueryBuilder);

        when(mockSupabase.from('supporting_texts')).thenReturn(mockQueryBuilder);

        await examViewModel.initialize();

        expect(examViewModel.attemptId, attemptId);
        verify(mockSupabase.from('user_exam_attempts')).called(1);
        verify(mockQueryBuilder.insert(argThat(allOf([
          containsPair('user_id', testUserId),
          containsPair('exam_id', testExamId),
          containsPair('course_id', testCourseId),
          containsPair('question_count', testQuestionCount),
          containsPair('status', 'in_progress'),
          contains('started_at'),
        ])))).called(1);
      });

      test('should load questions with answer choices and supporting texts', () async {
        final attemptId = 'attempt-123';
        final questionsData = [
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
        ];

        final answerChoicesData = [
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
        ];

        final supportingTextsData = [
          {
            'id': 'st1',
            'question_id': 'q1',
            'content': 'Supporting text for Q1',
            'content_type': 'text',
            'display_order': 1,
          },
        ];

        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': attemptId});

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('exam_id', testExamId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenAnswer((_) async => questionsData);

        when(mockSupabase.from('answer_choices')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter('question_id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('choice_order')).thenAnswer((_) async => answerChoicesData);

        when(mockSupabase.from('supporting_texts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter('question_id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('display_order')).thenAnswer((_) async => supportingTextsData);

        await examViewModel.initialize();

        expect(examViewModel.examQuestions.length, 2);
        expect(examViewModel.examQuestions[0].answerChoices.length, 2);
        expect(examViewModel.examQuestions[0].supportingTexts.length, 1);
        expect(examViewModel.examQuestions[1].answerChoices.length, 1);
        expect(examViewModel.error, isNull);
      });

      test('should handle answer selection correctly', () async {
        final attemptId = 'attempt-123';
        final questionsData = [
          {
            'id': 'q1',
            'enunciation': 'Question 1?',
            'difficulty_level': 'medium',
            'points': 1.0,
          },
        ];

        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': attemptId});

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('exam_id', testExamId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenAnswer((_) async => questionsData);

        when(mockSupabase.from('answer_choices')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order(any)).thenAnswer((_) async => []);

        when(mockSupabase.from('supporting_texts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order(any)).thenAnswer((_) async => []);

        await examViewModel.initialize();

        expect(examViewModel.selectedAnswers, isEmpty);

        examViewModel.selectAnswer('q1', 'A');
        expect(examViewModel.selectedAnswers['q1'], 'A');

        examViewModel.selectAnswer('q1', 'B');
        expect(examViewModel.selectedAnswers['q1'], 'B');
      });

      test('should submit user_responses in batch and calculate score', () async {
        final attemptId = 'attempt-123';
        final questionsData = [
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
        ];

        final answerChoicesData = [
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
            'is_correct': true,
            'choice_order': 1,
          },
        ];

        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': attemptId});
        when(mockQueryBuilder.update(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('exam_id', testExamId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenAnswer((_) async => questionsData);

        when(mockSupabase.from('answer_choices')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter('question_id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('choice_order')).thenAnswer((_) async => answerChoicesData);

        when(mockSupabase.from('supporting_texts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter('question_id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('display_order')).thenAnswer((_) async => []);

        when(mockSupabase.from('user_responses')).thenReturn(mockQueryBuilder);

        await examViewModel.initialize();

        examViewModel.selectAnswer('q1', 'A'); // Correct - 1 point
        examViewModel.selectAnswer('q2', 'A'); // Correct - 2 points

        final results = await examViewModel.finalize();

        expect(results['totalQuestions'], 2);
        expect(results['correctCount'], 2);
        expect(results['totalScore'], 3.0);
        expect(results['percentageScore'], 100.0);

        verify(mockSupabase.from('user_responses')).called(1);
        verify(mockQueryBuilder.insert(argThat(isA<List>()))).called(1);
        
        verify(mockQueryBuilder.update(argThat(allOf([
          containsPair('status', 'completed'),
          contains('completed_at'),
          contains('duration_seconds'),
          containsPair('total_score', 3.0),
          containsPair('percentage_score', 100.0),
        ])))).called(1);
      });

      test('should update user_exam_attempts with timestamps and score on completion', () async {
        final attemptId = 'attempt-123';
        final questionsData = [
          {
            'id': 'q1',
            'enunciation': 'Question 1?',
            'difficulty_level': 'medium',
            'points': 1.0,
          },
        ];

        final answerChoicesData = [
          {
            'id': 'ac1',
            'question_id': 'q1',
            'choice_key': 'A',
            'choice_text': 'Answer A',
            'is_correct': false,
            'choice_order': 1,
          },
        ];

        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': attemptId});
        when(mockQueryBuilder.update(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('exam_id', testExamId)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('is_active', true)).thenAnswer((_) async => questionsData);

        when(mockSupabase.from('answer_choices')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order(any)).thenAnswer((_) async => answerChoicesData);

        when(mockSupabase.from('supporting_texts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.inFilter(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order(any)).thenAnswer((_) async => []);

        when(mockSupabase.from('user_responses')).thenReturn(mockQueryBuilder);

        await examViewModel.initialize();
        examViewModel.selectAnswer('q1', 'A');

        final results = await examViewModel.finalize();

        expect(results['correctCount'], 0);
        expect(results['totalScore'], 0.0);

        final capturedUpdate = verify(mockQueryBuilder.update(captureAny)).captured[0];
        expect(capturedUpdate['completed_at'], isNotNull);
        expect(capturedUpdate['duration_seconds'], isA<int>());
        expect(capturedUpdate['total_score'], 0.0);
        expect(capturedUpdate['percentage_score'], 0.0);
        expect(capturedUpdate['status'], 'completed');
      });
    });

    group('Error Handling Tests', () {
      test('CourseSelectionViewModel - should handle error state', () async {
        final viewModel = CourseSelectionViewModel();
        
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
        final viewModel = QuizConfigViewModel(course: course);

        viewModel.setError('Failed to load exam');
        
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.canStartQuiz, false);
      });

      test('ExamViewModel - should handle initialization error', () async {
        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenThrow(Exception('Database error'));

        final examViewModel = ExamViewModel(
          supabase: mockSupabase,
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
        );

        await examViewModel.initialize();

        expect(examViewModel.error, isNotNull);
        expect(examViewModel.error, contains('Exception'));
        expect(examViewModel.examQuestions, isEmpty);
      });

      test('ExamViewModel - should handle question loading error', () async {
        when(mockSupabase.from('user_exam_attempts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': 'attempt-123'});

        when(mockSupabase.from('questions')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenThrow(Exception('Query failed'));

        final examViewModel = ExamViewModel(
          supabase: mockSupabase,
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
        );

        await examViewModel.initialize();

        expect(examViewModel.error, isNotNull);
        expect(examViewModel.examQuestions, isEmpty);
      });

      test('ExamViewModel - should handle finalization error when no attempt ID', () async {
        final examViewModel = ExamViewModel(
          supabase: mockSupabase,
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
        );

        expect(() => examViewModel.finalize(), throwsException);
      });
    });

    group('State Management Tests', () {
      test('CourseSelectionViewModel - notifies listeners on state changes', () async {
        final viewModel = CourseSelectionViewModel();
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
        final viewModel = QuizConfigViewModel(course: course);
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
          supabase: mockSupabase,
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
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
        final viewModel = CourseSelectionViewModel();
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
        final quizConfigVM = QuizConfigViewModel(course: course);
        
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
          supabase: mockSupabase,
          userId: 'test-user',
          examId: 'test-exam',
          courseId: 'test-course',
          questionCount: 5,
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
