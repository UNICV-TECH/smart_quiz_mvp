import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class SessionManager extends ChangeNotifier {
  SessionManager.enabled({
    required SupabaseClient client,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _client = client,
        _navigatorKey = navigatorKey,
        _isEnabled = true {
    _init();
  }

  SessionManager.disabled({
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _client = null,
        _navigatorKey = navigatorKey,
        _isEnabled = false {
    _isInitialized = true; // Se desabilitado, já nasce inicializado
  }

  final SupabaseClient? _client;
  final GlobalKey<NavigatorState> _navigatorKey;
  final bool _isEnabled;

  Session? _currentSession;
  bool _isInPasswordRecovery = false;
  bool _isInitialized = false; // 🔥 Adicionado para o ProtectedRoute
  StreamSubscription<AuthState>? _authSubscription;

  // --- Getters de Estado ---
  bool get isAuthenticated => _currentSession != null && !_isInPasswordRecovery;
  bool get isInPasswordRecovery => _isInPasswordRecovery;
  bool get initialized => _isInitialized; // 🔥 Resolve o erro do ProtectedRoute
  Session? get currentSession => _currentSession;

  // --- Getters de Compatibilidade ---
  
  /// Retorna o usuário logado (Resolve erro: sessionManager.currentUser)
  User? get currentUser => _currentSession?.user;
  User? get user => _currentSession?.user;

  /// Atalho para o ID do usuário
  String? get userId => _currentSession?.user.id;

  // --- Métodos de Inicialização ---

  /// 🔥 CORREÇÃO PARA splash_screen e ProtectedRoute
  Future<void> initialize() async {
    if (!_isEnabled) return;
    _currentSession = _client?.auth.currentSession;
    _isInitialized = true;
    notifyListeners();
    await Future.delayed(Duration.zero);
  }

  void _init() {
    if (!_isEnabled) {
      _isInitialized = true;
      notifyListeners();
      return;
    }
    _currentSession = _client?.auth.currentSession;
    _isInitialized = true; // 🔥 Marca como carregado logo no início
    _listenToAuthChanges();
    notifyListeners();
  }

  /// 🔥 CORREÇÃO PARA ViewModels (Tratamento de erros)
  String handleSupabaseError(dynamic error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'E-mail ou senha inválidos.';
        case 'user_not_found':
          return 'Usuário não encontrado.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  // --- Listener de Mudanças de Autenticação ---

  void _listenToAuthChanges() {
    _authSubscription = _client?.auth.onAuthStateChange.listen((data) {
      final authEvent = data.event;
      
      debugPrint('🔔 Supabase Auth Event: $authEvent');

      if (authEvent == AuthChangeEvent.signedOut) {
        _isInPasswordRecovery = false;
        _currentSession = null;
        notifyListeners();
        _redirectToLogin();
        return;
      }

      if (authEvent == AuthChangeEvent.passwordRecovery) {
        _isInPasswordRecovery = true;
        _currentSession = data.session;
        notifyListeners();
        _redirectToResetPassword(); 
        return;
      }

      if (authEvent == AuthChangeEvent.signedIn || 
          authEvent == AuthChangeEvent.tokenRefreshed ||
          authEvent == AuthChangeEvent.userUpdated) {
        _currentSession = data.session;
        _isInPasswordRecovery = false;
        notifyListeners();
      }
    });
  }

  // --- Navegação Global ---

  void _redirectToLogin() {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _redirectToResetPassword() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.resetPassword2,
        (route) => false,
      );
    });
  }

  // --- Ações ---

  Future<void> signOut({bool redirect = true}) async {
    await _client?.auth.signOut();
    if (redirect) {
      _isInPasswordRecovery = false;
      _currentSession = null;
      notifyListeners();
      _redirectToLogin();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// --- Extensão para as Views ---

/// 🔥 CORREÇÃO PARA VIEWS (Resolve erro: user?.name)
extension UserExt on User {
  String? get name => userMetadata?['display_name'] ?? 
                      userMetadata?['full_name'] ?? 
                      userMetadata?['name'];
}