import 'package:supabase_flutter/supabase_flutter.dart';

import 'exam_repository.dart';
import 'exam_repository_types.dart';

class SupabaseExamRepository implements ExamRepository {
  SupabaseExamRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<Exam> fetchExamByCourseKey(String courseKey) async {
    try {
      final response = await _client
          .from('exam')
          .select(
              'id, id_course, title, description, total_available_questions, time_limit_minutes, passing_score_percentage, is_active, created_at, updated_at, course:course!inner(course_key)')
          .eq('course.course_key', courseKey)
          .eq('is_active', true)
          .single();

      return Exam(
        id: response['id'] as String,
        courseId: response['id_course'] as String,
        title: response['title'] as String,
        description: response['description'] as String? ?? '',
        totalAvailableQuestions:
            response['total_available_questions'] as int? ?? 0,
        timeLimitMinutes: response['time_limit_minutes'] as int?,
        passingScorePercentage:
            (response['passing_score_percentage'] as num?)?.toDouble() ?? 70.0,
        isActive: response['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'] as String)
            : null,
      );
    } catch (error) {
      if (error is ExamRepositoryException) {
        rethrow;
      }
      throw ExamRepositoryException(
        'Não foi possível carregar os metadados da prova: ${error.toString()}',
      );
    }

  }

  @override
  Future<int> verifyAvailableQuestions(String examId) async {
    try {
      final examRecord = await _client
          .from('exam')
          .select('id_course')
          .eq('id', examId)
          .maybeSingle();

      if (examRecord == null || examRecord['id_course'] == null) {
        throw ExamRepositoryException(
          'Metadados do exame não encontrados para o id informado.',
        );
      }

      final response = await _client
          .from('question')
          .select('id')
          .eq('id_course', examRecord['id_course'] as String)
          .eq('is_active', true);

      return (response as List).length;
    } catch (error) {
      if (error is ExamRepositoryException) {
        rethrow;
      }
      throw ExamRepositoryException(
        'Não foi possível verificar questões disponíveis: ${error.toString()}',
      );
    }

  }
}
