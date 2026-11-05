class GamificationPoints {
  final String id;
  final String userId;
  final String seasonId;
  final String attemptId;
  final String examId;
  final String courseId;
  final String? examTemplateId;
  final int questionCount;
  final int correctCount;
  final double percentageScore;
  final int durationSeconds;
  final double basePoints;
  final double timeBonus;
  final double totalPoints;
  final DateTime createdAt;

  const GamificationPoints({
    required this.id,
    required this.userId,
    required this.seasonId,
    required this.attemptId,
    required this.examId,
    required this.courseId,
    this.examTemplateId,
    required this.questionCount,
    required this.correctCount,
    required this.percentageScore,
    required this.durationSeconds,
    required this.basePoints,
    required this.timeBonus,
    required this.totalPoints,
    required this.createdAt,
  });

  factory GamificationPoints.fromJson(Map<String, dynamic> json) {
    return GamificationPoints(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      seasonId: json['season_id'] as String,
      attemptId: json['attempt_id'] as String,
      examId: json['exam_id'] as String,
      courseId: json['course_id'] as String,
      examTemplateId: json['exam_template_id'] as String?,
      questionCount: (json['question_count'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      percentageScore: (json['percentage_score'] as num).toDouble(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      basePoints: (json['base_points'] as num).toDouble(),
      timeBonus: (json['time_bonus'] as num).toDouble(),
      totalPoints: (json['total_points'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'season_id': seasonId,
      'attempt_id': attemptId,
      'exam_id': examId,
      'course_id': courseId,
      if (examTemplateId != null) 'exam_template_id': examTemplateId,
      'question_count': questionCount,
      'correct_count': correctCount,
      'percentage_score': percentageScore,
      'duration_seconds': durationSeconds,
      'base_points': basePoints,
      'time_bonus': timeBonus,
      'total_points': totalPoints,
    };
  }
}

class SavePointsResult {
  /// Best score of THIS exam/template after the save (best-score-only scope).
  final double accumulatedPoints;

  /// Best score of THIS exam/template before the save.
  final double previousPoints;

  final bool didImprove;
  final double pointsSaved;

  /// Student's total in the season after the save. Levels are derived from
  /// this total, the same number the rankings show as season_points.
  /// Null when the total could not be read (the points were still saved).
  final double? seasonPoints;

  /// Student's total in the season before the save (for level-up detection).
  final double? previousSeasonPoints;

  const SavePointsResult({
    required this.accumulatedPoints,
    required this.previousPoints,
    required this.didImprove,
    required this.pointsSaved,
    this.seasonPoints,
    this.previousSeasonPoints,
  });
}
