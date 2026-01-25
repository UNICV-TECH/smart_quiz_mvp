import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_manager.dart';

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
  final List<Widget> _screens = [
    const BuildExamsScreen(),
    const CreateQuestionsScreen(),
    const TeacherProfileScreen(),
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

                  // Opção 3: Perfil
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
          // Botão de configurações do perfil
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Tela de perfil
              });
            },
            icon: Icon(
              Icons.settings,
              color: Colors.grey[600],
            ),
            tooltip: 'Configurações do perfil',
          ),
        ],
      ),
    );
  }
}

// Telas placeholder (podem ser desenvolvidas depois)
class BuildExamsScreen extends StatelessWidget {
  const BuildExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9F9F9),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Montar Provas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Aqui você pode criar e gerenciar suas provas. '
            'Use as opções para adicionar questões, definir parâmetros '
            'e organizar por disciplina ou período.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class CreateQuestionsScreen extends StatelessWidget {
  const CreateQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9F9F9),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Criar Questões',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nesta seção você pode criar novas questões, editar existentes '
            'ou importar questões do banco de dados.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
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
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9F9F9),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perfil do Usuário',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Gerencie suas informações pessoais, configurações da conta '
            'e preferências do sistema.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

