import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available theme variants.
enum AppThemeType { material, minimalist, neomorphism, flat, oneUI }

/// Theme state holds mode and selected variant.
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.type,
    required this.lightTheme,
    required this.darkTheme,
  });
  final ThemeMode mode;
  final AppThemeType type;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemeState copyWith({
    ThemeMode? mode,
    AppThemeType? type,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      type: type ?? this.type,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

final NotifierProvider<ThemeController, ThemeState> themeProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    const initialType = AppThemeType.material;
    return ThemeState(
      mode: ThemeMode.system,
      type: initialType,
      lightTheme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
    );
  }

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);

  void setType(AppThemeType type) {
    if (type == AppThemeType.material) {
      state = state.copyWith(
        type: type,
        lightTheme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
      );
    } else {
      state = state.copyWith(
        type: type,
        lightTheme: _buildTheme(type, Brightness.light),
        darkTheme: _buildTheme(type, Brightness.dark),
      );
    }
  }
}

TextTheme _fonted(TextTheme base) {
  // Global fonts: Prefer Inter/Open Sans/Roboto; iOS uses SF by default as fallback.
  return GoogleFonts.interTextTheme(base);
}

/// Theme factory that emulates selected design languages.
ThemeData _buildTheme(AppThemeType type, Brightness b) {
  final isDark = b == Brightness.dark;
  final colorSeed = switch (type) {
    AppThemeType.material => const Color(0xFF6750A4),
    AppThemeType.minimalist => const Color(0xFF1E88E5),
    AppThemeType.neomorphism => const Color(0xFF6C63FF),
    AppThemeType.flat => const Color(0xFF00BCD4),
    AppThemeType.oneUI => const Color(0xFF0A8F08),
  };

  var base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorSeed,
    brightness: b,
  );

  // Per theme tweaks
  switch (type) {
    case AppThemeType.material:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: const CardThemeData(elevation: 1),
      );
    case AppThemeType.minimalist:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF101316) : const Color(0xFFF7F9FB),
        cardTheme: CardThemeData(
          elevation: 0,
          color: isDark ? const Color(0xFF13171B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    case AppThemeType.neomorphism:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF1A1F24) : const Color(0xFFEFF3F8),
        cardTheme: CardThemeData(
          color: isDark ? const Color(0xFF21262C) : const Color(0xFFEFF3F8),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    case AppThemeType.flat:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: const CardThemeData(elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    case AppThemeType.oneUI:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          titleTextStyle: _fonted(base.textTheme)
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
  }

  return base;
}
