class ExamTemplateQuestion {
  final String id;
  final String examTemplateId;
  final String questionId;
  final int questionOrder;
  final double? pointsOverride;
  final DateTime createdAt;

  // Optional loaded relation
  final String? questionEnunciation;

  const ExamTemplateQuestion({
    required this.id,
    required this.examTemplateId,
    required this.questionId,
    this.questionOrder = 1,
    this.pointsOverride,
    required this.createdAt,
    this.questionEnunciation,
  });

  factory ExamTemplateQuestion.fromJson(Map<String, dynamic> json) {
    return ExamTemplateQuestion(
      id: json['id'] as String,
      examTemplateId: json['id_exam_template'] as String,
      questionId: json['id_question'] as String,
      questionOrder: json['question_order'] as int? ?? 1,
      pointsOverride: (json['points_override'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      questionEnunciation: json['question']?['enunciation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_exam_template': examTemplateId,
      'id_question': questionId,
      'question_order': questionOrder,
      'points_override': pointsOverride,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_exam_template': examTemplateId,
      'id_question': questionId,
      'question_order': questionOrder,
      'points_override': pointsOverride,
    };
  }

  ExamTemplateQuestion copyWith({
    String? id,
    String? examTemplateId,
    String? questionId,
    int? questionOrder,
    double? pointsOverride,
    DateTime? createdAt,
    String? questionEnunciation,
  }) {
    return ExamTemplateQuestion(
      id: id ?? this.id,
      examTemplateId: examTemplateId ?? this.examTemplateId,
      questionId: questionId ?? this.questionId,
      questionOrder: questionOrder ?? this.questionOrder,
      pointsOverride: pointsOverride ?? this.pointsOverride,
      createdAt: createdAt ?? this.createdAt,
      questionEnunciation: questionEnunciation ?? this.questionEnunciation,
    );
  }
}
