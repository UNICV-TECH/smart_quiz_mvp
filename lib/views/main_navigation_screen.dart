import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/gamification_repository.dart';
import '../ui/components/default_navbar.dart';
import '../viewmodels/course_selection_view_model.dart';
import '../viewmodels/gamification_view_model.dart';
import 'home.screen.dart';
import 'ranking_screen.dart';
import 'exam_history_screen.dart';
import 'profile_screen.dart';
import 'package:unicv_tech_mvp/repositories/course_repository.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  GamificationViewModel? _gamificationVm;

  @override
  void initState() {
    super.initState();
    // Create ViewModel once in initState to avoid recreation on setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gamRepo = context.read<GamificationRepository?>();
      if (gamRepo != null) {
        setState(() {
          _gamificationVm = GamificationViewModel(repository: gamRepo);
        });
      }
    });
  }

  @override
  void dispose() {
    _gamificationVm?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget rankingChild;
    if (_gamificationVm != null) {
      rankingChild = ChangeNotifierProvider<GamificationViewModel>.value(
        value: _gamificationVm!,
        child: const RankingScreen(),
      );
    } else {
      rankingChild = const RankingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ChangeNotifierProvider(
            create: (context) => CourseSelectionViewModel(
              courseRepository: context.read<CourseRepository?>(),
            ),
            child: const HomeScreen(),
          ),
          rankingChild,
          const ExamHistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
