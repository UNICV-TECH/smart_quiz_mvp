import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';
import '../ui/components/default_user_data_card.dart';
import '../constants/supabase_options.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Carregando...';
  String _userEmail = 'Carregando...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!SupabaseOptions.isConfigured) {
      setState(() {
        _userName = 'Usuário';
        _userEmail = 'Não disponível';
        _isLoading = false;
      });
      return;
    }

    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;

      if (authUser == null) {
        setState(() {
          _userName = 'Usuário não autenticado';
          _userEmail = 'Não disponível';
          _isLoading = false;
        });
        return;
      }

      // Buscar dados do usuário na tabela user
      final userData = await client
          .from('user')
          .select('first_name, surename, email')
          .eq('id', authUser.id)
          .maybeSingle();

      if (userData != null) {
        final firstName = userData['first_name'] as String? ?? '';
        final surname = userData['surename'] as String? ?? '';
        final fullName =
            [firstName, surname].where((s) => s.isNotEmpty).join(' ');

        setState(() {
          _userName = fullName.isNotEmpty
              ? fullName
              : authUser.userMetadata?['full_name'] as String? ??
                  authUser.email?.split('@').first ??
                  'Usuário';
          _userEmail = userData['email'] as String? ??
              authUser.email ??
              'Não disponível';
          _isLoading = false;
        });
      } else {
        // Se não encontrar na tabela user, usar dados do auth
        final fullName = authUser.userMetadata?['full_name'] as String?;
        setState(() {
          _userName = fullName ?? authUser.email?.split('@').first ?? 'Usuário';
          _userEmail = authUser.email ?? 'Não disponível';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      setState(() {
        _userName = 'Erro ao carregar';
        _userEmail = 'Não disponível';
        _isLoading = false;
      });
    }
  }

  Future<bool> _updateUserName(String newName) async {
    if (!SupabaseOptions.isConfigured) {
      return false;
    }

    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;

      if (authUser == null) {
        return false;
      }

      // Separar nome em primeiro nome e sobrenome
      final nameParts = newName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : newName;
      final surname =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

      // Atualizar na tabela user
      await client.from('user').update({
        'first_name': firstName,
        'surename': surname,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', authUser.id);

      // Atualizar também no metadata do auth (opcional)
      await client.auth.updateUser(
        UserAttributes(
          data: {'full_name': newName},
        ),
      );

      // Recarregar dados
      await _loadUserData();

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar nome do usuário: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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

                  // Conteúdo principal
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Card de perfil com edição inline
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.green,
                                    ),
                                  )
                                : UserDataCard(
                                    userName: _userName,
                                    userEmail: _userEmail,
                                    onNameUpdate: _updateUserName,
                                    onShowFeedback: (message,
                                        {isError = false}) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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

                            // Menu items
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

                            // Botão de Sair
                            _buildLogoutButton(),

                            const SizedBox(height: 100), // Espaço para o navbar
                          ],
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

            // Chevron para direita
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

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout,
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

            // Título
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

  void _handleLogout() {
    // Mostrar diálogo de confirmação
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
                Navigator.pop(context); // Fechar diálogo
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
