import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../services/session_manager.dart';
import '../../ui/components/default_input_select.dart' hide Preview;
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/question_list_view_model.dart';

/// Tela de listagem de questoes do professor
class TeacherQuestionListScreen extends StatelessWidget {
  const TeacherQuestionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final teacherId = sessionManager.currentUser?.id ?? '';
    final teacherRepo = context.read<TeacherRepository?>();
    final courseRepo = context.read<CourseRepository?>();

    if (teacherRepo == null || courseRepo == null) {
      return const Center(
        child: Text('Erro: conexao com o servidor nao disponivel'),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => QuestionListViewModel(
        teacherId: teacherId,
        teacherRepository: teacherRepo,
        courseRepository: courseRepo,
      )..loadInitialData(),
      child: const _QuestionListContent(),
    );
  }
}

class _QuestionListContent extends StatelessWidget {
  const _QuestionListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuestionListViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, viewModel),

          // Filters
          _buildFilters(context, viewModel),

          // Messages
          if (viewModel.errorMessage != null)
            _buildMessage(viewModel.errorMessage!, isError: true),
          if (viewModel.successMessage != null)
            _buildMessage(viewModel.successMessage!, isError: false),

          // Content
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.questions.isEmpty
                    ? _buildEmptyState()
                    : _buildQuestionList(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuestionListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Questoes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie suas questoes criadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Stats
          _buildStatChip(
            'Total',
            viewModel.totalQuestions.toString(),
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Ativas',
            viewModel.activeQuestions.toString(),
            AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, QuestionListViewModel viewModel) {
    final courseOptions = viewModel.courses
        .map((c) => SelectOption(value: c.id, label: c.title))
        .toList();

    final categoryOptions = viewModel.categories
        .map((c) => SelectOption(value: c.id, label: c.name))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectPesquisa(
              label: 'Curso',
              options: courseOptions,
              value: viewModel.filterCourseId,
              placeholder: 'Todos os cursos',
              onChanged: viewModel.setFilterCourse,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SelectPesquisa(
              label: 'Categoria',
              options: categoryOptions,
              value: viewModel.filterCategoryId,
              placeholder: 'Todas as categorias',
              onChanged: viewModel.setFilterCategory,
              enabled: viewModel.filterCourseId != null,
            ),
          ),
          const SizedBox(width: 16),
          // Toggle for inactive questions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mostrar inativas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Switch(
                value: viewModel.showInactiveOnly,
                onChanged: (_) => viewModel.toggleShowInactive(),
                activeTrackColor: AppColors.green.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.green;
                  }
                  return null;
                }),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Clear filters button
          if (viewModel.filterCourseId != null ||
              viewModel.filterCategoryId != null ||
              viewModel.showInactiveOnly)
            TextButton.icon(
              onPressed: viewModel.clearFilters,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar filtros'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.red.withValues(alpha: 0.1)
            : AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? AppColors.red : AppColors.green,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.red : AppColors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.red : AppColors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma questao encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira questao no menu "Nova Questao"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(
      BuildContext context, QuestionListViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: viewModel.questions.length,
      itemBuilder: (context, index) {
        final question = viewModel.questions[index];
        return _QuestionCard(
          enunciation: question.enunciationPreview,
          difficultyLevel: question.difficultyLabel,
          points: question.points,
          categoryName: question.categoryName,
          courseName: question.courseName,
          answerCount: question.answerCount,
          isActive: question.isActive,
          createdAt: question.createdAt,
          onEdit: () async {
            final result = await context.push<bool>(
              '/teacher/questions/${question.id}/edit',
            );
            if (result == true) {
              viewModel.loadQuestions();
            }
          },
          onDelete: () async {
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed == true) {
              await viewModel.deleteQuestion(question.id);
            }
          },
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusao'),
        content: const Text(
          'Tem certeza que deseja excluir esta questao? '
          'Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String enunciation;
  final String difficultyLevel;
  final double points;
  final String? categoryName;
  final String? courseName;
  final int answerCount;
  final bool isActive;
  final DateTime createdAt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.enunciation,
    required this.difficultyLevel,
    required this.points,
    this.categoryName,
    this.courseName,
    required this.answerCount,
    required this.isActive,
    required this.createdAt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.green : Colors.grey,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: badges and actions
            Row(
              children: [
                if (courseName != null) _buildBadge(courseName!, Colors.blue),
                if (categoryName != null) ...[
                  const SizedBox(width: 8),
                  _buildBadge(categoryName!, Colors.purple),
                ],
                const Spacer(),
                _buildBadge(
                  difficultyLevel,
                  _getDifficultyColor(difficultyLevel),
                ),
                const SizedBox(width: 8),
                _buildBadge('$points pts', Colors.orange),
                const SizedBox(width: 8),
                if (!isActive)
                  _buildBadge('Inativa', Colors.grey),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Editar questao',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Excluir questao',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Enunciation
            Text(
              enunciation,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Bottom row: metadata
            Row(
              children: [
                Icon(Icons.format_list_bulleted,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$answerCount alternativas',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
