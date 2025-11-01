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
  final String _logoUrl =
      'https://ibprddrdjzazqqaxhilj.supabase.co/storage/v1/object/public/test/LogoFundoClaro.png';

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
        _setFeedback('Faça login para iniciar o simulado.',
            FeedbackSeverity.error);
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

      final examRecord = await client
          .from('exam')
          .select('id')
          .eq('id_course', courseId)
          .order('created_at')
          .limit(1)
          .maybeSingle();

      if (examRecord == null || examRecord['id'] == null) {
        _setFeedback('Nenhum simulado configurado para este curso.',
            FeedbackSeverity.warning);
        return;
      }

      final examId = examRecord['id'] as String;

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 33.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 5.0),
                          child: Center(
                            child: AppLogoWidget.network(
                              size: AppLogoSize.small,
                              logoPath: _logoUrl,
                              semanticLabel: 'Logo UniCV',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: DefaultButtonArrowBack(
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
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
                        const Spacer(flex: 2),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.orange))
                            : DefaultButtonOrange(
                                texto: 'Iniciar',
                                onPressed: isButtonEnabled ? _startQuiz : null,
                                tipo: isButtonEnabled
                                    ? BotaoTipo.primario
                                    : BotaoTipo.desabilitado,
                              ),
                        const SizedBox(height: 35),
                      ],
                    ),
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
