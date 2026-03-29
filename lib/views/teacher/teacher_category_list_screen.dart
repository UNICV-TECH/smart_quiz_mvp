import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../ui/components/default_input_select.dart' hide Preview;
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/category_list_view_model.dart';

class TeacherCategoryListScreen extends StatelessWidget {
  const TeacherCategoryListScreen({super.key});

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
      create: (context) => CategoryListViewModel(
        teacherRepository: teacherRepo,
        courseRepository: courseRepo,
      )..loadInitialData(),
      child: const _CategoryListContent(),
    );
  }
}

class _CategoryListContent extends StatelessWidget {
  const _CategoryListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryListViewModel>();

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
                    : viewModel.categories.isEmpty
                        ? _buildEmptyState()
                        : _buildCategoryList(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CategoryListViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 800 ? 12 : 24),
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
                  'Categorias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie as categorias das matérias',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (viewModel.selectedCourseId != null)
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, viewModel),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nova Categoria'),
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

  Widget _buildFilters(BuildContext context, CategoryListViewModel viewModel) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final hasFilters = viewModel.selectedCourseId != null ||
        viewModel.selectedSubjectId != null;

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showFilterBottomSheet(context, viewModel),
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
                    color:
                        hasFilters ? AppColors.green : Colors.grey[300]!,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  viewModel.setFilterCourse(null);
                  viewModel.setFilterSubject(null);
                },
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Limpar filtros',
                style: IconButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ],
        ),
      );
    }

    return _buildDesktopFilters(context, viewModel);
  }

  void _showFilterBottomSheet(
      BuildContext context, CategoryListViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<CategoryListViewModel>(
            builder: (context, vm, _) {
              final courseOptions = vm.courses
                  .map((c) => SelectOption(value: c.id, label: c.title))
                  .toList();
              final subjectOptions = vm.subjects
                  .map((s) => SelectOption(value: s.id, label: s.name))
                  .toList();

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                              vm.setFilterCourse(null);
                              vm.setFilterSubject(null);
                              Navigator.pop(context);
                            },
                            child: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SelectPesquisa(
                            label: 'Curso',
                            options: courseOptions,
                            value: vm.selectedCourseId,
                            placeholder: 'Selecione um curso',
                            onChanged: vm.setFilterCourse,
                          ),
                          const SizedBox(height: 16),
                          SelectPesquisa(
                            label: 'Matéria',
                            options: subjectOptions,
                            value: vm.selectedSubjectId,
                            placeholder: vm.selectedCourseId != null
                                ? 'Todas as matérias'
                                : 'Selecione um curso primeiro',
                            onChanged: vm.setFilterSubject,
                            enabled: vm.selectedCourseId != null,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopFilters(
      BuildContext context, CategoryListViewModel viewModel) {
    final courseOptions = viewModel.courses
        .map((c) => SelectOption(value: c.id, label: c.title))
        .toList();
    final subjectOptions = viewModel.subjects
        .map((s) => SelectOption(value: s.id, label: s.name))
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
          const SizedBox(width: 16),
          Expanded(
            child: SelectPesquisa(
              label: 'Matéria',
              options: subjectOptions,
              value: viewModel.selectedSubjectId,
              placeholder: viewModel.selectedCourseId != null
                  ? 'Todas as matérias'
                  : 'Selecione um curso primeiro',
              onChanged: viewModel.setFilterSubject,
              enabled: viewModel.selectedCourseId != null,
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
            'Escolha um curso acima para ver e gerenciar suas categorias',
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
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma categoria encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em "Nova Categoria" para criar a primeira',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context, CategoryListViewModel viewModel) {
    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 800 ? 12 : 24),
      itemCount: viewModel.categories.length,
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        final subjectName = viewModel.subjects
            .where((s) => s.id == category.subjectId)
            .map((s) => s.name)
            .firstOrNull;
        final courseName = viewModel.courses
            .where((c) => c.id == category.courseId)
            .map((c) => c.title)
            .firstOrNull;

        return _CategoryCard(
          name: category.name,
          description: category.description,
          courseName: courseName,
          subjectName: subjectName,
          onEdit: () => _showEditDialog(context, viewModel, category.id,
              category.name, category.description),
          onDelete: () async {
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed == true) {
              await viewModel.deleteCategory(category.id);
            }
          },
        );
      },
    );
  }

  Future<void> _showCreateDialog(
      BuildContext context, CategoryListViewModel viewModel) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: Contratos',
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
              await viewModel.createCategory(
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
      CategoryListViewModel viewModel, String id, String name,
      String? description) async {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: description ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Categoria'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
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
              await viewModel.updateCategory(
                categoryId: id,
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
          'Tem certeza que deseja excluir esta categoria? '
          'As questões vinculadas não serão afetadas.',
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

class _CategoryCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? courseName;
  final String? subjectName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.name,
    this.description,
    this.courseName,
    this.subjectName,
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
          left: BorderSide(color: Colors.purple, width: 4),
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
                      if (subjectName != null) ...[
                        const SizedBox(width: 8),
                        _buildBadge(subjectName!, const Color(0xFF2E7D32)),
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
              tooltip: 'Editar categoria',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Excluir categoria',
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
