import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
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
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'ui/theme/app_color.dart';
import 'views/teacher/teacher_main_screen.dart';
import 'widgets/protected_route.dart';

bool _supabaseInitialized = false;
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    //setUrlStrategy(PathUrlStrategy());
    debugPrint('🔗 URL de entrada: ${Uri.base.toString()}');
  }

  AuthRepository authRepository;

  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: "assets/dotenv.env");
    } catch (_) {}
  }

  if (SupabaseOptions.isConfigured) {
    try {
      if (!_supabaseInitialized) {
        await Supabase.initialize(
          url: SupabaseOptions.url,
          anonKey: SupabaseOptions.anonKey,
          // Garante que o Supabase capture o link de recuperação no Web
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
          ),
        );
        _supabaseInitialized = true;
      }

      authRepository = SupabaseAuthRepository(
        client: Supabase.instance.client,
      );
    } catch (e) {
      _supabaseInitialized = false;
      debugPrint('❌ Erro ao inicializar Supabase: $e');
      authRepository = const DisabledAuthRepository();
    }
  } else {
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
        ChangeNotifierProvider<SessionManager>.value(
          value: sessionManager,
        ),
        Provider<CourseRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) return null;
            return SupabaseCourseRepository(
              client: Supabase.instance.client,
            );
          },
        ),
        Provider<TeacherRepository?>(
          create: (_) {
            if (!SupabaseOptions.isConfigured) return null;
            return SupabaseTeacherRepository(
              client: Supabase.instance.client,
            );
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
        // No Web, o Flutter usa a URL para definir a rota inicial. 
        // Se houver um token de reset, o SessionManager cuidará do redirecionamento.
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/teacher') == true) {
            return MaterialPageRoute(
              builder: (context) => ProtectedRoute(
                builder: (innerContext) => const TeacherMainScreen(),
                redirectRoute: AppRoutes.login,
              ),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}