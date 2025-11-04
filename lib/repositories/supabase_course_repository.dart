import 'package:supabase_flutter/supabase_flutter.dart';

import 'course_repository.dart';
import 'course_repository_types.dart';

class SupabaseCourseRepository implements CourseRepository {
  SupabaseCourseRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Course>> fetchActiveCourses() async {
    try {
      final response = await _client.from('course').select();

      return (response as List)
          .map((json) => Course(
                id: json['id'] as String,
                courseKey: _resolveCourseKey(json),
                title: _resolveTitle(json),
                description: _resolveDescription(json),
                iconKey: _resolveIconKey(json),
                isActive: _resolveIsActive(json),
                createdAt: _resolveCreatedAt(json),
              ))
          .where((course) => course.isActive)
          .toList()
        ..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    } catch (error) {
      throw CourseRepositoryException(
        'Não foi possível carregar os cursos: ${error.toString()}',
      );
    }
  }

  static String _resolveCourseKey(Map<String, dynamic> json) {
    final dynamic courseKey = json['course_key'];
    if (courseKey is String && courseKey.isNotEmpty) {
      return courseKey;
    }

    final String? title = _maybeString(json['title']);
    final String? name = _maybeString(json['name']);
    final String base = title ?? name ?? '';
    if (base.isEmpty) {
      return json['id'] as String;
    }
    return base
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _resolveTitle(Map<String, dynamic> json) {
    return _maybeString(json['title']) ?? _maybeString(json['name']) ?? 'Curso';
  }

  static String _resolveDescription(Map<String, dynamic> json) {
    return _maybeString(json['description']) ??
        _maybeString(json['long_description']) ??
        '';
  }

  static String? _resolveIconKey(Map<String, dynamic> json) {
    return _maybeString(json['icon_key']) ?? _maybeString(json['icon']);
  }

  static bool _resolveIsActive(Map<String, dynamic> json) {
    final dynamic value = json['is_active'];
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowered = value.toLowerCase();
      if (lowered == 'false' || lowered == '0' || lowered == 'inactive') {
        return false;
      }
      if (lowered == 'true' || lowered == '1') {
        return true;
      }
    }
    return true;
  }

  static DateTime _resolveCreatedAt(Map<String, dynamic> json) {
    final dynamic value = json['created_at'];
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  static String? _maybeString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
