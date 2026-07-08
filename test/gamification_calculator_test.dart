import 'package:flutter_test/flutter_test.dart';
import 'package:unicv_tech_mvp/services/gamification_calculator.dart';

void main() {
  group('pointsPerCorrectAnswer (faixas)', () {
    test('<=5 questoes vale 1.0', () {
      expect(GamificationCalculator.pointsPerCorrectAnswer(1), 1.0);
      expect(GamificationCalculator.pointsPerCorrectAnswer(5), 1.0);
    });
    test('6..10 questoes vale 1.25', () {
      expect(GamificationCalculator.pointsPerCorrectAnswer(6), 1.25);
      expect(GamificationCalculator.pointsPerCorrectAnswer(10), 1.25);
    });
    test('>10 questoes vale 1.5', () {
      expect(GamificationCalculator.pointsPerCorrectAnswer(11), 1.5);
      expect(GamificationCalculator.pointsPerCorrectAnswer(20), 1.5);
    });
  });

  group('calculateBasePoints', () {
    test('correctCount * pontos da faixa', () {
      // 5 questoes -> 1.0/acerto; 4 acertos -> 4.0
      expect(
        GamificationCalculator.calculateBasePoints(questionCount: 5, correctCount: 4),
        4.0,
      );
      // 10 questoes -> 1.25/acerto; 8 acertos -> 10.0
      expect(
        GamificationCalculator.calculateBasePoints(questionCount: 10, correctCount: 8),
        10.0,
      );
      // 20 questoes -> 1.5/acerto; 20 acertos -> 30.0
      expect(
        GamificationCalculator.calculateBasePoints(questionCount: 20, correctCount: 20),
        30.0,
      );
    });
    test('clamp: acertos acima do total nao passam do total', () {
      expect(
        GamificationCalculator.calculateBasePoints(questionCount: 5, correctCount: 9),
        5.0, // clamped a 5 * 1.0
      );
    });
    test('questionCount <= 0 retorna 0', () {
      expect(
        GamificationCalculator.calculateBasePoints(questionCount: 0, correctCount: 3),
        0.0,
      );
    });
  });

  group('tempo', () {
    test('normalTimeSeconds = 2min por questao', () {
      expect(GamificationCalculator.normalTimeSeconds(5), 5 * 120);
      expect(GamificationCalculator.normalTimeSeconds(10), 1200);
    });
    test('recordTimeSeconds = 80% do normal (floor)', () {
      expect(GamificationCalculator.recordTimeSeconds(5), (600 * 0.8).floor()); // 480
      expect(GamificationCalculator.recordTimeSeconds(10), 960);
    });
  });

  group('calculateTimeBonus', () {
    test('da bonus = questionCount quando >=70% e dentro do tempo recorde', () {
      // 5 questoes, 4 acertos (80%), tempo <= 480s
      expect(
        GamificationCalculator.calculateTimeBonus(
            questionCount: 5, correctCount: 4, durationSeconds: 400),
        5.0,
      );
      // exatamente no limite do tempo recorde
      expect(
        GamificationCalculator.calculateTimeBonus(
            questionCount: 5, correctCount: 4, durationSeconds: 480),
        5.0,
      );
    });
    test('sem bonus se acerto < 70%', () {
      // 5 questoes, 3 acertos (60%)
      expect(
        GamificationCalculator.calculateTimeBonus(
            questionCount: 5, correctCount: 3, durationSeconds: 100),
        0.0,
      );
    });
    test('sem bonus se estourou o tempo recorde', () {
      // 5 questoes, 4 acertos (80%) mas 481s > 480s
      expect(
        GamificationCalculator.calculateTimeBonus(
            questionCount: 5, correctCount: 4, durationSeconds: 481),
        0.0,
      );
    });
  });

  group('calculate (agregado)', () {
    test('base + bonus com tempo bom', () {
      final r = GamificationCalculator.calculate(
          questionCount: 5, correctCount: 4, durationSeconds: 400);
      expect(r.basePoints, 4.0);
      expect(r.timeBonus, 5.0);
      expect(r.totalPoints, 9.0);
      expect(r.hasTimeBonus, true);
    });
    test('sem bonus quando lento', () {
      final r = GamificationCalculator.calculate(
          questionCount: 5, correctCount: 4, durationSeconds: 600);
      expect(r.basePoints, 4.0);
      expect(r.timeBonus, 0.0);
      expect(r.totalPoints, 4.0);
      expect(r.hasTimeBonus, false);
    });
  });
}
