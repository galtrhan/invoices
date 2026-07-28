import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/data/media_store.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/theme/theme_catalog.dart';
import 'package:invoices/widgets/page_chrome.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.database,
    required this.theme,
    required this.colorTheme,
    required this.localization,
    required this.themes,
    required this.localizations,
    required this.onThemeChanged,
    required this.onColorThemeChanged,
    required this.onLocalizationChanged,
    required this.onRestoreSettings,
  });

  final AppDatabase database;
  final AppThemePreference theme;
  final String colorTheme;
  final String localization;
  final ThemeCatalog themes;
  final LocalizationCatalog localizations;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<String> onColorThemeChanged;
  final ValueChanged<String> onLocalizationChanged;
  final Future<void> Function() onRestoreSettings;

  static ButtonStyle _destructiveStyle(ColorScheme scheme) {
    return FilledButton.styleFrom(
      backgroundColor: scheme.error,
      foregroundColor: scheme.onError,
    );
  }

  Future<void> _runConfirmed({
    required BuildContext context,
    required String title,
    required String body,
    required String actionLabel,
    required String doneMessage,
    required String failedMessage,
    required Future<void> Function() action,
    bool destructive = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              style: destructive ? _destructiveStyle(scheme) : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(doneMessage)),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failedMessage)),
      );
    }
  }

  Future<void> _resetData(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _runConfirmed(
      context: context,
      title: l10n.settingsResetConfirmTitle,
      body: l10n.settingsResetConfirmBody,
      actionLabel: l10n.settingsResetConfirmAction,
      doneMessage: l10n.settingsResetDone,
      failedMessage: l10n.settingsResetFailed,
      destructive: true,
      action: () async {
        await database.clearAllData();
        await MediaStore.clearAll();
      },
    );
  }

  Future<void> _restoreSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _runConfirmed(
      context: context,
      title: l10n.settingsRestoreConfirmTitle,
      body: l10n.settingsRestoreConfirmBody,
      actionLabel: l10n.settingsRestoreConfirmAction,
      // Capture before restore — locale may switch to the default.
      doneMessage: l10n.settingsRestoreDone,
      failedMessage: l10n.settingsRestoreFailed,
      action: onRestoreSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

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
                  const SizedBox(height: 16),
                  SectionPanel(
                    title: l10n.settingsPreferences,
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(l10n.settingsRestoreBody),
                        const SizedBox(height: 16),
                        Align(
                          alignment: .centerLeft,
                          child: OutlinedButton(
                            onPressed: () => _restoreSettings(context),
                            child: Text(l10n.settingsRestoreButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionPanel(
                    title: l10n.settingsData,
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(l10n.settingsResetBody),
                        const SizedBox(height: 16),
                        Align(
                          alignment: .centerLeft,
                          child: FilledButton(
                            style: _destructiveStyle(scheme),
                            onPressed: () => _resetData(context),
                            child: Text(l10n.settingsResetButton),
                          ),
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
