class ExamAttemptRepositoryException implements Exception {
  const ExamAttemptRepositoryException(this.message);

  final String message;
}

class ExamAttemptCreated {
  const ExamAttemptCreated({
    required this.attemptId,
    required this.startedAt,
  });

  final String attemptId;
  final DateTime startedAt;
}

class UserResponseInput {
  const UserResponseInput({
    required this.questionId,
    required this.answerChoiceId,
    required this.selectedChoiceKey,
    required this.isCorrect,
    required this.pointsEarned,
    this.timeSpentSeconds,
  });

  final String questionId;
  final String? answerChoiceId;
  final String? selectedChoiceKey;
  final bool isCorrect;
  final double pointsEarned;
  final int? timeSpentSeconds;
}

class UserResponseDetail {
  const UserResponseDetail({
    required this.questionId,
    required this.selectedChoiceKey,
    required this.isCorrect,
    required this.pointsEarned,
  });

  final String questionId;
  final String? selectedChoiceKey;
  final bool isCorrect;
  final double pointsEarned;
}

class ExamAttemptHistory {
  const ExamAttemptHistory({
    required this.id,
    required this.examId,
    required this.courseId,
    required this.questionCount,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.totalScore,
    required this.percentageScore,
    required this.status,
  });

  final String id;
  final String examId;
  final String courseId;
  final int questionCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final double? totalScore;
  final double? percentageScore;
  final String status;
}
