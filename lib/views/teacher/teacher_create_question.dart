import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_create_question-statement.dart';
import 'package:unicv_tech_mvp/ui/components/default_create_question.dart'
    hide Preview;
import 'package:unicv_tech_mvp/ui/components/default_input_select.dart'
    hide Preview;
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

/// Tela de criação de questões que se integra ao menu lateral do professor
class TeacherScreenCreateQuestion extends StatelessWidget {
  const TeacherScreenCreateQuestion({super.key});

  @override
  Widget build(BuildContext context) {
    return _CreateQuestionContent();
  }
}

class _CreateQuestionContent extends StatelessWidget {
  const _CreateQuestionContent();

  static const List<SelectOption> _courseOptions = [
    SelectOption(value: 'ads', label: 'Análise e Desenvolvimento de Sistemas'),
    SelectOption(value: 'adm', label: 'Administração'),
  ];

  static const List<SelectOption> _professorOptions = [
    SelectOption(value: 'prof-1', label: 'Prof. João Lima'),
    SelectOption(value: 'prof-2', label: 'Profa. Maria Clara'),
  ];
  static const List<SelectOption> _yearOptions = [
    SelectOption(value: '2024', label: '2024'),
    SelectOption(value: '2025', label: '2025'),
  ];

  static const List<SelectOption> _semesterOptions = [
    SelectOption(value: '1', label: '1º semestre'),
    SelectOption(value: '2', label: '2º semestre'),
  ];
  static const List<SelectOption> _subjectOptions = [
    SelectOption(value: 'math-1', label: 'Cálculo I'),
    SelectOption(value: 'prog-1', label: 'Algoritmos'),
  ];

  static const List<SelectOption> _contentOptions = [
    SelectOption(value: 'matriz', label: 'Matrizes'),
    SelectOption(value: 'complexos', label: 'Números complexos'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildContextCard(context),
              const SizedBox(height: 32),
              _buildQuestionCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: DefaultCreateQuestionContextForm(
          courseOptions: _courseOptions,
          professorOptions: _professorOptions,
          yearOptions: _yearOptions,
          semesterOptions: _semesterOptions,
          subjectOptions: _subjectOptions,
          contentOptions: _contentOptions,
          semesterRequired: false,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final initialAlternatives = [
      AlternativeModel(id: 'alt_0', text: 'Questão 1', isCorrect: false),
      AlternativeModel(
          id: 'alt_1', text: 'Adicionar questão', isCorrect: false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.green, width: 6)),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultCreateQuestion(
          initialSupportingText: '',
          initialStatementText: '',
          initialQuestion: '',
          initialAlternatives: initialAlternatives,
          onSave: (
              {required String question,
              required List<AlternativeModel> alternatives,
              String? supportingText,
              String? statement}) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Questão salva com sucesso!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
