import 'package:flutter/material.dart';

import '../../models/admin_stats.dart';
import '../../repositories/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  AdminDashboardViewModel({
    required AdminRepository adminRepository,
  }) : _adminRepository = adminRepository;

  final AdminRepository _adminRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  AdminPlatformStats _platformStats = const AdminPlatformStats();
  List<AdminCourseStats> _courseStats = [];
  List<AdminMonthlyActivity> _monthlyActivity = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdminPlatformStats get platformStats => _platformStats;
  List<AdminCourseStats> get courseStats => List.unmodifiable(_courseStats);
  List<AdminMonthlyActivity> get monthlyActivity =>
      List.unmodifiable(_monthlyActivity);

  // Computed
  double get overallPassRate {
    final totalAttempts =
        _courseStats.fold(0, (sum, s) => sum + s.totalAttempts);
    final totalPassed =
        _courseStats.fold(0, (sum, s) => sum + s.totalPassed);
    if (totalAttempts == 0) return 0.0;
    return (totalPassed / totalAttempts) * 100;
  }

  // Load data
  Future<void> loadStats() async {
    _setLoading(true);
    _clearError();

    try {
      final results = await Future.wait([
        _adminRepository.getPlatformStats(),
        _adminRepository.getCourseStats(),
        _adminRepository.getMonthlyActivity(),
      ]);
      _platformStats = results[0] as AdminPlatformStats;
      _courseStats = results[1] as List<AdminCourseStats>;
      _monthlyActivity = results[2] as List<AdminMonthlyActivity>;
    } catch (error) {
      _setError('$error');
      _platformStats = const AdminPlatformStats();
      _courseStats = [];
      _monthlyActivity = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }

  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
