import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_color.dart';
import '../viewmodels/exam_detail_view_model.dart';
import '../repositories/question_repository_types.dart';
import '../repositories/exam_attempt_repository_types.dart';
import '../models/user_response.dart' as models;

class ExamDetailScreen extends StatelessWidget {
  final String attemptId;

  const ExamDetailScreen({
    super.key,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamDetailViewModel()..loadExamDetails(attemptId),
      child: const _ExamDetailViewBody(),
    );
  }
}

class _ExamDetailViewBody extends StatelessWidget {
  const _ExamDetailViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExamDetailViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/FundoWhiteHome.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // AppBar customizado
                _buildAppBar(context),
                // Conteúdo
                Expanded(
                  child: _buildContent(context, viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.9 * 255).round()),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.primaryDark,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detalhes da Prova',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExamDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            viewModel.errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.red,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (viewModel.questions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma questão encontrada',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.attempt != null)
            _buildSummaryCard(viewModel.attempt!, viewModel),
          const SizedBox(height: 24),
          Text(
            'Questões',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ...viewModel.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final response = viewModel.getResponseForQuestion(question.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _QuestionAccordion(
                questionNumber: index + 1,
                question: question,
                userResponse: response,
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      ExamAttemptHistory attempt, ExamDetailViewModel viewModel) {
    final correctCount = viewModel.correctAnswersCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.85 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withAlpha((0.1 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: AppColors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota: $correctCount/${attempt.questionCount}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${attempt.questionCount} questões',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionAccordion extends StatefulWidget {
  final int questionNumber;
  final Question question;
  final models.UserResponse? userResponse;

  const _QuestionAccordion({
    required this.questionNumber,
    required this.question,
    this.userResponse,
  });

  @override
  State<_QuestionAccordion> createState() => _QuestionAccordionState();
}

class _QuestionAccordionState extends State<_QuestionAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.userResponse?.isCorrect ?? false;
    final selectedChoiceKey = widget.userResponse?.selectedChoiceKey;
    final correctChoice = widget.question.answerChoices.firstWhere(
        (choice) => choice.isCorrect,
        orElse: () => widget.question.answerChoices.first);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha((0.85 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? AppColors.green.withAlpha((0.3 * 255).round())
              : AppColors.red.withAlpha((0.3 * 255).round()),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.green.withAlpha((0.15 * 255).round())
                : AppColors.red.withAlpha((0.15 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? AppColors.green : AppColors.red,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Questão ${widget.questionNumber}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isCorrect ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isCorrect ? 'Correta' : 'Incorreta',
                style: TextStyle(
                  fontSize: 13,
                  color: isCorrect ? AppColors.green : AppColors.red,
                  fontFamily: 'Poppins',
                ),
              ),
              if (selectedChoiceKey != null) ...[
                const SizedBox(width: 8),
                Text(
                  '• Você marcou: $selectedChoiceKey',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        AppColors.secondaryDark.withAlpha((0.7 * 255).round()),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppColors.primaryDark,
        ),
        children: [
          // Textos de apoio
          if (widget.question.supportingTexts.isNotEmpty) ...[
            ...widget.question.supportingTexts
                .map((supportingText) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark
                            .withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryDark
                              .withAlpha((0.1 * 255).round()),
                        ),
                      ),
                      child: Text(
                        supportingText.content,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    )),
            const SizedBox(height: 12),
          ],
          // Enunciado
          if (widget.question.enunciation.isNotEmpty) ...[
            Text(
              widget.question.enunciation,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Pergunta
          if (widget.question.questionText.isNotEmpty) ...[
            Text(
              widget.question.questionText,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Opções
          ...widget.question.answerChoices.map((choice) {
            final isSelected = selectedChoiceKey == choice.choiceKey;
            final isCorrectChoice = choice.isCorrect;

            Color backgroundColor = Colors.transparent;
            Color borderColor;
            IconData? icon;
            Color? iconColor;

            if (isCorrectChoice) {
              borderColor = AppColors.green;
              icon = Icons.check_circle;
              iconColor = AppColors.green;
            } else if (isSelected) {
              borderColor = AppColors.red;
              icon = Icons.cancel;
              iconColor = AppColors.red;
            } else {
              borderColor =
                  AppColors.primaryDark.withAlpha((0.2 * 255).round());
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || isCorrectChoice ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isSelected || isCorrectChoice)
                          ? borderColor.withAlpha((0.2 * 255).round())
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: (isSelected || isCorrectChoice)
                          ? null
                          : Border.all(
                              color: borderColor,
                              width: 1,
                            ),
                    ),
                    child: Center(
                      child: Text(
                        choice.choiceKey,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice.choiceText,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryDark,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Legenda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primaryDark.withAlpha((0.7 * 255).round()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Você acertou esta questão!'
                        : 'Resposta correta: ${correctChoice.choiceKey}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          AppColors.primaryDark.withAlpha((0.7 * 255).round()),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
