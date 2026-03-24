import 'package:flutter/material.dart';

class Preview {
  const Preview({required String name});
}

@Preview(name: 'Navbar Padrão Professor')
Widget defaultNavbarTeacherPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniCV - Sistema de Provas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isQuestionMenuExpanded = false;

  // Simulação de dados do usuário professor
  final Map<String, dynamic> _userData = {
    'name': 'Maria Alvarez',
    'email': 'maria.alvarez@gmail.com',
    'avatarUrl': '', // Pode ser uma URL ou vazio para usar ícone
    'role': 'Professora',
  };

  // Telas correspondentes às opções do menu
  final List<Widget> _screens = [
    const BuildExamsScreen(),
    const CreateQuestionsScreen(),
    const ProfileScreen(),
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

                  // Opções extras (simulando outras funcionalidades)
                  _buildMenuItem(
                    icon: Icons.library_books,
                    title: 'Banco de Questões',
                    index: 2,
                  ),

                  _buildMenuItem(
                    icon: Icons.analytics,
                    title: 'Relatórios',
                    index: 3,
                  ),

                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Configurações',
                    index: 4,
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
              'assets/images/SmartQuiz.png',
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

                    // Ícone de seta que gira ao expandir
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
                  // Subopções da sanfona
                  _buildSubMenuItem(
                    title: 'Nova Questão',
                    index: 1,
                  ),

                  _buildSubMenuItem(
                    title: 'Listar Questões',
                    index: 5,
                  ),

                  _buildSubMenuItem(
                    title: 'Importar Questões',
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),

          // Botão de configurações do perfil
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 8; // Supondo que 8 é a tela de perfil
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

// Telas de exemplo (simplificadas)
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
