import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exam_attempt_repository.dart';
import 'exam_attempt_repository_types.dart';
import '../models/user_response.dart' as models;

class SupabaseExamAttemptRepository implements ExamAttemptRepository {
  SupabaseExamAttemptRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<ExamAttemptCreated> createAttempt({
    required String userId,
    required String examId,
    required String courseId,
    required int questionCount,
  }) async {
    try {
      final response = await _client
          .from('user_exam_attempts')
          .insert({
            'user_id': userId,
            'exam_id': examId,
            'course_id': courseId,
            'question_count': questionCount,
            'status': 'in_progress',
          })
          .select()
          .single();

      return ExamAttemptCreated(
        attemptId: response['id'] as String,
        startedAt: DateTime.parse(response['started_at'] as String),
      );
    } catch (error) {
      throw ExamAttemptRepositoryException(
        'Não foi possível criar a tentativa de prova: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> insertResponses({
    required String attemptId,
    required List<UserResponseInput> responses,
  }) async {
    try {
      final data = responses.map((response) {
        return {
          'attempt_id': attemptId,
          'question_id': response.questionId,
          'answer_choice_id': response.answerChoiceId,
          'selected_choice_key': response.selectedChoiceKey,
          'is_correct': response.isCorrect,
          'points_earned': response.pointsEarned,
          'time_spent_seconds': response.timeSpentSeconds,
          'answered_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _client.from('user_responses').insert(data);
    } catch (error) {
      throw ExamAttemptRepositoryException(
        'Não foi possível salvar as respostas: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateCompletionStatus({
    required String attemptId,
    required int durationSeconds,
    required double totalScore,
    required double percentageScore,
  }) async {
    try {
      await _client.from('user_exam_attempts').update({
        'completed_at': DateTime.now().toIso8601String(),
        'duration_seconds': durationSeconds,
        'total_score': totalScore,
        'percentage_score': percentageScore,
        'status': 'completed',
      }).match({'id': attemptId});
    } catch (error) {
      throw ExamAttemptRepositoryException(
        'Não foi possível atualizar o status da prova: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<ExamAttemptHistory>> fetchUserAttempts({
    required String userId,
    String? courseId,
  }) async {
    try {
      dynamic query = _client
          .from('user_exam_attempts')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      if (courseId != null) {
        query = query.eq('course_id', courseId);
      }

      // Garantir que buscamos todos os registros (até 1000 por padrão do Supabase)
      final response = await query;

      final responseList = response as List;
      debugPrint(
          'SupabaseExamAttemptRepository: Retornados ${responseList.length} registros do banco');

      final attempts = responseList
          .map((json) => ExamAttemptHistory(
                id: json['id'] as String,
                examId: json['exam_id'] as String,
                courseId: json['course_id'] as String,
                questionCount: json['question_count'] as int,
                startedAt: DateTime.parse(json['started_at'] as String),
                completedAt: json['completed_at'] != null
                    ? DateTime.parse(json['completed_at'] as String)
                    : null,
                durationSeconds: json['duration_seconds'] as int?,
                totalScore: (json['total_score'] as num?)?.toDouble(),
                percentageScore: (json['percentage_score'] as num?)?.toDouble(),
                status: json['status'] as String,
              ))
          .toList();

      return attempts;
    } catch (error) {
      throw ExamAttemptRepositoryException(
        'Não foi possível carregar o histórico de provas: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<models.UserResponse>> fetchAttemptResponses({
    required String attemptId,
  }) async {
    try {
      final response = await _client
          .from('user_responses')
          .select()
          .eq('attempt_id', attemptId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => models.UserResponse.fromJson(json))
          .toList();
    } catch (error) {
      throw ExamAttemptRepositoryException(
        'Não foi possível carregar as respostas da prova: ${error.toString()}',
      );
    }
  }
}
