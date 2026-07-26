import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/theme/theme_catalog.dart';
import 'package:invoices/widgets/page_chrome.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.theme,
    required this.colorTheme,
    required this.localization,
    required this.themes,
    required this.localizations,
    required this.onThemeChanged,
    required this.onColorThemeChanged,
    required this.onLocalizationChanged,
  });

  final AppThemePreference theme;
  final String colorTheme;
  final String localization;
  final ThemeCatalog themes;
  final LocalizationCatalog localizations;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<String> onColorThemeChanged;
  final ValueChanged<String> onLocalizationChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: l10n.settingsTitle,
          subtitle: l10n.settingsSubtitle,
        ),
        Expanded(
          child: FormPageBody(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  SectionPanel(
                    title: l10n.settingsAppearance,
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        DropdownMenu<String>(
                          key: ValueKey('theme-$colorTheme'),
                          initialSelection: colorTheme,
                          label: Text(l10n.settingsTheme),
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
                        Text(l10n.settingsMode),
                        const SizedBox(height: 12),
                        SegmentedButton<AppThemePreference>(
                          segments: [
                            ButtonSegment(
                              value: AppThemePreference.light,
                              label: Text(l10n.settingsLight),
                              icon: const Icon(
                                Icons.light_mode_outlined,
                                size: 18,
                              ),
                            ),
                            ButtonSegment(
                              value: AppThemePreference.dark,
                              label: Text(l10n.settingsDark),
                              icon: const Icon(
                                Icons.dark_mode_outlined,
                                size: 18,
                              ),
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
                  const SizedBox(height: 16),
                  SectionPanel(
                    title: l10n.settingsLanguage,
                    child: DropdownMenu<String>(
                      key: ValueKey('locale-$localization'),
                      initialSelection: localization,
                      label: Text(l10n.settingsLanguage),
                      expandedInsets: .zero,
                      onSelected: (value) {
                        if (value != null) {
                          onLocalizationChanged(value);
                        }
                      },
                      dropdownMenuEntries: [
                        for (final option in localizations.localizations)
                          DropdownMenuEntry(
                            value: option.name,
                            label: option.name,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
