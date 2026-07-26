import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:invoices/app_info.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/shell/app_shell.dart';
import 'package:invoices/theme/theme_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final themes = await ThemeCatalog.load(AppConfig.themesDirectory);
  final loaded = await AppConfig.load();
  final resolvedName = themes.resolve(loaded.colorTheme).name;
  final config = loaded.colorTheme == resolvedName
      ? loaded
      : loaded.copyWith(colorTheme: resolvedName);

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

  runApp(InvoicesApp(config: config, themes: themes));
}

class InvoicesApp extends StatefulWidget {
  const InvoicesApp({
    super.key,
    required this.config,
    required this.themes,
  });

  final AppConfig config;
  final ThemeCatalog themes;

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

  Future<void> _persist(AppConfig next) async {
    setState(() => _config = next);
    await next.save();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.themes.resolve(_config.colorTheme);

    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: selected.lightTheme,
      darkTheme: selected.darkTheme,
      themeMode: switch (_config.theme) {
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.light => ThemeMode.light,
      },
      home: AppShell(
        config: _config,
        themes: widget.themes,
        onThemeChanged: (theme) => _persist(_config.copyWith(theme: theme)),
        onColorThemeChanged: (colorTheme) =>
            _persist(_config.copyWith(colorTheme: colorTheme)),
      ),
    );
  }
}
