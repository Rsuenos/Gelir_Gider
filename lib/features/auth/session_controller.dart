import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Listenable session state so GoRouter can refresh on auth changes.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier() {
    // Initial
    _isAuthenticated = SupabaseService.auth.currentSession != null;

    // Listen to auth state changes
    _subscription = SupabaseService.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      _isAuthenticated = session != null;
      notifyListeners();
    });
  }

  SessionNotifier.test({bool isAuthenticated = false})
      : _isAuthenticated = isAuthenticated {
    _subscription = const Stream<AuthState>.empty().listen((_) {});
  }
  bool _isAuthenticated = false;
  late final StreamSubscription<AuthState> _subscription;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

final sessionProvider = Provider<SessionNotifier>((ref) {
  final notifier = SessionNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
