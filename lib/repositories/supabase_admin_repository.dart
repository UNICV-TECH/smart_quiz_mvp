import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_stats.dart';
import '../models/admin_user.dart';
import '../models/exam_template.dart';
import 'admin_repository.dart';
import 'admin_repository_types.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  /// Mapeia mensagens de erro do PostgreSQL para mensagens amigáveis em PT-BR
  static const _errorMessages = <String, String>{
    // Toggle user active
    'Cannot deactivate your own account':
        'Você não pode desativar sua própria conta',
    // Update user role
    'Cannot change your own role':
        'Você não pode alterar seu próprio papel',
    'Invalid role':
        'O papel informado é inválido. Use: student, teacher ou admin',
    // Update user password
    'Use the regular password change for your own account':
        'Para alterar sua própria senha, use a opção no seu perfil',
    'Password must be at least 6 characters':
        'A senha deve ter no mínimo 6 caracteres',
    'User not found':
        'Usuário não encontrado no sistema',
    'Failed to update password: auth user not found':
        'Não foi possível atualizar a senha: usuário não encontrado na autenticação',
    // Access denied
    'Access denied: admin role required':
        'Acesso negado: você precisa ser administrador para realizar esta ação',
  };

  /// Extrai a mensagem amigável de uma exceção do Supabase/PostgreSQL
  String _friendlyMessage(Object error, String fallback) {
    final raw = error.toString();
    for (final entry in _errorMessages.entries) {
      if (raw.contains(entry.key)) {
        return entry.value;
      }
    }
    return fallback;
  }

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
        _friendlyMessage(error, 'Não foi possível carregar as estatísticas da plataforma'),
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
        _friendlyMessage(error, 'Não foi possível carregar as estatísticas por curso'),
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
        _friendlyMessage(error, 'Não foi possível carregar a atividade mensal'),
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
        _friendlyMessage(error, 'Não foi possível carregar a lista de usuários'),
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
        _friendlyMessage(error, 'Não foi possível atualizar o papel do usuário'),
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
        _friendlyMessage(error, 'Não foi possível alterar o status do usuário'),
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
        _friendlyMessage(error, 'Não foi possível alterar a senha do usuário'),
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
        _friendlyMessage(error, 'Não foi possível carregar a lista de questões'),
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
        _friendlyMessage(error, 'Não foi possível carregar os templates de prova'),
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
        _friendlyMessage(error, 'Não foi possível carregar a lista de cursos'),
      );
    }
  }
}
