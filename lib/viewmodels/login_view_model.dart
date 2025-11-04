import 'package:flutter/material.dart';

import '../models/auth_result.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool isInputValid({required GlobalKey<FormState> formKey}) {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  Future<SignInResult> submitLogin({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return const SignInResult(success: false);
    }

    _setLoading(true);

    try {
      final result = await _authService.signIn(
        email: email.trim(),
        password: password,
      );

      if (result.success) {
        _setFeedback(
          success: result.message ?? 'Bem-vindo de volta!',
        );
        return result;
      }

      final message = result.message ??
          (result.requiresEmailConfirmation
              ? 'Seu e-mail ainda não foi confirmado. Verifique sua caixa de entrada.'
              : 'Não foi possível realizar o login. Verifique suas credenciais e tente novamente.');

      _setFeedback(error: message);
      return result;
    } catch (_) {
      const fallbackMessage =
          'Ocorreu um erro inesperado. Tente novamente em instantes.';
      _setFeedback(error: fallbackMessage);
      return const SignInResult(
        success: false,
        message: fallbackMessage,
      );
    } finally {
      _setLoading(false);
    }
  }

  void clearFeedback() {
    if (_errorMessage == null && _successMessage == null) {
      return;
    }
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setFeedback({String? error, String? success}) {
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
