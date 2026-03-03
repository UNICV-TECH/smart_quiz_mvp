import '../models/exam_template.dart';

abstract class PublishedExamRepository {
  /// Fetch published and active exam templates for a given course
  Future<List<ExamTemplate>> fetchPublishedTemplates({
    required String courseId,
  });

  /// Generate an exam from a published template for a student
  Future<String> startExamFromTemplate({
    required String templateId,
    required String userId,
  });
}

class PublishedExamRepositoryException implements Exception {
  const PublishedExamRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
