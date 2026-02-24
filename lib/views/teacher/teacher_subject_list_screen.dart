import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../ui/components/default_input_select.dart' hide Preview;
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/subject_list_view_model.dart';

class TeacherSubjectListScreen extends StatelessWidget {
  const TeacherSubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherRepo = context.read<TeacherRepository?>();
    final courseRepo = context.read<CourseRepository?>();

    if (teacherRepo == null || courseRepo == null) {
      return const Center(
        child: Text('Erro: conexao com o servidor nao disponivel'),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => SubjectListViewModel(
        teacherRepository: teacherRepo,
        courseRepository: courseRepo,
      )..loadInitialData(),
      child: const _SubjectListContent(),
    );
  }
}

class _SubjectListContent extends StatelessWidget {
  const _SubjectListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SubjectListViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, viewModel),
          _buildFilters(context, viewModel),
          if (viewModel.errorMessage != null)
            _buildMessage(viewModel.errorMessage!, isError: true),
          if (viewModel.successMessage != null)
            _buildMessage(viewModel.successMessage!, isError: false),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.selectedCourseId == null
                    ? _buildSelectCourseState()
                    : viewModel.subjects.isEmpty
                        ? _buildEmptyState()
                        : _buildSubjectList(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubjectListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matérias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie as matérias dos cursos',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (viewModel.selectedCourseId != null)
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, viewModel),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nova Matéria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, SubjectListViewModel viewModel) {
    final courseOptions = viewModel.courses
        .map((c) => SelectOption(value: c.id, label: c.title))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectPesquisa(
              label: 'Curso',
              options: courseOptions,
              value: viewModel.selectedCourseId,
              placeholder: 'Selecione um curso',
              onChanged: viewModel.setFilterCourse,
            ),
          ),
          const Spacer(),
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
        border: Border.all(color: isError ? AppColors.red : AppColors.green),
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

  Widget _buildSelectCourseState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Selecione um curso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um curso acima para ver e gerenciar suas matérias',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma matéria encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em "Nova Matéria" para criar a primeira',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(
      BuildContext context, SubjectListViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: viewModel.subjects.length,
      itemBuilder: (context, index) {
        final subject = viewModel.subjects[index];
        final courseName = viewModel.courses
            .where((c) => c.id == subject.courseId)
            .map((c) => c.title)
            .firstOrNull;

        return _SubjectCard(
          name: subject.name,
          description: subject.description,
          courseName: courseName,
          onEdit: () => _showEditDialog(context, viewModel, subject.id,
              subject.name, subject.description),
          onDelete: () async {
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed == true) {
              await viewModel.deleteSubject(subject.id);
            }
          },
        );
      },
    );
  }

  Future<void> _showCreateDialog(
      BuildContext context, SubjectListViewModel viewModel) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova Matéria'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: Direito Civil',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descrição opcional',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);
              await viewModel.createSubject(
                name: nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context,
      SubjectListViewModel viewModel, String id, String name,
      String? description) async {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: description ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Matéria'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);
              await viewModel.updateSubject(
                subjectId: id,
                name: nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta matéria? '
          'As categorias vinculadas não serão afetadas.',
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

class _SubjectCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? courseName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.name,
    this.description,
    this.courseName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF2E7D32), width: 4),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (courseName != null) ...[
                        const SizedBox(width: 12),
                        _buildBadge(courseName!, Colors.blue),
                      ],
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Editar matéria',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Excluir matéria',
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
}
