import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../ui/components/default_button_orange.dart';
import '../ui/components/default_password_input_47.dart';
import '../ui/theme/app_color.dart';

class ResetPasswordScreen2 extends StatefulWidget {
  const ResetPasswordScreen2({super.key});

  @override
  State<ResetPasswordScreen2> createState() => _ResetPasswordScreen2State();
}

class _ResetPasswordScreen2State extends State<ResetPasswordScreen2> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    context.read<SessionManager>().clearPendingPasswordRecovery();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _meetsCriteria(String pwd) {
    if (pwd.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(pwd)) return false;
    if (!RegExp(r'\d').hasMatch(pwd)) return false;
    return true;
  }

  void _validateRealtime() {
    final p = _passwordController.text;
    final c = _confirmController.text;

    setState(() {
      _passwordError = null;
      _confirmError = null;

      if (p.isNotEmpty && !_meetsCriteria(p)) {
        _passwordError = 'Senha deve ter ≥8 caracteres, 1 maiúscula e 1 número';
      }

      if (c.isNotEmpty && p != c) {
        _confirmError = 'As senhas não coincidem';
      }
    });
  }

  bool get _canSubmit {
    final p = _passwordController.text;
    final c = _confirmController.text;
    return p.isNotEmpty &&
        c.isNotEmpty &&
        p == c &&
        _meetsCriteria(p) &&
        !_isLoading;
  }

  Future<void> _submit() async {
    _validateRealtime();
    if (!_canSubmit) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.updatePassword(_passwordController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      setState(() {
        _passwordError = result.message;
      });
      return;
    }

    // Mostra dialog de sucesso com botão OK que redireciona para login
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Senha alterada'),
        content: const Text('Senha alterada com sucesso!'),
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
          // Imagem de fundo (igual ao layout do login/reset1)
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
                      // Espaço superior
                      const SizedBox(height: 42),

                      // Logo centralizado
                      Center(
                        child: Image.asset(
                          'assets/images/SmartQuiz_branca.png',
                          width: 300,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // Container branco com formulário
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
                                  'Nova Senha',
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

                            Text(
                              'Crie sua nova senha. Ela deve ter ao menos 8 caracteres, incluir uma letra maiúscula e um número.',
                              style: TextStyle(
                                color: AppColors.secondaryDark,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Campos de senha
                            ComponentePasswordInput(
                              controller: _passwordController,
                              labelText: 'Nova senha',
                              hintText: 'Digite a nova senha',
                              errorMessage: _passwordError,
                              onChanged: (_) => _validateRealtime(),
                            ),

                            const SizedBox(height: 20),

                            ComponentePasswordInput(
                              controller: _confirmController,
                              labelText: 'Confirmar nova senha',
                              hintText: 'Repita a nova senha',
                              errorMessage: _confirmError,
                              onChanged: (_) => _validateRealtime(),
                            ),

                            const SizedBox(height: 30),

                            DefaultButtonOrange(
                              texto: _isLoading ? 'Aguarde...' : 'Cadastrar',
                              onPressed: _canSubmit ? _submit : null,
                            ),
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
