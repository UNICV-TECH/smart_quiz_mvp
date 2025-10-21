import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool isInputsValid({required GlobalKey<FormState> formKey}) {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  Future<SignUpResult> submitSignup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    if (_isLoading) {
      return const SignUpResult(success: false);
    }

    if (!acceptedTerms) {
      _setFeedback(
        error:
            'Você precisa aceitar os Termos de serviço e a Política de privacidade.',
      );
      return const SignUpResult(
        success: false,
        message:
            'Você precisa aceitar os Termos de serviço e a Política de privacidade.',
      );
    }

    if (password != confirmPassword) {
      _setFeedback(error: 'As senhas não conferem.');
      return const SignUpResult(
        success: false,
        message: 'As senhas não conferem.',
      );
    }

    _setLoading(true);

    try {
      final result = await _authService.signUp(
        email: email.trim(),
        password: password,
        name: name.trim(),
      );

      if (result.success) {
        _setFeedback(
          success: result.message ??
              'Conta criada com sucesso! Verifique seu e-mail para continuar.',
        );
        return result;
      }

      _setFeedback(
        error: result.message ??
            'Não foi possível concluir o cadastro. Tente novamente.',
      );
      return result;
    } catch (_) {
      _setFeedback(
        error: 'Ocorreu um erro inesperado. Tente novamente em instantes.',
      );
      return const SignUpResult(
        success: false,
        message: 'Ocorreu um erro inesperado. Tente novamente em instantes.',
      );
    } finally {
      _setLoading(false);
    }
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

  void clearFeedback() {
    if (_errorMessage == null && _successMessage == null) {
      return;
    }
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
