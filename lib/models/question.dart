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
    );
  }
}
