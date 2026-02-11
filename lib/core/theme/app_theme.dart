import 'package:flutter/material.dart';

class AppTheme {
  static const Color _lightSurface = Color(0xFFF8FAFF);
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightAccent = Color(0xFF06B6D4);

  static const Color _darkSurface = Color(0xFF0D1321);
  static const Color _darkPrimary = Color(0xFF60A5FA);
  static const Color _darkAccent = Color(0xFF22D3EE);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightAccent,
      surface: _lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkAccent,
      surface: _darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
