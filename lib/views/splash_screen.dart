import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session_manager.dart';
import '../ui/theme/app_color.dart';
import '../routes/app_routes.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final int _splashDuration = 1500;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    Timer(Duration(milliseconds: _splashDuration), () {
      _navigateToNextScreen();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
  if (!mounted) return;

  final sessionManager = context.read<SessionManager>();
  await sessionManager.initialize();

  if (kIsWeb) {
    final uri = Uri.base;

    final path = uri.path;
    final fragment = uri.fragment; // 🔥 ESSENCIAL

    debugPrint('PATH: $path');
    debugPrint('FRAGMENT: $fragment');

    // 🔥 RESET PASSWORD (funciona com hash routing)
    if (path.contains(AppRoutes.resetPassword2) ||
        fragment.contains(AppRoutes.resetPassword2)) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.resetPassword2,
      );
      return;
    }

    // 🔥 ROTAS DE PROFESSOR
    if (path.startsWith('/teacher') ||
        fragment.startsWith('/teacher') ||
        path.startsWith('/professor') ||
        fragment.startsWith('/professor')) {
      final target =
          fragment.isNotEmpty ? fragment : path;

      Navigator.of(context).pushReplacementNamed(target);
      return;
    }
  }

  // 🔥 FLUXO NORMAL
  if (sessionManager.isAuthenticated) {
    Navigator.of(context)
        .pushReplacementNamed(AppRoutes.main);
    return;
  }

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const WelcomeScreen(),
      transitionDuration:
          const Duration(milliseconds: 600),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
            opacity: animation, child: child);
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/logo.webp',
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}