import 'package:flutter/foundation.dart';

/// Notifier compartilhado que telas de formulário usam para sinalizar
/// que possuem dados não salvos. Os shells (Student/Teacher) consultam
/// este notifier antes de permitir troca de aba/menu.
class FormProtectionNotifier extends ChangeNotifier {
  bool _hasUnsavedChanges = false;
  String _screenLabel = '';

  bool get hasUnsavedChanges => _hasUnsavedChanges;
  String get screenLabel => _screenLabel;

  void markUnsaved({String label = 'formulário'}) {
    if (!_hasUnsavedChanges || _screenLabel != label) {
      _hasUnsavedChanges = true;
      _screenLabel = label;
      notifyListeners();
    }
  }

  void markSaved() {
    if (_hasUnsavedChanges) {
      _hasUnsavedChanges = false;
      _screenLabel = '';
      notifyListeners();
    }
  }
}
