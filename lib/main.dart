import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:invoices/app_info.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/shell/app_shell.dart';
import 'package:invoices/theme/theme_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final results = await (
    ThemeCatalog.load(AppConfig.themesDirectory),
    LocalizationCatalog.load(AppConfig.localizationsDirectory),
    AppConfig.load(),
  ).wait;
  final themes = results.$1;
  final localizations = results.$2;
  final loaded = results.$3;
  final database = AppDatabase();

  final resolvedTheme = themes.resolve(loaded.colorTheme).name;
  final resolvedLocale = localizations.resolve(loaded.localization).name;
  final config = loaded.copyWith(
    colorTheme: resolvedTheme,
    localization: resolvedLocale,
  );

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(960, 640),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: AppInfo.name,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    InvoicesApp(
      config: config,
      themes: themes,
      localizations: localizations,
      database: database,
    ),
  );
}

class InvoicesApp extends StatefulWidget {
  const InvoicesApp({
    super.key,
    required this.config,
    required this.themes,
    required this.localizations,
    required this.database,
  });

  final AppConfig config;
  final ThemeCatalog themes;
  final LocalizationCatalog localizations;
  final AppDatabase database;

  @override
  State<InvoicesApp> createState() => _InvoicesAppState();
}

class _InvoicesAppState extends State<InvoicesApp> {
  late AppConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  @override
  void dispose() {
    widget.database.close();
    super.dispose();
  }

  Future<void> _persist(AppConfig next) async {
    setState(() => _config = next);
    await next.save();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = widget.themes.resolve(_config.colorTheme);
    final selectedLocale =
        widget.localizations.resolve(_config.localization);

    return AppLocalizations(
      strings: selectedLocale,
      child: MaterialApp(
        title: AppInfo.name,
        debugShowCheckedModeBanner: false,
        theme: selectedTheme.lightTheme,
        darkTheme: selectedTheme.darkTheme,
        themeMode: switch (_config.theme) {
          AppThemePreference.dark => ThemeMode.dark,
          AppThemePreference.light => ThemeMode.light,
        },
        home: AppShell(
          config: _config,
          themes: widget.themes,
          localizations: widget.localizations,
          database: widget.database,
          onThemeChanged: (theme) => _persist(_config.copyWith(theme: theme)),
          onColorThemeChanged: (colorTheme) =>
              _persist(_config.copyWith(colorTheme: colorTheme)),
          onLocalizationChanged: (localization) =>
              _persist(_config.copyWith(localization: localization)),
          onRestoreSettings: () => _persist(AppConfig.defaults),
        ),
      ),
    );
  }
}
