import 'package:flutter/material.dart';

import 'package:invoices/widgets/page_chrome.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const PageToolbar(
          title: 'Company',
          subtitle: 'Your business details for the invoice header',
        ),
        Expanded(
          child: FormPageBody(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Business profile', style: textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Edits are versioned like clients. Past invoices keep the company block from when they were issued.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const LogoUploadTile(
                    title: 'Company logo',
                    subtitle: 'Shown on every new invoice snapshot.',
                    icon: Icons.apartment_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Company name'),
                  ),
                  const SizedBox(height: 12),
                  const FieldGrid(
                    children: [
                      TextField(decoration: InputDecoration(labelText: 'Email')),
                      TextField(decoration: InputDecoration(labelText: 'Phone')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Tax / VAT ID'),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Address'),
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Payment / bank details',
                    ),
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Contact notes'),
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Save company'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('View history'),
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
