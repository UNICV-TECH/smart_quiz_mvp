class QuestionRepositoryException implements Exception {
  const QuestionRepositoryException(this.message);

  final String message;
}

class AnswerChoice {
  const AnswerChoice({
    required this.id,
    required this.questionId,
    required this.choiceKey,
    required this.choiceText,
    required this.isCorrect,
    required this.choiceOrder,
  });

  final String id;
  final String questionId;
  final String choiceKey;
  final String choiceText;
  final bool isCorrect;
  final int choiceOrder;
}

class SupportingText {
  const SupportingText({
    required this.id,
    required this.questionId,
    this.contentType,
    required this.content,
    required this.displayOrder,
  });

  final String id;
  final String questionId;
  final String? contentType;
  final String content;
  final int displayOrder;
}

class Question {
  const Question({
    required this.id,
    required this.examId,
    required this.enunciation,
    required this.questionText,
    required this.questionOrder,
    required this.difficultyLevel,
    required this.points,
    required this.isActive,
    required this.answerChoices,
    required this.supportingTexts,
  });

  final String id;
  final String examId;
  final String enunciation;
  final String questionText;
  final int? questionOrder;
  final String? difficultyLevel;
  final double points;
  final bool isActive;
  final List<AnswerChoice> answerChoices;
  final List<SupportingText> supportingTexts;
}
