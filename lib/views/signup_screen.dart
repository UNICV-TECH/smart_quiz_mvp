import 'package:flutter/material.dart';
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
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    // Lógica de cadastro será implementada aqui
    // Por enquanto, apenas navega para tela de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
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
                          ),

                          const SizedBox(height: 20),

                          // Campo E-mail
                          ComponenteInput(
                            controller: _emailController,
                            labelText: AppStrings.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          // Campo Senha
                          ComponentePasswordInput(
                            controller: _passwordController,
                            labelText: AppStrings.passwordLabel,
                          ),

                          const SizedBox(height: 20),

                          // Campo Confirmar Senha
                          ComponentePasswordInput(
                            controller: _confirmPasswordController,
                            labelText: AppStrings.confirmPasswordLabel,
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
                            texto: AppStrings.signupButton,
                            onPressed: _handleSignup,
                          ),

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
