import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/viewmodels/exam_view_model.dart';
import 'package:unicv_tech_mvp/views/exam_result_screen.dart';

class _FakeExamDataSource implements ExamRemoteDataSource {
  _FakeExamDataSource();

  int createAttemptCalls = 0;
  final List<List<Map<String, dynamic>>> recordedResponses = [];
  final Map<String, Map<String, dynamic>> attemptUpdates = {};
  final List<String> createdAttemptIds = [];

  @override
  Future<String> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
    required DateTime startedAt,
  }) async {
    createAttemptCalls += 1;
    final attemptId = 'attempt_$createAttemptCalls';
    createdAttemptIds.add(attemptId);
    return attemptId;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions({
    required String examId,
    required String courseId,
  }) async {
    return [
      {
        'id': 'question-1',
        'exam_id': examId,
        'enunciation': 'Quanto é 2 + 2?',
        'question_order': 0,
        'difficulty_level': 'easy',
        'points': 1,
        'is_active': true,
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnswerChoices(
    List<String> questionIds,
  ) async {
    return [
      {
        'id': 'answer-1',
        'question_id': 'question-1',
        'choice_key': 'A',
        'choice_text': '4',
        'is_correct': true,
        'choice_order': 1,
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
      },
      {
        'id': 'answer-2',
        'question_id': 'question-1',
        'choice_key': 'B',
        'choice_text': '5',
        'is_correct': false,
        'choice_order': 2,
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSupportingTexts(
    List<String> questionIds,
  ) async {
    return const [];
  }

  @override
  Future<void> insertResponses(List<Map<String, dynamic>> responses) async {
    recordedResponses.add(responses);
  }

  @override
  Future<void> updateAttempt(
    String attemptId,
    Map<String, dynamic> updates,
  ) async {
    attemptUpdates[attemptId] = updates;
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? replacedRoute;
  Route<dynamic>? replacementRoute;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacementRoute = newRoute;
    replacedRoute = oldRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Retake exam workflow', () {
    test('finalize returns identifiers required for retake and new attempt is created', () async {
      final dataSource = _FakeExamDataSource();
      final viewModel = ExamViewModel(
        dataSource: dataSource,
        userId: 'user-1',
        examId: 'exam-1',
        courseId: 'course-1',
        questionCount: 1,
      );

      await viewModel.initialize();
      expect(dataSource.createAttemptCalls, 1);
      expect(viewModel.examQuestions, isNotEmpty);

      final questionId = viewModel.examQuestions.first.question.id;
      viewModel.selectAnswer(questionId, 'A');

      final results = await viewModel.finalize();

      expect(results['userId'], equals('user-1'));
      expect(results['examId'], equals('exam-1'));
      expect(results['courseId'], equals('course-1'));
      expect(results['questionCount'], equals(1));
      expect(results['attemptId'], equals('attempt_1'));
      expect(dataSource.recordedResponses.single, isNotEmpty);
      expect(dataSource.attemptUpdates['attempt_1'], containsPair('status', 'completed'));

      final secondViewModel = ExamViewModel(
        dataSource: dataSource,
        userId: 'user-1',
        examId: 'exam-1',
        courseId: 'course-1',
        questionCount: 1,
      );

      await secondViewModel.initialize();
      expect(dataSource.createAttemptCalls, 2);
      expect(secondViewModel.attemptId, equals('attempt_2'));
      expect(secondViewModel.attemptId, isNot(equals(viewModel.attemptId)));
    });

    testWidgets('Retake button pushes /exam with validated arguments', (tester) async {
      final observer = _RecordingNavigatorObserver();
      final resultsPayload = {
        'attemptId': 'attempt_1',
        'userId': 'user-1',
        'examId': 'exam-1',
        'courseId': 'course-1',
        'questionCount': 5,
        'totalQuestions': 5,
        'correctCount': 4,
        'totalScore': 4.0,
        'percentageScore': 80.0,
        'durationSeconds': 120,
        'questionsBreakdown': const [],
      };

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            '/exam/result': (context) => ExamResultScreen(results: resultsPayload),
            '/exam': (context) => const SizedBox.shrink(),
          },
          initialRoute: '/exam/result',
          navigatorObservers: [observer],
        ),
      );

      await tester.tap(find.text('Refazer prova'));
      await tester.pumpAndSettle();

      final replacement = observer.replacementRoute;
      expect(replacement, isNotNull);
      expect(replacement!.settings.name, equals('/exam'));
      expect(replacement.settings.arguments, isA<Map<String, dynamic>>());

      final args = replacement.settings.arguments! as Map<String, dynamic>;
      expect(args['userId'], equals('user-1'));
      expect(args['examId'], equals('exam-1'));
      expect(args['courseId'], equals('course-1'));
      expect(args['questionCount'], equals(5));
    });
  });
}
