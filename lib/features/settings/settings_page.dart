import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/theme/theme_catalog.dart';
import 'package:invoices/widgets/page_chrome.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.theme,
    required this.colorTheme,
    required this.themes,
    required this.onThemeChanged,
    required this.onColorThemeChanged,
  });

  final AppThemePreference theme;
  final String colorTheme;
  final ThemeCatalog themes;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<String> onColorThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const PageToolbar(
          title: 'Settings',
          subtitle: 'Application preferences',
        ),
        Expanded(
          child: FormPageBody(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SectionPanel(
                title: 'Appearance',
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    DropdownMenu<String>(
                      key: ValueKey(colorTheme),
                      initialSelection: colorTheme,
                      label: const Text('Theme'),
                      expandedInsets: .zero,
                      onSelected: (value) {
                        if (value != null) {
                          onColorThemeChanged(value);
                        }
                      },
                      dropdownMenuEntries: [
                        for (final option in themes.themes)
                          DropdownMenuEntry(
                            value: option.name,
                            label: option.name,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Mode'),
                    const SizedBox(height: 12),
                    SegmentedButton<AppThemePreference>(
                      segments: const [
                        ButtonSegment(
                          value: AppThemePreference.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: AppThemePreference.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined, size: 18),
                        ),
                      ],
                      selected: {theme},
                      onSelectionChanged: (selected) {
                        onThemeChanged(selected.single);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
