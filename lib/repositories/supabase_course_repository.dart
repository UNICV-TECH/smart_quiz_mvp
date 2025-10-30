import 'package:supabase_flutter/supabase_flutter.dart';

import 'course_repository.dart';
import 'course_repository_types.dart';

class SupabaseCourseRepository implements CourseRepository {
  SupabaseCourseRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Course>> fetchActiveCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('is_active', true)
          .order('title');

      return (response as List)
          .map((json) => Course(
                id: json['id'] as String,
                courseKey: json['course_key'] as String,
                title: json['title'] as String,
                description: json['description'] as String? ?? '',
                iconKey: json['icon_key'] as String?,
                isActive: json['is_active'] as bool? ?? true,
              ))
          .toList();
    } catch (error) {
      throw CourseRepositoryException(
        'Não foi possível carregar os cursos: ${error.toString()}',
      );
    }
  }
}
