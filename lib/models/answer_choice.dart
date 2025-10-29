class AnswerChoice {
  final String id;
  final String questionId;
  final String choiceKey;
  final String choiceText;
  final bool isCorrect;
  final int choiceOrder;
  final DateTime createdAt;

  const AnswerChoice({
    required this.id,
    required this.questionId,
    required this.choiceKey,
    required this.choiceText,
    required this.isCorrect,
    required this.choiceOrder,
    required this.createdAt,
  });

  factory AnswerChoice.fromJson(Map<String, dynamic> json) {
    return AnswerChoice(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      choiceKey: json['choice_key'] as String,
      choiceText: json['choice_text'] as String,
      isCorrect: json['is_correct'] as bool,
      choiceOrder: json['choice_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_key': choiceKey,
      'choice_text': choiceText,
      'is_correct': isCorrect,
      'choice_order': choiceOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AnswerChoice copyWith({
    String? id,
    String? questionId,
    String? choiceKey,
    String? choiceText,
    bool? isCorrect,
    int? choiceOrder,
    DateTime? createdAt,
  }) {
    return AnswerChoice(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      choiceKey: choiceKey ?? this.choiceKey,
      choiceText: choiceText ?? this.choiceText,
      isCorrect: isCorrect ?? this.isCorrect,
      choiceOrder: choiceOrder ?? this.choiceOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
