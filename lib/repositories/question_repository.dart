import 'question_repository_types.dart';

abstract class QuestionRepository {
  Future<List<Question>> fetchQuestionsByIds({
    required List<String> questionIds,
  });
}
