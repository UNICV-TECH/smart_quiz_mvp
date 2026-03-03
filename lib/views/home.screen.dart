import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unicv_tech_mvp/models/course.dart';
import 'package:unicv_tech_mvp/viewmodels/course_selection_view_model.dart';
import 'package:unicv_tech_mvp/ui/components/default_Logo.dart';
import 'package:unicv_tech_mvp/ui/components/default_subject_card.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/ui/theme/string_text.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final String _logoAssetPath = 'assets/images/logo_color.png';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseSelectionViewModel>().loadCourses();
    });
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/FundoWhiteHome.png',
                fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<CourseSelectionViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.green,
                          ),
                        );
                      }
                      if (viewModel.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.secondaryDark,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: viewModel.loadCourses,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 33.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12.0, bottom: 20.0),
                                  child: AppLogoWidget.asset(
                                    size: AppLogoSize.small,
                                    logoPath: _logoAssetPath,
                                    semanticLabel: 'Logo UniCV',
                                  ),
                                ),
                              ),
                              const AppText('Para qual prova',
                                  style: AppTextStyle.titleSmall,
                                  color: AppColors.primaryDark),
                              const SizedBox(height: 1),
                              AppText(
                                'gostaria de se preparar?',
                                style: AppTextStyle.subtitleMedium,
                                color: AppColors.secondaryDark
                                    .withAlpha((0.8 * 255).round()),
                              ),
                              const SizedBox(height: 35),
                              Column(
                                children: viewModel.courses.map((course) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: SubjectCard(
                                      icon: Icon(
                                        _getIconData(course.iconKey),
                                        color: AppColors.green,
                                        size: 30,
                                      ),
                                      title: course.title,
                                      isSelected: viewModel.selectedCourseId ==
                                          course.id,
                                      onTap: () =>
                                          _onCourseSelected(course, viewModel),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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