import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum AppThemePreference { light, dark }

class AppConfig {
  const AppConfig({
    this.windowDecorations = false,
    this.theme = AppThemePreference.light,
  });

  final bool windowDecorations;
  final AppThemePreference theme;

  static const AppConfig defaults = AppConfig();

  /// Debug (`make run`): project-local `config.json` (or `APP_CONFIG_PATH`).
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

    return 'config.json';
  }

  AppConfig copyWith({
    bool? windowDecorations,
    AppThemePreference? theme,
  }) {
    return AppConfig(
      windowDecorations: windowDecorations ?? this.windowDecorations,
      theme: theme ?? this.theme,
    );
  }

  Map<String, Object> toJson() => {
        'window_decorations': windowDecorations,
        'theme': theme == AppThemePreference.dark ? 'dark' : 'light',
      };

  static AppThemePreference _themeFromJson(Object? value) {
    if (value == 'dark') {
      return AppThemePreference.dark;
    }
    return AppThemePreference.light;
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
        theme: _themeFromJson(decoded['theme']),
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
