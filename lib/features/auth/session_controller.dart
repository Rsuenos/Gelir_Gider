import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';

/// Listenable session state so GoRouter can refresh on auth changes.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier() {
    // Initial
    _isAuthenticated = SupabaseService.auth.currentSession != null;

    // Listen to auth state changes
    SupabaseService.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      _isAuthenticated = session != null;
      notifyListeners();
    });
  }
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }
}

final sessionProvider = ChangeNotifierProvider<SessionNotifier>((ref) {
  return SessionNotifier();
});
