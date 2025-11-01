import 'package:flutter/foundation.dart';
import '../../models/auth_user.dart';
import '../../services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;

  ProfileViewModel(this._authService);

  AuthUser? _user;
  AuthUser? get user => _user;

  bool get isAuthenticated => _authService.isAuthenticated;

  Future<void> loadUserData() async {
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<bool> updateUserName(String newName) async {
    if (newName.isEmpty || _user == null) return false;

    try {
      await _authService.updateUserName(newName); // <-- usa o método correto
      _user = AuthUser(
        id: _user!.id,
        email: _user!.email,
        name: newName,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar nome: $e');
      return false;
    }
  }
}
