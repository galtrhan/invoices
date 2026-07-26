import 'package:flutter/material.dart';

/// Chrome tokens for shell surfaces outside Material color roles.
@immutable
class AppChromeColors extends ThemeExtension<AppChromeColors> {
  const AppChromeColors({
    required this.sidebar,
    required this.sidebarHover,
    required this.sidebarBorder,
    required this.danger,
  });

  final Color sidebar;
  final Color sidebarHover;
  final Color sidebarBorder;
  final Color danger;

  @override
  AppChromeColors copyWith({
    Color? sidebar,
    Color? sidebarHover,
    Color? sidebarBorder,
    Color? danger,
  }) {
    return AppChromeColors(
      sidebar: sidebar ?? this.sidebar,
      sidebarHover: sidebarHover ?? this.sidebarHover,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppChromeColors lerp(ThemeExtension<AppChromeColors>? other, double t) {
    if (other is! AppChromeColors) {
      return this;
    }
    return AppChromeColors(
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      sidebarHover: Color.lerp(sidebarHover, other.sidebarHover, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

@immutable
class ThemePalette {
  const ThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.scaffold,
    required this.muted,
    required this.fieldFill,
    required this.outline,
    required this.sidebar,
    required this.sidebarHover,
    required this.sidebarBorder,
    required this.danger,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color scaffold;
  final Color muted;
  final Color fieldFill;
  final Color outline;
  final Color sidebar;
  final Color sidebarHover;
  final Color sidebarBorder;
  final Color danger;

  factory ThemePalette.fromJson(Map<String, Object?> json) {
    Color require(String key) {
      final value = json[key];
      if (value is! String) {
        throw FormatException('Theme palette missing color "$key"');
      }
      return _parseColor(value);
    }

    return ThemePalette(
      primary: require('primary'),
      onPrimary: require('on_primary'),
      surface: require('surface'),
      onSurface: require('on_surface'),
      scaffold: require('scaffold'),
      muted: require('muted'),
      fieldFill: require('field_fill'),
      outline: require('outline'),
      sidebar: require('sidebar'),
      sidebarHover: require('sidebar_hover'),
      sidebarBorder: require('sidebar_border'),
      danger: require('danger'),
    );
  }

  ThemeData toThemeData(Brightness brightness) {
    final chrome = AppChromeColors(
      sidebar: sidebar,
      sidebarHover: sidebarHover,
      sidebarBorder: sidebarBorder,
      danger: danger,
    );
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: danger,
      onError: onPrimary,
      surface: surface,
      onSurface: onSurface,
      primaryContainer: Color.lerp(primary, surface, 0.82)!,
      onPrimaryContainer: onSurface,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      dividerColor: outline,
      extensions: [chrome],
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(fontSize: 14, height: 1.4, color: onSurface),
        bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: muted),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: onSurface,
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
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: .circular(6)),
          padding: const .symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: .circular(6)),
          padding: const .symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return onPrimary;
            }
            return onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
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

class ThemeDefinition {
  ThemeDefinition({
    required this.name,
    required this.light,
    required this.dark,
  });

  final String name;
  final ThemePalette light;
  final ThemePalette dark;

  ThemeData? _lightTheme;
  ThemeData? _darkTheme;

  ThemeData get lightTheme =>
      _lightTheme ??= light.toThemeData(Brightness.light);
  ThemeData get darkTheme => _darkTheme ??= dark.toThemeData(Brightness.dark);

  static const String defaultName = 'Default';

  static final ThemeDefinition builtinDefault = ThemeDefinition(
    name: defaultName,
    light: const ThemePalette(
      primary: Color(0xFF0F6E56),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A2332),
      scaffold: Color(0xFFF3F5F7),
      muted: Color(0xFF5C6B7A),
      fieldFill: Color(0xFFFFFFFF),
      outline: Color(0xFFD8DEE6),
      sidebar: Color(0xFF1A2332),
      sidebarHover: Color(0xFF243041),
      sidebarBorder: Color(0xFF2A3545),
      danger: Color(0xFFB42318),
    ),
    dark: const ThemePalette(
      primary: Color(0xFF3D9B7F),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFF1A2332),
      onSurface: Color(0xFFE8EEF4),
      scaffold: Color(0xFF10161E),
      muted: Color(0xFF9AA8B6),
      fieldFill: Color(0xFF243041),
      outline: Color(0xFF2F3B4C),
      sidebar: Color(0xFF10161E),
      sidebarHover: Color(0xFF243041),
      sidebarBorder: Color(0xFF2F3B4C),
      danger: Color(0xFFB42318),
    ),
  );

  factory ThemeDefinition.fromJson(Map<String, Object?> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Theme JSON missing "name"');
    }

    final light = json['light'];
    final dark = json['dark'];
    if (light is! Map || dark is! Map) {
      throw const FormatException('Theme JSON requires "light" and "dark"');
    }

    return ThemeDefinition(
      name: name.trim(),
      light: ThemePalette.fromJson(Map<String, Object?>.from(light)),
      dark: ThemePalette.fromJson(Map<String, Object?>.from(dark)),
    );
  }
}

Color _parseColor(String raw) {
  var hex = raw.trim();
  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) {
    throw FormatException('Invalid color "$raw"');
  }
  return Color(int.parse(hex, radix: 16));
}
