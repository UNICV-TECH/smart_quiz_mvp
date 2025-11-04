import 'course_repository_types.dart';

abstract class CourseRepository {
  Future<List<Course>> fetchActiveCourses();
}
