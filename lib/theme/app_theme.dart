import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color ink = Color(0xFF1A2332);
  static const Color slate = Color(0xFF5C6B7A);
  static const Color mist = Color(0xFFF3F5F7);
  static const Color line = Color(0xFFD8DEE6);
  static const Color panel = Color(0xFFEEF1F4);
  static const Color accent = Color(0xFF0F6E56);
  static const Color danger = Color(0xFFB42318);

  static const Color darkCanvas = Color(0xFF10161E);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkPanel = Color(0xFF243041);
  static const Color darkLine = Color(0xFF2F3B4C);
  static const Color darkSlate = Color(0xFF9AA8B6);
  static const Color darkInk = Color(0xFFE8EEF4);

  static final ThemeData lightTheme = _build(
        brightness: Brightness.light,
        scheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          primary: accent,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: ink,
        ),
        scaffold: mist,
        divider: line,
        inkColor: ink,
        mutedColor: slate,
        fieldFill: Colors.white,
        outline: line,
      );

  static final ThemeData darkTheme = _build(
        brightness: Brightness.dark,
        scheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          primary: const Color(0xFF3D9B7F),
          onPrimary: Colors.white,
          surface: darkSurface,
          onSurface: darkInk,
        ),
        scaffold: darkCanvas,
        divider: darkLine,
        inkColor: darkInk,
        mutedColor: darkSlate,
        fieldFill: darkPanel,
        outline: darkLine,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color divider,
    required Color inkColor,
    required Color mutedColor,
    required Color fieldFill,
    required Color outline,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      dividerColor: divider,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: inkColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: inkColor,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: inkColor,
        ),
        bodyLarge: TextStyle(fontSize: 14, height: 1.4, color: inkColor),
        bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: mutedColor),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: inkColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const .symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: .circular(6),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .circular(6),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(6),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: .circular(6)),
          padding: const .symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkColor,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: .circular(6)),
          padding: const .symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return inkColor;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primary;
            }
            return fieldFill;
          }),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        contentPadding: .symmetric(horizontal: 16),
      ),
    );
  }
}
