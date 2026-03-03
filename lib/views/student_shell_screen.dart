import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/components/default_navbar.dart';

class StudentShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onItemTapped: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
