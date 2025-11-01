import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_color.dart';
import '../ui/components/default_navbar.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/auth_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildExploreScreen(),
          _buildProfileContent(), // Tela de perfil integrada
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Tela de Início
  Widget _buildHomeScreen() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 80,
              color: AppColors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Tela de Início',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Em desenvolvimento',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tela de Explorar
  Widget _buildExploreScreen() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 80,
              color: AppColors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Tela de Explorar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Em desenvolvimento',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryDark,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tela de Perfil (usando ProfileViewModel)
  Widget _buildProfileContent() {
    return ChangeNotifierProvider(
      create: (_) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final viewModel = ProfileViewModel(authService);
        viewModel.loadUserData();
        return viewModel;
      },
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          final user = viewModel.user;
          final userName = user?.name ?? 'Usuário';
          final userEmail = user?.email ?? 'email@exemplo.com';

          return SafeArea(
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

                // Conteúdo principal
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Card de perfil
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar/Ícone
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              userName,
                                              style: TextStyle(
                                                color: AppColors.primaryDark,
                                                fontSize: 20,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              // TODO: tela de edição de perfil
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.orange,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        userEmail,
                                        style: TextStyle(
                                          color: AppColors.secondaryDark,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Menu items
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Ajuda',
                            onTap: () {
                              Navigator.pushNamed(context, '/help');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.info_outline,
                            title: 'Sobre',
                            onTap: () {
                              Navigator.pushNamed(context, '/about');
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Sair',
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            iconColor: AppColors.red,
                            showChevron: false,
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget genérico de menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool showChevron = true,
  }) {
    final color = iconColor ?? AppColors.green;

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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
            if (showChevron)
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
}
