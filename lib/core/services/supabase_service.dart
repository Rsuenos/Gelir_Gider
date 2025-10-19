import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase initialization and handy shortcuts.
/// Responsible only for setup, not for business logic.
class SupabaseService {
  static Future<void> init({
    required String supabaseUrl,
    required String anonKey,
    String? redirectUrl,
  }) async {
    FlutterAuthClientOptions? authOptions;
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final callbackHost = Uri.tryParse(redirectUrl)?.host;
      authOptions = FlutterAuthClientOptions(
        redirectUrl: redirectUrl,
        authCallbackUrlHostname: callbackHost != null && callbackHost.isNotEmpty
            ? callbackHost
            : null,
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      authOptions: authOptions,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;
}
