import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/constants/supabase_options.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_chekbox.dart';
import 'package:unicv_tech_mvp/ui/components/default_inline_message.dart';
import 'package:unicv_tech_mvp/ui/components/default_navbar.dart';
import 'package:unicv_tech_mvp/ui/components/feedback_severity.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/theme/string_text.dart';

class QuizConfigScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const QuizConfigScreen({super.key, required this.course});

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String? _selectedQuantity;
  bool _isLoading = false;
  int _navBarIndex = 0;
  String? _feedbackMessage;
  FeedbackSeverity? _feedbackSeverity;

  final List<String> _quantityOptions = ['5', '10', '15', '20'];
  final String _logoAssetPath = 'assets/images/logo_color.png';

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

      // Contar total de questões disponíveis para o curso
      final questionsResponse = await client
          .from('question')
          .select('id')
          .eq('id_course', courseId)
          .eq('is_active', true);

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

      await Navigator.pushNamed(
        context,
        '/exam',
        arguments: {
          'userId': user.id,
          'examId': examId,
          'courseId': courseId,
          'questionCount': int.parse(_selectedQuantity!),
        },
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
                              const SizedBox(height: 15),
                              Center(
                                child: AppLogoWidget.asset(
                                  size: AppLogoSize.small,
                                  logoPath: _logoAssetPath,
                                  semanticLabel: 'Logo UniCV',
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: DefaultButtonArrowBack(
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const AppText(
                                'Escolha a quantidade de questões',
                                style: AppTextStyle.titleSmall,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(height: 5),
                              AppText(
                                'Alinhe ao seu tempo disponível!',
                                style: AppTextStyle.subtitleMedium,
                                color: AppColors.secondaryDark
                                    .withAlpha((0.8 * 255).round()),
                              ),
                              const SizedBox(height: 30),
                              SelectionBox(
                                options: _quantityOptions,
                                initialOption: _selectedQuantity,
                                onOptionSelected: _onQuantitySelected,
                              ),
                              if (_feedbackMessage != null &&
                                  _feedbackSeverity != null) ...[
                                const SizedBox(height: 20),
                                DefaultInlineMessage(
                                  message: _feedbackMessage!,
                                  severity: _feedbackSeverity!,
                                  onDismissed: _clearFeedback,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.orange),
                                    )
                                  : DefaultButtonOrange(
                                      texto: 'Iniciar',
                                      onPressed:
                                          isButtonEnabled ? _startQuiz : null,
                                      tipo: isButtonEnabled
                                          ? BotaoTipo.primario
                                          : BotaoTipo.desabilitado,
                                    ),
                              const SizedBox(height: 35),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CustomNavBar(
                  selectedIndex: _navBarIndex,
                  onItemTapped: (index) {
                    setState(() {
                      _navBarIndex = index;
                    });
                    if (index == 0) {
                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == '/main' || route.isFirst,
                      );
                    } else {
                      debugPrint("NavBar Tapped: $index");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
