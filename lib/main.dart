import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/views/reset_password_screen1.dart';
import 'package:unicv_tech_mvp/views/reset_password_screen2.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/splash_screen.dart';
import 'views/welcome_screen.dart';
import 'views/signup_screen.dart';
import 'views/login_screen.dart';
import 'views/profile_screen.dart';
import 'views/main_navigation_screen.dart';
import 'views/help_screen.dart';
import 'views/about_screen.dart';
import 'ui/theme/app_color.dart';
import 'constants/supabase_options.dart';
import 'repositories/auth/auth_repository.dart';
import 'repositories/auth/disabled_auth_repository.dart';
import 'repositories/auth/supabase_auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/supabase_course_repository.dart';
import 'services/auth_service.dart';
import 'viewmodels/login_view_model.dart';
import 'viewmodels/signup_view_model.dart';
import 'viewmodels/exam_view_model.dart';
import 'views/exam_screen.dart';
import 'views/exam_result_screen.dart';
import 'views/quiz_config_screen_wrapper.dart';

// Variável estática para rastrear se o Supabase já foi inicializado
bool _supabaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository authRepository;

  // Tentar carregar .env apenas se não estiver na web
  // Na web, o arquivo .env não pode ser carregado como asset
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: "assets/dotenv.env");
      debugPrint('✓ Arquivo .env carregado com sucesso');
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      debugPrint(
          '✓ SUPABASE_URL: ${url.isNotEmpty ? "${url.substring(0, 30)}..." : "VAZIO"}');
      debugPrint(
          '✓ SUPABASE_ANON_KEY: ${key.isNotEmpty ? "${key.substring(0, 30)}..." : "VAZIO"}');
      debugPrint('✓ isConfigured: ${SupabaseOptions.isConfigured}');
    } catch (e) {
      debugPrint('✗ Erro ao carregar arquivo .env: $e');
      debugPrint('✗ Tentando carregar valores diretamente...');
      // Continua sem o arquivo .env se não existir
    }
  } else {
    debugPrint(
        'Plataforma web detectada: usando valores padrão ou variáveis de ambiente.');
  }

  // Verificar configuração do Supabase
  final supabaseUrl = SupabaseOptions.url;
  final supabaseKey = SupabaseOptions.anonKey;

  debugPrint('Verificando configuração do Supabase:');
  debugPrint(
      '  URL: ${supabaseUrl.isNotEmpty ? "${supabaseUrl.substring(0, 30)}..." : "VAZIO"}');
  debugPrint(
      '  Key: ${supabaseKey.isNotEmpty ? "${supabaseKey.substring(0, 30)}..." : "VAZIO"}');
  debugPrint('  isConfigured: ${SupabaseOptions.isConfigured}');

  if (SupabaseOptions.isConfigured) {
    try {
      // Inicializar Supabase apenas se ainda não foi inicializado
      if (!_supabaseInitialized) {
        await Supabase.initialize(
          url: SupabaseOptions.url,
          anonKey: SupabaseOptions.anonKey,
        );
        _supabaseInitialized = true;
        debugPrint('✓ Supabase inicializado com sucesso!');
      } else {
        debugPrint(
            '✓ Supabase já estava inicializado (pulando reinicialização)');
      }

      authRepository = SupabaseAuthRepository(
        client: Supabase.instance.client,
      );
    } catch (e, stackTrace) {
      debugPrint('✗ Erro ao inicializar Supabase: $e');
      debugPrint('Stack trace: $stackTrace');
      _supabaseInitialized = false; // Reset flag em caso de erro
      authRepository = const DisabledAuthRepository();
    }
  } else {
    debugPrint(
      '✗ Supabase credentials are missing. Signup features will be disabled until configured.',
    );
    authRepository = const DisabledAuthRepository();
  }

  final authService = AuthService(repository: authRepository);

  runApp(
    MyApp(
      authRepository: authRepository,
      authService: authService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.authService,
  });

  final AuthRepository authRepository;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AuthService>.value(value: authService),
        Provider<CourseRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) {
              return null;
            }
            return SupabaseCourseRepository(client: Supabase.instance.client);
          },
        ),
      ],
      child: MaterialApp(
        title: 'UniCV Tech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/signup': (context) => ChangeNotifierProvider(
                create: (context) => SignUpViewModel(
                  authService: context.read<AuthService>(),
                ),
                child: const SignupScreen(),
              ),
          '/login': (context) => ChangeNotifierProvider(
                create: (context) => LoginViewModel(
                  authService: context.read<AuthService>(),
                ),
                child: const LoginScreen(),
              ),
          '/home': (context) =>
              const Scaffold(body: Center(child: Text('Tela Principal'))),
          '/reset_password': (context) => const ResetPasswordScreen1(),
          '/reset_password2': (context) => const ResetPasswordScreen2(),
          '/main': (context) => const MainNavigationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/help': (context) => const HelpScreen(),
          '/about': (context) => const AboutScreen(),
          '/exam': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
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
          '/quiz/config': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
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
          '/exam/result': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
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
        },
      ),
    );
  }
}
