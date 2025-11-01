class Exam {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int totalAvailableQuestions;
  final int? timeLimitMinutes;
  final double passingScorePercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Exam({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.totalAvailableQuestions,
    this.timeLimitMinutes,
    this.passingScorePercentage = 70.0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalAvailableQuestions: json['total_available_questions'] as int,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      passingScorePercentage: (json['passing_score_percentage'] as num?)?.toDouble() ?? 70.0,
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
      'course_id': courseId,
      'title': title,
      'description': description,
      'total_available_questions': totalAvailableQuestions,
      'time_limit_minutes': timeLimitMinutes,
      'passing_score_percentage': passingScorePercentage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Exam copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? totalAvailableQuestions,
    int? timeLimitMinutes,
    double? passingScorePercentage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exam(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalAvailableQuestions: totalAvailableQuestions ?? this.totalAvailableQuestions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScorePercentage: passingScorePercentage ?? this.passingScorePercentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
