import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/viewmodels/signup_view_model.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/default_input.dart';
import '../ui/components/default_password_input_47.dart';
import '../ui/components/default_button_orange.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _handleSignup() async {
    final viewModel = context.read<SignUpViewModel>();
    viewModel.clearFeedback();

    if (!viewModel.isInputsValid(formKey: _formKey)) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    final result = await viewModel.submitSignup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      acceptedTerms: _acceptedTerms,
    );

    if (!mounted) {
      return;
    }

    if (result.success) {
      final message = viewModel.successMessage ??
          'Conta criada com sucesso! Verifique seu e-mail.';
      messenger.showSnackBar(SnackBar(content: Text(message)));

      if (!result.needsEmailConfirmation) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (viewModel.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
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

                    const SizedBox(height: 40),

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
                      child: Form(
                        key: _formKey,
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
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                                Text(
                                  'Cadastrar',
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

                            // Campo Nome
                            ComponenteInput(
                              controller: _nameController,
                              labelText: AppStrings.nameLabel,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu nome';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo E-mail
                            ComponenteInput(
                              controller: _emailController,
                              labelText: AppStrings.emailLabel,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu email';
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
                                  return 'Por favor, insira sua senha';
                                }
                                if (value.length < 6) {
                                  return 'Sua senha deve ter ao menos 6 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Campo Confirmar Senha
                            ComponentePasswordInput(
                              controller: _confirmPasswordController,
                              labelText: AppStrings.confirmPasswordLabel,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, confirme sua senha';
                                }
                                if (value != _passwordController.text) {
                                  return 'As senhas não conferem';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Checkbox de termos
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _acceptedTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptedTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.orange,
                                    side: BorderSide(
                                      color: AppColors.orange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: AppColors.secondaryDark,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Ao continuar você concorda com nossos ',
                                        ),
                                        TextSpan(
                                          text: 'Termos de serviço',
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' e ',
                                        ),
                                        TextSpan(
                                          text: 'Política de privacidade',
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Botão Cadastrar
                            DefaultButtonOrange(
                              texto: viewModel.isLoading
                                  ? 'Cadastrando...'
                                  : AppStrings.signupButton,
                              tipo: viewModel.isLoading
                                  ? BotaoTipo.desabilitado
                                  : BotaoTipo.primario,
                              onPressed:
                                  viewModel.isLoading ? null : _handleSignup,
                            ),

                            if (viewModel.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            if (viewModel.successMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                viewModel.successMessage!,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Link para Login
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.alreadyHaveAccount,
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
                                          context, '/login');
                                    },
                                    child: Text(
                                      AppStrings.loginLink,
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
        ],
      ),
    );
  }
}
