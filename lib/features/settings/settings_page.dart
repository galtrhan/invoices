import 'package:flutter/material.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/widgets/page_chrome.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.theme,
    required this.onThemeChanged,
  });

  final AppThemePreference theme;
  final ValueChanged<AppThemePreference> onThemeChanged;

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
                    const Text('Theme'),
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
