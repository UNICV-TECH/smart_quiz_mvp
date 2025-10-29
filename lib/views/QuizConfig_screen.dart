import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_arrow_back.dart';
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

  void _startQuiz() async {
    if (_selectedQuantity == null) return;

    setState(() { _isLoading = true; });
    debugPrint('Iniciando quiz para ${widget.course['title']} com $_selectedQuantity questões...');

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() { _isLoading = false; });
      debugPrint('Navegação para a tela do Quiz a ser implementada aqui.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulado para ${widget.course['title']} (${_selectedQuantity} questões) iniciado! (Navegação pendente)'),
          duration: const Duration(seconds: 2),
        ),
      );
   
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
                  selectedIndex: _navBarIndex, // Informa qual item está ativo
                  onItemTapped: (index) {      // Define o que acontece ao tocar
                    setState(() { _navBarIndex = index; }); // Atualiza o item ativo
                    if (index == 0) {
                      // Se clicar em Início, volta para a HomeScreen
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

