import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/course_repository.dart';
import '../repositories/gamification_repository.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../viewmodels/course_selection_view_model.dart';
import '../viewmodels/exam_view_model.dart';
import '../viewmodels/gamification_view_model.dart';
import '../viewmodels/login_view_model.dart';
import '../viewmodels/signup_view_model.dart';
import '../views/admin/admin_main_screen.dart';
import '../views/about_screen.dart';
import '../views/exam_detail_screen.dart';
import '../views/exam_history_screen.dart';
import '../views/exam_result_screen.dart';
import '../views/exam_screen.dart';
import '../views/help_screen.dart';
import '../views/home.screen.dart';
import '../views/login_screen.dart';
import '../views/not_found_screen.dart';
import '../views/profile_screen.dart';
import '../views/quiz_config_screen_wrapper.dart';
import '../views/ranking_screen.dart';
import '../views/reset_password_screen1.dart';
import '../views/reset_password_screen2.dart';
import '../views/signup_screen.dart';
import '../views/splash_screen.dart';
import '../views/student_shell_screen.dart';
import '../views/teacher/teacher_category_list_screen.dart';
import '../views/teacher/teacher_create_question.dart';
import '../views/teacher/teacher_edit_question_screen.dart';
import '../views/teacher/teacher_exam_templates_screen.dart';
import '../views/teacher/teacher_gamification_screen.dart';
import '../views/teacher/teacher_main_screen.dart';
import '../views/teacher/teacher_question_list_screen.dart';
import '../views/teacher/teacher_shell_screen.dart';
import '../views/teacher/teacher_stats_screen.dart';
import '../views/teacher/teacher_subject_list_screen.dart';
import '../views/welcome_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(SessionManager sessionManager) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: sessionManager,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isInitialized = sessionManager.initialized;
      final isAuthenticated = sessionManager.isAuthenticated;
      final isTeacher = sessionManager.isTeacher;
      final isAdmin = sessionManager.isAdmin;
      final pendingRecovery = sessionManager.pendingPasswordRecovery;

      // 1. If not initialized and not on splash, go to splash
      if (!isInitialized && location != '/splash') {
        return '/splash';
      }

      // 2. If pending password recovery, redirect to confirm screen
      if (pendingRecovery && location != '/reset-password/confirm') {
        return '/reset-password/confirm';
      }

      // 2b. If on confirm screen without pending recovery and not authenticated,
      //     redirect to reset-password (user navigated directly without email link)
      if (!pendingRecovery &&
          !isAuthenticated &&
          location == '/reset-password/confirm') {
        return '/reset-password';
      }

      // 3. Define public routes
      const publicRoutes = [
        '/splash',
        '/welcome',
        '/login',
        '/signup',
        '/reset-password',
        '/reset-password/confirm',
      ];

      final isPublicRoute = publicRoutes.contains(location);

      // 4. If not authenticated and trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // 5. If authenticated and on a public route (except splash)
      if (isAuthenticated && isPublicRoute && location != '/splash') {
        if (isAdmin) return '/admin';
        if (isTeacher) return '/teacher/templates';
        return '/home';
      }

      // 6. If authenticated admin/teacher trying to access student routes
      if (isAuthenticated && (isTeacher || isAdmin)) {
        // Allow admins viewing as student to access student routes
        if (isAdmin && sessionManager.viewingAsStudent) {
          // no redirect — let admin use student panel
        } else {
          const studentPrefixes = [
            '/home',
            '/ranking',
            '/history',
            '/profile',
            '/quiz',
            '/exam',
          ];
          if (studentPrefixes.any((prefix) => location.startsWith(prefix))) {
            return isAdmin ? '/admin' : '/teacher/templates';
          }
        }
      }

      // 7. If authenticated student trying to access teacher/admin routes
      if (isAuthenticated && !isTeacher && !isAdmin && location.startsWith('/teacher')) {
        return '/home';
      }
      if (isAuthenticated && !isAdmin && location.startsWith('/admin')) {
        return isTeacher ? '/teacher/templates' : '/home';
      }

      // 8. No redirect needed
      return null;
    },
    errorBuilder: (context, state) => NotFoundScreen(
      message: 'Página não encontrada: ${state.uri.path}',
    ),
    routes: [
      // --- Public routes ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authService: context.read<AuthService>(),
          ),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => SignUpViewModel(
            authService: context.read<AuthService>(),
          ),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen1(),
      ),
      GoRoute(
        path: '/reset-password/confirm',
        builder: (context, state) => const ResetPasswordScreen2(),
      ),

      // --- Student shell (bottom nav) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StudentShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => CourseSelectionViewModel(
                    courseRepository: context.read<CourseRepository?>(),
                  ),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // Branch 1: Ranking
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ranking',
                builder: (context, state) {
                  final gamRepo = context.read<GamificationRepository?>();
                  if (gamRepo != null) {
                    return ChangeNotifierProvider(
                      create: (_) => GamificationViewModel(repository: gamRepo),
                      child: const RankingScreen(),
                    );
                  }
                  return const RankingScreen();
                },
              ),
            ],
          ),
          // Branch 2: History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const ExamHistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':attemptId',
                    builder: (context, state) {
                      final attemptId = state.pathParameters['attemptId']!;
                      return ExamDetailScreen(attemptId: attemptId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Student standalone routes ---
      GoRoute(
        path: '/quiz/config/:courseId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final title =
              state.uri.queryParameters['title'] ?? 'Curso';
          final courseKey =
              state.uri.queryParameters['courseKey'] ?? '';
          final iconKey =
              state.uri.queryParameters['iconKey'] ?? '';

          final course = <String, dynamic>{
            'id': courseId,
            'course_key': courseKey,
            'title': title,
            'icon_key': iconKey.isNotEmpty ? iconKey : null,
          };
          return QuizConfigScreenWrapper(course: course);
        },
      ),
      GoRoute(
        path: '/exam/:examId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final sessionMgr = context.read<SessionManager>();
          final userId = sessionMgr.currentUser?.id ?? '';
          final courseId =
              state.uri.queryParameters['courseId'] ?? '';
          final questionCount = int.tryParse(
                  state.uri.queryParameters['questionCount'] ?? '') ??
              10;
          final isRetake =
              state.uri.queryParameters['isRetake'] == 'true';
          final extra = state.extra as Map<String, dynamic>?;
          final previousQuestionIds =
              extra?['previousQuestionIds'] as List<String>?;

          return ChangeNotifierProvider(
            create: (context) => ExamViewModel(
              supabase: Supabase.instance.client,
              sessionManager: context.read<SessionManager>(),
              userId: userId,
              examId: examId,
              courseId: courseId,
              questionCount: questionCount,
              isRetake: isRetake,
              previousQuestionIds: previousQuestionIds,
            ),
            child: ExamScreen(
              userId: userId,
              examId: examId,
              courseId: courseId,
              questionCount: questionCount,
            ),
          );
        },
      ),
      GoRoute(
        path: '/exam-result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final results = state.extra as Map<String, dynamic>? ?? {};
          return ExamResultScreen(results: results);
        },
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),

      // --- Admin route ---
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminMainScreen(),
      ),

      // --- Teacher shell (sidebar) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TeacherShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Templates
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/templates',
                builder: (context, state) =>
                    const TeacherExamTemplatesScreen(),
              ),
            ],
          ),
          // Branch 1: Create Question
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/create-question',
                builder: (context, state) =>
                    const TeacherScreenCreateQuestion(),
              ),
            ],
          ),
          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/profile',
                builder: (context, state) => const TeacherProfileScreen(),
              ),
            ],
          ),
          // Branch 3: Questions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/questions',
                builder: (context, state) =>
                    const TeacherQuestionListScreen(),
              ),
            ],
          ),
          // Branch 4: Stats
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/stats',
                builder: (context, state) => const TeacherStatsScreen(),
              ),
            ],
          ),
          // Branch 5: Gamification
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/gamification',
                builder: (context, state) =>
                    const TeacherGamificationScreen(),
              ),
            ],
          ),
          // Branch 6: Subjects
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/subjects',
                builder: (context, state) =>
                    const TeacherSubjectListScreen(),
              ),
            ],
          ),
          // Branch 7: Categories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/categories',
                builder: (context, state) =>
                    const TeacherCategoryListScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Teacher standalone route ---
      GoRoute(
        path: '/teacher/questions/:questionId/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final questionId = state.pathParameters['questionId']!;
          return TeacherEditQuestionScreen(questionId: questionId);
        },
      ),
    ],
  );
}
