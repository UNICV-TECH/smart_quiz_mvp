import 'auth_user.dart';

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

class SignInResult {
  const SignInResult({
    required this.success,
    this.user,
    this.requiresEmailConfirmation = false,
    this.message,
  });

  final bool success;
  final AuthUser? user;
  final bool requiresEmailConfirmation;
  final String? message;
}
