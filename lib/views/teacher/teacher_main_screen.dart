import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/session_manager.dart';
import '../../services/auth_service.dart';
import '../../ui/theme/app_color.dart';
import '../../ui/components/default_user_data_card.dart';
import '../../viewmodels/profile_view_model.dart';
import '../../constants/app_strings.dart';
import 'teacher_create_question.dart';
import 'teacher_gamification_screen.dart';
import 'teacher_question_list_screen.dart';
import 'teacher_subject_list_screen.dart';
import 'teacher_category_list_screen.dart';
import 'teacher_exam_templates_screen.dart';
import 'teacher_stats_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _selectedIndex = 0;
  bool _isQuestionMenuExpanded = false;

  // Dados do usuário obtidos do SessionManager
  Map<String, dynamic> get _userData {
    final sessionManager = context.watch<SessionManager>();
    final user = sessionManager.currentUser;

    return {
      'name': user?.name ?? 'Professor',
      'email': user?.email ?? '',
      'avatarUrl': '',
      'role': 'Professor',
    };
  }

  // Telas correspondentes às opções do menu
  List<Widget> get _screens => [
        const TeacherExamTemplatesScreen(), // 0: Montar Provas
        const TeacherScreenCreateQuestion(), // 1: Nova Questão
        const TeacherProfileScreen(), // 2: Perfil
        const TeacherQuestionListScreen(), // 3: Listar Questões
        const TeacherStatsScreen(), // 4: Dashboard
        const TeacherGamificationScreen(), // 5: Gamificação
        const TeacherSubjectListScreen(), // 6: Matérias
        const TeacherCategoryListScreen(), // 7: Categorias
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu lateral para professores
          _buildTeacherSideMenu(),

          // Conteúdo principal
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
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
          // Topo: Identidade Visual
          _buildMenuHeader(),

          const SizedBox(height: 20),

          // Opções do menu
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Opção 1: Montar Provas
                  _buildMenuItem(
                    icon: Icons.assignment,
                    title: 'Montar Provas',
                    index: 0,
                  ),

                  const SizedBox(height: 8),

                  // Opção 2: Criar Questões (Sanfona/Accordion)
                  _buildAccordionMenuItem(),

                  const SizedBox(height: 8),

                  // Opção 3: Dashboard
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    index: 4,
                  ),

                  const SizedBox(height: 8),

                  // Opção 4: Gamificação
                  _buildMenuItem(
                    icon: Icons.emoji_events,
                    title: 'Gamificação',
                    index: 5,
                  ),

                  const SizedBox(height: 8),

                  // Opção 5: Perfil
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Perfil',
                    index: 2,
                  ),
                ],
              ),
            ),
          ),

          // Componente de Perfil (rodapé)
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
          // Logo da instituição
          SizedBox(
            height: 72,
            child: Image.asset(
              'assets/images/logo.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          // Título do menu
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
    required int index,
    bool isSubItem = false,
  }) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 24.0 : 0),
      child: Material(
        color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
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
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: const Color(0xFF2E7D32),
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
          // Cabeçalho da sanfona
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
          // Conteúdo da sanfona (expandido)
          if (_isQuestionMenuExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                children: [
                  _buildSubMenuItem(
                    title: 'Nova Questão',
                    index: 1,
                  ),
                  _buildSubMenuItem(
                    title: 'Listar Questões',
                    index: 3,
                  ),
                  _buildSubMenuItem(
                    title: 'Matérias',
                    index: 6,
                  ),
                  _buildSubMenuItem(
                    title: 'Categorias',
                    index: 7,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;

    return Material(
      color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
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
          // Avatar do usuário
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
          // Informações do usuário
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

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadUserProfile(),
      child: const _TeacherProfileViewBody(),
    );
  }
}

class _TeacherProfileViewBody extends StatelessWidget {
  const _TeacherProfileViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Perfil do Usuário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),

              // Conteúdo do perfil
              Builder(
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

                  return Column(
                    children: [
                      // Card de perfil
                      UserDataCard(
                        userName: user.name,
                        userEmail: user.email,
                        onNameUpdate: (newName) async {
                          final success =
                              await viewModel.updateUserName(newName);
                          return success;
                        },
                        onShowFeedback: (message, {isError = false}) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor:
                                  isError ? AppColors.red : AppColors.green,
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
                          context.push('/help');
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: AppStrings.about,
                        onTap: () {
                          context.push('/about');
                        },
                      ),

                      const SizedBox(height: 32),

                      // Botão de sair
                      _buildLogoutButton(context),

                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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
