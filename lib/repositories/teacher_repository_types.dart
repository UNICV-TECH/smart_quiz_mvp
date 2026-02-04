class TeacherRepositoryException implements Exception {
  const TeacherRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Request to create a new question
class CreateQuestionRequest {
  final String teacherId;
  final String courseId;
  final String? categoryId;
  final String enunciation;
  final String difficultyLevel;
  final double points;
  final List<SupportingTextInput> supportingTexts;
  final List<AnswerChoiceInput> answerChoices;

  const CreateQuestionRequest({
    required this.teacherId,
    required this.courseId,
    this.categoryId,
    required this.enunciation,
    this.difficultyLevel = 'medium',
    this.points = 1.0,
    this.supportingTexts = const [],
    required this.answerChoices,
  });

  Map<String, dynamic> toRpcParams() {
    return {
      'p_teacher_id': teacherId,
      'p_course_id': courseId,
      'p_category_id': categoryId,
      'p_enunciation': enunciation,
      'p_difficulty_level': difficultyLevel,
      'p_points': points,
      'p_supporting_texts': supportingTexts.map((e) => e.toJson()).toList(),
      'p_answer_choices': answerChoices.map((e) => e.toJson()).toList(),
    };
  }
}

/// Request to update an existing question
class UpdateQuestionRequest {
  final String questionId;
  final String? categoryId;
  final String? enunciation;
  final String? difficultyLevel;
  final double? points;
  final bool? isActive;

  const UpdateQuestionRequest({
    required this.questionId,
    this.categoryId,
    this.enunciation,
    this.difficultyLevel,
    this.points,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (categoryId != null) json['id_category'] = categoryId;
    if (enunciation != null) json['enunciation'] = enunciation;
    if (difficultyLevel != null) json['difficulty_level'] = difficultyLevel;
    if (points != null) json['points'] = points;
    if (isActive != null) json['is_active'] = isActive;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }
}

/// Input for supporting text when creating a question
class SupportingTextInput {
  final String? contentType;
  final String content;
  final int? displayOrder;

  const SupportingTextInput({
    this.contentType = 'text',
    required this.content,
    this.displayOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType,
      'content': content,
      if (displayOrder != null) 'display_order': displayOrder,
    };
  }
}

/// Input for answer choice when creating a question
class AnswerChoiceInput {
  final String? letter;
  final String content;
  final bool isCorrect;

  const AnswerChoiceInput({
    this.letter,
    required this.content,
    this.isCorrect = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (letter != null) 'letter': letter,
      'content': content,
      'is_correct': isCorrect,
    };
  }
}

/// Filter options for fetching teacher questions
class TeacherQuestionsFilter {
  final String teacherId;
  final String? courseId;
  final String? categoryId;
  final bool activeOnly;

  const TeacherQuestionsFilter({
    required this.teacherId,
    this.courseId,
    this.categoryId,
    this.activeOnly = true,
  });
}
