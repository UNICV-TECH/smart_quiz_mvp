// The result screen must show the student's level from the SEASON total (the
// same number the rankings show), not from the points of the exam just taken.
//
// Bug report: result showed "Iniciante 10 / 100 pts" while the ranking showed
// the student with 107 pts (Explorador).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/views/exam_result_screen.dart';

Map<String, dynamic> _results({
  required double totalPoints,
  required double seasonPoints,
  required double previousSeasonPoints,
}) =>
    {
      'totalQuestions': 5,
      'correctCount': 5,
      'percentageScore': 100.0,
      'durationSeconds': 60,
      'questionsBreakdown': const [],
      'gamificationSaved': true,
      'gamificationDidImprove': true,
      'gamificationBasePoints': 5.0,
      'gamificationTimeBonus': 5.0,
      'gamificationHasTimeBonus': true,
      'gamificationTotalPoints': totalPoints,
      'gamificationSeasonPoints': seasonPoints,
      'gamificationPreviousSeasonPoints': previousSeasonPoints,
    };

Future<void> _pumpResult(WidgetTester tester, Map<String, dynamic> results) async {
  tester.view.physicalSize = const Size(1280, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(home: ExamResultScreen(results: results)));
  // Confetti and level-up animations never settle; pump a fixed time instead.
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('level and progress come from the season total (97 + 10 = 107)',
      (tester) async {
    await _pumpResult(
      tester,
      _results(totalPoints: 10, seasonPoints: 107, previousSeasonPoints: 97),
    );

    expect(find.text('+10.0 pts'), findsOneWidget, reason: 'points earned');
    expect(find.text('107 / 200 pts'), findsOneWidget);
    expect(find.text('Explorador'), findsOneWidget);
    expect(find.text('10 / 100 pts'), findsNothing);
    expect(find.text('Iniciante'), findsNothing);
  });

  testWidgets('crossing 100 pts in the season shows the level-up card',
      (tester) async {
    await _pumpResult(
      tester,
      _results(totalPoints: 10, seasonPoints: 107, previousSeasonPoints: 97),
    );

    expect(
      find.text('Parabéns! Você alcançou o nível Explorador!'),
      findsOneWidget,
    );
  });

  testWidgets('no level-up card when the season total stays in the same level',
      (tester) async {
    await _pumpResult(
      tester,
      _results(totalPoints: 10, seasonPoints: 60, previousSeasonPoints: 50),
    );

    expect(find.text('60 / 100 pts'), findsOneWidget);
    expect(find.textContaining('Parabéns! Você alcançou'), findsNothing);
  });
}
