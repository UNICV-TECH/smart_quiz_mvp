import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/supabase_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _supabaseService.getCurrentUserProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao carregar perfil: $e';
      notifyListeners();
    }
  }

  
  Future<bool> updateUserName(String newName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _supabaseService.updateUserName(newName);

      if (success && _user != null) {
        _user = UserModel(
          id: _user!.id,
          email: _user!.email,
          name: newName,
        );
      }

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao atualizar nome: $e';
      notifyListeners();
      return false;
    }
  }
}
