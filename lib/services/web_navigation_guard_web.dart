import 'dart:js_interop';
import 'package:web/web.dart' as web;

class WebNavigationGuard {
  static JSFunction? _listener;

  static void enable() {
    disable();
    _listener = ((web.BeforeUnloadEvent event) {
      event.preventDefault();
      // Chrome requires returnValue to be set
      event.returnValue = '';
    }).toJS;
    web.window.addEventListener('beforeunload', _listener!);
  }

  static void disable() {
    if (_listener != null) {
      web.window.removeEventListener('beforeunload', _listener!);
      _listener = null;
    }
  }
}
