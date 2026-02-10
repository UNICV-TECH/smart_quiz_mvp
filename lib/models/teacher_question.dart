/// Model representing a question as viewed by the teacher
/// This is optimized for list views and includes aggregated data
class TeacherQuestion {
  final String id;
  final String enunciation;
  final String? difficultyLevel;
  final double points;
  final bool isActive;
  final String? categoryName;
  final String? courseName;
  final int answerCount;
  final int supportingTextCount;
  final DateTime createdAt;

  const TeacherQuestion({
    required this.id,
    required this.enunciation,
    this.difficultyLevel,
    this.points = 1.0,
    this.isActive = true,
    this.categoryName,
    this.courseName,
    this.answerCount = 0,
    this.supportingTextCount = 0,
    required this.createdAt,
  });

  factory TeacherQuestion.fromJson(Map<String, dynamic> json) {
    return TeacherQuestion(
      id: json['id'] as String,
      enunciation: json['enunciation'] as String,
      difficultyLevel: json['difficulty_level'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      categoryName: json['category_name'] as String?,
      courseName: json['course_name'] as String?,
      answerCount: (json['answer_count'] as num?)?.toInt() ?? 0,
      supportingTextCount: (json['supporting_text_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get difficultyLabel {
    switch (difficultyLevel) {
      case 'easy':
        return 'Facil';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Dificil';
      default:
        return 'N/A';
    }
  }

  String get statusLabel => isActive ? 'Ativa' : 'Inativa';

  String get enunciationPreview {
    if (enunciation.length <= 100) return enunciation;
    return '${enunciation.substring(0, 97)}...';
  }
}
