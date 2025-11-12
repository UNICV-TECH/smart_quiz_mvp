import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/session_manager.dart';

class ProtectedRoute extends StatefulWidget {
  const ProtectedRoute({
    super.key,
    required this.builder,
    this.redirectRoute = '/login',
  });

  final WidgetBuilder builder;
  final String redirectRoute;

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

    _redirectScheduled = false;
    return widget.builder(context);
  }
}

