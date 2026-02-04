/// Statistics about questions created by a teacher
class TeacherQuestionStats {
  final String teacherId;
  final String? courseId;
  final String? courseName;
  final int totalQuestions;
  final int activeQuestions;
  final int categoriesUsed;
  final double avgPoints;

  const TeacherQuestionStats({
    required this.teacherId,
    this.courseId,
    this.courseName,
    this.totalQuestions = 0,
    this.activeQuestions = 0,
    this.categoriesUsed = 0,
    this.avgPoints = 0.0,
  });

  factory TeacherQuestionStats.fromJson(Map<String, dynamic> json) {
    return TeacherQuestionStats(
      teacherId: json['id_teacher'] as String,
      courseId: json['id_course'] as String?,
      courseName: json['course_name'] as String?,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      activeQuestions: (json['active_questions'] as num?)?.toInt() ?? 0,
      categoriesUsed: (json['categories_used'] as num?)?.toInt() ?? 0,
      avgPoints: (json['avg_points'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static TeacherQuestionStats empty(String teacherId) {
    return TeacherQuestionStats(teacherId: teacherId);
  }
}

/// Statistics about exam templates and results
class TeacherExamStats {
  final String teacherId;
  final String? courseId;
  final String? courseName;
  final int totalTemplates;
  final int publishedTemplates;
  final int totalExamsTaken;
  final double avgScore;
  final int totalPassed;

  const TeacherExamStats({
    required this.teacherId,
    this.courseId,
    this.courseName,
    this.totalTemplates = 0,
    this.publishedTemplates = 0,
    this.totalExamsTaken = 0,
    this.avgScore = 0.0,
    this.totalPassed = 0,
  });

  factory TeacherExamStats.fromJson(Map<String, dynamic> json) {
    return TeacherExamStats(
      teacherId: json['id_teacher'] as String,
      courseId: json['id_course'] as String?,
      courseName: json['course_name'] as String?,
      totalTemplates: (json['total_templates'] as num?)?.toInt() ?? 0,
      publishedTemplates: (json['published_templates'] as num?)?.toInt() ?? 0,
      totalExamsTaken: (json['total_exams_taken'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      totalPassed: (json['total_passed'] as num?)?.toInt() ?? 0,
    );
  }

  static TeacherExamStats empty(String teacherId) {
    return TeacherExamStats(teacherId: teacherId);
  }

  double get passRate {
    if (totalExamsTaken == 0) return 0.0;
    return (totalPassed / totalExamsTaken) * 100;
  }
}

/// Combined stats for the teacher dashboard
class TeacherDashboardStats {
  final List<TeacherQuestionStats> questionStats;
  final List<TeacherExamStats> examStats;

  const TeacherDashboardStats({
    this.questionStats = const [],
    this.examStats = const [],
  });

  int get totalQuestions =>
      questionStats.fold(0, (sum, s) => sum + s.totalQuestions);

  int get totalTemplates =>
      examStats.fold(0, (sum, s) => sum + s.totalTemplates);

  int get totalExamsTaken =>
      examStats.fold(0, (sum, s) => sum + s.totalExamsTaken);

  double get overallAvgScore {
    if (examStats.isEmpty) return 0.0;
    final total = examStats.fold(0.0, (sum, s) => sum + s.avgScore);
    return total / examStats.length;
  }
}
