import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_template.dart';
import 'published_exam_repository.dart';

class SupabasePublishedExamRepository implements PublishedExamRepository {
  SupabasePublishedExamRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<ExamTemplate>> fetchPublishedTemplates({
    required String courseId,
  }) async {
    try {
      final response = await _client
          .from('exam_template')
          .select('*, teacher:id_teacher(first_name, surename)')
          .eq('id_course', courseId)
          .eq('is_published', true)
          .eq('is_active', true)
          .order('name');

      return (response as List).map((raw) {
        final json = Map<String, dynamic>.from(raw as Map<String, dynamic>);
        final teacherData = json['teacher'] as Map<String, dynamic>?;
        if (teacherData != null) {
          final firstName = teacherData['first_name'] as String? ?? '';
          final surname = teacherData['surename'] as String? ?? '';
          final fullName = '$firstName $surname'.trim();
          json['teacher'] = {'name': fullName.isNotEmpty ? fullName : null};
        }
        return ExamTemplate.fromJson(json);
      }).toList();
    } catch (error) {
      throw PublishedExamRepositoryException(
        'Erro ao carregar provas publicadas: ${error.toString()}',
      );
    }
  }

  @override
  Future<String> startExamFromTemplate({
    required String templateId,
    required String userId,
  }) async {
    try {
      final response = await _client.rpc(
        'generate_exam_from_template',
        params: {
          'p_template_id': templateId,
          'p_user_id': userId,
        },
      );

      return response as String;
    } catch (error) {
      throw PublishedExamRepositoryException(
        'Erro ao iniciar prova: ${error.toString()}',
      );
    }
  }
}
