class CourseRepositoryException implements Exception {
  const CourseRepositoryException(this.message);

  final String message;
}

class Course {
  const Course({
    required this.id,
    required this.courseKey,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String courseKey;
  final String title;
  final String description;
  final String? iconKey;
  final bool isActive;
  final DateTime createdAt;
}
