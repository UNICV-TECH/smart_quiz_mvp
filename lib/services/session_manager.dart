import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_user.dart' as local;

class SessionManager extends ChangeNotifier {
  SessionManager._({
    required SupabaseClient? client,
    required this.navigatorKey,
  }) : _client = client;

  factory SessionManager.enabled({
    required SupabaseClient client,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    final manager = SessionManager._(
      client: client,
      navigatorKey: navigatorKey,
    );
    manager._listenToAuthChanges();
    return manager;
  }

  factory SessionManager.disabled({
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    return SessionManager._(
      client: null,
      navigatorKey: navigatorKey,
    );
  }

  final SupabaseClient? _client;
  final GlobalKey<NavigatorState> navigatorKey;

  local.AuthUser? _currentUser;
  bool _initialized = false;
  bool _handlingUnauthorized = false;
  StreamSubscription<AuthState>? _authSubscription;

  local.AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    if (_client != null) {
      final session = _client!.auth.currentSession;
      _updateFromSession(session);
    } else {
      _currentUser = null;
    }
    _initialized = true;
    notifyListeners();
  }

  void setAuthenticatedUser(local.AuthUser user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signOut({bool redirect = true}) async {
    if (_client != null) {
      try {
        await _client!.auth.signOut();
      } catch (error) {
        debugPrint('SessionManager: erro ao fazer signOut: $error');
      }
    }
    _updateFromSession(null);
    notifyListeners();
    if (redirect) {
      _redirectToLogin();
    }
  }

  Future<void> handleUnauthorized({String? reason}) async {
    if (_client == null) {
      if (isAuthenticated) {
        await signOut();
      }
      return;
    }
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    debugPrint(
        'SessionManager: sessão inválida detectada${reason != null ? " ($reason)" : ""}. Executando signOut.');
    try {
      await signOut();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  bool handleSupabaseError(Object error) {
    final isUnauthorized = _isUnauthorizedError(error);
    if (isUnauthorized) {
      unawaited(handleUnauthorized(
        reason: error.runtimeType.toString(),
      ));
    }
    return isUnauthorized;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthChanges() {
    _authSubscription = _client?.auth.onAuthStateChange.listen((event) {
      final authEvent = event.event;
      if (authEvent == AuthChangeEvent.signedOut) {
        _updateFromSession(null);
        notifyListeners();
        _redirectToLogin();
        return;
      }

      if (authEvent == AuthChangeEvent.signedIn ||
          authEvent == AuthChangeEvent.tokenRefreshed ||
          authEvent == AuthChangeEvent.userUpdated) {
        _updateFromSession(event.session);
        notifyListeners();
      }
    });
  }

  void _updateFromSession(Session? session) {
    if (session == null) {
      _currentUser = null;
      return;
    }

    final supabaseUser = session.user;
    final email = supabaseUser.email ?? '';
    final metadata = supabaseUser.userMetadata ?? {};
    final name = _extractFullName(metadata);

    _currentUser = local.AuthUser(
      id: supabaseUser.id,
      email: email,
      name: name,
    );
  }

  String? _extractFullName(Map<String, dynamic> metadata) {
    final fullName = metadata['full_name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    final firstName = metadata['first_name'];
    final lastName = metadata['last_name'];
    if (firstName is String && lastName is String) {
      return '${firstName.trim()} ${lastName.trim()}'.trim();
    }
    if (firstName is String && firstName.trim().isNotEmpty) {
      return firstName.trim();
    }
    return null;
  }

  void _redirectToLogin() {
    final navigator = navigatorKey.currentState;
    final context = navigatorKey.currentContext;

    String? currentRoute;
    if (context != null) {
      final route = ModalRoute.of(context);
      currentRoute = route?.settings.name;
    }

    if (navigator == null) {
      return;
    }

    if (currentRoute == '/login') {
      return;
    }

    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  bool _isUnauthorizedError(Object error) {
    if (error is PostgrestException) {
      final code = error.code?.trim();
      final message = error.message.toLowerCase();
      if (code == '401' || code == '403') {
        return true;
      }
      if (message.contains('jwt expired') ||
          message.contains('invalid token') ||
          message.contains('invalid jwt')) {
        return true;
      }
    } else if (error is AuthException) {
      final statusCode = error.statusCode?.trim();
      final message = error.message.toLowerCase();
      if (statusCode == '401' || statusCode == '403') {
        return true;
      }
      if (message.contains('jwt expired') ||
          message.contains('invalid token') ||
          message.contains('invalid jwt')) {
        return true;
      }
    }
    return false;
  }
}
