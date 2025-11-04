import 'exam_attempt_repository_types.dart';

abstract class ExamAttemptRepository {
  Future<ExamAttemptCreated> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  });

  Future<void> insertResponses({
    required String attemptId,
    required List<UserResponseInput> responses,
  });

  Future<void> updateCompletionStatus({
    required String attemptId,
    required int durationSeconds,
    required double totalScore,
    required double percentageScore,
  });

  Future<List<ExamAttemptHistory>> fetchUserAttempts({
    required String userId,
    String? courseId,
  });
}
