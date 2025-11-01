import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/viewmodels/quiz_config_view_model.dart';
import 'package:unicv_tech_mvp/models/course.dart';

void main() {
  group('Widget Integration Tests', () {
    testWidgets(
        'CourseSelectionViewModel UI state updates correctly during loading',
        (WidgetTester tester) async {
      final viewModel = CourseSelectionViewModel(
        loadDelay: const Duration(milliseconds: 1),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CourseSelectionViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.errorMessage != null) {
                    return Center(child: Text('Error: ${vm.errorMessage}'));
                  }
                  return ListView.builder(
                    itemCount: vm.courses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        key: Key('course_$index'),
                        title: Text(vm.courses[index].title),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should be empty (not loading by default)
      expect(find.byType(ListTile), findsNothing);

      // Trigger load
      viewModel.loadCourses();
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for load to complete
      await tester.pumpAndSettle();

      // Should show courses
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('CourseSelectionViewModel error state displays correctly',
        (WidgetTester tester) async {
      final viewModel = CourseSelectionViewModel(
        loadDelay: const Duration(milliseconds: 1),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CourseSelectionViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${vm.errorMessage}'),
                          ElevatedButton(
                            onPressed: vm.loadCourses,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No courses'));
                },
              ),
            ),
          ),
        ),
      );

      // Set error
      viewModel.setError('Network error occurred');
      await tester.pump();

      // Should display error message
      expect(find.text('Error: Network error occurred'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Error should be cleared and courses shown
      expect(find.text('Error: Network error occurred'), findsNothing);
    });

    testWidgets(
        'QuizConfigViewModel updates UI correctly on quantity selection',
        (WidgetTester tester) async {
      final course = Course(
        id: 'test-course',
        courseKey: 'test',
        title: 'Test Course',
        iconKey: 'school_outlined',
        createdAt: DateTime.now(),
      );
      final viewModel = QuizConfigViewModel(
        course: course,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<QuizConfigViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    children: [
                      Text('Selected: ${vm.selectedQuantity ?? "None"}'),
                      ElevatedButton(
                        onPressed: () => vm.selectQuantity('10'),
                        child: const Text('Select 10'),
                      ),
                      ElevatedButton(
                        onPressed: () => vm.selectQuantity('15'),
                        child: const Text('Select 15'),
                      ),
                      ElevatedButton(
                        onPressed: vm.canStartQuiz ? () {} : null,
                        child: const Text('Start Quiz'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially no selection
      expect(find.text('Selected: None'), findsOneWidget);

      final startButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Start Quiz'),
      );
      expect(startButton.onPressed, isNull);

      // Select 10 questions
      await tester.tap(find.text('Select 10'));
      await tester.pump();

      expect(find.text('Selected: 10'), findsOneWidget);

      // Select 15 questions
      await tester.tap(find.text('Select 15'));
      await tester.pump();

      expect(find.text('Selected: 15'), findsOneWidget);
    });

    testWidgets('QuizConfigViewModel enables start button only when ready',
        (WidgetTester tester) async {
      final course = Course(
        id: 'test-course',
        courseKey: 'test',
        title: 'Test Course',
        iconKey: 'school_outlined',
        createdAt: DateTime.now(),
      );
      final viewModel = QuizConfigViewModel(
        course: course,
        metadataDelay: Duration.zero,
        startDelay: Duration.zero,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<QuizConfigViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => vm.selectQuantity('10'),
                        child: const Text('Select 10'),
                      ),
                      ElevatedButton(
                        onPressed: vm.canStartQuiz ? () {} : null,
                        child: const Text('Start Quiz'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Start button should be disabled initially
      var startButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Start Quiz'),
      );
      expect(startButton.onPressed, isNull);

      // Select quantity
      await tester.tap(find.text('Select 10'));
      await tester.pump();

      // Still disabled (no exam loaded)
      startButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Start Quiz'),
      );
      expect(startButton.onPressed, isNull);

      // Load exam metadata
      viewModel.loadExamMetadata();
      await tester.pumpAndSettle();

      // Now should be enabled
      startButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Start Quiz'),
      );
      expect(startButton.onPressed, isNotNull);
    });

    testWidgets('Navigation data flow: course selection to quiz config',
        (WidgetTester tester) async {
      final viewModel =
          CourseSelectionViewModel(loadDelay: Duration.zero);
      await viewModel.loadCourses();

      String? navigatedCourseId;
      String? navigatedCourseTitle;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CourseSelectionViewModel>(
                builder: (context, vm, child) {
                  return ListView.builder(
                    itemCount: vm.courses.length,
                    itemBuilder: (context, index) {
                      final course = vm.courses[index];
                      return ListTile(
                        key: Key('course_$index'),
                        title: Text(course.title),
                        onTap: () {
                          vm.selectCourse(course.id);
                          navigatedCourseId = course.id;
                          navigatedCourseTitle = course.title;
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first course
      await tester.tap(find.byKey(const Key('course_0')));
      await tester.pump();

      // Verify data was captured for navigation
      expect(navigatedCourseId, isNotNull);
      expect(navigatedCourseTitle, isNotNull);
      expect(viewModel.selectedCourseId, navigatedCourseId);
      expect(viewModel.selectedCourse!.title, navigatedCourseTitle);
    });
  });
}
