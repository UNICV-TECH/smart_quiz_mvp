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
  final String? subjectId;
  final String? categoryId;
  final String enunciation;
  final String difficultyLevel;
  final double points;
  final List<SupportingTextInput> supportingTexts;
  final List<AnswerChoiceInput> answerChoices;

  const CreateQuestionRequest({
    required this.teacherId,
    required this.courseId,
    this.subjectId,
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
      'p_subject_id': subjectId,
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

/// Detail of an answer choice (for editing)
class AnswerChoiceDetail {
  final String id;
  final String letter;
  final String content;
  final bool isCorrect;

  const AnswerChoiceDetail({
    required this.id,
    required this.letter,
    required this.content,
    required this.isCorrect,
  });

  factory AnswerChoiceDetail.fromJson(Map<String, dynamic> json) {
    return AnswerChoiceDetail(
      id: json['id'] as String,
      letter: json['letter'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isCorrect: json['correctanswer'] as bool? ?? false,
    );
  }
}

/// Detail of a supporting text (for editing)
class SupportingTextDetail {
  final String id;
  final String contentType;
  final String content;
  final int displayOrder;

  const SupportingTextDetail({
    required this.id,
    required this.contentType,
    required this.content,
    required this.displayOrder,
  });

  factory SupportingTextDetail.fromJson(Map<String, dynamic> json) {
    return SupportingTextDetail(
      id: json['id'] as String,
      contentType: json['content_type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Complete question detail for editing
class QuestionDetail {
  final String id;
  final String enunciation;
  final String? difficultyLevel;
  final double points;
  final String courseId;
  final String? subjectId;
  final String? categoryId;
  final List<AnswerChoiceDetail> answerChoices;
  final List<SupportingTextDetail> supportingTexts;

  const QuestionDetail({
    required this.id,
    required this.enunciation,
    this.difficultyLevel,
    this.points = 1.0,
    required this.courseId,
    this.subjectId,
    this.categoryId,
    this.answerChoices = const [],
    this.supportingTexts = const [],
  });
}

/// Request to update a complete question (enunciation + answer choices + supporting texts)
class FullUpdateQuestionRequest {
  final String questionId;
  final String teacherId;
  final String? subjectId;
  final String? categoryId;
  final String enunciation;
  final String difficultyLevel;
  final double points;
  final List<SupportingTextInput> supportingTexts;
  final List<AnswerChoiceInput> answerChoices;

  const FullUpdateQuestionRequest({
    required this.questionId,
    required this.teacherId,
    this.subjectId,
    this.categoryId,
    required this.enunciation,
    this.difficultyLevel = 'medium',
    this.points = 1.0,
    this.supportingTexts = const [],
    required this.answerChoices,
  });

  Map<String, dynamic> toRpcParams() {
    return {
      'p_question_id': questionId,
      'p_teacher_id': teacherId,
      'p_subject_id': subjectId,
      'p_category_id': categoryId,
      'p_enunciation': enunciation,
      'p_difficulty_level': difficultyLevel,
      'p_points': points,
      'p_supporting_texts': supportingTexts.map((e) => e.toJson()).toList(),
      'p_answer_choices': answerChoices.map((e) => e.toJson()).toList(),
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
