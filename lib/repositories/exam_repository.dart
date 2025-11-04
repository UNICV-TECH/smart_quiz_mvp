import 'exam_repository_types.dart';

abstract class ExamRepository {
  Future<Exam> fetchExamByCourseKey(String courseKey);
  Future<int> verifyAvailableQuestions(String examId);
}
