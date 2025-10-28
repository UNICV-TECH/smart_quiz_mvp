enum AuthRepositoryErrorCode {
  emailNotConfirmed,
  invalidCredentials,
  unknown,
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(
    this.message, {
    this.code = AuthRepositoryErrorCode.unknown,
  });

  final String message;
  final AuthRepositoryErrorCode code;
}

class AuthRepositoryUser {
  const AuthRepositoryUser({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;
}

class AuthRepositorySignUpResponse {
  const AuthRepositorySignUpResponse({required this.needsEmailConfirmation});

  final bool needsEmailConfirmation;
}

class AuthRepositorySignInResponse {
  const AuthRepositorySignInResponse({
    required this.user,
  });

  final AuthRepositoryUser user;
}
