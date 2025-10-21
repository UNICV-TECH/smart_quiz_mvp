import '../repositories/auth_repository.dart';

class SignUpResult {
  const SignUpResult({
    required this.success,
    this.needsEmailConfirmation = false,
    this.message,
  });

  final bool success;
  final bool needsEmailConfirmation;
  final String? message;
}

class AuthService {
  AuthService({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

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
}
