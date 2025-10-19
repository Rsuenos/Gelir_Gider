import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase initialization and handy shortcuts.
/// Responsible only for setup, not for business logic.
class SupabaseService {
  static Future<void> init({
    required String supabaseUrl,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;
}
