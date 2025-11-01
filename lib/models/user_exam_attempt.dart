class UserExamAttempt {
  final String id;
  final String userId;
  final String examId;
  final String courseId;
  final int questionCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final double? totalScore;
  final double? percentageScore;
  final String status;
  final DateTime createdAt;

  const UserExamAttempt({
    required this.id,
    required this.userId,
    required this.examId,
    required this.courseId,
    required this.questionCount,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.totalScore,
    this.percentageScore,
    this.status = 'in_progress',
    required this.createdAt,
  });

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isAbandoned => status == 'abandoned';

  Duration? get duration {
    if (durationSeconds == null) return null;
    return Duration(seconds: durationSeconds!);
  }

  factory UserExamAttempt.fromJson(Map<String, dynamic> json) {
    return UserExamAttempt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      examId: json['exam_id'] as String,
      courseId: json['course_id'] as String,
      questionCount: json['question_count'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      totalScore: (json['total_score'] as num?)?.toDouble(),
      percentageScore: (json['percentage_score'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'in_progress',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exam_id': examId,
      'course_id': courseId,
      'question_count': questionCount,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'total_score': totalScore,
      'percentage_score': percentageScore,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserExamAttempt copyWith({
    String? id,
    String? userId,
    String? examId,
    String? courseId,
    int? questionCount,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    double? totalScore,
    double? percentageScore,
    String? status,
    DateTime? createdAt,
  }) {
    return UserExamAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      examId: examId ?? this.examId,
      courseId: courseId ?? this.courseId,
      questionCount: questionCount ?? this.questionCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalScore: totalScore ?? this.totalScore,
      percentageScore: percentageScore ?? this.percentageScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
