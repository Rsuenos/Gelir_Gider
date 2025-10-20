import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light([Color seed = const Color(0xFF2E7D32)]) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().black.apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static ThemeData dark([Color seed = const Color(0xFF2E7D32)]) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().white.apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
