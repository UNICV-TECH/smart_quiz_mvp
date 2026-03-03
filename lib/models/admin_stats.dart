/// Platform-wide statistics for admin dashboard
class AdminPlatformStats {
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int totalQuestions;
  final int totalExams;
  final int totalTemplates;
  final int totalCourses;
  final double avgScore;
  final int totalAttempts;

  const AdminPlatformStats({
    this.totalUsers = 0,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalAdmins = 0,
    this.totalQuestions = 0,
    this.totalExams = 0,
    this.totalTemplates = 0,
    this.totalCourses = 0,
    this.avgScore = 0.0,
    this.totalAttempts = 0,
  });

  factory AdminPlatformStats.fromJson(Map<String, dynamic> json) {
    return AdminPlatformStats(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      totalTeachers: (json['total_teachers'] as num?)?.toInt() ?? 0,
      totalAdmins: (json['total_admins'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalExams: (json['total_exams'] as num?)?.toInt() ?? 0,
      totalTemplates: (json['total_templates'] as num?)?.toInt() ?? 0,
      totalCourses: (json['total_courses'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Per-course statistics for admin dashboard
class AdminCourseStats {
  final String courseId;
  final String courseName;
  final int totalQuestions;
  final int totalTemplates;
  final int totalExams;
  final double avgScore;
  final int totalPassed;
  final int totalAttempts;

  const AdminCourseStats({
    required this.courseId,
    required this.courseName,
    this.totalQuestions = 0,
    this.totalTemplates = 0,
    this.totalExams = 0,
    this.avgScore = 0.0,
    this.totalPassed = 0,
    this.totalAttempts = 0,
  });

  factory AdminCourseStats.fromJson(Map<String, dynamic> json) {
    return AdminCourseStats(
      courseId: json['course_id'] as String? ?? '',
      courseName: json['course_name'] as String? ?? '',
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalTemplates: (json['total_templates'] as num?)?.toInt() ?? 0,
      totalExams: (json['total_exams'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      totalPassed: (json['total_passed'] as num?)?.toInt() ?? 0,
      totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
    );
  }

  double get passRate {
    if (totalAttempts == 0) return 0.0;
    return (totalPassed / totalAttempts) * 100;
  }
}

/// Monthly activity data for admin charts
class AdminMonthlyActivity {
  final String month;
  final int totalAttempts;
  final int activeUsers;
  final double avgScore;

  const AdminMonthlyActivity({
    required this.month,
    this.totalAttempts = 0,
    this.activeUsers = 0,
    this.avgScore = 0.0,
  });

  factory AdminMonthlyActivity.fromJson(Map<String, dynamic> json) {
    return AdminMonthlyActivity(
      month: json['month'] as String? ?? '',
      totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
      activeUsers: (json['active_users'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
