import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/components/default_navbar.dart';
import '../viewmodels/course_selection_view_model.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const RankingScreen(),
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
