import 'package:flutter/material.dart';

import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/widgets/page_chrome.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: l10n.companyTitle,
          subtitle: l10n.companySubtitle,
        ),
        Expanded(
          child: FormPageBody(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(l10n.companyProfile, style: textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(l10n.companyHint, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  LogoUploadTile(
                    title: l10n.companyLogoTitle,
                    subtitle: l10n.companyLogoSubtitle,
                    icon: Icons.apartment_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: l10n.companyFieldName),
                  ),
                  const SizedBox(height: 12),
                  FieldGrid(
                    children: [
                      TextField(
                        decoration:
                            InputDecoration(labelText: l10n.companyFieldEmail),
                      ),
                      TextField(
                        decoration:
                            InputDecoration(labelText: l10n.companyFieldPhone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(labelText: l10n.companyFieldTax),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration:
                        InputDecoration(labelText: l10n.companyFieldAddress),
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration:
                        InputDecoration(labelText: l10n.companyFieldPayment),
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration:
                        InputDecoration(labelText: l10n.companyFieldNotes),
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: Text(l10n.companySave),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(l10n.companyViewHistory),
                      ),
                    ],
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
