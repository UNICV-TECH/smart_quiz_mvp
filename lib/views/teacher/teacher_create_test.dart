import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/components/default_radio_question.dart';
import 'package:unicv_tech_mvp/ui/components/default_input.dart';

/// Modelo para representar uma questão
class Question {
  final String id;
  final String enunciation;
  final List<String> options;
  final int order;
  final double? score;

  Question({
    required this.id,
    required this.enunciation,
    required this.options,
    required this.order,
    this.score,
  });

  Question copyWith({
    String? id,
    String? enunciation,
    List<String>? options,
    int? order,
    double? score,
  }) {
    return Question(
      id: id ?? this.id,
      enunciation: enunciation ?? this.enunciation,
      options: options ?? this.options,
      order: order ?? this.order,
      score: score ?? this.score,
    );
  }
}

/// Modelo para representar a resposta de um aluno
class StudentAnswerData {
  final String id;
  final String studentName;
  final String studentEmail;
  final DateTime completedAt;
  final int questionsAnswered;
  final int totalQuestions;
  final int durationMinutes;
  final int durationSeconds;
  final int score;
  final int totalScore;
  final double points;

  StudentAnswerData({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.completedAt,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.durationSeconds,
    required this.score,
    required this.totalScore,
    required this.points,
  });
}

/// Tela de criação de prova com abas e gerenciamento de questões
class TeacherCreateTestView extends StatefulWidget {
  const TeacherCreateTestView({super.key});

  @override
  State<TeacherCreateTestView> createState() => _TeacherCreateTestViewState();
}

class _TeacherCreateTestViewState extends State<TeacherCreateTestView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Controladores de texto
  late TextEditingController _testTitleController;
  late TextEditingController _testDescriptionController;

  // Estado da prova
  List<Question> questions = [];

  // Controlador de busca para respostas
  late TextEditingController _answerSearchController;

  // Estado das configurações da prova
  bool _showWrongQuestions = true;
  bool _showCorrectAnswers = true;
  bool _showScores = true;
  bool _requireInstitutionalLogin = true;
  bool _singleAttemptOnly = true;
  bool _useDefaultQuestionScore = true;

  // Dados fictícios de respostas dos alunos
  final List<StudentAnswerData> studentAnswers = [
    StudentAnswerData(
      id: '1',
      studentName: 'Debora Rosada',
      studentEmail: 'deboraRosada@unicv.gov.br',
      completedAt: DateTime(2025, 12, 1, 21, 59),
      questionsAnswered: 5,
      totalQuestions: 5,
      durationMinutes: 2,
      durationSeconds: 50,
      score: 4,
      totalScore: 5,
      points: 8.0,
    ),
    StudentAnswerData(
      id: '2',
      studentName: 'Debora Rosada',
      studentEmail: 'deboraRosada@unicv.gov.br',
      completedAt: DateTime(2025, 12, 1, 21, 59),
      questionsAnswered: 5,
      totalQuestions: 5,
      durationMinutes: 2,
      durationSeconds: 50,
      score: 4,
      totalScore: 5,
      points: 8.0,
    ),
  ];

  // Dados fictícios para importação com informações completas
  final List<QuestionListItemData> availableQuestions = [
    QuestionListItemData(
      id: 'q1',
      enunciation:
          'Qual é a definição correta de Programação Orientada a Objetos?',
      content: 'POO',
      subject: 'Algoritmos',
      professor: 'Prof. João Lima',
      semester: '1º semestre',
      year: '2024',
    ),
    QuestionListItemData(
      id: 'q2',
      enunciation:
          'Em uma matriz A de ordem 3x3, qual é o determinante se todos os elementos da diagonal principal são iguais a 2 e os demais são zero?',
      content: 'Matrizes',
      subject: 'Cálculo I',
      professor: 'Profa. Maria Clara',
      semester: '1º semestre',
      year: '2024',
    ),
    QuestionListItemData(
      id: 'q3',
      enunciation: 'O que caracteriza um número complexo na forma algébrica?',
      content: 'Números Complexos',
      subject: 'Cálculo I',
      professor: 'Profa. Maria Clara',
      semester: '2º semestre',
      year: '2024',
    ),
    QuestionListItemData(
      id: 'q4',
      enunciation:
          'Qual é a principal diferença entre herança e composição em POO?',
      content: 'POO',
      subject: 'Algoritmos',
      professor: 'Prof. João Lima',
      semester: '2º semestre',
      year: '2025',
    ),
    QuestionListItemData(
      id: 'q5',
      enunciation: 'Explique o conceito de polimorfismo na programação.',
      content: 'POO',
      subject: 'Algoritmos',
      professor: 'Prof. João Lima',
      semester: '1º semestre',
      year: '2025',
    ),
    QuestionListItemData(
      id: 'q6',
      enunciation: 'Qual é a definição de limite em cálculo diferencial?',
      content: 'Limites',
      subject: 'Cálculo I',
      professor: 'Profa. Maria Clara',
      semester: '1º semestre',
      year: '2024',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _testTitleController = TextEditingController();
    _testDescriptionController = TextEditingController();
    _answerSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _testTitleController.dispose();
    _testDescriptionController.dispose();
    _answerSearchController.dispose();
    super.dispose();
  }

  void _deleteQuestion(String questionId) {
    setState(() {
      questions.removeWhere((q) => q.id == questionId);
      // Reordenar
      for (int i = 0; i < questions.length; i++) {
        questions[i] = questions[i].copyWith(order: i);
      }
    });
  }

  void _duplicateQuestion(String questionId) {
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      final originalQuestion = questions[questionIndex];
      final duplicatedQuestion = Question(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}',
        enunciation: originalQuestion.enunciation,
        options: List.from(originalQuestion.options),
        order: questionIndex + 1,
        score: originalQuestion.score,
      );

      setState(() {
        questions.insert(questionIndex + 1, duplicatedQuestion);
        // Reordenar
        for (int i = 0; i < questions.length; i++) {
          questions[i] = questions[i].copyWith(order: i);
        }
      });
    }
  }

  void _moveQuestionUp(String questionId) {
    final index = questions.indexWhere((q) => q.id == questionId);
    if (index > 0) {
      setState(() {
        final temp = questions[index];
        questions[index] = questions[index - 1].copyWith(order: index);
        questions[index - 1] = temp.copyWith(order: index - 1);

        // Trocar posições
        questions[index] = questions[index];
        questions[index - 1] = questions[index - 1];
      });
    }
  }

  void _moveQuestionDown(String questionId) {
    final index = questions.indexWhere((q) => q.id == questionId);
    if (index < questions.length - 1) {
      setState(() {
        final temp = questions[index];
        questions[index] = questions[index + 1].copyWith(order: index);
        questions[index + 1] = temp.copyWith(order: index + 1);

        // Trocar posições
        questions[index] = questions[index];
        questions[index + 1] = questions[index + 1];
      });
    }
  }

  void _showImportModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportQuestionModal(
        availableQuestions: availableQuestions,
        onImport: (selectedIds) {
          // Lógica para importar as questões selecionadas
          for (final questionId in selectedIds) {
            final importedQuestion =
                availableQuestions.firstWhere((q) => q.id == questionId);

            final newQuestion = Question(
              id: 'q_${DateTime.now().millisecondsSinceEpoch}_$questionId',
              enunciation: importedQuestion.enunciation,
              options: ['', '', '', ''],
              order: questions.length,
              score: 0,
            );

            setState(() {
              questions.add(newQuestion);
            });
          }

          Navigator.pop(context);

          // Mostrar feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedIds.length} questão(ões) importada(s) com sucesso!',
              ),
              backgroundColor: AppColors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _updateQuestion(String questionId, String enunciation) {
    final index = questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      setState(() {
        questions[index] = questions[index].copyWith(enunciation: enunciation);
      });
    }
  }

  void _updateQuestionScore(String questionId, String value) {
    final index = questions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;

    final parsed = double.tryParse(value.replaceAll(',', '.'));
    setState(() {
      questions[index] = questions[index].copyWith(score: parsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montar Provas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            Text(
              'Criar questões',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyText,
                  ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Abas de navegação
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.green,
              unselectedLabelColor: AppColors.greyText,
              indicatorColor: AppColors.green,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Perguntas'),
                Tab(text: 'Respostas'),
                Tab(text: 'Configurações'),
              ],
            ),
          ),
          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba Perguntas
                _buildQuestionsTab(),
                // Aba Respostas
                _buildAnswersTab(),
                // Aba Configurações
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cabeçalho da Prova
          _buildTestHeader(),

          const SizedBox(height: 24),

          // Card de Importação de Questões
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildImportQuestionsCard(),
          ),

          const SizedBox(height: 24),

          // Lista de Questões
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questões Adicionadas (${questions.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cards de Questões
                if (questions.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _buildQuestionCard(question, index);
                    },
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportQuestionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenSplash,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Ícone central
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_download_outlined,
              size: 40,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            'Importar Questões do Banco',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Descrição
          Text(
            'Selecione questões já cadastradas no sistema para adicionar à sua prova. Use filtros e busca para encontrar rapidamente.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyText,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Botão de ação
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showImportModal,
              icon: const Icon(Icons.add_circle_outline, size: 24),
              label: const Text(
                'Abrir Banco de Questões',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Informação adicional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Você pode selecionar múltiplas questões de uma só vez',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w500,
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

  Widget _buildTestHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenSplash,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informações da Prova',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ComponenteInput(
              controller: _testTitleController,
              labelText: 'Título da Prova',
              hintText: 'Prova sem título',
              backgroundColor: AppColors.whiteBg,
              borderColor: AppColors.greyLight,
              borderColorFocus: AppColors.green,
              borderRadius: 12.0,
              onChanged: (value) {
                setState(() {}); // Trigger rebuild para salvar
              },
            ),
            const SizedBox(height: 20),
            ComponenteInput(
              controller: _testDescriptionController,
              labelText: 'Descrição',
              hintText: 'Descrição da prova',
              backgroundColor: AppColors.whiteBg,
              borderColor: AppColors.greyLight,
              borderColorFocus: AppColors.green,
              borderRadius: 12.0,
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                setState(() {}); // Trigger rebuild para salvar
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Salvo automaticamente',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card com número e ações
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Questão ${index + 1}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          initialValue:
                              question.score == null ? '' : '${question.score}',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Pontuação',
                            hintText: 'Ex: 1,0',
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.whiteBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.greyLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.greyLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.green,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) =>
                              _updateQuestionScore(question.id, value),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botões de ação
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Setas de reordenação
                    _buildIconButton(
                      icon: Icons.arrow_upward,
                      onPressed:
                          index > 0 ? () => _moveQuestionUp(question.id) : null,
                      tooltip: 'Mover para cima',
                    ),
                    _buildIconButton(
                      icon: Icons.arrow_downward,
                      onPressed: index < questions.length - 1
                          ? () => _moveQuestionDown(question.id)
                          : null,
                      tooltip: 'Mover para baixo',
                    ),
                    // Duplicar
                    _buildIconButton(
                      icon: Icons.copy,
                      onPressed: () => _duplicateQuestion(question.id),
                      tooltip: 'Duplicar',
                    ),
                    // Excluir
                    _buildIconButton(
                      icon: Icons.delete_outline,
                      onPressed: () => _deleteQuestion(question.id),
                      color: AppColors.error,
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(
            height: 0,
            color: AppColors.greyLight,
          ),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enunciado',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: question.enunciation),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Digite o enunciado da questão',
                    hintStyle: TextStyle(
                      color: AppColors.greyText.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: AppColors.whiteBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.green,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => _updateQuestion(question.id, value),
                ),

                const SizedBox(height: 16),

                // Opções de múltipla escolha
                Text(
                  'Opções',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  question.options.length,
                  (optionIndex) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optionIndex),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                                text: question.options[optionIndex]),
                            decoration: InputDecoration(
                              hintText: 'Opção ${optionIndex + 1}',
                              hintStyle: TextStyle(
                                color:
                                    AppColors.greyText.withValues(alpha: 0.7),
                              ),
                              filled: true,
                              fillColor: AppColors.whiteBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.greyLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.greyLight,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color color = AppColors.greyText,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 20,
      color: onPressed != null ? color : AppColors.greyLight,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma questão adicionada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Adicionar Questão" para começar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyText.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersTab() {
    // Filtrar respostas baseado na busca
    final filteredAnswers = studentAnswers.where((answer) {
      final query = _answerSearchController.text.toLowerCase();
      return query.isEmpty ||
          answer.studentName.toLowerCase().contains(query) ||
          answer.studentEmail.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com contador de respostas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredAnswers.length} resposta${filteredAnswers.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo de busca com filtro
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Pesquise pelo aluno',
                      hintStyle: TextStyle(
                        color: AppColors.greyText.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.greyText,
                        size: 20,
                      ),
                      suffixIcon: _answerSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.greyText,
                                size: 20,
                              ),
                              onPressed: () {
                                _answerSearchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.greyLight,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.greyLight,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.tune,
                      color: AppColors.greyText,
                    ),
                    onPressed: () {
                      // TODO: Implementar filtros avançados
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filtros em desenvolvimento'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lista de cards de respostas
            if (filteredAnswers.isEmpty)
              _buildEmptyAnswersState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredAnswers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final answer = filteredAnswers[index];
                  return _buildAnswerCard(answer);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAnswersState() {
    final hasSearch = _answerSearchController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.assignment_outlined,
            size: 64,
            color: AppColors.greyText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch
                ? 'Nenhuma resposta encontrada'
                : 'Ainda não há respostas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Tente buscar por outro nome ou e-mail'
                : 'As respostas dos alunos aparecerão aqui quando eles completarem a prova',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(StudentAnswerData answer) {
    final formattedDate = _formatDateTime(answer.completedAt);
    final duration =
        '${answer.durationMinutes}:${answer.durationSeconds.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com informações do aluno
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answer.studentName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer.studentEmail,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.greyText,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 0, color: AppColors.greyLight),

          // Estatísticas da prova
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.article_outlined,
                  label: 'Questões',
                  value: answer.questionsAnswered.toString(),
                ),
                _buildStatItem(
                  icon: Icons.timer_outlined,
                  label: 'Duração',
                  value: duration,
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Nota',
                  value: '${answer.score}/${answer.totalScore}',
                ),
              ],
            ),
          ),

          const Divider(height: 0, color: AppColors.greyLight),

          // Pontuação e ação
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.whiteBg,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pontuação: ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                    ),
                    Text(
                      answer.points.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    // TODO: Navegar para tela de detalhes da resposta
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Visualizando detalhes de ${answer.studentName}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Clique para ver detalhes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: AppColors.greyText,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal de configurações
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da página
                  Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Seção: Configuração das Perguntas
                  Text(
                    'Configuração das perguntas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Opção 1: Perguntas erradas
                  _buildSettingItem(
                    title: 'Perguntas erradas',
                    description:
                        'O alunos poderão ver as perguntas que foram respondidas incorretamente.',
                    value: _showWrongQuestions,
                    onChanged: (value) {
                      setState(() => _showWrongQuestions = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Opção 2: Respostas corretas
                  _buildSettingItem(
                    title: 'Respostas corretas',
                    description:
                        'Os alunos poderão ver as respostas corretas após a liberação das notas.',
                    value: _showCorrectAnswers,
                    onChanged: (value) {
                      setState(() => _showCorrectAnswers = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Opção 3: Valores
                  _buildSettingItem(
                    title: 'Valores',
                    description:
                        'Os alunos poderão ver a pontuação total e os pontos recebidos para cada pergunta.',
                    value: _showScores,
                    onChanged: (value) {
                      setState(() => _showScores = value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Seção: Configuração de Acesso
                  Text(
                    'Configuração de acesso',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Opção 4: Acesso à prova
                  _buildSettingItem(
                    title: 'Acesso a prova',
                    description: 'Login com email institucional necessário.',
                    value: _requireInstitutionalLogin,
                    onChanged: (value) {
                      setState(() => _requireInstitutionalLogin = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Opção 5: Tentativa única
                  _buildSettingItem(
                    title:
                        'Restringe a realização da prova a uma única tentativa.',
                    description: '',
                    value: _singleAttemptOnly,
                    onChanged: (value) {
                      setState(() => _singleAttemptOnly = value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Seção: Pontuação
                  Text(
                    'Pontuação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Opção 6: Pontuação padrão
                  _buildSettingItem(
                    title: 'Pontuação padrão das perguntas',
                    description: 'Pontos de cada pergunta nova.',
                    value: _useDefaultQuestionScore,
                    onChanged: (value) {
                      setState(() => _useDefaultQuestionScore = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.greyText,
                              height: 1.4,
                            ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildSwitch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.green,
      activeTrackColor: AppColors.green.withValues(alpha: 0.3),
      inactiveThumbColor: AppColors.greyLight,
      inactiveTrackColor: AppColors.greyLight.withValues(alpha: 0.3),
    );
  }
}

/// Modal para importar questões usando o componente QuestionSelectionList
class _ImportQuestionModal extends StatefulWidget {
  final List<QuestionListItemData> availableQuestions;
  final Function(Set<String> selectedIds) onImport;

  const _ImportQuestionModal({
    required this.availableQuestions,
    required this.onImport,
  });

  @override
  State<_ImportQuestionModal> createState() => _ImportQuestionModalState();
}

class _ImportQuestionModalState extends State<_ImportQuestionModal> {
  Set<String> _selectedQuestionIds = {};

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: screenWidth * 0.9,
        height: screenHeight * 0.85,
        child: Column(
          children: [
            // Cabeçalho do modal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.download_outlined,
                    color: AppColors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Importar Questões',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selecione as questões do banco para adicionar à prova',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                    iconSize: 28,
                  ),
                ],
              ),
            ),

            // Área de informação
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                border: const Border(
                  bottom: BorderSide(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use os filtros e a busca para encontrar questões específicas. Você pode selecionar múltiplas questões.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Contador de seleções
            if (_selectedQuestionIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedQuestionIds.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedQuestionIds.length == 1
                            ? '1 questão selecionada'
                            : '${_selectedQuestionIds.length} questões selecionadas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            // Conteúdo do modal com o componente de seleção
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _CompactQuestionSelectionList(
                  items: widget.availableQuestions,
                  initialSelectedIds: _selectedQuestionIds,
                  onSelectionChanged: (selectedIds) {
                    setState(() {
                      _selectedQuestionIds = selectedIds;
                    });
                  },
                ),
              ),
            ),

            // Rodapé do modal com botões
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.whiteBg,
                border: Border(
                  top: BorderSide(
                    color: AppColors.greyLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Informação adicional
                  Expanded(
                    child: Text(
                      _selectedQuestionIds.isEmpty
                          ? 'Nenhuma questão selecionada'
                          : 'Pronto para importar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _selectedQuestionIds.isNotEmpty
                            ? () {
                                widget.onImport(_selectedQuestionIds);
                              }
                            : null,
                        icon: const Icon(Icons.check),
                        label: Text(
                          _selectedQuestionIds.length == 1
                              ? 'Importar 1 Questão'
                              : 'Importar ${_selectedQuestionIds.length} Questões',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.greyLight,
                          disabledForegroundColor:
                              AppColors.greyText.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Versão compacta da lista de seleção de questões para uso em modal
class _CompactQuestionSelectionList extends StatefulWidget {
  const _CompactQuestionSelectionList({
    required this.items,
    required this.initialSelectedIds,
    required this.onSelectionChanged,
  });

  final List<QuestionListItemData> items;
  final Set<String> initialSelectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<_CompactQuestionSelectionList> createState() =>
      _CompactQuestionSelectionListState();
}

class _CompactQuestionSelectionListState
    extends State<_CompactQuestionSelectionList> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Set<String>> _selectedFilters = {
    'Conteúdo': <String>{},
    'Matéria': <String>{},
    'Professor': <String>{},
    'Semestre': <String>{},
    'Ano': <String>{},
  };

  late Set<String> _selectedIds;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  void _updateFilter(String category, String value, bool selected) {
    setState(() {
      final filters = _selectedFilters[category];
      if (filters == null) return;
      if (selected) {
        filters.add(value);
      } else {
        filters.remove(value);
      }
    });
  }

  List<QuestionListItemData> _applyFilters(List<QuestionListItemData> items) {
    final query = _searchController.text.trim().toLowerCase();

    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.enunciation.toLowerCase().contains(query) ||
          item.tagMap.values
              .any((value) => value.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      for (final entry in _selectedFilters.entries) {
        final selectedValues = entry.value;
        if (selectedValues.isEmpty) continue;

        final itemValue = item.tagMap[entry.key] ?? '';
        if (!selectedValues.contains(itemValue)) return false;
      }

      return true;
    }).toList(growable: false);
  }

  Map<String, List<String>> _availableFilters() {
    final Map<String, Set<String>> collected = {
      'Conteúdo': <String>{},
      'Matéria': <String>{},
      'Professor': <String>{},
      'Semestre': <String>{},
      'Ano': <String>{},
    };

    for (final item in widget.items) {
      item.tagMap.forEach((key, value) {
        if (value.trim().isEmpty) return;
        collected[key]?.add(value);
      });
    }

    return collected.map((key, value) {
      final list = value.toList()..sort();
      return MapEntry(key, list);
    });
  }

  int get _activeFiltersCount {
    return _selectedFilters.values.fold(0, (sum, set) => sum + set.length);
  }

  @override
  Widget build(BuildContext context) {
    final filters = _availableFilters();
    final filteredItems = _applyFilters(widget.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de busca
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Pesquisar enunciado ou tags...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.webNeutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.webNeutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botão para mostrar/ocultar filtros
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          icon: Icon(
            _showFilters ? Icons.filter_list_off : Icons.filter_list,
            size: 18,
          ),
          label: Text(
            _showFilters
                ? 'Ocultar Filtros'
                : 'Mostrar Filtros${_activeFiltersCount > 0 ? ' ($_activeFiltersCount)' : ''}',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                _activeFiltersCount > 0 ? AppColors.green : AppColors.greyText,
            side: BorderSide(
              color: _activeFiltersCount > 0
                  ? AppColors.green
                  : AppColors.webNeutral300,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),

        // Seção de filtros expansível e com altura limitada
        if (_showFilters)
          Container(
            margin: const EdgeInsets.only(top: 12),
            constraints: const BoxConstraints(
              maxHeight: 200, // Altura máxima dos filtros
            ),
            decoration: BoxDecoration(
              color: AppColors.whiteBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.webNeutral300),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _CompactFilterSection(
                filters: filters,
                selectedFilters: _selectedFilters,
                onFilterChanged: _updateFilter,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Contador de resultados
        Row(
          children: [
            Text(
              '${filteredItems.length} questão(ões) encontrada(s)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (_activeFiltersCount > 0 || _searchController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedFilters.forEach((key, value) => value.clear());
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Limpar filtros',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.orange,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Lista de questões com scroll
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma questão encontrada com os filtros atuais.',
                    style: TextStyle(
                      color: AppColors.webNeutral600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompactQuestionCard(
                        item: item,
                        isSelected: isSelected,
                        onToggle: () => _toggleSelection(item.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Card compacto de questão
class _CompactQuestionCard extends StatefulWidget {
  const _CompactQuestionCard({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  final QuestionListItemData item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  State<_CompactQuestionCard> createState() => _CompactQuestionCardState();
}

class _CompactQuestionCardState extends State<_CompactQuestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final highlightColor = AppColors.green.withValues(alpha: 0.08);
    final borderColor =
        widget.isSelected ? AppColors.green : AppColors.webNeutral200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => _expanded = !_expanded);
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected ? highlightColor : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onToggle(),
                activeColor: AppColors.green,
                checkColor: AppColors.white,
                side: BorderSide(color: AppColors.webNeutral400),
              ),
              const SizedBox(width: 8),

              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.enunciation,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.item.tagMap.entries
                          .where((entry) => entry.value.trim().isNotEmpty)
                          .map((entry) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        AppColors.green.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),

              // Ícone de expandir
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.webNeutral500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção de filtros compacta
class _CompactFilterSection extends StatelessWidget {
  const _CompactFilterSection({
    required this.filters,
    required this.selectedFilters,
    required this.onFilterChanged,
  });

  final Map<String, List<String>> filters;
  final Map<String, Set<String>> selectedFilters;
  final void Function(String category, String value, bool selected)
      onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filters.entries.map((entry) {
        if (entry.value.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.webNeutral700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.value.map((value) {
                  final selected =
                      selectedFilters[entry.key]?.contains(value) ?? false;

                  return InkWell(
                    onTap: () => onFilterChanged(entry.key, value, !selected),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.green.withValues(alpha: 0.18)
                            : AppColors.webNeutral100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.green
                              : AppColors.webNeutral300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.green,
                            ),
                          if (selected) const SizedBox(width: 4),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? AppColors.green
                                  : AppColors.webNeutral700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}
