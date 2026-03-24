import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/constants/supabase_options.dart';
import 'package:unicv_tech_mvp/models/exam_template.dart';
import 'package:unicv_tech_mvp/repositories/published_exam_repository.dart';
import 'package:unicv_tech_mvp/viewmodels/published_exams_view_model.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_chekbox.dart';
import 'package:unicv_tech_mvp/ui/components/default_inline_message.dart';
import 'package:unicv_tech_mvp/ui/components/feedback_severity.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/theme/string_text.dart';

enum _QuizMode { simulado, provas }

class QuizConfigScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const QuizConfigScreen({super.key, required this.course});

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String? _selectedQuantity;
  bool _isLoading = false;
  String? _feedbackMessage;
  FeedbackSeverity? _feedbackSeverity;
  _QuizMode _mode = _QuizMode.simulado;
  String? _startingTemplateId;

  PublishedExamsViewModel? _publishedExamsVM;

  final List<String> _quantityOptions = ['5', '10', '15', '20'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPublishedExamsVM();
    });
  }

  void _initPublishedExamsVM() {
    final repo = context.read<PublishedExamRepository?>();
    final courseId =
        (widget.course['courseId'] ?? widget.course['id']) as String?;
    if (repo != null && courseId != null) {
      _publishedExamsVM = PublishedExamsViewModel(
        repository: repo,
        courseId: courseId,
      );
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _publishedExamsVM?.dispose();
    super.dispose();
  }

  void _onModeChanged(_QuizMode mode) {
    setState(() {
      _mode = mode;
      _feedbackMessage = null;
      _feedbackSeverity = null;
    });
    if (mode == _QuizMode.provas && _publishedExamsVM != null) {
      if (_publishedExamsVM!.templates.isEmpty &&
          !_publishedExamsVM!.isLoading) {
        _publishedExamsVM!.loadTemplates();
      }
    }
  }

  void _onQuantitySelected(String quantity) {
    setState(() {
      _selectedQuantity = quantity;
      _feedbackMessage = null;
      _feedbackSeverity = null;
    });
  }

  void _setFeedback(String message, FeedbackSeverity severity) {
    if (!mounted) return;
    setState(() {
      _feedbackMessage = message;
      _feedbackSeverity = severity;
    });
  }

  void _clearFeedback() {
    if (!mounted) return;
    if (_feedbackMessage == null && _feedbackSeverity == null) {
      return;
    }
    setState(() {
      _feedbackMessage = null;
      _feedbackSeverity = null;
    });
  }

  Future<void> _ensureUserRecord(SupabaseClient client, User user) async {
    try {
      final existing = await client
          .from('user')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        debugPrint('Usuário já existe na tabela user: ${user.id}');
        return;
      }

      final email = user.email;
      if (email == null) {
        throw Exception(
          'Impossível criar registro: usuário autenticado sem e-mail disponível.',
        );
      }

      final firstName = user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['first_name'] as String?;
      final surname = user.userMetadata?['last_name'] as String?;

      await client.from('user').upsert({
        'id': user.id,
        'email': email,
        'first_name': firstName,
        'surename': surname,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Registro do usuário criado na tabela user: ${user.id}');
    } catch (e) {
      debugPrint('Erro ao garantir registro do usuário: $e');
      rethrow;
    }
  }

  void _startQuiz() async {
    if (_selectedQuantity == null || _isLoading) return;

    _clearFeedback();

    setState(() {
      _isLoading = true;
    });

    try {
      if (!SupabaseOptions.isConfigured) {
        _setFeedback(
          'Supabase não está configurado nesta build.',
          FeedbackSeverity.error,
        );
        return;
      }

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        _setFeedback(
            'Faça login para iniciar o simulado.', FeedbackSeverity.error);
        return;
      }

      final courseId =
          (widget.course['courseId'] ?? widget.course['id']) as String?;
      if (courseId == null || courseId.isEmpty) {
        _setFeedback('Não foi possível identificar o curso selecionado.',
            FeedbackSeverity.error);
        return;
      }

      debugPrint(
          'Iniciando quiz para ${widget.course['title']} com $_selectedQuantity questões...');

      final questionCount = int.parse(_selectedQuantity!);

      // Contar total de questões disponíveis para simulado (apenas ENADE, sem questões de professores)
      final questionsResponse = await client
          .from('question')
          .select('id')
          .eq('id_course', courseId)
          .eq('is_active', true)
          .isFilter('id_teacher', null);

      final totalAvailableQuestions = questionsResponse.length;

      if (totalAvailableQuestions == 0) {
        _setFeedback('Nenhuma questão disponível para este curso.',
            FeedbackSeverity.warning);
        return;
      }

      if (totalAvailableQuestions < questionCount) {
        _setFeedback(
            'Este curso possui apenas $totalAvailableQuestions questão(ões) disponível(is).',
            FeedbackSeverity.warning);
        return;
      }

      // Garantir que o usuário existe na tabela user antes de criar o exame
      await _ensureUserRecord(client, user);

      // Sempre criar novo exame com a quantidade escolhida
      final courseTitle = widget.course['title'] as String? ?? 'Curso';
      final newExam = await client
          .from('exam')
          .insert({
            'id_course': courseId,
            'id_user': user.id, // Adicionar ID do usuário
            'title': 'Simulado de $courseTitle - $_selectedQuantity questões',
            'description':
                'Simulado de preparação para o curso de $courseTitle com $_selectedQuantity questões.',
            'total_available_questions': totalAvailableQuestions,
            'question_count': questionCount,
            'time_limit_minutes': 60,
            'passing_score_percentage': 70.0,
            'is_active': true,
            'date_start': DateTime.now().toIso8601String(),
            'date_end':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'is_completed': false,
          })
          .select('id')
          .single();

      final examId = newExam['id'] as String;
      debugPrint('Novo exame criado: $examId com $questionCount questões');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      await context.push(
        '/exam/$examId?courseId=${Uri.encodeComponent(courseId)}&questionCount=${int.parse(_selectedQuantity!)}',
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao iniciar quiz: $error');
      debugPrintStack(stackTrace: stackTrace);
      _setFeedback('Erro ao iniciar o simulado. Tente novamente.',
          FeedbackSeverity.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startPublishedExam(ExamTemplate template) async {
    final vm = _publishedExamsVM;
    if (vm == null || _startingTemplateId != null) return;

    _clearFeedback();

    setState(() {
      _startingTemplateId = template.id;
    });

    try {
      if (!SupabaseOptions.isConfigured) {
        _setFeedback(
          'Supabase não está configurado nesta build.',
          FeedbackSeverity.error,
        );
        return;
      }

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        _setFeedback(
            'Faça login para iniciar a prova.', FeedbackSeverity.error);
        return;
      }

      final courseId =
          (widget.course['courseId'] ?? widget.course['id']) as String?;
      if (courseId == null || courseId.isEmpty) {
        _setFeedback('Não foi possível identificar o curso selecionado.',
            FeedbackSeverity.error);
        return;
      }

      await _ensureUserRecord(client, user);

      final examId = await vm.startExam(
        templateId: template.id,
        userId: user.id,
      );

      if (examId == null) {
        _setFeedback(
          vm.error ?? 'Erro ao iniciar a prova.',
          FeedbackSeverity.error,
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _startingTemplateId = null;
      });

      await context.push(
        '/exam/$examId?courseId=${Uri.encodeComponent(courseId)}&questionCount=${template.questionCount}',
      );
    } catch (error, stackTrace) {
      debugPrint('Falha ao iniciar prova publicada: $error');
      debugPrintStack(stackTrace: stackTrace);
      _setFeedback(
          'Erro ao iniciar a prova. Tente novamente.', FeedbackSeverity.error);
    } finally {
      if (mounted) {
        setState(() {
          _startingTemplateId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = _selectedQuantity != null && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 33.0),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/SmartQuiz.png',
                                  width: 500,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: DefaultButtonArrowBack(
                                  onPressed: () => context.pop(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildModeToggle(),
                              const SizedBox(height: 24),
                              if (_mode == _QuizMode.simulado)
                                _buildSimuladoContent(isButtonEnabled)
                              else if (_publishedExamsVM != null)
                                ListenableBuilder(
                                  listenable: _publishedExamsVM!,
                                  builder: (context, _) =>
                                      _buildProvasContent(),
                                )
                              else
                                _buildProvasContent(),
                              if (_feedbackMessage != null &&
                                  _feedbackSeverity != null) ...[
                                const SizedBox(height: 20),
                                DefaultInlineMessage(
                                  message: _feedbackMessage!,
                                  severity: _feedbackSeverity!,
                                  onDismissed: _clearFeedback,
                                ),
                              ],
                              const SizedBox(height: 35),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyShade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleTab(
              label: 'Simulado',
              isActive: _mode == _QuizMode.simulado,
              onTap: () => _onModeChanged(_QuizMode.simulado),
            ),
          ),
          Expanded(
            child: _buildToggleTab(
              label: 'Provas',
              isActive: _mode == _QuizMode.provas,
              onTap: () => _onModeChanged(_QuizMode.provas),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.secondaryDark,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildSimuladoContent(bool isButtonEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Escolha a quantidade de questões',
          style: AppTextStyle.titleSmall,
          color: AppColors.primaryDark,
        ),
        const SizedBox(height: 5),
        AppText(
          'Quantas questões deseja fazer ?',
          style: AppTextStyle.subtitleMedium,
          color: AppColors.secondaryDark.withAlpha((0.8 * 255).round()),
        ),
        const SizedBox(height: 30),
        SelectionBox(
          options: _quantityOptions,
          initialOption: _selectedQuantity,
          onOptionSelected: _onQuantitySelected,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              )
            : DefaultButtonOrange(
                texto: 'Iniciar',
                onPressed: isButtonEnabled ? _startQuiz : null,
                tipo: isButtonEnabled
                    ? BotaoTipo.primario
                    : BotaoTipo.desabilitado,
              ),
      ],
    );
  }

  Widget _buildProvasContent() {
    if (_publishedExamsVM == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Serviço indisponível.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryDark,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    if (_publishedExamsVM!.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );
    }

    if (_publishedExamsVM!.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                _publishedExamsVM!.error!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.error,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _publishedExamsVM!.loadTemplates();
                },
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: AppColors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final templates = _publishedExamsVM!.templates;

    if (templates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Nenhuma prova disponível para este curso.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryDark,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Provas do Professor',
          style: AppTextStyle.titleSmall,
          color: AppColors.primaryDark,
        ),
        const SizedBox(height: 5),
        AppText(
          'Selecione uma prova para iniciar',
          style: AppTextStyle.subtitleMedium,
          color: AppColors.secondaryDark.withAlpha((0.8 * 255).round()),
        ),
        const SizedBox(height: 20),
        ...templates.map((t) => _buildExamTemplateCard(t)),
      ],
    );
  }

  Widget _buildExamTemplateCard(ExamTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            if (template.teacherName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.secondaryDark),
                  const SizedBox(width: 4),
                  Text(
                    template.teacherName!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInfoChip(
                  Icons.quiz_outlined,
                  '${template.questionCount} questões',
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.timer_outlined,
                  template.timeLimitLabel,
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildInfoChip(
              Icons.grade_outlined,
              'Nota mínima: ${template.passingScorePercentage.toStringAsFixed(0)}%',
            ),
            if (template.description != null &&
                template.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                template.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: _startingTemplateId == template.id
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    )
                  : DefaultButtonOrange(
                      texto: 'Iniciar Prova',
                      onPressed: _startingTemplateId != null
                          ? null
                          : () => _startPublishedExam(template),
                      tipo: _startingTemplateId != null
                          ? BotaoTipo.desabilitado
                          : BotaoTipo.primario,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.green),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryDark,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
