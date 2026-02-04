class ExamTemplateCategory {
  final String id;
  final String examTemplateId;
  final String categoryId;
  final int questionCount;
  final DateTime createdAt;

  // Optional loaded relation
  final String? categoryName;

  const ExamTemplateCategory({
    required this.id,
    required this.examTemplateId,
    required this.categoryId,
    this.questionCount = 5,
    required this.createdAt,
    this.categoryName,
  });

  factory ExamTemplateCategory.fromJson(Map<String, dynamic> json) {
    return ExamTemplateCategory(
      id: json['id'] as String,
      examTemplateId: json['id_exam_template'] as String,
      categoryId: json['id_category'] as String,
      questionCount: json['question_count'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      categoryName: json['category']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_exam_template': examTemplateId,
      'id_category': categoryId,
      'question_count': questionCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_exam_template': examTemplateId,
      'id_category': categoryId,
      'question_count': questionCount,
    };
  }

  ExamTemplateCategory copyWith({
    String? id,
    String? examTemplateId,
    String? categoryId,
    int? questionCount,
    DateTime? createdAt,
    String? categoryName,
  }) {
    return ExamTemplateCategory(
      id: id ?? this.id,
      examTemplateId: examTemplateId ?? this.examTemplateId,
      categoryId: categoryId ?? this.categoryId,
      questionCount: questionCount ?? this.questionCount,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
