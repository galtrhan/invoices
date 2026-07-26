import 'package:flutter/material.dart';

import 'package:invoices/widgets/master_detail.dart';
import 'package:invoices/widgets/page_chrome.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  _Detail _detail = const _Detail.empty();
  final List<_InvoiceDraft> _invoices = [];

  void _startCreate() => setState(() => _detail = const _Detail.create());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: 'Invoices',
          subtitle: 'Generate invoices from clients, company, and job lines',
          actions: [
            FilledButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New invoice'),
            ),
          ],
        ),
        Expanded(
          child: MasterDetail(
            master: _InvoiceList(
              invoices: _invoices,
              selectedId: switch (_detail) {
                _Selected(:final invoice) => invoice.id,
                _ => null,
              },
              onSelect: (invoice) {
                setState(() => _detail = _Detail.selected(invoice));
              },
              onCreate: _startCreate,
            ),
            detail: switch (_detail) {
              _Create() => const _InvoiceEditor.create(),
              _Selected(:final invoice) => _InvoiceEditor.view(invoice),
              _Empty() => EmptyPane(
                title: 'No invoice selected',
                message:
                    'Create an invoice or select one from the list. '
                    'Client and company details are pulled in automatically.',
                actionLabel: 'New invoice',
                onAction: _startCreate,
              ),
            },
          ),
        ),
      ],
    );
  }
}

sealed class _Detail {
  const _Detail();
  const factory _Detail.empty() = _Empty;
  const factory _Detail.create() = _Create;
  const factory _Detail.selected(_InvoiceDraft invoice) = _Selected;
}

final class _Empty extends _Detail {
  const _Empty();
}

final class _Create extends _Detail {
  const _Create();
}

final class _Selected extends _Detail {
  const _Selected(this.invoice);
  final _InvoiceDraft invoice;
}

class _InvoiceDraft {
  const _InvoiceDraft({
    required this.id,
    required this.number,
    required this.clientName,
    required this.issuedOn,
    required this.totalLabel,
  });

  final String id;
  final String number;
  final String clientName;
  final String issuedOn;
  final String totalLabel;
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
  });

  final List<_InvoiceDraft> invoices;
  final String? selectedId;
  final ValueChanged<_InvoiceDraft> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return EmptyPane(
        title: 'No invoices yet',
        message:
            'Start with a job list and pricing. Client and company data fill in from their sections.',
        actionLabel: 'New invoice',
        onAction: onCreate,
      );
    }

    return ListView.separated(
      itemCount: invoices.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return ListTile(
          selected: invoice.id == selectedId,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(invoice.number),
          subtitle: Text('${invoice.clientName} · ${invoice.issuedOn}'),
          trailing: Text(
            invoice.totalLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () => onSelect(invoice),
        );
      },
    );
  }
}

class _InvoiceEditor extends StatelessWidget {
  const _InvoiceEditor.create() : invoice = null;
  const _InvoiceEditor.view(this.invoice);

  final _InvoiceDraft? invoice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCreate = invoice == null;

    return FormPageBody(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            isCreate ? 'New invoice' : invoice!.number,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isCreate
                ? 'Pick a client, enter jobs and pricing, then preview.'
                : 'Saved snapshot of client and company is used by default.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const SectionPanel(
            title: 'Client',
            child: Text(
              'Select a client. Past invoices keep the client details from when they were issued; you can switch to current data when regenerating.',
            ),
          ),
          const SizedBox(height: 16),
          const SectionPanel(
            title: 'Company',
            child: Text(
              'Your company details are pulled from the Company section and snapshotted onto this invoice.',
            ),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: 'Jobs',
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                const Text(
                  'Add line items with description, quantity, and price.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add job line'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionPanel(
            title: 'History',
            child: Text(
              'When regenerating: default = as saved at invoice time. Optional = use current client/company data.',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Save invoice')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('Preview')),
            ],
          ),
        ],
      ),
    );
  }
}
