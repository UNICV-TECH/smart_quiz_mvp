import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/session_manager.dart';
import '../ui/components/default_navbar.dart';

class StudentShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final isAdminViewing = sessionManager.isAdmin && sessionManager.viewingAsStudent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Column(
        children: [
          if (isAdminViewing)
            _buildAdminBanner(context, sessionManager),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onItemTapped: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  Widget _buildAdminBanner(BuildContext context, SessionManager sessionManager) {
    return Material(
      color: const Color(0xFFB8860B),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.visibility, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Visualizando como aluno',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  sessionManager.exitStudentView();
                  context.go('/admin');
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                label: const Text(
                  'Voltar ao Admin',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
