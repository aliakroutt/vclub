import 'dart:async';

/// Signals when the app's initial destination (Login, or the logged-in
/// user's main screen) has actually been navigated to, so deep links can
/// wait and push on top of it instead of racing the app's own startup.
class AppReadyState {
  AppReadyState._();

  static final Completer<void> _completer = Completer<void>();

  static bool get isReady => _completer.isCompleted;

  static void markReady() {
    if (!_completer.isCompleted) _completer.complete();
  }

  static Future<void> get ready => _completer.future;
}