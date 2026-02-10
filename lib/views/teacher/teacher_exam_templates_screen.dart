import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../services/session_manager.dart';
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/exam_template_view_model.dart';

/// Tela de listagem e gerenciamento de templates de prova
class TeacherExamTemplatesScreen extends StatelessWidget {
  const TeacherExamTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final teacherId = sessionManager.currentUser?.id ?? '';

    return ChangeNotifierProvider(
      create: (context) => ExamTemplateViewModel(
        teacherId: teacherId,
        teacherRepository: context.read<TeacherRepository?>(),
        courseRepository: context.read<CourseRepository?>(),
      )..loadInitialData(),
      child: const _ExamTemplatesContent(),
    );
  }
}

class _ExamTemplatesContent extends StatelessWidget {
  const _ExamTemplatesContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExamTemplateViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, viewModel),

          // Messages
          if (viewModel.errorMessage != null)
            _buildMessage(viewModel.errorMessage!, isError: true),
          if (viewModel.successMessage != null)
            _buildMessage(viewModel.successMessage!, isError: false),

          // Content
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.templates.isEmpty
                    ? _buildEmptyState(context, viewModel)
                    : _buildTemplateList(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExamTemplateViewModel viewModel) {
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
                  'Templates de Prova',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Crie e gerencie seus modelos de prova',
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
            'Publicados',
            viewModel.publishedCount.toString(),
            AppColors.green,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Rascunhos',
            viewModel.draftCount.toString(),
            Colors.orange,
          ),
          const SizedBox(width: 16),
          // New template button
          ElevatedButton.icon(
            onPressed: () => _showTemplateEditor(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text('Novo Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
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

  Widget _buildEmptyState(
      BuildContext context, ExamTemplateViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum template criado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie seu primeiro template de prova',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showTemplateEditor(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text('Criar Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(
      BuildContext context, ExamTemplateViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: viewModel.templates.length,
      itemBuilder: (context, index) {
        final template = viewModel.templates[index];
        return _TemplateCard(
          name: template.name,
          description: template.description,
          courseName: template.courseName,
          questionCount: template.questionCount,
          timeLimitMinutes: template.timeLimitMinutes,
          passingScore: template.passingScorePercentage,
          isPublished: template.isPublished,
          createdAt: template.createdAt,
          onEdit: () async {
            await viewModel.selectTemplate(template.id);
            if (context.mounted) {
              _showTemplateEditor(context, viewModel, isEditing: true);
            }
          },
          onPublish: template.isPublished
              ? () => viewModel.unpublishTemplate(template.id)
              : () => viewModel.publishTemplate(template.id),
          onDelete: () async {
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed == true) {
              await viewModel.deleteTemplate(template.id);
            }
          },
        );
      },
    );
  }

  void _showTemplateEditor(
    BuildContext context,
    ExamTemplateViewModel viewModel, {
    bool isEditing = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: viewModel,
        child: _TemplateEditorDialog(isEditing: isEditing),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusao'),
        content: const Text(
          'Tem certeza que deseja excluir este template? '
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

class _TemplateCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? courseName;
  final int questionCount;
  final int? timeLimitMinutes;
  final double passingScore;
  final bool isPublished;
  final DateTime createdAt;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.name,
    this.description,
    this.courseName,
    required this.questionCount,
    this.timeLimitMinutes,
    required this.passingScore,
    required this.isPublished,
    required this.createdAt,
    required this.onEdit,
    required this.onPublish,
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
            color: isPublished ? AppColors.green : Colors.orange,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // Info row
            Row(
              children: [
                if (courseName != null) ...[
                  _buildInfoChip(Icons.school_outlined, courseName!),
                  const SizedBox(width: 16),
                ],
                _buildInfoChip(
                    Icons.format_list_numbered, '$questionCount questoes'),
                const SizedBox(width: 16),
                _buildInfoChip(
                  Icons.timer_outlined,
                  timeLimitMinutes != null
                      ? '$timeLimitMinutes min'
                      : 'Sem limite',
                ),
                const SizedBox(width: 16),
                _buildInfoChip(Icons.check_circle_outline,
                    'Aprovacao: ${passingScore.toInt()}%'),
              ],
            ),
            const SizedBox(height: 16),

            // Actions row
            Row(
              children: [
                Text(
                  'Criado em ${_formatDate(createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onPublish,
                  icon: Icon(
                    isPublished
                        ? Icons.unpublished_outlined
                        : Icons.publish_outlined,
                    size: 18,
                  ),
                  label: Text(isPublished ? 'Despublicar' : 'Publicar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Excluir'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublished
            ? AppColors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPublished
              ? AppColors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublished ? Icons.check_circle : Icons.edit_note,
            size: 16,
            color: isPublished ? AppColors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isPublished ? 'Publicado' : 'Rascunho',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPublished ? AppColors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _TemplateEditorDialog extends StatefulWidget {
  final bool isEditing;

  const _TemplateEditorDialog({required this.isEditing});

  @override
  State<_TemplateEditorDialog> createState() => _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends State<_TemplateEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ExamTemplateViewModel>();
    _nameController = TextEditingController(text: viewModel.templateName);
    _descriptionController =
        TextEditingController(text: viewModel.templateDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExamTemplateViewModel>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Editar Template' : 'Novo Template',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      viewModel.clearSelection();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Description
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Template *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: viewModel.setTemplateName,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descricao',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: viewModel.setTemplateDescription,
                    ),
                    const SizedBox(height: 24),

                    // Course selection
                    DropdownButtonFormField<String>(
                      initialValue: viewModel.selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Curso *',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.courses.map((course) {
                        return DropdownMenuItem(
                          value: course.id,
                          child: Text(course.title),
                        );
                      }).toList(),
                      onChanged: (value) => viewModel.setCourse(value),
                    ),
                    const SizedBox(height: 24),

                    // Settings
                    const Text(
                      'Configuracoes da Prova',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: viewModel.questionCount.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Numero de questoes',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final count = int.tryParse(value);
                              if (count != null) {
                                viewModel.setQuestionCount(count);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                viewModel.timeLimitMinutes?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Tempo limite (min)',
                              border: OutlineInputBorder(),
                              hintText: 'Vazio = sem limite',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final minutes =
                                  value.isEmpty ? null : int.tryParse(value);
                              viewModel.setTimeLimitMinutes(minutes);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                viewModel.passingScorePercentage.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Nota de aprovacao (%)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final score = double.tryParse(value);
                              if (score != null) {
                                viewModel.setPassingScorePercentage(score);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Toggles
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        _buildToggle(
                          'Embaralhar questoes',
                          viewModel.shuffleQuestions,
                          viewModel.setShuffleQuestions,
                        ),
                        _buildToggle(
                          'Embaralhar alternativas',
                          viewModel.shuffleChoices,
                          viewModel.setShuffleChoices,
                        ),
                        _buildToggle(
                          'Mostrar gabarito',
                          viewModel.showCorrectAnswers,
                          viewModel.setShowCorrectAnswers,
                        ),
                        _buildToggle(
                          'Permitir revisao',
                          viewModel.allowReview,
                          viewModel.setAllowReview,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: const Border(
                  top: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      viewModel.clearSelection();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: viewModel.isSaving || !viewModel.isFormValid
                        ? null
                        : () async {
                            final success = await viewModel.saveTemplate();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: viewModel.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.isEditing ? 'Atualizar' : 'Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.green,
        ),
        Text(label),
      ],
    );
  }
}
