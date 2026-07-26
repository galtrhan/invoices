import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/features/clients/clients_page.dart';
import 'package:invoices/features/company/company_page.dart';
import 'package:invoices/features/invoices/invoices_page.dart';
import 'package:invoices/features/settings/settings_page.dart';
import 'package:invoices/app_info.dart';
import 'package:invoices/shell/side_nav.dart';
import 'package:invoices/shell/window_title_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.config,
    required this.onThemeChanged,
  });

  final AppConfig config;
  final ValueChanged<AppThemePreference> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _section = AppSection.invoices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBar(
            title: AppInfo.name,
            showWindowControls: !widget.config.windowDecorations,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                SideNav(
                  section: _section,
                  onSectionSelected: (section) {
                    setState(() => _section = section);
                  },
                ),
                Expanded(child: _pageFor(_section)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageFor(AppSection section) {
    return switch (section) {
      AppSection.invoices => const InvoicesPage(),
      AppSection.clients => const ClientsPage(),
      AppSection.company => const CompanyPage(),
      AppSection.settings => SettingsPage(
          theme: widget.config.theme,
          onThemeChanged: widget.onThemeChanged,
        ),
    };
  }
}
