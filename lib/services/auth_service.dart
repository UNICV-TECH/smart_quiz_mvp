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

  // =============================
  // SIGN UP
  // =============================
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

  // =============================
  // SIGN IN
  // =============================
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

      // 🔥 Delegar controle da sessão ao SessionManager
      //_sessionManager?.setAuthenticatedUser(user);

      final trimmedName = user.name?.trim();
      final greetingMessage =
          (trimmedName != null && trimmedName.isNotEmpty)
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

  // =============================
  // RESET PASSWORD EMAIL
  // =============================
  Future<ResetPasswordResult> resetPasswordForEmail(String email) async {
    try {
      await _repository.resetPasswordForEmail(email);

      return const ResetPasswordResult(
        success: true,
        message: 'E-mail de recuperação enviado com sucesso.',
      );
    } on AuthRepositoryException catch (error) {
      return ResetPasswordResult(
        success: false,
        message: error.message,
      );
    } catch (_) {
      return const ResetPasswordResult(
        success: false,
        message:
            'Não foi possível enviar o e-mail de recuperação. Tente novamente.',
      );
    }
  }

  // =============================
  // UPDATE PASSWORD
  // =============================
  Future<ResetPasswordResult> updatePassword(
      String newPassword) async {
    try {
      await _repository.updatePassword(newPassword);

      // 🔥 Não definir _currentUser aqui
      // 🔥 Não tratar como login
      // Deixar SessionManager controlar fluxo

      return const ResetPasswordResult(
        success: true,
        message: 'Senha alterada com sucesso.',
      );
    } on AuthRepositoryException catch (error) {
      return ResetPasswordResult(
        success: false,
        message: error.message,
      );
    } catch (_) {
      return const ResetPasswordResult(
        success: false,
        message:
            'Não foi possível alterar a senha. Tente novamente.',
      );
    }
  }

  // =============================
  // SIGN OUT
  // =============================
  Future<void> signOut() async {
    _currentUser = null;
    await _sessionManager?.signOut();
  }
}