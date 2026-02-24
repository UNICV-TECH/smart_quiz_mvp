import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/teacher_repository.dart';
import '../../repositories/teacher_repository_types.dart';
import '../../services/session_manager.dart';
import '../../ui/components/default_create_question-statement.dart' hide Preview;
import '../../ui/components/default_input_select.dart' hide Preview;
import '../../ui/theme/app_color.dart';
import '../../viewmodels/teacher/edit_question_view_model.dart';

class TeacherEditQuestionScreen extends StatelessWidget {
  const TeacherEditQuestionScreen({super.key, required this.questionId});

  final String questionId;

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final teacherId = sessionManager.currentUser?.id ?? '';
    final teacherRepo = context.read<TeacherRepository?>();
    final courseRepo = context.read<CourseRepository?>();

    if (teacherRepo == null || courseRepo == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erro: conexao com o servidor nao disponivel'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => EditQuestionViewModel(
        questionId: questionId,
        teacherId: teacherId,
        teacherRepository: teacherRepo,
        courseRepository: courseRepo,
      )..loadInitialData(),
      child: const _EditQuestionContent(),
    );
  }
}

class _EditQuestionContent extends StatelessWidget {
  const _EditQuestionContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditQuestionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Questao'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Messages
                      if (viewModel.errorMessage != null)
                        _buildMessageBanner(
                          viewModel.errorMessage!,
                          isError: true,
                          onDismiss: viewModel.clearMessages,
                        ),
                      if (viewModel.successMessage != null)
                        _buildMessageBanner(
                          viewModel.successMessage!,
                          isError: false,
                          onDismiss: viewModel.clearMessages,
                        ),
                      if (viewModel.errorMessage != null ||
                          viewModel.successMessage != null)
                        const SizedBox(height: 16),

                      // Context Card
                      _buildContextCard(context, viewModel),
                      const SizedBox(height: 32),

                      // Question Card
                      _buildQuestionCard(context, viewModel),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMessageBanner(
    String message, {
    required bool isError,
    required VoidCallback onDismiss,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.red.withValues(alpha: 0.1)
            : AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? AppColors.red : AppColors.green,
          width: 1,
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
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDismiss,
            color: isError ? AppColors.red : AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard(
      BuildContext context, EditQuestionViewModel viewModel) {
    final courseOptions = viewModel.courses
        .map((c) => SelectOption(value: c.id, label: c.title))
        .toList();

    final categoryOptions = viewModel.categories
        .map((c) => SelectOption(value: c.id, label: c.name))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contexto da Questao',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectPesquisa(
                        label: 'Curso',
                        options: courseOptions,
                        value: viewModel.selectedCourseId,
                        required: true,
                        placeholder: 'Selecione o curso',
                        onChanged: viewModel.setCourse,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SelectPesquisa(
                        label: 'Categoria',
                        options: categoryOptions,
                        value: viewModel.selectedCategoryId,
                        required: false,
                        placeholder: viewModel.selectedCourseId != null
                            ? 'Selecione a categoria'
                            : 'Selecione um curso primeiro',
                        onChanged: viewModel.setCategory,
                        enabled: viewModel.selectedCourseId != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectPesquisa(
                        label: 'Dificuldade',
                        options: const [
                          SelectOption(value: 'easy', label: 'Facil'),
                          SelectOption(value: 'medium', label: 'Medio'),
                          SelectOption(value: 'hard', label: 'Dificil'),
                        ],
                        value: viewModel.difficultyLevel,
                        required: true,
                        placeholder: 'Selecione a dificuldade',
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.setDifficultyLevel(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SelectPesquisa(
                        label: 'Pontos',
                        options: const [
                          SelectOption(value: '0.5', label: '0.5 pontos'),
                          SelectOption(value: '1.0', label: '1.0 ponto'),
                          SelectOption(value: '1.5', label: '1.5 pontos'),
                          SelectOption(value: '2.0', label: '2.0 pontos'),
                          SelectOption(value: '2.5', label: '2.5 pontos'),
                          SelectOption(value: '3.0', label: '3.0 pontos'),
                        ],
                        value: viewModel.points.toString(),
                        required: true,
                        placeholder: 'Selecione os pontos',
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.setPoints(double.parse(value));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, EditQuestionViewModel viewModel) {
    final initialAlternatives = viewModel.answerChoices.map((choice) {
      return AlternativeModel(
        id: choice.letter ?? 'A',
        text: choice.content,
        isCorrect: choice.isCorrect,
      );
    }).toList();

    final initialSupportingText = viewModel.supportingTexts.isNotEmpty
        ? viewModel.supportingTexts.first.content
        : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            const Border(left: BorderSide(color: AppColors.green, width: 6)),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultCreateQuestion(
          initialSupportingText: initialSupportingText,
          initialStatementText: viewModel.enunciation,
          initialQuestion: '',
          initialAlternatives: initialAlternatives,
          onSave: ({
            required String question,
            required List<AlternativeModel> alternatives,
            String? supportingText,
            String? statement,
          }) async {
            viewModel.setEnunciation(statement ?? question);

            for (int i = 0; i < alternatives.length && i < 5; i++) {
              final alt = alternatives[i];
              viewModel.updateAnswerChoice(
                i,
                AnswerChoiceInput(
                  letter: String.fromCharCode(65 + i),
                  content: alt.text,
                  isCorrect: alt.isCorrect,
                ),
              );
            }

            if (supportingText != null && supportingText.isNotEmpty) {
              if (viewModel.supportingTexts.isEmpty) {
                viewModel.addSupportingText(
                  SupportingTextInput(content: supportingText),
                );
              } else {
                viewModel.updateSupportingText(
                  0,
                  SupportingTextInput(content: supportingText),
                );
              }
            } else if (viewModel.supportingTexts.isNotEmpty) {
              viewModel.removeSupportingText(0);
            }

            final success = await viewModel.saveQuestion();

            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Questao atualizada com sucesso!'),
                  backgroundColor: AppColors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );
  }
}
