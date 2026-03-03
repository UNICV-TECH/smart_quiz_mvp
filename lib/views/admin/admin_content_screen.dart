import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/admin/admin_content_view_model.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  static const _indigoColor = Color(0xFF3F51B5);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminContentViewModel>();

    return DefaultTabController(
      length: 3,
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'Conteúdo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _indigoColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: viewModel.refresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TabBar(
                labelColor: _indigoColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _indigoColor,
                tabs: [
                  Tab(text: 'Questões'),
                  Tab(text: 'Templates'),
                  Tab(text: 'Cursos'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildQuestionsTab(viewModel),
                        _buildTemplatesTab(viewModel),
                        _buildCoursesTab(viewModel),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsTab(AdminContentViewModel viewModel) {
    if (viewModel.questions.isEmpty) {
      return const Center(
        child: Text('Nenhuma questão encontrada', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
          columns: const [
            DataColumn(label: Text('Enunciado', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Curso', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Professor', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dificuldade', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Respostas', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: viewModel.questions.map((question) {
            final enunciation = question.enunciation.length > 50
                ? '${question.enunciation.substring(0, 50)}...'
                : question.enunciation;
            return DataRow(
              cells: [
                DataCell(
                  Tooltip(
                    message: question.enunciation,
                    child: Text(enunciation),
                  ),
                ),
                DataCell(Text(question.courseName)),
                DataCell(
                  Tooltip(
                    message: question.teacherEmail,
                    child: Text(
                      question.teacherName.isEmpty
                          ? question.teacherEmail
                          : question.teacherName,
                    ),
                  ),
                ),
                DataCell(Text(question.difficultyLevel ?? '-')),
                DataCell(Text(question.answerCount.toString())),
                DataCell(_buildStatusBadge(question.isActive)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab(AdminContentViewModel viewModel) {
    if (viewModel.templates.isEmpty) {
      return const Center(
        child: Text('Nenhum template encontrado', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
          columns: const [
            DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Curso', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Questões', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Publicado', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: viewModel.templates.map((template) {
            return DataRow(
              cells: [
                DataCell(Text(template.name)),
                DataCell(Text(template.courseName ?? '-')),
                DataCell(Text(template.questionCount.toString())),
                DataCell(_buildStatusBadge(template.isPublished)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCoursesTab(AdminContentViewModel viewModel) {
    if (viewModel.courses.isEmpty) {
      return const Center(
        child: Text('Nenhum curso encontrado', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
          columns: const [
            DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: viewModel.courses.map((course) {
            return DataRow(
              cells: [
                DataCell(Text(course.name)),
                DataCell(Text(course.description ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
