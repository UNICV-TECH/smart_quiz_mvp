import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/session_manager.dart';
import '../../services/auth_service.dart';
import '../../repositories/admin_repository.dart';
import '../../viewmodels/admin/admin_dashboard_view_model.dart';
import '../../viewmodels/admin/admin_user_management_view_model.dart';
import '../../viewmodels/admin/admin_content_view_model.dart';
import 'admin_dashboard_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_content_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  static const _indigoColor = Color(0xFF3F51B5);
  static const _indigoLight = Color(0xFFE8EAF6);

  Map<String, dynamic> get _userData {
    final sessionManager = context.watch<SessionManager>();
    final user = sessionManager.currentUser;
    return {
      'name': user?.name ?? 'Admin',
      'email': user?.email ?? '',
      'role': 'Administrador',
    };
  }

  @override
  Widget build(BuildContext context) {
    final adminRepo = context.read<AdminRepository?>();
    if (adminRepo == null) {
      return const Scaffold(
        body: Center(child: Text('Admin não disponível')),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSideMenu(),
          Expanded(
            child: _buildContent(adminRepo),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminRepository adminRepo) {
    switch (_selectedIndex) {
      case 0:
        return ChangeNotifierProvider(
          create: (_) => AdminDashboardViewModel(adminRepository: adminRepo)
            ..loadStats(),
          child: const AdminDashboardScreen(),
        );
      case 1:
        return ChangeNotifierProvider(
          create: (_) => AdminUserManagementViewModel(adminRepository: adminRepo)
            ..loadUsers(),
          child: const AdminUserListScreen(),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (_) => AdminContentViewModel(adminRepository: adminRepo)
            ..loadContent(),
          child: const AdminContentScreen(),
        );
      default:
        return const Center(child: Text('Página não encontrada'));
    }
  }

  Widget _buildSideMenu() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
        border: const Border(
          right: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildMenuHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    index: 0,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.people_outlined,
                    title: 'Usuários',
                    index: 1,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.library_books_outlined,
                    title: 'Conteúdo',
                    index: 2,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.school_outlined,
                    title: 'Painel Professor',
                    index: -1,
                    onTap: () {
                      context.go('/teacher/templates');
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildProfileFooter(),
        ],
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _indigoColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: Image.asset(
              'assets/images/logo.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Painel Admin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    bool isSelected = _selectedIndex == index;

    return Material(
      color: isSelected ? _indigoLight : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap ??
            () {
              setState(() {
                _selectedIndex = index;
              });
            },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    left: BorderSide(
                      color: _indigoColor,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? _indigoColor : Colors.grey[700],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? _indigoColor : Colors.grey[800],
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: _indigoColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _indigoColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _userData['email'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _userData['role'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _indigoColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 20),
            onPressed: () => _handleLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = context.read<AuthService>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmar saída',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Tem certeza que deseja sair?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authService.signOut();
              },
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
