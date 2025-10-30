class Question {
  final String id;
  final String examId;
  final String enunciation;
  final int? questionOrder;
  final String? difficultyLevel;
  final double points;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<AnswerChoice> answerChoices;
  final List<SupportingText> supportingTexts;

  const Question({
    required this.id,
    required this.examId,
    required this.enunciation,
    this.questionOrder,
    this.difficultyLevel,
    this.points = 1.0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.answerChoices = const [],
    this.supportingTexts = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      enunciation: json['enunciation'] as String,
      questionOrder: json['question_order'] as int?,
      difficultyLevel: json['difficulty_level'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      answerChoices: (json['answer_choices'] as List<dynamic>?)
              ?.map((e) => AnswerChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      supportingTexts: (json['supporting_texts'] as List<dynamic>?)
              ?.map((e) => SupportingText.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'enunciation': enunciation,
      'question_order': questionOrder,
      'difficulty_level': difficultyLevel,
      'points': points,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'answer_choices': answerChoices.map((e) => e.toJson()).toList(),
      'supporting_texts': supportingTexts.map((e) => e.toJson()).toList(),
    };
  }

  Question copyWith({
    String? id,
    String? examId,
    String? enunciation,
    int? questionOrder,
    String? difficultyLevel,
    double? points,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AnswerChoice>? answerChoices,
    List<SupportingText>? supportingTexts,
  }) {
    return Question(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      enunciation: enunciation ?? this.enunciation,
      questionOrder: questionOrder ?? this.questionOrder,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answerChoices: answerChoices ?? this.answerChoices,
      supportingTexts: supportingTexts ?? this.supportingTexts,
    );
  }
}

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
    this.isCorrect = false,
    required this.choiceOrder,
    required this.createdAt,
  });

  factory AnswerChoice.fromJson(Map<String, dynamic> json) {
    return AnswerChoice(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      choiceKey: json['choice_key'] as String,
      choiceText: json['choice_text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
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

class SupportingText {
  final String id;
  final String questionId;
  final String contentType;
  final String content;
  final int displayOrder;
  final DateTime createdAt;

  const SupportingText({
    required this.id,
    required this.questionId,
    required this.contentType,
    required this.content,
    this.displayOrder = 1,
    required this.createdAt,
  });

  factory SupportingText.fromJson(Map<String, dynamic> json) {
    return SupportingText(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      contentType: json['content_type'] as String,
      content: json['content'] as String,
      displayOrder: json['display_order'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content_type': contentType,
      'content': content,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SupportingText copyWith({
    String? id,
    String? questionId,
    String? contentType,
    String? content,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return SupportingText(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
