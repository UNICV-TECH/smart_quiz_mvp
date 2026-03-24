import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../ui/components/default_input.dart';
import '../ui/components/default_button_orange.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';

class ResetPasswordScreen1 extends StatefulWidget {
  const ResetPasswordScreen1({super.key});

  @override
  State<ResetPasswordScreen1> createState() => _ResetPasswordScreen1State();
}

class _ResetPasswordScreen1State extends State<ResetPasswordScreen1> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, List<DateTime>> _attempts = {};

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[\w-.]+@[\w-]+\.[a-zA-Z]{2,}");
    return regex.hasMatch(email);
  }

  Future<void> _sendRecoveryEmail() async {
    final email = _emailController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Formato de e-mail inválido';
      });
      return;
    }

    // Limite local de tentativas: 3 tentativas por hora por e-mail
    final now = DateTime.now();
    _attempts.putIfAbsent(email, () => []);
    _attempts[email] = _attempts[email]!
        .where((t) => now.difference(t).inHours < 1)
        .toList();

    if (_attempts[email]!.length >= 3) {
      setState(() {
        _errorMessage = 'Muitas tentativas. Tente novamente em uma hora.';
      });
      return;
    }

    _attempts[email]!.add(now);

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.resetPasswordForEmail(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      setState(() {
        _errorMessage = result.message;
      });
      return;
    }

    // Sucesso: mostra dialog informando que o email foi enviado
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('E-mail enviado'),
        content: const Text(
          'Se o e-mail estiver cadastrado, você receberá um link de recuperação. Verifique sua caixa de entrada.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo (igual ao layout do login)
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: AppColors.whiteBg,
            ),
            child: Image.asset(
              'assets/images/fundo.png',
              fit: BoxFit.cover,
            ),
          ),

          // Conteúdo com scroll seguindo padrão do login
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Espaço superior igual ao login
                      const SizedBox(height: 42),

                      // Logo centralizado
                      Center(
                        child: Image.asset(
                          'assets/images/SmartQuiz.png',
                          width: 256,
                          height: 93,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // Container branco com formulário seguindo o login
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26.0, vertical: 40.0),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(207),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título com ícone de voltar
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.chevron_left,
                                      color: AppColors.green,
                                      size: 40,
                                    ),
                                    onPressed: () {
                                      context.go('/login');
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                                Text(
                                  'Recuperar\nSenha',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 40,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Formulário com o campo de e-mail
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ComponenteInput(
                                    controller: _emailController,
                                    labelText: AppStrings.emailLabel,
                                    hintText: AppStrings.emailPlaceholder,
                                    keyboardType: TextInputType.emailAddress,
                                    errorMessage: _errorMessage,
                                  ),

                                  const SizedBox(height: 20),

                                  // Mensagem de erro abaixo do campo
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 20),

                                  // Botão Enviar
                                  DefaultButtonOrange(
                                    texto:
                                        _isLoading ? 'Enviando...' : 'Enviar',
                                    onPressed:
                                        _isLoading ? null : _sendRecoveryEmail,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
