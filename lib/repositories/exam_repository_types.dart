class ExamRepositoryException implements Exception {
  const ExamRepositoryException(this.message);

  final String message;
}

class Exam {
  const Exam({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.totalAvailableQuestions,
    required this.timeLimitMinutes,
    required this.passingScorePercentage,
    required this.isActive,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final int totalAvailableQuestions;
  final int? timeLimitMinutes;
  final double passingScorePercentage;
  final bool isActive;
}
