import 'package:unicv_tech_mvp/models/exam_history.dart';

/// Abstraction that hides how exam history data is fetched.
abstract class ExamHistoryRepository {
  Future<List<SubjectExamHistory>> fetchSubjectExamHistories();

  Future loadExamHistory() async {}
}