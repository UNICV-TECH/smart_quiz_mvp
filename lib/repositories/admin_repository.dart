import '../models/admin_stats.dart';
import '../models/admin_user.dart';
import '../models/exam_template.dart';
import 'admin_repository_types.dart';

/// Repository interface for admin-specific operations
abstract class AdminRepository {
  // ============================================
  // Analytics
  // ============================================

  /// Get platform-wide statistics
  Future<AdminPlatformStats> getPlatformStats();

  /// Get per-course statistics
  Future<List<AdminCourseStats>> getCourseStats();

  /// Get monthly activity data
  Future<List<AdminMonthlyActivity>> getMonthlyActivity();

  // ============================================
  // User Management
  // ============================================

  /// List all users with stats and optional filters
  Future<List<AdminUserEntry>> listUsers(AdminUsersFilter filter);

  /// Update a user's role
  Future<void> updateUserRole(String userId, String newRole);

  /// Toggle a user's active status
  Future<void> toggleUserActive(String userId, bool isActive);

  // ============================================
  // Content Management (global view)
  // ============================================

  /// List all questions globally with teacher info
  Future<List<AdminQuestionEntry>> listQuestions(AdminQuestionsFilter filter);

  /// List all exam templates globally
  Future<List<ExamTemplate>> listTemplates();

  /// List all courses
  Future<List<AdminCourseEntry>> listCourses();
}

/// Question entry with teacher info for admin content view
class AdminQuestionEntry {
  final String id;
  final String enunciation;
  final String? difficultyLevel;
  final double points;
  final bool isActive;
  final String courseName;
  final String teacherName;
  final String teacherEmail;
  final int answerCount;
  final DateTime? createdAt;

  const AdminQuestionEntry({
    required this.id,
    required this.enunciation,
    this.difficultyLevel,
    this.points = 1.0,
    this.isActive = true,
    required this.courseName,
    this.teacherName = '',
    this.teacherEmail = '',
    this.answerCount = 0,
    this.createdAt,
  });

  factory AdminQuestionEntry.fromJson(Map<String, dynamic> json) {
    return AdminQuestionEntry(
      id: json['id'] as String? ?? '',
      enunciation: json['enunciation'] as String? ?? '',
      difficultyLevel: json['difficulty_level'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      courseName: json['course_name'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      teacherEmail: json['teacher_email'] as String? ?? '',
      answerCount: (json['answer_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// Course entry for admin content view
class AdminCourseEntry {
  final String id;
  final String name;
  final String? description;

  const AdminCourseEntry({
    required this.id,
    required this.name,
    this.description,
  });

  factory AdminCourseEntry.fromJson(Map<String, dynamic> json) {
    return AdminCourseEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}
