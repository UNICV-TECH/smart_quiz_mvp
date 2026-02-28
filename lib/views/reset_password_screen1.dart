import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/forgot_password_viewmodel.dart';
import '../routes/app_routes.dart';

import '../ui/components/default_button_orange.dart';
import '../ui/components/default_inline_message.dart';
import '../ui/components/default_input.dart';
import '../ui/components/feedback_severity.dart';
import '../ui/theme/app_color.dart';

class ResetPasswordScreen1 extends StatefulWidget {
  const ResetPasswordScreen1({super.key});

  @override
  State<ResetPasswordScreen1> createState() =>
      _ResetPasswordScreen1State();
}

class _ResetPasswordScreen1State
    extends State<ResetPasswordScreen1> {
  final TextEditingController _emailController =
      TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final vm = context.read<ForgotPasswordViewModel>();
    vm.clear();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await vm.sendRecoveryEmail(
      _emailController.text.trim(),
    );

    if (vm.isSuccess && mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.login,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🔥 Fundo igual login
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
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 42),

                      // 🔥 Logo igual login
                      Center(
                        child: Image.asset(
                          'assets/images/logo.webp',
                          width: 256,
                          height: 93,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // 🔥 Container branco igual login
                      Container(
                        width: size.width,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 40,
                        ),
                        decoration:
                            const BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.only(
                            topRight:
                                Radius.circular(207),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Título
                              Center(
                                child: Text(
                                  'Recuperar senha',
                                  style: TextStyle(
                                    color:
                                        AppColors.green,
                                    fontSize: 36,
                                    fontFamily:
                                        'Open Sans',
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Campo Email
                              ComponenteInput(
                                controller:
                                    _emailController,
                                labelText: 'E-mail',
                                keyboardType:
                                    TextInputType
                                        .emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return 'Informe seu e-mail';
                                  }
                                  final emailRegex =
                                      RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex
                                      .hasMatch(
                                          value)) {
                                    return 'Informe um e-mail válido';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Você receberá um link para redefinir sua senha.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      AppColors.secondaryDark,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Botão
                              DefaultButtonOrange(
                                texto: vm.isLoading
                                    ? 'Enviando...'
                                    : 'Enviar link',
                                onPressed:
                                    vm.isLoading
                                        ? null
                                        : _handleSend,
                                tipo: vm.isLoading
                                    ? BotaoTipo
                                        .desabilitado
                                    : BotaoTipo
                                        .primario,
                              ),

                              if (vm.message !=
                                  null) ...[
                                const SizedBox(
                                    height: 16),
                                DefaultInlineMessage(
                                  message:
                                      vm.message!,
                                  severity: vm
                                          .isSuccess
                                      ? FeedbackSeverity
                                          .success
                                      : FeedbackSeverity
                                          .error,
                                  onDismissed:
                                      vm.clear,
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Voltar para login
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes
                                          .login,
                                    );
                                  },
                                  child: const Text(
                                    'Voltar para login',
                                    style: TextStyle(
                                      color: AppColors
                                          .orange,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight
                                              .bold,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}