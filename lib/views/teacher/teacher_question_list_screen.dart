import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../ui/components/default_input_select.dart' hide Preview;
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/question_list_view_model.dart';

/// Tela de listagem de questões do professor
class TeacherQuestionListScreen extends StatelessWidget {
  const TeacherQuestionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherRepo = context.read<TeacherRepository?>();
    final courseRepo = context.read<CourseRepository?>();

    if (teacherRepo == null || courseRepo == null) {
      return const Center(
        child: Text('Erro: conexão com o servidor não disponível'),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => QuestionListViewModel(
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
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 800 ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Banco de Questoes',
=======
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Banco de Questões',
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
<<<<<<< HEAD
              ),
              IconButton(
                onPressed: viewModel.loadQuestions,
                icon: const Icon(Icons.refresh),
                tooltip: 'Recarregar questoes',
                color: const Color(0xFF2E7D32),
              ),
            ],
          ),
          const Text(
            'Gerencie todas as questoes cadastradas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
=======
                SizedBox(height: 4),
                Text(
                  'Gerencie todas as questões cadastradas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatChip(
                'Total',
                viewModel.totalQuestions.toString(),
                Colors.blue,
              ),
              _buildStatChip(
                'Ativas',
                viewModel.activeQuestions.toString(),
                AppColors.green,
              ),
              _buildStatChip(
                'Inativas',
                viewModel.inactiveQuestions.toString(),
                Colors.grey,
              ),
            ],
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Inativas',
            viewModel.inactiveQuestions.toString(),
            Colors.grey,
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: viewModel.loadQuestions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar questoes',
            color: const Color(0xFF2E7D32),
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
    final isMobile = MediaQuery.of(context).size.width < 800;

    final hasFilters = viewModel.filterCourseId != null ||
        viewModel.filterSubjectId != null ||
        viewModel.filterCategoryId != null ||
        viewModel.filterOrigin != null ||
        viewModel.showInactiveOnly;

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFilterBottomSheet(context, viewModel),
                icon: Badge(
                  isLabelVisible: hasFilters,
                  backgroundColor: AppColors.green,
                  smallSize: 8,
                  child: const Icon(Icons.filter_list, size: 20),
                ),
                label: Text(hasFilters ? 'Filtros ativos' : 'Filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      hasFilters ? AppColors.green : Colors.grey[700],
                  side: BorderSide(
                    color: hasFilters
                        ? AppColors.green
                        : Colors.grey[300]!,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: viewModel.clearFilters,
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Limpar filtros',
                style: IconButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return _buildDesktopFilters(context, viewModel, hasFilters);
  }

  void _showFilterBottomSheet(
      BuildContext context, QuestionListViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<QuestionListViewModel>(
            builder: (context, vm, _) {
              final courseOptions = vm.courses
                  .map((c) => SelectOption(value: c.id, label: c.title))
                  .toList();
              final subjectOptions = vm.subjects
                  .map((s) => SelectOption(value: s.id, label: s.name))
                  .toList();
              final categoryOptions = vm.categories
                  .map((c) => SelectOption(value: c.id, label: c.name))
                  .toList();
              const originOptions = [
                SelectOption(value: 'enade', label: 'ENADE'),
                SelectOption(value: 'teacher', label: 'Professor'),
              ];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list,
                                color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            const Text(
                              'Filtros',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                vm.clearFilters();
                                Navigator.pop(context);
                              },
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Filter fields
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectPesquisa(
                                label: 'Curso',
                                options: courseOptions,
                                value: vm.filterCourseId,
                                placeholder: 'Todos os cursos',
                                onChanged: vm.setFilterCourse,
                              ),
                              const SizedBox(height: 16),
                              SelectPesquisa(
                                label: 'Materia',
                                options: subjectOptions,
                                value: vm.filterSubjectId,
                                placeholder: 'Todas as materias',
                                onChanged: vm.setFilterSubject,
                                enabled: vm.filterCourseId != null,
                              ),
                              const SizedBox(height: 16),
                              SelectPesquisa(
                                label: 'Categoria',
                                options: categoryOptions,
                                value: vm.filterCategoryId,
                                placeholder: 'Todas as categorias',
                                onChanged: vm.setFilterCategory,
                                enabled: vm.filterCourseId != null,
                              ),
                              const SizedBox(height: 16),
                              SelectPesquisa(
                                label: 'Origem',
                                options: originOptions,
                                value: vm.filterOrigin,
                                placeholder: 'Todas as origens',
                                onChanged: vm.setFilterOrigin,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Mostrar inativas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch(
                                    value: vm.showInactiveOnly,
                                    onChanged: (_) =>
                                        vm.toggleShowInactive(),
                                    activeTrackColor: AppColors.green
                                        .withValues(alpha: 0.5),
                                    thumbColor:
                                        WidgetStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return AppColors.green;
                                      }
                                      return null;
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Apply button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Aplicar Filtros',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopFilters(BuildContext context,
      QuestionListViewModel viewModel, bool hasFilters) {
    final courseOptions = viewModel.courses
        .map((c) => SelectOption(value: c.id, label: c.title))
        .toList();
<<<<<<< HEAD
    final subjectOptions = viewModel.subjects
        .map((s) => SelectOption(value: s.id, label: s.name))
        .toList();
=======

    final subjectOptions = viewModel.subjects
        .map((s) => SelectOption(value: s.id, label: s.name))
        .toList();

>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
    final categoryOptions = viewModel.categories
        .map((c) => SelectOption(value: c.id, label: c.name))
        .toList();
    const originOptions = [
      SelectOption(value: 'enade', label: 'ENADE'),
      SelectOption(value: 'teacher', label: 'Professor'),
    ];

    const originOptions = [
      SelectOption(value: 'enade', label: 'ENADE'),
      SelectOption(value: 'teacher', label: 'Professor'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 200,
            child: SelectPesquisa(
              label: 'Curso',
              options: courseOptions,
              value: viewModel.filterCourseId,
              placeholder: 'Todos os cursos',
              onChanged: viewModel.setFilterCourse,
            ),
          ),
          SizedBox(
            width: 200,
            child: SelectPesquisa(
              label: 'Materia',
              options: subjectOptions,
              value: viewModel.filterSubjectId,
              placeholder: 'Todas as materias',
              onChanged: viewModel.setFilterSubject,
              enabled: viewModel.filterCourseId != null,
            ),
          ),
          SizedBox(
            width: 200,
            child: SelectPesquisa(
              label: 'Categoria',
              options: categoryOptions,
              value: viewModel.filterCategoryId,
              placeholder: 'Todas as categorias',
              onChanged: viewModel.setFilterCategory,
              enabled: viewModel.filterCourseId != null,
            ),
          ),
          SizedBox(
            width: 200,
            child: SelectPesquisa(
              label: 'Origem',
              options: originOptions,
              value: viewModel.filterOrigin,
              placeholder: 'Todas as origens',
              onChanged: viewModel.setFilterOrigin,
            ),
          ),
<<<<<<< HEAD
=======
          // Toggle for inactive questions
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
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
<<<<<<< HEAD
          if (hasFilters)
=======
          // Clear filters button
          if (viewModel.filterCourseId != null ||
              viewModel.filterSubjectId != null ||
              viewModel.filterCategoryId != null ||
              viewModel.filterOrigin != null ||
              viewModel.showInactiveOnly)
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
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
            'Nenhuma questão encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira questão no menu "Nova Questão"',
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
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 800 ? 12 : 24),
      itemCount: viewModel.questions.length,
      itemBuilder: (context, index) {
        final question = viewModel.questions[index];
        return _QuestionCard(
          enunciation: question.enunciationPreview,
          difficultyLevel: question.difficultyLabel,
          points: question.points,
          categoryName: question.categoryName,
          subjectName: question.subjectName,
          courseName: question.courseName,
          teacherName: question.teacherName,
          answerCount: question.answerCount,
          isActive: question.isActive,
          isEnade: question.isEnade,
          createdAt: question.createdAt,
          onEdit: () async {
            final result = await context.push<bool>(
              '/teacher/questions/${question.id}/edit',
            );
            if (result == true) {
              viewModel.loadQuestions();
            }
          },
          onToggleActive: () async {
            await viewModel.toggleQuestionActive(question.id, question.isActive);
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
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta questão? '
          'Esta ação não pode ser desfeita.',
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
  final String? subjectName;
  final String? courseName;
  final String? teacherName;
  final int answerCount;
  final bool isActive;
  final bool isEnade;
  final DateTime createdAt;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.enunciation,
    required this.difficultyLevel,
    required this.points,
    this.categoryName,
    this.subjectName,
    this.courseName,
    this.teacherName,
    required this.answerCount,
    required this.isActive,
    this.isEnade = false,
    required this.createdAt,
    required this.onEdit,
    required this.onToggleActive,
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
            // Top row: badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(
                  isEnade ? 'ENADE' : 'Professor',
                  isEnade ? const Color(0xFF1565C0) : const Color(0xFF00897B),
                ),
<<<<<<< HEAD
                if (courseName != null)
                  _buildBadge(courseName!, Colors.blue),
                if (subjectName != null)
                  _buildBadge(subjectName!, Colors.teal),
                if (categoryName != null)
=======
                if (courseName != null) ...[
                  const SizedBox(width: 8),
                  _buildBadge(courseName!, Colors.blue),
                ],
                if (subjectName != null) ...[
                  const SizedBox(width: 8),
                  _buildBadge(subjectName!, Colors.teal),
                ],
                if (categoryName != null) ...[
                  const SizedBox(width: 8),
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
                  _buildBadge(categoryName!, Colors.purple),
                _buildBadge(
                  difficultyLevel,
                  _getDifficultyColor(difficultyLevel),
                ),
                _buildBadge('$points pts', Colors.orange),
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

<<<<<<< HEAD
            // Bottom row: metadata
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
=======
            // Bottom row: metadata and actions
            Row(
>>>>>>> 0fdd1bbc10f6000dc33ac41f1c649250e3c7f575
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_list_bulleted,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$answerCount alternativas',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (teacherName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        teacherName!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tooltip(
                  message: isActive ? 'Desativar questao' : 'Ativar questao',
                  child: InkWell(
                    onTap: onToggleActive,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AppColors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 16,
                            color: isActive ? AppColors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Ativa' : 'Inativa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Editar questao',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Excluir questao',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                if (teacherName != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    teacherName!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
                const Spacer(),
                // Toggle active/inactive
                Tooltip(
                  message: isActive ? 'Desativar questao' : 'Ativar questao',
                  child: InkWell(
                    onTap: onToggleActive,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AppColors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 16,
                            color: isActive ? AppColors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Ativa' : 'Inativa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
