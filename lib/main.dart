import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unicv_tech_mvp/views/reset_password_screen1.dart';
import 'package:unicv_tech_mvp/views/reset_password_screen2.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'viewmodels/signup_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository authRepository;
  await dotenv.load(fileName: ".env");

  if (SupabaseOptions.isConfigured) {
    await Supabase.initialize(
      url: SupabaseOptions.url,
      anonKey: SupabaseOptions.anonKey,
    );
    authRepository = SupabaseAuthRepository(
      client: Supabase.instance.client,
    );
  } else {
    debugPrint(
      'Supabase credentials are missing. Signup features will be disabled until configured.',
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
          '/login': (context) => const LoginScreen(),
          '/home': (context) =>
              const Scaffold(body: Center(child: Text('Tela Principal'))),
          '/reset_password': (context) => const ResetPasswordScreen1(),
          '/reset_password2': (context) => const ResetPasswordScreen2(),
          '/main': (context) => const MainNavigationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/help': (context) => const HelpScreen(),
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
