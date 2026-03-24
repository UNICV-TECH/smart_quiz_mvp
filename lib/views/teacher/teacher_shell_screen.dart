import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/form_protection_notifier.dart';
import '../../services/session_manager.dart';
import '../../ui/components/default_exit_confirmation_dialog.dart';

class TeacherShellScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const TeacherShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<TeacherShellScreen> createState() => _TeacherShellScreenState();
}

class _TeacherShellScreenState extends State<TeacherShellScreen> {
  bool _isQuestionMenuExpanded = false;

  Future<void> _navigateToBranch(int branchIndex) async {
    if (widget.navigationShell.currentIndex == branchIndex) return;

    final formProtection = context.read<FormProtectionNotifier>();
    if (formProtection.hasUnsavedChanges) {
      final result = await DefaultExitConfirmationDialog.show(
        context,
        title: 'Alterações não salvas',
        message:
            'Você tem alterações não salvas no ${formProtection.screenLabel}. '
            'Se sair agora, suas alterações serão perdidas.',
      );

      if (result == null || result == ExitConfirmationResult.continueWork) {
        return;
      }
      formProtection.markSaved();
    }

    widget.navigationShell.goBranch(branchIndex);
  }

  Map<String, dynamic> get _userData {
    final sessionManager = context.watch<SessionManager>();
    final user = sessionManager.currentUser;

    return {
      'name': user?.name ?? 'Professor',
      'email': user?.email ?? '',
      'role': 'Professor',
    };
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();
    final isAdminViewing =
        sessionManager.isAdmin && sessionManager.viewingAsTeacher;

    return Scaffold(
      body: Column(
        children: [
          if (isAdminViewing)
            _buildAdminBanner(context, sessionManager),
          Expanded(
            child: Row(
              children: [
                _buildTeacherSideMenu(),
                Expanded(
                  child: widget.navigationShell,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBanner(
      BuildContext context, SessionManager sessionManager) {
    return Material(
      color: const Color(0xFFB8860B),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.visibility, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Visualizando como professor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                sessionManager.exitTeacherView();
                context.go('/admin');
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
              label: const Text(
                'Voltar ao Admin',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSideMenu() {
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
                    icon: Icons.assignment,
                    title: 'Montar Provas',
                    branchIndex: 0,
                  ),
                  const SizedBox(height: 8),
                  _buildAccordionMenuItem(),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    branchIndex: 4,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.emoji_events,
                    title: 'Gamificação',
                    branchIndex: 5,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Perfil',
                    branchIndex: 2,
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
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: Image.asset(
              'assets/images/SmartQuiz.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Menu do Professor',
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
    required int branchIndex,
    bool isSubItem = false,
  }) {
    bool isSelected = widget.navigationShell.currentIndex == branchIndex;

    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 24.0 : 0),
      child: Material(
        color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _navigateToBranch(branchIndex),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isSelected
                  ? const Border(
                      left: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 4,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSubItem ? 14 : 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF2E7D32),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionMenuItem() {
    return Container(
      decoration: BoxDecoration(
        color: _isQuestionMenuExpanded
            ? const Color(0xFFF5F5F5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isQuestionMenuExpanded = !_isQuestionMenuExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      color: _isQuestionMenuExpanded
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[700],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Criar Questões',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _isQuestionMenuExpanded
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _isQuestionMenuExpanded
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[800],
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: AlwaysStoppedAnimation(
                        _isQuestionMenuExpanded ? 0.5 : 0,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isQuestionMenuExpanded
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isQuestionMenuExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                children: [
                  _buildSubMenuItem(title: 'Nova Questão', branchIndex: 1),
                  _buildSubMenuItem(title: 'Listar Questões', branchIndex: 3),
                  _buildSubMenuItem(title: 'Matérias', branchIndex: 6),
                  _buildSubMenuItem(title: 'Categorias', branchIndex: 7),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required int branchIndex,
  }) {
    bool isSelected = widget.navigationShell.currentIndex == branchIndex;

    return Material(
      color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => _navigateToBranch(branchIndex),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 1,
                  )
                : Border.all(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xFF2E7D32) : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color:
                        isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
                  ),
                ),
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
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person,
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
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
