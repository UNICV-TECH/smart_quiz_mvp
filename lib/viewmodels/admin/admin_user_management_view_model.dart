import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/admin_repository_types.dart';

class AdminUserManagementViewModel extends ChangeNotifier {
  AdminUserManagementViewModel({
    required AdminRepository adminRepository,
  }) : _adminRepository = adminRepository;

  final AdminRepository _adminRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Data
  List<AdminUserEntry> _users = [];

  // Filters
  String? _roleFilter;
  bool? _activeFilter;
  String? _searchQuery;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<AdminUserEntry> get users => List.unmodifiable(_users);
  String? get roleFilter => _roleFilter;
  bool? get activeFilter => _activeFilter;
  String? get searchQuery => _searchQuery;

  // Set filters
  void setRoleFilter(String? role) {
    _roleFilter = role;
    notifyListeners();
    loadUsers();
  }

  void setActiveFilter(bool? isActive) {
    _activeFilter = isActive;
    notifyListeners();
    loadUsers();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query?.isEmpty == true ? null : query;
    notifyListeners();
    loadUsers();
  }

  void clearFilters() {
    _roleFilter = null;
    _activeFilter = null;
    _searchQuery = null;
    notifyListeners();
    loadUsers();
  }

  // Load users
  Future<void> loadUsers() async {
    _setLoading(true);
    _clearMessages();

    try {
      _users = await _adminRepository.listUsers(
        AdminUsersFilter(
          role: _roleFilter,
          isActive: _activeFilter,
          search: _searchQuery,
        ),
      );
    } catch (error) {
      _setError('Erro ao carregar usuários: $error');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    _clearMessages();

    try {
      await _adminRepository.updateUserRole(userId, newRole);
      _setSuccess('Papel do usuário atualizado com sucesso');
      await loadUsers();
      return true;
    } catch (error) {
      _setError('Erro ao atualizar papel: $error');
      return false;
    }
  }

  // Toggle user active status
  Future<bool> toggleUserActive(String userId, bool isActive) async {
    _clearMessages();

    try {
      await _adminRepository.toggleUserActive(userId, isActive);
      _setSuccess(
        isActive ? 'Usuário ativado com sucesso' : 'Usuário desativado com sucesso',
      );
      await loadUsers();
      return true;
    } catch (error) {
      _setError('Erro ao alterar status: $error');
      return false;
    }
  }

  Future<void> refresh() async {
    await loadUsers();
  }

  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }
}
