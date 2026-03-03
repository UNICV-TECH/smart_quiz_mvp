/// Centralized route path constants for the application.
class AppRoutes {
  AppRoutes._();

  // Student routes
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String ranking = '/ranking';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String about = '/about';
  static const String quizConfig = '/quiz/config';
  static const String exam = '/exam';
  static const String examResult = '/exam-result';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordConfirm = '/reset-password/confirm';

  // Teacher routes
  static const String teacherTemplates = '/teacher/templates';
  static const String teacherCreateQuestion = '/teacher/create-question';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherQuestions = '/teacher/questions';
  static const String teacherQuestionEdit = '/teacher/questions/:questionId/edit';
  static const String teacherStats = '/teacher/stats';
  static const String teacherGamification = '/teacher/gamification';
  static const String teacherSubjects = '/teacher/subjects';
  static const String teacherCategories = '/teacher/categories';
}
