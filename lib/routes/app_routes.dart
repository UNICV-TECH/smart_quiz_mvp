import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../viewmodels/exam_view_model.dart';
import '../viewmodels/login_view_model.dart';
import '../viewmodels/signup_view_model.dart';
import '../views/about_screen.dart';
import '../views/exam_result_screen.dart';
import '../views/exam_screen.dart';
import '../views/help_screen.dart';
import '../views/login_screen.dart';
import '../views/main_navigation_screen.dart';
import '../views/profile_screen.dart';
import '../views/quiz_config_screen_wrapper.dart';
import '../views/signup_screen.dart';
import '../views/splash_screen.dart';
import '../views/welcome_screen.dart';
import '../views/reset_password_screen1.dart';
import '../views/reset_password_screen2.dart';
import '../models/user_model.dart';
import '../views/admin/admin_main_screen.dart';
import '../views/teacher/teacher_main_screen.dart';
import '../views/teacher/teacher_create_question.dart';
import '../views/teacher/teacher_question_list_screen.dart';
import '../views/teacher/teacher_edit_question_screen.dart';
import '../views/teacher/teacher_exam_templates_screen.dart';
import '../views/teacher/teacher_stats_screen.dart';
import '../widgets/protected_route.dart';

/// Classe centralizada para gerenciar todas as rotas da aplicação
class AppRoutes {
  AppRoutes._();

  // Constantes para rotas de alunos
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String about = '/about';
  static const String exam = '/exam';
  static const String quizConfig = '/quiz/config';
  static const String examResult = '/exam/result';
  static const String resetPassword = '/reset_password';
  static const String resetPassword2 = '/reset_password2';

  // Constantes para rotas de administradores
  static const String admin = '/admin';
  static const String adminHome = '/admin/home';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';

  // Constantes para rotas de professores
  static const String teacher = '/teacher';
  static const String teacherHome = '/teacher/home';
  static const String teacherCreateQuestion = '/teacher/create-question';
  static const String teacherQuestions = '/teacher/questions';
  static const String teacherQuestionEdit = '/teacher/questions/edit';
  static const String teacherTemplates = '/teacher/templates';
  static const String teacherTemplateEdit = '/teacher/templates/edit';
  static const String teacherStats = '/teacher/stats';

  /// Retorna o mapa completo de rotas da aplicação
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Rotas de alunos (mantidas como estavam)
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      signup: (context) => ChangeNotifierProvider(
            create: (context) => SignUpViewModel(
              authService: context.read<AuthService>(),
            ),
            child: const SignupScreen(),
          ),
      login: (context) => ChangeNotifierProvider(
            create: (context) => LoginViewModel(
              authService: context.read<AuthService>(),
            ),
            child: const LoginScreen(),
          ),
      home: (context) =>
          const Scaffold(body: Center(child: Text('Tela Principal'))),
      resetPassword: (context) => const ResetPasswordScreen1(),
      resetPassword2: (context) => const ResetPasswordScreen2(),
      main: (context) => ProtectedRoute(
            builder: (innerContext) => const MainNavigationScreen(),
          ),
      profile: (context) => ProtectedRoute(
            builder: (innerContext) => const ProfileScreen(),
          ),
      help: (context) => ProtectedRoute(
            builder: (innerContext) => const HelpScreen(),
          ),
      about: (context) => ProtectedRoute(
            builder: (innerContext) => const AboutScreen(),
          ),
      exam: (context) => ProtectedRoute(
            builder: (innerContext) {
              final args = ModalRoute.of(innerContext)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Missing exam arguments'),
                  ),
                );
              }
              final isRetake = args['isRetake'] as bool? ?? false;
              final previousQuestionIdsRaw =
                  args['previousQuestionIds'] as List<dynamic>?;
              final previousQuestionIds =
                  previousQuestionIdsRaw?.map((id) => id.toString()).toList();

              return ChangeNotifierProvider(
                create: (context) => ExamViewModel(
                  supabase: Supabase.instance.client,
                  sessionManager: context.read<SessionManager>(),
                  userId: args['userId'] as String,
                  examId: args['examId'] as String,
                  courseId: args['courseId'] as String,
                  questionCount: args['questionCount'] as int,
                  isRetake: isRetake,
                  previousQuestionIds: previousQuestionIds,
                ),
                child: ExamScreen(
                  userId: args['userId'] as String,
                  examId: args['examId'] as String,
                  courseId: args['courseId'] as String,
                  questionCount: args['questionCount'] as int,
                ),
              );
            },
          ),
      quizConfig: (context) => ProtectedRoute(
            builder: (innerContext) {
              final args = ModalRoute.of(innerContext)!.settings.arguments
                  as Map<String, dynamic>?;
              final course = args?['course'] as Map<String, dynamic>?;
              if (course == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Missing course data'),
                  ),
                );
              }
              return QuizConfigScreenWrapper(course: course);
            },
          ),
      examResult: (context) => ProtectedRoute(
            builder: (innerContext) {
              final args = ModalRoute.of(innerContext)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Missing result data'),
                  ),
                );
              }
              return ExamResultScreen(results: args);
            },
          ),

      // Rotas de administradores
      admin: (context) => ProtectedRoute(
            requiredRole: UserRole.admin,
            builder: (innerContext) => const AdminMainScreen(),
          ),
      adminHome: (context) => ProtectedRoute(
            requiredRole: UserRole.admin,
            builder: (innerContext) => const AdminMainScreen(),
          ),
      adminUsers: (context) => ProtectedRoute(
            requiredRole: UserRole.admin,
            builder: (innerContext) => const AdminMainScreen(),
          ),
      adminContent: (context) => ProtectedRoute(
            requiredRole: UserRole.admin,
            builder: (innerContext) => const AdminMainScreen(),
          ),

      // Rotas de professores
      teacher: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherMainScreen(),
          ),
      teacherHome: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherMainScreen(),
          ),
      teacherCreateQuestion: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherScreenCreateQuestion(),
          ),
      teacherQuestions: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherQuestionListScreen(),
          ),
      teacherQuestionEdit: (context) => ProtectedRoute(
            builder: (innerContext) {
              final args = ModalRoute.of(innerContext)!.settings.arguments
                  as Map<String, dynamic>?;
              final questionId = args?['questionId'] as String?;
              if (questionId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('ID da questao nao informado'),
                  ),
                );
              }
              return TeacherEditQuestionScreen(questionId: questionId);
            },
          ),
      teacherTemplates: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherExamTemplatesScreen(),
          ),
      teacherStats: (context) => ProtectedRoute(
            builder: (innerContext) => const TeacherStatsScreen(),
          ),
    };
  }
}
