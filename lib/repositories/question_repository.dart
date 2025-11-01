import 'question_repository_types.dart';

abstract class QuestionRepository {
  Future<List<Question>> fetchQuestions({
    required String examId,
    required int limit,
  });
}
