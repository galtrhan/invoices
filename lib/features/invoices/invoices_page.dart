import 'package:flutter/material.dart';

import 'package:invoices/l10n/localization_definition.dart';
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: l10n.invoicesTitle,
          subtitle: l10n.invoicesSubtitle,
          actions: [
            FilledButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.invoicesNew),
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
                title: l10n.invoicesNoneSelectedTitle,
                message: l10n.invoicesNoneSelectedMessage,
                actionLabel: l10n.invoicesNew,
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
    final l10n = AppLocalizations.of(context);

    if (invoices.isEmpty) {
      return EmptyPane(
        title: l10n.invoicesEmptyTitle,
        message: l10n.invoicesEmptyMessage,
        actionLabel: l10n.invoicesNew,
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
    final l10n = AppLocalizations.of(context);
    final isCreate = invoice == null;

    return FormPageBody(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            isCreate ? l10n.invoicesEditorNew : invoice!.number,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isCreate
                ? l10n.invoicesEditorCreateHint
                : l10n.invoicesEditorViewHint,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SectionPanel(
            title: l10n.invoicesSectionClient,
            child: Text(l10n.invoicesSectionClientBody),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionCompany,
            child: Text(l10n.invoicesSectionCompanyBody),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionJobs,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(l10n.invoicesSectionJobsBody),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.invoicesAddJobLine),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionHistory,
            child: Text(l10n.invoicesSectionHistoryBody),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton(
                onPressed: () {},
                child: Text(l10n.invoicesSave),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: Text(l10n.invoicesPreview),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
