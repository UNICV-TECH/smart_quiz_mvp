import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/models/course.dart';
import 'package:unicv_tech_mvp/services/session_manager.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/ui/components/default_subject_card.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, IconData> _iconMap = {
    'psychology_outlined': Icons.psychology_outlined,
    'groups_outlined': Icons.groups_outlined,
    'business_center_outlined': Icons.business_center_outlined,
    'medical_services_outlined': Icons.medical_services_outlined,
    'engineering_outlined': Icons.engineering_outlined,
    'monetization_on_outlined': Icons.monetization_on_outlined,
    'school_outlined': Icons.school_outlined,
    'palette_outlined': Icons.palette_outlined,
    'gavel_outlined': Icons.gavel_outlined,
    'calculate_outlined': Icons.calculate_outlined,
  };

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseSelectionViewModel>().loadCourses();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  IconData _getIconData(String? iconKey) {
    if (iconKey == null) return Icons.school_outlined;
    return _iconMap[iconKey] ?? Icons.school_outlined;
  }

  void _onCourseSelected(Course course, CourseSelectionViewModel viewModel) {
    viewModel.selectCourse(course.id);
    context.push(
      '/quiz/config/${course.id}?title=${Uri.encodeComponent(course.title)}&courseKey=${Uri.encodeComponent(course.courseKey)}&iconKey=${Uri.encodeComponent(course.iconKey ?? '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionManager>();
    final userName = session.currentUser?.name;
    final firstName = userName != null && userName.isNotEmpty
        ? userName.split(' ').first
        : null;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Consumer<CourseSelectionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.secondaryDark,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: viewModel.loadCourses,
                    icon: const Icon(Icons.refresh, color: AppColors.green),
                    label: const Text(
                      'Tentar novamente',
                      style: TextStyle(
                        color: AppColors.green,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeIn,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header com gradiente
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.headerGradientStart,
                          AppColors.headerGradientMid,
                          AppColors.headerGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/SmartQuiz_branca.png',
                                width: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  firstName != null
                                      ? 'Olá, $firstName!'
                                      : 'Olá!',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Pronto para o desafio?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // Course cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = viewModel.courses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SubjectCard(
                            icon: Icon(
                              _getIconData(course.iconKey),
                              color: AppColors.green,
                              size: 30,
                            ),
                            title: course.title,
                            isSelected: viewModel.selectedCourseId == course.id,
                            onTap: () => _onCourseSelected(course, viewModel),
                          ),
                        );
                      },
                      childCount: viewModel.courses.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}
