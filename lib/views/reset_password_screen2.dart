import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/reset_password_viewmodel.dart';
import '../routes/app_routes.dart';
import '../services/session_manager.dart';

import '../ui/components/default_button_orange.dart';
import '../ui/components/default_inline_message.dart';
import '../ui/components/default_password_input_47.dart';
import '../ui/components/feedback_severity.dart';
import '../ui/theme/app_color.dart';

class ResetPasswordScreen2 extends StatefulWidget {
  const ResetPasswordScreen2({super.key});

  @override
  State<ResetPasswordScreen2> createState() => _ResetPasswordScreen2State();
}

class _ResetPasswordScreen2State extends State<ResetPasswordScreen2> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final vm = context.read<ResetPasswordViewModel>();
    final sessionManager = context.read<SessionManager>();

    vm.clear();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await vm.updatePassword(
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (vm.isSuccess) {
      // Faz logoff para garantir que a nova sessão exija o login novo
      await sessionManager.signOut(redirect: false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResetPasswordViewModel>();
    final sessionManager = context.read<SessionManager>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem
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
                      const SizedBox(height: 42),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logo.webp',
                          width: 256,
                          height: 93,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      // Card Branco de Input
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 40,
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
                              const Center(
                                child: Text(
                                  'Criar nova senha',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 32,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Campo: Nova Senha
                              ComponentePasswordInput(
                                controller: _passwordController,
                                labelText: 'Nova senha',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe a nova senha';
                                  }
                                  if (value.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Campo: Confirmar Nova Senha
                              ComponentePasswordInput(
                                controller: _confirmPasswordController,
                                labelText: 'Confirmar nova senha',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirme sua senha';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 30),

                              // Botão de Salvar
                              DefaultButtonOrange(
                                texto: vm.isLoading
                                    ? 'Salvando...'
                                    : 'Salvar nova senha',
                                onPressed: vm.isLoading ? null : _handleUpdate,
                                tipo: vm.isLoading
                                    ? BotaoTipo.desabilitado
                                    : BotaoTipo.primario,
                              ),

                              // Mensagens de Erro/Sucesso
                              if (vm.message != null) ...[
                                const SizedBox(height: 16),
                                DefaultInlineMessage(
                                  message: vm.message!,
                                  severity: vm.isSuccess
                                      ? FeedbackSeverity.success
                                      : FeedbackSeverity.error,
                                  onDismissed: vm.clear,
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Botão Voltar
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    await sessionManager.signOut(redirect: false);
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: const Text(
                                    'Voltar para login',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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