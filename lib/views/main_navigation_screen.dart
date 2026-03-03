import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/gamification_repository.dart';
import '../services/session_manager.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gamificationVm == null) {
      final gamRepo = context.read<GamificationRepository?>();
      if (gamRepo != null) {
        _gamificationVm = GamificationViewModel(repository: gamRepo);
      }
    }
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

    final isAdmin = context.watch<SessionManager>().isAdmin;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: !isAdmin,
      body: Column(
        children: [
          if (isAdmin)
            Material(
              color: const Color(0xFFB8860B),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Voltar ao Painel Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
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
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
