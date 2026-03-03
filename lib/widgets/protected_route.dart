import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/session_manager.dart';

class ProtectedRoute extends StatefulWidget {
  const ProtectedRoute({
    super.key,
    required this.builder,
    this.redirectRoute = '/login',
    this.requiredRole,
  });

  final WidgetBuilder builder;
  final String redirectRoute;
  final UserRole? requiredRole;

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  bool _redirectScheduled = false;

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.watch<SessionManager>();

    if (!sessionManager.initialized) {
      return const SizedBox.shrink();
    }

    if (!sessionManager.isAuthenticated) {
      if (!_redirectScheduled) {
        _redirectScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            widget.redirectRoute,
            (route) => false,
          );
        });
      }
      return const SizedBox.shrink();
    }

    // Role-based access control
    if (widget.requiredRole != null) {
      final user = sessionManager.currentUser;
      if (user != null && !_hasAccess(user.role, widget.requiredRole!)) {
        if (!_redirectScheduled) {
          _redirectScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/main',
              (route) => false,
            );
          });
        }
        return const SizedBox.shrink();
      }
    }

    _redirectScheduled = false;
    return widget.builder(context);
  }

  /// Admin can access everything, teacher can access teacher+student, student only student
  bool _hasAccess(UserRole userRole, UserRole requiredRole) {
    if (userRole == UserRole.admin) return true;
    if (userRole == UserRole.teacher) {
      return requiredRole == UserRole.teacher ||
          requiredRole == UserRole.student;
    }
    return requiredRole == UserRole.student;
  }
}
