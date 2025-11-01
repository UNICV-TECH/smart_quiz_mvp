import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/models/exam_history.dart';
import 'package:unicv_tech_mvp/ui/components/default_radio_group.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_back.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_forward.dart';
import 'package:unicv_tech_mvp/ui/components/default_question_navigation.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart' as logo;
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/viewmodels/exam_view_model.dart';

class ExamScreen extends StatefulWidget {
  final String userId;
  final String examId;
  final String courseId;
  final int questionCount;

  const ExamScreen({
    super.key,
    required this.userId,
    required this.examId,
    required this.courseId,
    required this.questionCount,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int currentQuestionIndex = 0;
  final ScrollController _questionScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ExamViewModel>();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.loading && viewModel.examQuestions.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.green,
                ),
              ),
            ),
          );
        }

        if (viewModel.error != null && viewModel.examQuestions.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar o exame',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (viewModel.examQuestions.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                    Color(0xFFE8F5ED),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma questão disponível',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final currentExamQuestion =
            viewModel.examQuestions[currentQuestionIndex];
        final currentAnswer =
            viewModel.selectedAnswers[currentExamQuestion.question.id];
        final isFirstQuestion = currentQuestionIndex == 0;
        final isLastQuestion =
            currentQuestionIndex == viewModel.examQuestions.length - 1;

        const horizontalPadding = 24.0;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5ED),
                  Color(0xFFE8F5ED),
                  Color(0xFFE8F5ED),
                ],
              ),
            ),
            child: Column(
              children: [
                _buildAppBar(horizontalPadding),
                _buildProgressIndicator(horizontalPadding,
                    viewModel.examQuestions.length, viewModel),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionTitle(currentQuestionIndex + 1),
                        const SizedBox(height: 16),
                        _buildEnunciation(
                            currentExamQuestion.question.enunciation),
                        if (currentExamQuestion.supportingTexts.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...currentExamQuestion.supportingTexts
                              .map((st) => _buildSupportingText(st)),
                        ],
                        const SizedBox(height: 24),
                        AlternativeSelectorVertical(
                          labels: currentExamQuestion.answerChoices
                              .map((ac) => ac.choiceText)
                              .toList(),
                          selectedOption: currentAnswer,
                          onChanged: (option) {
                            viewModel.selectAnswer(
                                currentExamQuestion.question.id, option);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _buildNavigationButtons(
                  isFirstQuestion: isFirstQuestion,
                  isLastQuestion: isLastQuestion,
                  horizontalPadding: horizontalPadding,
                  viewModel: viewModel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(double horizontalPadding) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
        child: Row(
          children: [
            DefaultButtonArrowBack(
              onPressed: () async {
                final shouldExit = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Sair do simulado?'),
                      content: const Text(
                        'Ao sair agora, sua tentativa não será salva.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Continuar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Sair'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldExit == true && mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            Expanded(
              child: Center(
                child: logo.AppLogoWidget.asset(
                  size: logo.AppLogoSize.small,
                  logoPath: 'assets/images/logo_color.png',
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
      double horizontalPadding, int totalQuestions, ExamViewModel viewModel) {
    final answeredQuestions = viewModel.selectedAnswers.keys
        .map((qId) {
          final index =
              viewModel.examQuestions.indexWhere((eq) => eq.question.id == qId);
          return index + 1;
        })
        .where((index) => index > 0)
        .toSet();

    final answeredCount = answeredQuestions.length;
    final double progress = totalQuestions == 0
        ? 0
        : answeredCount.clamp(0, totalQuestions) / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questões',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '$answeredCount de $totalQuestions respondidas',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                controller: _questionScrollController,
                scrollDirection: Axis.horizontal,
                child: QuestionNavigation(
                  totalQuestions: totalQuestions,
                  currentQuestion: currentQuestionIndex + 1,
                  onQuestionSelected: (questionNumber) {
                    setState(() {
                      currentQuestionIndex = questionNumber - 1;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToQuestion(
                          totalQuestions: totalQuestions,
                          horizontalPadding: horizontalPadding,
                        );
                      });
                    });
                  },
                  answeredQuestions: answeredQuestions,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.0,
              backgroundColor: AppColors.green.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
              semanticsLabel: 'Progresso de respostas',
              semanticsValue:
                  '$answeredCount de $totalQuestions questões respondidas',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTitle(int questionNumber) {
    return Text(
      'Questão $questionNumber',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _buildEnunciation(String enunciation) {
    return Text(
      enunciation,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.primaryDark,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildSupportingText(SupportingText supportingText) {
    if (supportingText.contentType == 'text') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            supportingText.content,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNavigationButtons({
    required bool isFirstQuestion,
    required bool isLastQuestion,
    required double horizontalPadding,
    required ExamViewModel viewModel,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isFirstQuestion)
              DefaultButtonBack(
                text: 'Anterior',
                icon: Icons.arrow_back_ios,
                onPressed: () {
                  if (currentQuestionIndex > 0) {
                    setState(() {
                      currentQuestionIndex--;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToQuestion(
                        totalQuestions: viewModel.examQuestions.length,
                        horizontalPadding: horizontalPadding,
                      );
                    });
                  }
                },
              )
            else
              const SizedBox(width: 90),
            DefaultButtonForward(
              text: isLastQuestion ? 'Finalizar' : 'Próxima',
              icon: Icons.arrow_forward_ios,
              onPressed: () {
                if (isLastQuestion) {
                  _showFinishDialog(viewModel);
                } else {
                  if (currentQuestionIndex <
                      viewModel.examQuestions.length - 1) {
                    setState(() {
                      currentQuestionIndex++;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToQuestion(
                        totalQuestions: viewModel.examQuestions.length,
                        horizontalPadding: horizontalPadding,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog(ExamViewModel viewModel) {
    final answeredCount = viewModel.selectedAnswers.length;
    final totalQuestions = viewModel.examQuestions.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar Simulado'),
          content: Text(
            'Você respondeu $answeredCount de $totalQuestions questões. '
            'Deseja finalizar o simulado?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitExam(viewModel);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitExam(ExamViewModel viewModel) async {
    try {
      final results = await viewModel.finalize();

      if (!mounted) return;

      await Navigator.popAndPushNamed(
        context,
        '/exam/result',
        arguments: results,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar simulado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToQuestion({
    required int totalQuestions,
    required double horizontalPadding,
  }) {
    if (!_questionScrollController.hasClients) {
      return;
    }

    final double indicatorExtent =
        QuestionNavigation.itemExtentForCount(totalQuestions);
    final double availableWidth =
        MediaQuery.of(context).size.width - (horizontalPadding * 2);
    final double targetCenter =
        currentQuestionIndex * indicatorExtent + (indicatorExtent / 2);
    final double targetOffset =
        targetCenter - (availableWidth / 2).clamp(0.0, double.infinity);

    _questionScrollController.animateTo(
      targetOffset.clamp(
          0.0, _questionScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _questionScrollController.dispose();
    super.dispose();
  }
}
