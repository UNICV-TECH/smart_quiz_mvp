import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/quiz_config_view_model.dart';
import 'package:unicv_tech_mvp/models/course.dart';

void main() {
  group('CourseSelectionViewModel Tests', () {
    test('should load courses successfully', () async {
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);

      expect(viewModel.isLoading, false);
      expect(viewModel.courses, isEmpty);

      await viewModel.loadCourses();

      expect(viewModel.isLoading, false);
      expect(viewModel.courses, isNotEmpty);
      expect(viewModel.courses.length, 8);
      expect(viewModel.errorMessage, isNull);
    });

    test('should select course and maintain selection state', () async {
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);
      await viewModel.loadCourses();

      final course = viewModel.courses.first;
      viewModel.selectCourse(course.id);

      expect(viewModel.selectedCourseId, course.id);
      expect(viewModel.hasSelection, true);
      expect(viewModel.selectedCourse, isNotNull);
      expect(viewModel.selectedCourse!.id, course.id);
    });

    test('should handle course selection state changes correctly', () async {
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);
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
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);
      await viewModel.loadCourses();

      viewModel.setError('Test error');
      expect(viewModel.errorMessage, isNotNull);

      viewModel.selectCourse(viewModel.courses.first.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('should handle error state', () async {
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);
      
      viewModel.setError('Network error');
      
      expect(viewModel.errorMessage, 'Network error');
      expect(viewModel.isLoading, false);
      
      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
    });

    test('should notify listeners on state changes', () async {
      final viewModel = CourseSelectionViewModel(loadDelay: Duration.zero);
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
  });

  group('QuizConfigViewModel Tests', () {
    late Course testCourse;

    setUp(() {
      testCourse = Course(
        id: 'test_course',
        courseKey: 'test',
        title: 'Test Course',
        iconKey: 'school_outlined',
        createdAt: DateTime.now(),
      );
    });

    test('should load exam metadata successfully', () async {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.exam, isNull);

      await viewModel.loadExamMetadata();

      expect(viewModel.isLoading, false);
      expect(viewModel.exam, isNotNull);
      expect(viewModel.exam!.courseId, testCourse.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('should handle question quantity selection', () {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

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
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      expect(viewModel.canStartQuiz, false);

      viewModel.selectQuantity('10');
      expect(viewModel.canStartQuiz, false);

      await viewModel.loadExamMetadata();
      expect(viewModel.canStartQuiz, true);
    });

    test('should start quiz with correct parameters', () async {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

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
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: const Duration(milliseconds: 1),
        startDelay: Duration.zero,
      );

      expect(viewModel.isLoading, false);
      
      final loadFuture = viewModel.loadExamMetadata();
      expect(viewModel.isLoading, true);
      
      await loadFuture;
      expect(viewModel.isLoading, false);
    });

    test('should clear feedback when selecting quantity', () async {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      await viewModel.loadExamMetadata();
      viewModel.selectQuantity('10');
      
      viewModel.setError('Test error');
      expect(viewModel.errorMessage, isNotNull);

      viewModel.selectQuantity('15');
      expect(viewModel.errorMessage, isNull);
    });

    test('should handle exam metadata load error', () async {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      viewModel.setError('Failed to load exam');
      
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.canStartQuiz, false);
    });

    test('should notify listeners on state changes', () async {
      final viewModel = QuizConfigViewModel(
        course: testCourse,
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
  });
}
