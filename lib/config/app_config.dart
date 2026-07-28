import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/config/currency.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/pdf/invoice_template_definition.dart';
import 'package:invoices/theme/theme_definition.dart';

enum AppThemePreference { light, dark }

class AppConfig {
  static const _copyWithUnset = Object();

  const AppConfig({
    this.windowDecorations = true,
    this.theme = AppThemePreference.light,
    this.colorTheme = ThemeDefinition.defaultName,
    this.localization = LocalizationDefinition.defaultName,
    this.pdfTemplate = InvoiceTemplateDefinition.defaultName,
    this.pdfFont,
    this.currency = Currency.defaultCode,
  });

  final bool windowDecorations;
  final AppThemePreference theme;

  /// Theme `name` from JSON (or Default).
  final String colorTheme;

  /// Localization `name` from JSON (or English).
  final String localization;

  /// PDF template `name` from JSON (or Default).
  final String pdfTemplate;

  /// PDF font family name selected by the user (null = automatic).
  final String? pdfFont;

  final String currency;

  static const AppConfig defaults = AppConfig();

  /// Debug (`make run` / `make run-windows`): project-local
  /// `config/config.json` (or `APP_CONFIG_PATH`).
  /// Release Linux: `~/.config/invoices/config.json`.
  /// Release Windows: `%APPDATA%/invoices/config.json`.
  static String get configPath {
    const fromDefine = String.fromEnvironment('APP_CONFIG_PATH');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    if (kReleaseMode) {
      if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'];
        final base = (appData != null && appData.isNotEmpty)
            ? appData
            : '${Platform.environment['USERPROFILE']}/AppData/Roaming';
        return '$base/invoices/config.json';
      }

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

  /// `<configDir>/templates`.
  static String get templatesDirectory => configSubdirectory('templates');

  static String get databasePath => configSubdirectory('invoices.db');

  static String get mediaDirectory => configSubdirectory('media');

  AppConfig copyWith({
    bool? windowDecorations,
    AppThemePreference? theme,
    String? colorTheme,
    String? localization,
    String? pdfTemplate,
    Object? pdfFont = _copyWithUnset,
    Object? currency = _copyWithUnset,
  }) {
    return AppConfig(
      windowDecorations: windowDecorations ?? this.windowDecorations,
      theme: theme ?? this.theme,
      colorTheme: colorTheme ?? this.colorTheme,
      localization: localization ?? this.localization,
      pdfTemplate: pdfTemplate ?? this.pdfTemplate,
      pdfFont: identical(pdfFont, _copyWithUnset)
          ? this.pdfFont
          : pdfFont as String?,
      currency: identical(currency, _copyWithUnset)
          ? this.currency
          : currency as String,
    );
  }

  Map<String, Object> toJson() => {
        'window_decorations': windowDecorations,
        'theme': theme == AppThemePreference.dark ? 'dark' : 'light',
        'color_theme': colorTheme,
        'localization': localization,
        'pdf_template': pdfTemplate,
        'pdf_font': ?pdfFont,
        'currency': currency,
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

  static String pdfTemplateFromJson(Object? value) =>
      namedPreferenceFromJson(value, InvoiceTemplateDefinition.defaultName);

  static String? optionalStringFromJson(Object? value) =>
      optionalCatalogString(value);

  static String currencyFromJson(Object? value) => Currency.fromCode(
        value is String ? value : Currency.defaultCode,
      ).code;

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
            : true,
        theme: decoded['theme'] == 'dark'
            ? AppThemePreference.dark
            : AppThemePreference.light,
        colorTheme: colorThemeFromJson(decoded['color_theme']),
        localization: localizationFromJson(decoded['localization']),
        pdfTemplate: pdfTemplateFromJson(decoded['pdf_template']),
        pdfFont: optionalStringFromJson(decoded['pdf_font']),
        currency: currencyFromJson(decoded['currency']),
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
