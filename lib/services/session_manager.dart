import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_user.dart' as local;
import '../models/user_model.dart';

class SessionManager extends ChangeNotifier {
  SessionManager._({
    required SupabaseClient? client,
  }) : _client = client;

  factory SessionManager.enabled({
    required SupabaseClient client,
  }) {
    final manager = SessionManager._(
      client: client,
    );
    manager._listenToAuthChanges();
    return manager;
  }

  factory SessionManager.disabled() {
    return SessionManager._(
      client: null,
    );
  }

  final SupabaseClient? _client;

  local.AuthUser? _currentUser;
  bool _initialized = false;
  bool _handlingUnauthorized = false;
  bool _pendingPasswordRecovery = false;
  bool _viewingAsStudent = false;
  bool _viewingAsTeacher = false;
  StreamSubscription<AuthState>? _authSubscription;
  Future<void> _roleLoadFuture = Future.value();

  local.AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get initialized => _initialized;
  bool get pendingPasswordRecovery => _pendingPasswordRecovery;

  /// Returns the user's role (student, teacher, or admin)
  UserRole get userRole => _currentUser?.role ?? UserRole.student;

  /// Checks if the current user is a teacher or admin
  bool get isTeacher => _currentUser?.isTeacher ?? false;

  /// Checks if the current user is an admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Whether admin is temporarily viewing the student panel
  bool get viewingAsStudent => _viewingAsStudent;

  /// Whether admin is temporarily viewing the teacher panel
  bool get viewingAsTeacher => _viewingAsTeacher;

  void enterStudentView() {
    _viewingAsStudent = true;
    _viewingAsTeacher = false;
    notifyListeners();
  }

  void exitStudentView() {
    _viewingAsStudent = false;
    notifyListeners();
  }

  void enterTeacherView() {
    _viewingAsTeacher = true;
    _viewingAsStudent = false;
    notifyListeners();
  }

  void exitTeacherView() {
    _viewingAsTeacher = false;
    notifyListeners();
  }

  void clearPendingPasswordRecovery() {
    _pendingPasswordRecovery = false;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    if (_client != null) {
      final session = _client!.auth.currentSession;
      _updateFromSession(session);
      await _roleLoadFuture;
    } else {
      _currentUser = null;
    }
    _initialized = true;
    notifyListeners();
  }

  /// Aguarda o carregamento do role do usuário (chamado após login)
  Future<void> ensureRoleLoaded() => _roleLoadFuture;

  void setAuthenticatedUser(local.AuthUser user) {
    _currentUser = user;
    _roleLoadFuture = _fetchUserRole(user.id);
    notifyListeners();
  }

  Future<void> signOut() async {
    _viewingAsStudent = false;
    _viewingAsTeacher = false;
    if (_client != null) {
      try {
        await _client!.auth.signOut();
      } catch (error) {
        debugPrint('SessionManager: erro ao fazer signOut: $error');
      }
    }
    _updateFromSession(null);
    notifyListeners();
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
        return;
      }

      if (authEvent == AuthChangeEvent.passwordRecovery) {
        _updateFromSession(event.session);
        _pendingPasswordRecovery = true;
        notifyListeners();
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

    // Fetch user role from database
    _roleLoadFuture = _fetchUserRole(supabaseUser.id);
  }

  Future<void> _fetchUserRole(String userId) async {
    if (_client == null) return;

    try {
      final response = await _client!
          .from('user')
          .select('role, is_active')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && _currentUser != null) {
        final isActive = response['is_active'] as bool? ?? true;

        if (!isActive) {
          debugPrint(
              'SessionManager: usuário desativado detectado. Executando signOut.');
          await signOut();
          return;
        }

        final role = UserRole.fromString(response['role'] as String?);
        _currentUser = _currentUser!.copyWith(role: role);
        notifyListeners();
      }
    } catch (error) {
      debugPrint('SessionManager: erro ao buscar role do usuario: $error');
    }
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
