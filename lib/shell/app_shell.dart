import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/features/clients/clients_page.dart';
import 'package:invoices/features/company/company_page.dart';
import 'package:invoices/features/invoices/invoices_page.dart';
import 'package:invoices/features/settings/settings_page.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/pdf/invoice_template_catalog.dart';
import 'package:invoices/shell/side_nav.dart';
import 'package:invoices/theme/theme_catalog.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.config,
    required this.themes,
    required this.localizations,
    required this.templates,
    required this.database,
    required this.onThemeChanged,
    required this.onColorThemeChanged,
    required this.onLocalizationChanged,
    required this.onPdfTemplateChanged,
    required this.onRestoreSettings,
  });

  final AppConfig config;
  final ThemeCatalog themes;
  final LocalizationCatalog localizations;
  final InvoiceTemplateCatalog templates;
  final AppDatabase database;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<String> onColorThemeChanged;
  final ValueChanged<String> onLocalizationChanged;
  final ValueChanged<String> onPdfTemplateChanged;
  final Future<void> Function() onRestoreSettings;

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
      AppSection.invoices => InvoicesPage(
          database: widget.database,
          localizations: widget.localizations,
          templates: widget.templates,
          pdfTemplate: widget.config.pdfTemplate,
        ),
      AppSection.clients => ClientsPage(
          database: widget.database,
          templates: widget.templates,
        ),
      AppSection.company => CompanyPage(database: widget.database),
      AppSection.settings => SettingsPage(
          database: widget.database,
          theme: widget.config.theme,
          colorTheme: widget.config.colorTheme,
          localization: widget.config.localization,
          pdfTemplate: widget.config.pdfTemplate,
          themes: widget.themes,
          localizations: widget.localizations,
          templates: widget.templates,
          onThemeChanged: widget.onThemeChanged,
          onColorThemeChanged: widget.onColorThemeChanged,
          onLocalizationChanged: widget.onLocalizationChanged,
          onPdfTemplateChanged: widget.onPdfTemplateChanged,
          onRestoreSettings: widget.onRestoreSettings,
        ),
    };
  }
}
