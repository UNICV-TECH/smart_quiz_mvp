import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session_manager.dart';
import '../ui/theme/app_color.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final int _splashDuration = 2500;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Curva suave
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
    // Verificar se está na web e se há uma rota especial na URL
    String? targetRoute;

    if (kIsWeb) {
      try {
        final uri = Uri.base;
        final path = uri.path;

        // Verificar se é um fluxo de recuperação de senha (PKCE ou implicit)
        final isRecovery = uri.queryParameters['type'] == 'recovery' ||
            uri.fragment.contains('type=recovery');

        if (isRecovery) {
          targetRoute = '/reset_password2';
        }
        // Se a URL começa com /admin, redirecione para admin
        else if (path.startsWith('/admin')) {
          targetRoute = path.isEmpty ? '/admin' : path;
        }
        // Se a URL é /teacher ou começa com /teacher/, redirecione para professores
        else if (path.startsWith('/teacher') ||
            path.startsWith('/professor')) {
          targetRoute = path.isEmpty ? '/teacher' : path;
        }
      } catch (e) {
        debugPrint('Erro ao ler URL no splash: $e');
      }
    }

    // Se não encontrou rota especial na URL, verifica autenticação e role
    if (targetRoute == null) {
      final sessionManager = context.read<SessionManager>();
      await sessionManager.initialize();
      if (sessionManager.isAuthenticated) {
        final user = sessionManager.currentUser;
        if (user != null && user.isAdmin) {
          targetRoute = '/admin';
        } else if (user != null && user.isTeacher) {
          targetRoute = '/teacher';
        } else {
          targetRoute = '/main';
        }
      } else {
        targetRoute = '/welcome';
      }
    }

    if (!mounted) return;

    _animationController.reverse();

    // Navegar para a rota determinada
    if (targetRoute == '/reset_password2') {
      Navigator.of(context).pushReplacementNamed('/reset_password2');
      return;
    }

    if (targetRoute == '/main') {
      Navigator.of(context).pushReplacementNamed('/main');
      return;
    }

    if (targetRoute.startsWith('/admin')) {
      Navigator.of(context).pushReplacementNamed(targetRoute);
      return;
    }

    if (targetRoute.startsWith('/teacher') ||
        targetRoute.startsWith('/professor')) {
      Navigator.of(context).pushReplacementNamed(targetRoute);
      return;
    }

    // Para welcome screen, usar transição customizada
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const WelcomeScreen();
        },
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.greenSplash,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo do app
                Image.asset(
                  'assets/images/logo.webp',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 24)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
