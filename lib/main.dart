import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/supabase_options.dart';
import 'repositories/auth/auth_repository.dart';
import 'repositories/auth/disabled_auth_repository.dart';
import 'repositories/auth/supabase_auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/supabase_course_repository.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'ui/theme/app_color.dart';
import 'views/splash_screen.dart';
import 'views/teacher/teacher_main_screen.dart';
import 'widgets/protected_route.dart';

// Variável estática para rastrear se o Supabase já foi inicializado
bool _supabaseInitialized = false;
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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

  final sessionManager = SupabaseOptions.isConfigured
      ? SessionManager.enabled(
          client: Supabase.instance.client,
          navigatorKey: appNavigatorKey,
        )
      : SessionManager.disabled(
          navigatorKey: appNavigatorKey,
        );

  final authService = AuthService(
    repository: authRepository,
    sessionManager: sessionManager,
  );

  runApp(
    MyApp(
      authRepository: authRepository,
      authService: authService,
      sessionManager: sessionManager,
      navigatorKey: appNavigatorKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.authService,
    required this.sessionManager,
    required this.navigatorKey,
  });

  final AuthRepository authRepository;
  final AuthService authService;
  final SessionManager sessionManager;
  final GlobalKey<NavigatorState> navigatorKey;

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
      ],
      child: MaterialApp(
        title: 'UniCV Tech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          // Interceptar rotas que começam com /teacher ou /professor
          if (settings.name?.startsWith('/teacher') == true ||
              settings.name?.startsWith('/professor') == true) {
            return MaterialPageRoute(
              builder: (context) => ProtectedRoute(
                builder: (innerContext) => const TeacherMainScreen(),
                redirectRoute: AppRoutes.login,
              ),
              settings: settings,
            );
          }

          // Para outras rotas, retorna null para usar o sistema padrão
          return null;
        },
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
