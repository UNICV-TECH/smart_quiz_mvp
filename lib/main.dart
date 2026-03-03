import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/supabase_options.dart';
import 'repositories/auth/auth_repository.dart';
import 'repositories/auth/disabled_auth_repository.dart';
import 'repositories/auth/supabase_auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/supabase_course_repository.dart';
import 'repositories/teacher_repository.dart';
import 'repositories/supabase_teacher_repository.dart';
import 'repositories/gamification_repository.dart';
import 'repositories/supabase_gamification_repository.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'ui/theme/app_color.dart';

// Static variable to track whether Supabase has already been initialized
bool _supabaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  AuthRepository authRepository;

  // Try to load .env only if not on web
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
    }
  } else {
    debugPrint(
        'Plataforma web detectada: usando valores padrão ou variáveis de ambiente.');
  }

  // Check Supabase configuration
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
      _supabaseInitialized = false;
      authRepository = const DisabledAuthRepository();
    }
  } else {
    debugPrint(
      '✗ Supabase credentials are missing. Signup features will be disabled until configured.',
    );
    authRepository = const DisabledAuthRepository();
  }

  final sessionManager = SupabaseOptions.isConfigured
      ? SessionManager.enabled(
          client: Supabase.instance.client,
        )
      : SessionManager.disabled();

  final authService = AuthService(
    repository: authRepository,
    sessionManager: sessionManager,
  );

  final router = createAppRouter(sessionManager);

  runApp(
    MyApp(
      authRepository: authRepository,
      authService: authService,
      sessionManager: sessionManager,
      router: router,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.authService,
    required this.sessionManager,
    required this.router,
  });

  final AuthRepository authRepository;
  final AuthService authService;
  final SessionManager sessionManager;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<SessionManager>.value(value: sessionManager),
        Provider<CourseRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) {
              return null;
            }
            return SupabaseCourseRepository(client: Supabase.instance.client);
          },
        ),
        Provider<TeacherRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) {
              return null;
            }
            return SupabaseTeacherRepository(client: Supabase.instance.client);
          },
        ),
        Provider<GamificationRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) {
              return null;
            }
            return SupabaseGamificationRepository(
                client: Supabase.instance.client);
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'UniCV Tech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        routerConfig: router,
      ),
    );
  }
}
