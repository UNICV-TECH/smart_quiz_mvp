class ExamTemplate {
  final String id;
  final String name;
  final String? description;
  final String courseId;
  final String teacherId;
  final int? timeLimitMinutes;
  final int questionCount;
  final double passingScorePercentage;
  final bool shuffleQuestions;
  final bool shuffleChoices;
  final bool showCorrectAnswers;
  final bool allowReview;
  final int? maxAttempts;
  final bool isPublished;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional loaded relations
  final String? courseName;
  final String? teacherName;

  const ExamTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.courseId,
    required this.teacherId,
    this.timeLimitMinutes,
    this.questionCount = 10,
    this.passingScorePercentage = 60.0,
    this.shuffleQuestions = true,
    this.shuffleChoices = true,
    this.showCorrectAnswers = true,
    this.allowReview = true,
    this.maxAttempts = 1,
    this.isPublished = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.courseName,
    this.teacherName,
  });

  factory ExamTemplate.fromJson(Map<String, dynamic> json) {
    return ExamTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      courseId: json['id_course'] as String,
      teacherId: json['id_teacher'] as String,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      questionCount: json['question_count'] as int? ?? 10,
      passingScorePercentage:
          (json['passing_score_percentage'] as num?)?.toDouble() ?? 60.0,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? true,
      shuffleChoices: json['shuffle_choices'] as bool? ?? true,
      showCorrectAnswers: json['show_correct_answers'] as bool? ?? true,
      allowReview: json['allow_review'] as bool? ?? true,
      maxAttempts: json['max_attempts'] as int?,
      isPublished: json['is_published'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      courseName: json['course']?['title'] as String? ??
          json['course']?['name'] as String?,
      teacherName: json['teacher']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'id_course': courseId,
      'id_teacher': teacherId,
      'time_limit_minutes': timeLimitMinutes,
      'question_count': questionCount,
      'passing_score_percentage': passingScorePercentage,
      'shuffle_questions': shuffleQuestions,
      'shuffle_choices': shuffleChoices,
      'show_correct_answers': showCorrectAnswers,
      'allow_review': allowReview,
      'max_attempts': maxAttempts,
      'is_published': isPublished,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'id_course': courseId,
      'id_teacher': teacherId,
      'time_limit_minutes': timeLimitMinutes,
      'question_count': questionCount,
      'passing_score_percentage': passingScorePercentage,
      'shuffle_questions': shuffleQuestions,
      'shuffle_choices': shuffleChoices,
      'show_correct_answers': showCorrectAnswers,
      'allow_review': allowReview,
      'max_attempts': maxAttempts,
      'is_published': isPublished,
      'is_active': isActive,
    };
  }

  ExamTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? courseId,
    String? teacherId,
    int? timeLimitMinutes,
    int? questionCount,
    double? passingScorePercentage,
    bool? shuffleQuestions,
    bool? shuffleChoices,
    bool? showCorrectAnswers,
    bool? allowReview,
    int? maxAttempts,
    bool? isPublished,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? courseName,
    String? teacherName,
  }) {
    return ExamTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      teacherId: teacherId ?? this.teacherId,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questionCount: questionCount ?? this.questionCount,
      passingScorePercentage:
          passingScorePercentage ?? this.passingScorePercentage,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleChoices: shuffleChoices ?? this.shuffleChoices,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      allowReview: allowReview ?? this.allowReview,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isPublished: isPublished ?? this.isPublished,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseName: courseName ?? this.courseName,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  String get statusLabel => isPublished ? 'Publicado' : 'Rascunho';
  String get timeLimitLabel =>
      timeLimitMinutes != null ? '$timeLimitMinutes min' : 'Sem limite';
}
