import '../models/auth_result.dart';
import '../models/auth_user.dart';
import '../repositories/auth/auth_repository.dart';
import '../repositories/auth/auth_repository_types.dart';
import 'session_manager.dart';

class AuthService {
  AuthService({
    required AuthRepository repository,
    SessionManager? sessionManager,
  })  : _repository = repository,
        _sessionManager = sessionManager;

  final AuthRepository _repository;
  final SessionManager? _sessionManager;
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        name: name,
      );

      final requiresConfirmation = response.needsEmailConfirmation;

      return SignUpResult(
        success: true,
        needsEmailConfirmation: requiresConfirmation,
        message: requiresConfirmation
            ? 'Enviamos um e-mail de confirmação para $email.'
            : null,
      );
    } on AuthRepositoryException catch (error) {
      return SignUpResult(
        success: false,
        message: error.message,
      );
    } catch (_) {
      return const SignUpResult(
        success: false,
        message: 'Não foi possível concluir o cadastro. Tente novamente.',
      );
    }
  }

  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    _currentUser = null;

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );

      final user = AuthUser(
        id: response.user.id,
        email: response.user.email,
        name: response.user.name,
      );

      _currentUser = user;
      _sessionManager?.setAuthenticatedUser(user);

      final trimmedName = user.name?.trim();
      final greetingMessage = (trimmedName != null && trimmedName.isNotEmpty)
          ? 'Bem-vindo de volta, $trimmedName!'
          : 'Bem-vindo de volta!';

      return SignInResult(
        success: true,
        user: user,
        message: greetingMessage,
      );
    } on AuthRepositoryException catch (error) {
      _currentUser = null;

      final requiresConfirmation =
          error.code == AuthRepositoryErrorCode.emailNotConfirmed;

      return SignInResult(
        success: false,
        requiresEmailConfirmation: requiresConfirmation,
        message: error.message,
      );
    } catch (_) {
      _currentUser = null;

      return const SignInResult(
        success: false,
        message: 'Não foi possível concluir o login. Tente novamente.',
      );
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _sessionManager?.signOut();
  }
}
