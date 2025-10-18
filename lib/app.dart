import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/router/app_router.dart';
import 'package:gelir_gider/core/theme/theme_provider.dart';

/// Root App widget that wires up routing, theme, and localization.
class FinanceXApp extends ConsumerWidget {
  const FinanceXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gelir Gider',
      themeMode: themeState.mode,
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      routerConfig: ref.watch(appRouterProvider),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
