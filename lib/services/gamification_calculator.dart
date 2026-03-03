class GamificationCalculator {
  const GamificationCalculator._();

  /// Points per correct answer based on question count.
  /// 5 questions -> 1.0, 10 -> 1.25, >10 -> 1.5
  static double pointsPerCorrectAnswer(int questionCount) {
    if (questionCount <= 5) return 1.0;
    if (questionCount <= 10) return 1.25;
    return 1.5;
  }

  /// Base points = correctCount * pointsPerCorrectAnswer
  static double calculateBasePoints({
    required int questionCount,
    required int correctCount,
  }) {
    if (questionCount <= 0) return 0.0;
    final clamped = correctCount.clamp(0, questionCount);
    return clamped * pointsPerCorrectAnswer(questionCount);
  }

  /// Normal time = questionCount * 2 minutes (in seconds)
  static int normalTimeSeconds(int questionCount) => questionCount * 2 * 60;

  /// Record time = 80% of normal time (in seconds)
  static int recordTimeSeconds(int questionCount) =>
      (normalTimeSeconds(questionCount) * 0.8).floor();

  /// Time bonus = questionCount points if >=70% correct AND time <= record time
  static double calculateTimeBonus({
    required int questionCount,
    required int correctCount,
    required int durationSeconds,
  }) {
    if (questionCount <= 0) return 0.0;
    final percentage = correctCount / questionCount * 100;
    if (percentage >= 70 && durationSeconds <= recordTimeSeconds(questionCount)) {
      return questionCount.toDouble();
    }
    return 0.0;
  }

  /// Calculate total gamification points for an attempt.
  static GamificationResult calculate({
    required int questionCount,
    required int correctCount,
    required int durationSeconds,
  }) {
    final base = calculateBasePoints(
      questionCount: questionCount,
      correctCount: correctCount,
    );
    final bonus = calculateTimeBonus(
      questionCount: questionCount,
      correctCount: correctCount,
      durationSeconds: durationSeconds,
    );
    return GamificationResult(
      basePoints: base,
      timeBonus: bonus,
      totalPoints: base + bonus,
      hasTimeBonus: bonus > 0,
    );
  }

  /// Motivational message based on performance.
  static String getMotivationalMessage({
    required double percentageScore,
    required bool hasTimeBonus,
    required bool didImprove,
    bool gamificationSaved = true,
  }) {
    if (!gamificationSaved) {
      return 'Seus pontos não puderam ser salvos. Tente novamente mais tarde.';
    }
    if (!didImprove) {
      return 'Sua pontuação anterior foi mantida. Tente superar!';
    }
    if (percentageScore >= 90 && hasTimeBonus) {
      return 'Incrível! Performance perfeita!';
    }
    if (percentageScore >= 80 && hasTimeBonus) {
      return 'Excelente! Você está voando!';
    }
    if (percentageScore >= 70 && hasTimeBonus) {
      return 'Ótimo! Velocidade e precisão!';
    }
    if (percentageScore >= 70) {
      return 'Bom trabalho! Continue assim!';
    }
    if (percentageScore >= 50) {
      return 'Bom esforço! Pratique mais para melhorar!';
    }
    return 'Continue tentando! A prática leva à perfeição!';
  }
}

class GamificationResult {
  final double basePoints;
  final double timeBonus;
  final double totalPoints;
  final bool hasTimeBonus;

  const GamificationResult({
    required this.basePoints,
    required this.timeBonus,
    required this.totalPoints,
    required this.hasTimeBonus,
  });
}
