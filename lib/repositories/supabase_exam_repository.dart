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
          .from('exams')
          .select('*, courses!inner(course_key)')
          .eq('courses.course_key', courseKey)
          .eq('is_active', true)
          .single();

      return Exam(
        id: response['id'] as String,
        courseId: response['course_id'] as String,
        title: response['title'] as String,
        description: response['description'] as String? ?? '',
        totalAvailableQuestions: response['total_available_questions'] as int? ?? 0,
        timeLimitMinutes: response['time_limit_minutes'] as int?,
        passingScorePercentage: (response['passing_score_percentage'] as num?)?.toDouble() ?? 70.0,
        isActive: response['is_active'] as bool? ?? true,
      );
    } catch (error) {
      throw ExamRepositoryException(
        'Não foi possível carregar os metadados da prova: ${error.toString()}',
      );
    }
  }

  @override
  Future<int> verifyAvailableQuestions(String examId) async {
    try {
      final response = await _client
          .from('questions')
          .select('id')
          .eq('exam_id', examId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (error) {
      throw ExamRepositoryException(
        'Não foi possível verificar questões disponíveis: ${error.toString()}',
      );
    }
  }
}
