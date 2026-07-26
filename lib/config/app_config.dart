import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:invoices/theme/theme_definition.dart';

enum AppThemePreference { light, dark }

class AppConfig {
  const AppConfig({
    this.windowDecorations = false,
    this.theme = AppThemePreference.light,
    this.colorTheme = ThemeDefinition.defaultName,
  });

  final bool windowDecorations;
  final AppThemePreference theme;

  /// Theme `name` from JSON (or Default).
  final String colorTheme;

  static const AppConfig defaults = AppConfig();

  /// Debug (`make run`): project-local `config/config.json` (or `APP_CONFIG_PATH`).
  /// Release (`make release`): `~/.config/invoices/config.json`.
  static String get configPath {
    const fromDefine = String.fromEnvironment('APP_CONFIG_PATH');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    if (kReleaseMode) {
      final xdg = Platform.environment['XDG_CONFIG_HOME'];
      final base = (xdg != null && xdg.isNotEmpty)
          ? xdg
          : '${Platform.environment['HOME']}/.config';
      return '$base/invoices/config.json';
    }

    return 'config/config.json';
  }

  /// `<configDir>/themes`.
  static String get themesDirectory =>
      '${File(configPath).parent.path}/themes';

  AppConfig copyWith({
    bool? windowDecorations,
    AppThemePreference? theme,
    String? colorTheme,
  }) {
    return AppConfig(
      windowDecorations: windowDecorations ?? this.windowDecorations,
      theme: theme ?? this.theme,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }

  Map<String, Object> toJson() => {
        'window_decorations': windowDecorations,
        'theme': theme == AppThemePreference.dark ? 'dark' : 'light',
        'color_theme': colorTheme,
      };

  /// Accepts display names or legacy slugs (`tokyo_night` → `tokyo night`).
  static String colorThemeFromJson(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return ThemeDefinition.defaultName;
    }
    return value.trim().replaceAll('_', ' ');
  }

  static Future<AppConfig> load() async {
    final file = File(configPath);
    if (!await file.exists()) {
      return defaults;
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        return defaults;
      }
      return AppConfig(
        windowDecorations: decoded['window_decorations'] is bool
            ? decoded['window_decorations'] as bool
            : false,
        theme: decoded['theme'] == 'dark'
            ? AppThemePreference.dark
            : AppThemePreference.light,
        colorTheme: colorThemeFromJson(decoded['color_theme']),
      );
    } on FormatException {
      return defaults;
    } on FileSystemException {
      return defaults;
    }
  }

  Future<void> save() async {
    final file = File(configPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(toJson()),
    );
  }
}
