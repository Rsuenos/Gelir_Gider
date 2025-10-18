import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/app.dart';
import 'package:gelir_gider/core/constants.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';

/// Entry-point: Minimal, readable, and sets up only the essentials.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase (Auth + DB)
  await SupabaseService.init(
    supabaseUrl: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: FinanceXApp()),
    ),
  );
}
