import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../models/auth_result.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel({
    required AuthService authService,
  }) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _message;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get message => _message;

  Future<void> updatePassword(String newPassword) async {
    _setLoading(true);
    _message = null;
    _isSuccess = false;

    try {
      // 🔥 Esperar sessão do Supabase (máx ~2s)
      int attempts = 0;

      while (Supabase.instance.client.auth.currentSession == null &&
          attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      final session =
          Supabase.instance.client.auth.currentSession;

      if (session == null) {
        _message =
            'Sessão de redefinição não encontrada. Abra o link novamente.';
        _isSuccess = false;
        _setLoading(false);
        return;
      }

      final ResetPasswordResult result =
          await _authService.updatePassword(newPassword);

      _isSuccess = result.success;
      _message = result.message;
    } catch (e) {
      _isSuccess = false;
      _message =
          'Erro inesperado ao atualizar senha. Tente novamente.';
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() {
    _isLoading = false;
    _isSuccess = false;
    _message = null;
    notifyListeners();
  }
}