import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/constants/supabase_options.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'package:unicv_tech_mvp/ui/components/default_chekbox.dart';
import 'package:unicv_tech_mvp/ui/components/default_navbar.dart';
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

  final List<String> _quantityOptions = ['5', '10', '15', '20'];
  final String _logoUrl = 'https://ibprddrdjzazqqaxhilj.supabase.co/storage/v1/object/public/test/LogoFundoClaro.png';

  void _onQuantitySelected(String quantity) {
    setState(() {
      _selectedQuantity = quantity;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _startQuiz() async {
    if (_selectedQuantity == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!SupabaseOptions.isConfigured) {
        _showMessage('Supabase não está configurado nesta build.');
        return;
      }

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        _showMessage('Faça login para iniciar o simulado.');
        return;
      }

      final courseId = (widget.course['courseId'] ?? widget.course['id']) as String?;
      if (courseId == null || courseId.isEmpty) {
        _showMessage('Não foi possível identificar o curso selecionado.');
        return;
      }

      debugPrint('Iniciando quiz para ${widget.course['title']} com $_selectedQuantity questões...');

      final examRecord = await client
          .from('exam')
          .select('id')
          .eq('id_course', courseId)
          .order('created_at')
          .limit(1)
          .maybeSingle();

      if (examRecord == null || examRecord['id'] == null) {
        _showMessage('Nenhum simulado configurado para este curso.');
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
      _showMessage('Erro ao iniciar o simulado. Tente novamente.');
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
                          padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
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
                          color: AppColors.secondaryDark.withAlpha((0.8 * 255).round()),
                        ),
                        const SizedBox(height: 30),
                        SelectionBox(
                          options: _quantityOptions,
                          initialOption: _selectedQuantity,
                          onOptionSelected: _onQuantitySelected,
                        ),
                        const Spacer(flex: 2),
                         _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                            : DefaultButtonOrange(
                                texto: 'Iniciar',
                                onPressed: isButtonEnabled ? _startQuiz : null,
                                tipo: isButtonEnabled ? BotaoTipo.primario : BotaoTipo.desabilitado,
                              ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
                CustomNavBar(
                  selectedIndex: _navBarIndex,
                  onItemTapped: (index) {
                    setState(() { _navBarIndex = index; });
                    if (index == 0) {
                       Navigator.popUntil(context, ModalRoute.withName('/home'));
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
