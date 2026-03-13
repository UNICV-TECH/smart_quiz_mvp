import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_stats.dart';
import '../models/admin_user.dart';
import '../models/exam_template.dart';
import 'admin_repository.dart';
import 'admin_repository_types.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  // ============================================
  // Analytics
  // ============================================

  @override
  Future<AdminPlatformStats> getPlatformStats() async {
    try {
      final response =
          await _client.from('admin_platform_stats').select().single();
      return AdminPlatformStats.fromJson(response);
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao carregar estatísticas da plataforma: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<AdminCourseStats>> getCourseStats() async {
    try {
      final response = await _client.from('admin_course_stats').select();
      return (response as List)
          .map((json) => AdminCourseStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao carregar estatísticas por curso: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<AdminMonthlyActivity>> getMonthlyActivity() async {
    try {
      final response = await _client.from('admin_monthly_activity').select();
      return (response as List)
          .map((json) =>
              AdminMonthlyActivity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao carregar atividade mensal: ${error.toString()}',
      );
    }
  }

  // ============================================
  // User Management
  // ============================================

  @override
  Future<List<AdminUserEntry>> listUsers(AdminUsersFilter filter) async {
    try {
      final response = await _client.rpc('admin_list_users', params: {
        'p_role': filter.role,
        'p_is_active': filter.isActive,
        'p_search': filter.search,
      });
      return (response as List)
          .map((json) => AdminUserEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao listar usuários: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _client.rpc('admin_update_user_role', params: {
        'p_user_id': userId,
        'p_new_role': newRole,
      });
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao atualizar papel do usuário: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _client.rpc('admin_toggle_user_active', params: {
        'p_user_id': userId,
        'p_is_active': isActive,
      });
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao alterar status do usuário: ${error.toString()}',
      );
    }
  }

  @override
  Future<void> updateUserPassword(String userId, String newPassword) async {
    try {
      await _client.rpc('admin_update_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
      });
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao alterar senha do usuário: ${error.toString()}',
      );
    }
  }

  // ============================================
  // Content Management
  // ============================================

  @override
  Future<List<AdminQuestionEntry>> listQuestions(
      AdminQuestionsFilter filter) async {
    try {
      final response = await _client.rpc('admin_list_questions', params: {
        'p_course_id': filter.courseId,
        'p_teacher_id': filter.teacherId,
        'p_active_only': filter.activeOnly,
      });
      return (response as List)
          .map((json) =>
              AdminQuestionEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao listar questões: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<ExamTemplate>> listTemplates() async {
    try {
      final response = await _client
          .from('exam_template')
          .select('*, course:id_course(title, name)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => ExamTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao listar templates: ${error.toString()}',
      );
    }
  }

  @override
  Future<List<AdminCourseEntry>> listCourses() async {
    try {
      final response =
          await _client.from('course').select().order('name');
      return (response as List)
          .map((json) =>
              AdminCourseEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw AdminRepositoryException(
        'Erro ao listar cursos: ${error.toString()}',
      );
    }
  }
}
