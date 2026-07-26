import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:invoices/app_info.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/shell/app_shell.dart';
import 'package:invoices/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final config = await AppConfig.load();

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

  runApp(InvoicesApp(config: config));
}

class InvoicesApp extends StatefulWidget {
  const InvoicesApp({super.key, required this.config});

  final AppConfig config;

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

  Future<void> _setTheme(AppThemePreference theme) async {
    final next = _config.copyWith(theme: theme);
    setState(() => _config = next);
    await next.save();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: switch (_config.theme) {
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.light => ThemeMode.light,
      },
      home: AppShell(
        config: _config,
        onThemeChanged: _setTheme,
      ),
    );
  }
}
