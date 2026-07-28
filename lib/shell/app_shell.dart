import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/features/clients/clients_page.dart';
import 'package:invoices/features/company/company_page.dart';
import 'package:invoices/features/invoices/invoices_page.dart';
import 'package:invoices/features/settings/settings_page.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/shell/side_nav.dart';
import 'package:invoices/theme/theme_catalog.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.config,
    required this.themes,
    required this.localizations,
    required this.database,
    required this.onThemeChanged,
    required this.onColorThemeChanged,
    required this.onLocalizationChanged,
  });

  final AppConfig config;
  final ThemeCatalog themes;
  final LocalizationCatalog localizations;
  final AppDatabase database;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<String> onColorThemeChanged;
  final ValueChanged<String> onLocalizationChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _section = AppSection.invoices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: .stretch,
        children: [
          SideNav(
            database: widget.database,
            section: _section,
            onSectionSelected: (section) {
              setState(() => _section = section);
            },
          ),
          Expanded(child: _pageFor(_section)),
        ],
      ),
    );
  }

  Widget _pageFor(AppSection section) {
    return switch (section) {
      AppSection.invoices => const InvoicesPage(),
      AppSection.clients => ClientsPage(database: widget.database),
      AppSection.company => CompanyPage(database: widget.database),
      AppSection.settings => SettingsPage(
          theme: widget.config.theme,
          colorTheme: widget.config.colorTheme,
          localization: widget.config.localization,
          themes: widget.themes,
          localizations: widget.localizations,
          onThemeChanged: widget.onThemeChanged,
          onColorThemeChanged: widget.onColorThemeChanged,
          onLocalizationChanged: widget.onLocalizationChanged,
        ),
    };
  }
}
