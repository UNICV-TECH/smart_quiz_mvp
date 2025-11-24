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
          .from('question')
          .select('*, answerchoice(*), supportingtext(*)')
          .eq('exam_id', examId)
          .eq('is_active', true)
          .limit(limit);

      return (response as List).map((json) {
        final answerChoicesJson = json['answerchoice'] as List?;
        final answerChoices = answerChoicesJson?.map((choiceJson) {
              final letterRaw = (choiceJson['letter'] as String?)?.trim() ?? '';
              final letter = letterRaw.toUpperCase();

              // Mapear correctanswer de forma robusta
              final correctAnswerRaw = choiceJson['correctanswer'];
              bool isCorrect = false;
              if (correctAnswerRaw is bool) {
                isCorrect = correctAnswerRaw;
              } else if (correctAnswerRaw is String) {
                isCorrect = correctAnswerRaw.toLowerCase() == 'true' ||
                    correctAnswerRaw == '1';
              } else if (correctAnswerRaw is int) {
                isCorrect = correctAnswerRaw == 1;
              }

              return AnswerChoice(
                id: choiceJson['id'] as String,
                questionId: choiceJson['idquestion'] as String? ??
                    choiceJson['question_id'] as String? ??
                    '',
                choiceKey: letter.isNotEmpty ? letter : letterRaw,
                choiceText: choiceJson['content'] as String,
                isCorrect: isCorrect,
                choiceOrder: letter.isNotEmpty ? letter.codeUnitAt(0) - 64 : 0,
              );
            }).toList() ??
            [];

        answerChoices.sort((a, b) => a.choiceOrder.compareTo(b.choiceOrder));

        final supportingTextsJson = json['supportingtext'] as List?;
        final supportingTexts = supportingTextsJson
                ?.map((textJson) => SupportingText(
                      id: textJson['id'] as String,
                      questionId: textJson['id_question'] as String? ??
                          textJson['idquestion'] as String? ??
                          textJson['question_id'] as String? ??
                          '',
                      contentType: textJson['content_type'] as String?,
                      content: textJson['content'] as String,
                      displayOrder: textJson['display_order'] as int? ?? 1,
                    ))
                .toList() ??
            [];

        supportingTexts
            .sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        return Question(
          id: json['id'] as String,
          examId: json['exam_id'] as String? ?? '',
          enunciation: json['enunciation'] as String,
          questionText: json['question_text'] as String? ??
              json['question'] as String? ??
              '',
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

  @override
  Future<List<Question>> fetchQuestionsByIds({
    required List<String> questionIds,
  }) async {
    if (questionIds.isEmpty) return [];

    try {
      final response = await _client
          .from('question')
          .select('*, answerchoice(*), supportingtext(*)')
          .inFilter('id', questionIds)
          .eq('is_active', true);

      return (response as List).map((json) {
        final answerChoicesJson = json['answerchoice'] as List?;
        final answerChoices = answerChoicesJson?.map((choiceJson) {
              final letterRaw = (choiceJson['letter'] as String?)?.trim() ?? '';
              final letter = letterRaw.toUpperCase();

              // Mapear correctanswer de forma robusta
              final correctAnswerRaw = choiceJson['correctanswer'];
              bool isCorrect = false;
              if (correctAnswerRaw is bool) {
                isCorrect = correctAnswerRaw;
              } else if (correctAnswerRaw is String) {
                isCorrect = correctAnswerRaw.toLowerCase() == 'true' ||
                    correctAnswerRaw == '1';
              } else if (correctAnswerRaw is int) {
                isCorrect = correctAnswerRaw == 1;
              }

              return AnswerChoice(
                id: choiceJson['id'] as String,
                questionId: choiceJson['idquestion'] as String? ??
                    choiceJson['question_id'] as String? ??
                    '',
                choiceKey: letter.isNotEmpty ? letter : letterRaw,
                choiceText: choiceJson['content'] as String,
                isCorrect: isCorrect,
                choiceOrder: letter.isNotEmpty ? letter.codeUnitAt(0) - 64 : 0,
              );
            }).toList() ??
            [];

        answerChoices.sort((a, b) => a.choiceOrder.compareTo(b.choiceOrder));

        final supportingTextsJson = json['supportingtext'] as List?;
        final supportingTexts = supportingTextsJson
                ?.map((textJson) => SupportingText(
                      id: textJson['id'] as String,
                      questionId: textJson['id_question'] as String? ??
                          textJson['idquestion'] as String? ??
                          textJson['question_id'] as String? ??
                          '',
                      contentType: textJson['content_type'] as String?,
                      content: textJson['content'] as String,
                      displayOrder: textJson['display_order'] as int? ?? 1,
                    ))
                .toList() ??
            [];

        supportingTexts
            .sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        return Question(
          id: json['id'] as String,
          examId: json['exam_id'] as String? ?? '',
          enunciation: json['enunciation'] as String,
          questionText: json['question_text'] as String? ??
              json['question'] as String? ??
              '',
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
