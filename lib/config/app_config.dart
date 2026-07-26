import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/theme/theme_definition.dart';

enum AppThemePreference { light, dark }

class AppConfig {
  const AppConfig({
    this.windowDecorations = false,
    this.theme = AppThemePreference.light,
    this.colorTheme = ThemeDefinition.defaultName,
    this.localization = LocalizationDefinition.defaultName,
  });

  final bool windowDecorations;
  final AppThemePreference theme;

  /// Theme `name` from JSON (or Default).
  final String colorTheme;

  /// Localization `name` from JSON (or English).
  final String localization;

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

  static String configSubdirectory(String segment) =>
      '${File(configPath).parent.path}/$segment';

  /// `<configDir>/themes`.
  static String get themesDirectory => configSubdirectory('themes');

  /// `<configDir>/localizations`.
  static String get localizationsDirectory =>
      configSubdirectory('localizations');

  AppConfig copyWith({
    bool? windowDecorations,
    AppThemePreference? theme,
    String? colorTheme,
    String? localization,
  }) {
    return AppConfig(
      windowDecorations: windowDecorations ?? this.windowDecorations,
      theme: theme ?? this.theme,
      colorTheme: colorTheme ?? this.colorTheme,
      localization: localization ?? this.localization,
    );
  }

  Map<String, Object> toJson() => {
        'window_decorations': windowDecorations,
        'theme': theme == AppThemePreference.dark ? 'dark' : 'light',
        'color_theme': colorTheme,
        'localization': localization,
      };

  /// Accepts display names or legacy slugs (`tokyo_night` → `tokyo night`).
  static String namedPreferenceFromJson(Object? value, String defaultName) {
    if (value is! String || value.trim().isEmpty) {
      return defaultName;
    }
    return value.trim().replaceAll('_', ' ');
  }

  static String colorThemeFromJson(Object? value) =>
      namedPreferenceFromJson(value, ThemeDefinition.defaultName);

  static String localizationFromJson(Object? value) =>
      namedPreferenceFromJson(value, LocalizationDefinition.defaultName);

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
        localization: localizationFromJson(decoded['localization']),
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
