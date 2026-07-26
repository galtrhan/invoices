import 'dart:convert';
import 'dart:io';

import 'package:invoices/theme/theme_definition.dart';

/// Loads custom themes from `<configDir>/themes/*.json` and prepends Default.
class ThemeCatalog {
  ThemeCatalog._(this.themes);

  final List<ThemeDefinition> themes;

  static String _key(String name) => name.trim().toLowerCase();

  static Future<ThemeCatalog> load(String themesDirectory) async {
    final dir = Directory(themesDirectory);
    if (!await dir.exists()) {
      return ThemeCatalog._([ThemeDefinition.builtinDefault]);
    }

    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    final decoded = await Future.wait(files.map((file) async {
      try {
        final raw = jsonDecode(await file.readAsString());
        if (raw is! Map) {
          return null;
        }
        return ThemeDefinition.fromJson(Map<String, Object?>.from(raw));
      } on FormatException {
        return null;
      } on FileSystemException {
        return null;
      }
    }));

    final seen = {_key(ThemeDefinition.defaultName)};
    final loaded = <ThemeDefinition>[];
    for (final theme in decoded) {
      if (theme == null) {
        continue;
      }
      final key = _key(theme.name);
      if (!seen.add(key)) {
        continue;
      }
      loaded.add(theme);
    }

    loaded.sort((a, b) => _key(a.name).compareTo(_key(b.name)));

    return ThemeCatalog._([
      ThemeDefinition.builtinDefault,
      ...loaded,
    ]);
  }

  ThemeDefinition resolve(String name) {
    final needle = _key(name);
    for (final theme in themes) {
      if (_key(theme.name) == needle) {
        return theme;
      }
    }
    return ThemeDefinition.builtinDefault;
  }
}
