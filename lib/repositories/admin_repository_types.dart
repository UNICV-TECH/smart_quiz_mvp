class AdminRepositoryException implements Exception {
  const AdminRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Filter options for listing users
class AdminUsersFilter {
  final String? role;
  final bool? isActive;
  final String? search;

  const AdminUsersFilter({
    this.role,
    this.isActive,
    this.search,
  });
}

/// Filter options for listing questions globally
class AdminQuestionsFilter {
  final String? courseId;
  final String? teacherId;
  final bool activeOnly;

  const AdminQuestionsFilter({
    this.courseId,
    this.teacherId,
    this.activeOnly = false,
  });
}
