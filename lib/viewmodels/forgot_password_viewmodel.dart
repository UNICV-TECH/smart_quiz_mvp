import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_result.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({
    required AuthService authService,
  }) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get message => _message;
  bool get isSuccess => _isSuccess;

  /// Envia o e-mail de recuperação de senha
  Future<void> sendRecoveryEmail(String email) async {
    _setLoading(true);
    _clearState();

    final ResetPasswordResult result =
        await _authService.resetPasswordForEmail(email);

    _isSuccess = result.success;
    _message = result.message;

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearState() {
    _message = null;
    _isSuccess = false;
  }

  /// Limpa estado ao sair da tela
  void clear() {
    _isLoading = false;
    _message = null;
    _isSuccess = false;
    notifyListeners();
  }
}