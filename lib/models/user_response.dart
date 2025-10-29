class UserResponse {
  final String id;
  final String attemptId;
  final String questionId;
  final String? answerChoiceId;
  final String? selectedChoiceKey;
  final bool? isCorrect;
  final double pointsEarned;
  final int? timeSpentSeconds;
  final DateTime? answeredAt;
  final DateTime createdAt;

  const UserResponse({
    required this.id,
    required this.attemptId,
    required this.questionId,
    this.answerChoiceId,
    this.selectedChoiceKey,
    this.isCorrect,
    this.pointsEarned = 0.0,
    this.timeSpentSeconds,
    this.answeredAt,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      attemptId: json['attempt_id'] as String,
      questionId: json['question_id'] as String,
      answerChoiceId: json['answer_choice_id'] as String?,
      selectedChoiceKey: json['selected_choice_key'] as String?,
      isCorrect: json['is_correct'] as bool?,
      pointsEarned: (json['points_earned'] as num?)?.toDouble() ?? 0.0,
      timeSpentSeconds: json['time_spent_seconds'] as int?,
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'answer_choice_id': answerChoiceId,
      'selected_choice_key': selectedChoiceKey,
      'is_correct': isCorrect,
      'points_earned': pointsEarned,
      'time_spent_seconds': timeSpentSeconds,
      'answered_at': answeredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAnswered => selectedChoiceKey != null && answerChoiceId != null;
  bool get isUnanswered => selectedChoiceKey == null;

  Duration? get timeSpent =>
      timeSpentSeconds != null ? Duration(seconds: timeSpentSeconds!) : null;

  UserResponse copyWith({
    String? id,
    String? attemptId,
    String? questionId,
    String? answerChoiceId,
    String? selectedChoiceKey,
    bool? isCorrect,
    double? pointsEarned,
    int? timeSpentSeconds,
    DateTime? answeredAt,
    DateTime? createdAt,
  }) {
    return UserResponse(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      answerChoiceId: answerChoiceId ?? this.answerChoiceId,
      selectedChoiceKey: selectedChoiceKey ?? this.selectedChoiceKey,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      answeredAt: answeredAt ?? this.answeredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
