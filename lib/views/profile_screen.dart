import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/default_user_data_card.dart';
import '../viewmodels/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadUserProfile(),
      child: const _ProfileViewBody(),
    );
  }
}

class _ProfileViewBody extends StatelessWidget {
  const _ProfileViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/FundoWhiteHome.png',
              fit: BoxFit.cover,
            ),
          ),

          // Conteúdo principal
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Header com logo
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_color.png',
                        width: 120,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 50,
                            color: AppColors.green,
                            child: Center(
                              child: Text(
                                'Logo',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Conteúdo do perfil
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (viewModel.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (viewModel.errorMessage != null) {
                          return Center(
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final user = viewModel.user;
                        if (user == null) {
                          return const Center(
                            child: Text(
                              'Usuário não encontrado.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Card de perfil
                              UserDataCard(
                                userName: user.name,
                                userEmail: user.email,
                                onNameUpdate: (newName) async {
                                  final success = await viewModel.updateUserName(newName);
                                  return success;
                                },
                                onShowFeedback: (message, {isError = false}) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: isError
                                          ? AppColors.red
                                          : AppColors.green,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // Itens de menu
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                title: AppStrings.help,
                                onTap: () {
                                  Navigator.pushNamed(context, '/help');
                                },
                              ),

                              const SizedBox(height: 16),

                              _buildMenuItem(
                                icon: Icons.info_outline,
                                title: AppStrings.about,
                                onTap: () {
                                  Navigator.pushNamed(context, '/about');
                                },
                              ),

                              const SizedBox(height: 32),

                              // Botão de sair
                              _buildLogoutButton(context),

                              const SizedBox(height: 100),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Título
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Seta para direita
            Icon(
              Icons.chevron_right,
              color: AppColors.secondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.red,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Text(
                'Sair',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar saída',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.secondaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text(
                'Sair',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
