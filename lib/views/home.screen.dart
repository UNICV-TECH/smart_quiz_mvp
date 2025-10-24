import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart';
import 'package:unicv_tech_mvp/ui/components/default_navbar.dart'; 
import 'package:unicv_tech_mvp/ui/components/default_subject_card.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/theme/string_text.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['title'] as String),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Tela de preparação para o curso:\n${course['title']}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCourseId;

  final List<Map<String, dynamic>> _courses = [
    {
      'id': 'psicologia',
      'title': 'Psicologia',
      'icon': Icons.psychology_outlined
    },
    {
      'id': 'ciencias_sociais',
      'title': 'Ciências Sociais',
      'icon': Icons.groups_outlined
    },
    {
      'id': 'administracao',
      'title': 'Administração',
      'icon': Icons.business_center_outlined
    },
    {
      'id': 'gestao_financeira',
      'title': 'Gestão Finan.',
      'icon': Icons.monetization_on_outlined
    },
    {'id': 'pedagogia', 'title': 'Pedagogia', 'icon': Icons.school_outlined},
    {
      'id': 'design_grafico',
      'title': 'Design Gráfico',
      'icon': Icons.palette_outlined
    },
    {'id': 'direito', 'title': 'Direito', 'icon': Icons.gavel_outlined},
    {
      'id': 'ciencias_contabeis',
      'title': 'Ciências Contábeis',
      'icon': Icons.calculate_outlined
    },
  ];

  final String _logoUrl =
      'https://ibprddrdjzazqqaxhilj.supabase.co/storage/v1/object/public/test/LogoFundoClaro.png';

  void _onCourseSelected(Map<String, dynamic> course) {
    if (!mounted) return;

    setState(() {
      _selectedCourseId = course['id'];
    });

    debugPrint("Curso selecionado: '${course['title']}'. Navegando...");

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _selectedCourseId == course['id']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fundo da tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/FundoWhiteHome.png',
              fit: BoxFit.cover,
            ),
          ),

          // Conteúdo principal (lista de cursos)
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      // Usamos `only` para adicionar o padding inferior sem
                      // afetar o horizontal que já existia.
                      padding: const EdgeInsets.only(
                        left: 33.0,
                        right: 33.0,
                        bottom: 120.0, // Espaço extra para a NavBar
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12.0, bottom: 20.0),
                              child: AppLogoWidget.network(
                                size: AppLogoSize.small,
                                logoPath: _logoUrl,
                                semanticLabel: 'Logo UniCV',
                              ),
                            ),
                          ),
                          const AppText(
                            'Para qual prova',
                            style: AppTextStyle.titleSmall,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(height: 1),
                          AppText(
                            'gostaria de se preparar?',
                            style: AppTextStyle.subtitleMedium,
                            color: AppColors.secondaryDark.withOpacity(0.8),
                          ),
                          const SizedBox(height: 35),
                          Column(
                            children: _courses.map((course) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SubjectCard(
                                  icon: Icon(course['icon'] as IconData,
                                      color: AppColors.green, size: 30),
                                  title: course['title'] as String,
                                  isSelected: _selectedCourseId == course['id'],
                                  onTap: () => _onCourseSelected(course),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // A CustomNavBar foi REMOVIDA daqui.
              ],
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(),
          ),
        ],
      ),
    );
  }
}