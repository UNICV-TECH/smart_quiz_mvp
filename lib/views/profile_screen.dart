import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gamification_level.dart';
import '../repositories/gamification_repository.dart';
import '../services/session_manager.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/default_user_data_card.dart';
import '../viewmodels/gamification_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamRepo = context.read<GamificationRepository?>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..loadUserProfile(),
        ),
        if (gamRepo != null)
          ChangeNotifierProvider(
            create: (_) {
              final userId =
                  context.read<SessionManager>().currentUser?.id;
              final vm = GamificationViewModel(repository: gamRepo);
              if (userId != null) {
                vm.loadUserGamification(userId);
                vm.loadSeasonHistory(userId);
              }
              return vm;
            },
          ),
      ],
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
                              Builder(
                                builder: (ctx) {
                                  final gamVm = ctx.watch<GamificationViewModel?>();
                                  final medalAsset = gamVm != null && gamVm.userPoints > 0
                                      ? gamVm.userLevel.medalAsset
                                      : null;
                                  return UserDataCard(
                                    userName: user.name,
                                    userEmail: user.email,
                                    medalAsset: medalAsset,
                                    onNameUpdate: (newName) async {
                                      final success =
                                          await viewModel.updateUserName(newName);
                                      return success;
                                    },
                                    onShowFeedback: (message, {isError = false}) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor: isError
                                              ? AppColors.red
                                              : AppColors.green,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Gamification card
                              _buildGamificationCard(context),

                              const SizedBox(height: 20),

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

  Widget _buildGamificationCard(BuildContext context) {
    final gamVm = context.watch<GamificationViewModel?>();
    if (gamVm == null || gamVm.activeSeason == null) {
      return const SizedBox.shrink();
    }

    final level = gamVm.userLevel;
    final points = gamVm.userPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current level card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    level.medalAsset,
                    width: 48,
                    height: 48,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.military_tech,
                      size: 48,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          level.pointsLabel(points),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF558B2F),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: level.progressInLevel(points),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFC8E6C9),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.green),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Temporada ${gamVm.activeSeason!.name}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF558B2F),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Season history
        if (gamVm.seasonHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Histórico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          ...gamVm.seasonHistory.map((entry) {
            final entryLevel =
                GamificationLevel.fromPoints(entry.totalPoints);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: entry.isActive
                    ? Border.all(color: AppColors.green, width: 1.5)
                    : Border.all(color: const Color(0xFFE2E7DE)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    entryLevel.medalAsset,
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.military_tech,
                      size: 28,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temporada ${entry.seasonName}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${entry.totalPoints.toStringAsFixed(0)} pts — #${entry.rankPosition}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Atual',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ],
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

  Future<void> _handleLogout(BuildContext context) async {
    final authService = context.read<AuthService>();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.secondaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authService.signOut();
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
