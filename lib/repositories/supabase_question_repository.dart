import 'package:supabase_flutter/supabase_flutter.dart';

import 'question_repository.dart';
import 'question_repository_types.dart';

class SupabaseQuestionRepository implements QuestionRepository {
  SupabaseQuestionRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Question>> fetchQuestions({
    required String examId,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('questions')
          .select('*, answer_choices(*), supporting_texts(*)')
          .eq('exam_id', examId)
          .eq('is_active', true)
          .order('question_order', nullsFirst: false)
          .limit(limit);

      return (response as List).map((json) {
        final answerChoicesJson = json['answer_choices'] as List?;
        final answerChoices = answerChoicesJson
                ?.map((choiceJson) => AnswerChoice(
                      id: choiceJson['id'] as String,
                      questionId: choiceJson['question_id'] as String,
                      choiceKey: choiceJson['choice_key'] as String,
                      choiceText: choiceJson['choice_text'] as String,
                      isCorrect: choiceJson['is_correct'] as bool? ?? false,
                      choiceOrder: choiceJson['choice_order'] as int,
                    ))
                .toList() ??
            [];

        answerChoices.sort((a, b) => a.choiceOrder.compareTo(b.choiceOrder));

        final supportingTextsJson = json['supporting_texts'] as List?;
        final supportingTexts = supportingTextsJson
                ?.map((textJson) => SupportingText(
                      id: textJson['id'] as String,
                      questionId: textJson['question_id'] as String,
                      contentType: textJson['content_type'] as String,
                      content: textJson['content'] as String,
                      displayOrder: textJson['display_order'] as int? ?? 1,
                    ))
                .toList() ??
            [];

        supportingTexts.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        return Question(
          id: json['id'] as String,
          examId: json['exam_id'] as String,
          enunciation: json['enunciation'] as String,
          questionOrder: json['question_order'] as int?,
          difficultyLevel: json['difficulty_level'] as String?,
          points: (json['points'] as num?)?.toDouble() ?? 1.0,
          isActive: json['is_active'] as bool? ?? true,
          answerChoices: answerChoices,
          supportingTexts: supportingTexts,
        );
      }).toList();
    } catch (error) {
      throw QuestionRepositoryException(
        'Não foi possível carregar as questões: ${error.toString()}',
      );
    }
  }
}
