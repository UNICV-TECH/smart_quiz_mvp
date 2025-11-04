import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/viewmodels/login_view_model.dart';

import '../constants/app_strings.dart';
import '../ui/components/default_button_orange.dart';
import '../ui/components/default_inline_message.dart';
import '../ui/components/default_input.dart';
import '../ui/components/default_password_input_47.dart';
import '../ui/components/feedback_severity.dart';
import '../ui/theme/app_color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    viewModel.clearFeedback();

    if (!viewModel.isInputValid(formKey: _formKey)) {
      return;
    }

    final result = await viewModel.submitLogin(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
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

          // Conteúdo com scroll
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
                      // Logo a 42px do topo
                      const SizedBox(height: 42),
                      Center(
                        child: Image.asset(
                          'assets/images/logo.webp',
                          width: 256,
                          height: 93,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // Container branco com formulário
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26.0,
                          vertical: 40.0,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(207),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              Center(
                                child: Text(
                                  AppStrings.loginTitle,
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 40,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Campo E-mail
                              ComponenteInput(
                                controller: _emailController,
                                labelText: AppStrings.emailLabel,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe seu e-mail';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Informe um e-mail válido';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Campo Senha
                              ComponentePasswordInput(
                                controller: _passwordController,
                                labelText: AppStrings.passwordLabel,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe sua senha';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Esqueceu a senha
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/reset_password',
                                    );
                                  },
                                  child: Text(
                                    AppStrings.forgotPassword,
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Botão Login
                              DefaultButtonOrange(
                                texto: viewModel.isLoading
                                    ? 'Entrando...'
                                    : AppStrings.loginButton,
                                onPressed:
                                    viewModel.isLoading ? null : _handleLogin,
                                tipo: viewModel.isLoading
                                    ? BotaoTipo.desabilitado
                                    : BotaoTipo.primario,
                              ),

                              if (viewModel.errorMessage != null) ...[
                                const SizedBox(height: 16),
                                DefaultInlineMessage(
                                  message: viewModel.errorMessage!,
                                  severity: FeedbackSeverity.error,
                                  onDismissed: viewModel.clearFeedback,
                                ),
                              ],

                              if (viewModel.successMessage != null) ...[
                                const SizedBox(height: 16),
                                DefaultInlineMessage(
                                  message: viewModel.successMessage!,
                                  severity: FeedbackSeverity.success,
                                  onDismissed: viewModel.clearFeedback,
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Link para Cadastro
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.dontHaveAccount,
                                      style: TextStyle(
                                        color: AppColors.secondaryDark,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/signup',
                                        );
                                      },
                                      child: Text(
                                        AppStrings.signupLink,
                                        style: TextStyle(
                                          color: AppColors.orange,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
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
