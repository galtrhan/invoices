import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:invoices/data/app_database.dart';
import 'package:invoices/data/invoice_number_format.dart';
import 'package:invoices/data/media_store.dart';
import 'package:invoices/data/system_font_catalog.dart';
import 'package:invoices/features/invoices/invoice_pdf.dart';
import 'package:invoices/features/invoices/invoice_pdf_fonts.dart';
import 'package:invoices/features/invoices/invoice_pdf_preview_page.dart';
import 'package:invoices/config/currency.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/pdf/invoice_template_catalog.dart';
import 'package:invoices/pdf/invoice_template_definition.dart';
import 'package:invoices/widgets/master_detail.dart';
import 'package:invoices/widgets/page_chrome.dart';

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y.$m.$d';
}

/// Returns null when [raw] is not empty and not a number.
double? _tryParseAmount(String raw) {
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return 0;
  }
  return double.tryParse(normalized);
}

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({
    super.key,
    required this.database,
    required this.localizations,
    required this.templates,
    required this.pdfTemplate,
    this.pdfFont,
    required this.currency,
    required this.systemFonts,
  });

  final AppDatabase database;
  final LocalizationCatalog localizations;
  final InvoiceTemplateCatalog templates;
  final String pdfTemplate;
  final String? pdfFont;
  final String currency;
  final SystemFontCatalog systemFonts;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  _Detail _detail = const _Detail.empty();
  late Stream<List<Invoice>> _invoicesStream = widget.database.watchInvoices();

  @override
  void didUpdateWidget(covariant InvoicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.database, widget.database)) {
      _invoicesStream = widget.database.watchInvoices();
    }
  }

  void _startCreate() => setState(() => _detail = const _Detail.create());

  void _select(Invoice invoice) {
    setState(() => _detail = _Detail.selected(invoice.id));
  }

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
          child: StreamBuilder<List<Invoice>>(
            stream: _invoicesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return EmptyPane(
                  title: l10n.invoicesLoadFailed,
                  message: l10n.invoicesLoadFailed,
                );
              }

              final invoices = snapshot.data ?? const <Invoice>[];
              final selectedId = switch (_detail) {
                _Selected(:final id) => id,
                _ => null,
              };
              final selected = selectedId == null
                  ? null
                  : invoices.where((row) => row.id == selectedId).firstOrNull;

              final currency = Currency.fromCode(widget.currency);

              return MasterDetail(
                master: _InvoiceList(
                  invoices: invoices,
                  selectedId: selectedId,
                  onSelect: _select,
                  onCreate: _startCreate,
                  currency: currency,
                ),
                detail: switch (_detail) {
                  _Create() => _InvoiceEditor(
                      key: const ValueKey('new'),
                      database: widget.database,
                      localizations: widget.localizations,
                      templates: widget.templates,
                      pdfTemplate: widget.pdfTemplate,
                      pdfFont: widget.pdfFont,
                      currency: currency,
                      systemFonts: widget.systemFonts,
                      invoice: null,
                      onSaved: _select,
                    ),
                  _Selected() when selected != null => _InvoiceEditor(
                      key: ValueKey(selected.id),
                      database: widget.database,
                      localizations: widget.localizations,
                      templates: widget.templates,
                      pdfTemplate: widget.pdfTemplate,
                      pdfFont: widget.pdfFont,
                      currency: currency,
                      systemFonts: widget.systemFonts,
                      invoice: selected,
                      onSaved: _select,
                      onDeleted: () =>
                          setState(() => _detail = const _Detail.empty()),
                    ),
                  _Selected() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  _Empty() => EmptyPane(
                      title: l10n.invoicesNoneSelectedTitle,
                      message: l10n.invoicesNoneSelectedMessage,
                      actionLabel: l10n.invoicesNew,
                      onAction: _startCreate,
                    ),
                },
              );
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
  const factory _Detail.selected(int id) = _Selected;
}

final class _Empty extends _Detail {
  const _Empty();
}

final class _Create extends _Detail {
  const _Create();
}

final class _Selected extends _Detail {
  const _Selected(this.id);
  final int id;
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
    required this.currency,
  });

  final List<Invoice> invoices;
  final int? selectedId;
  final ValueChanged<Invoice> onSelect;
  final VoidCallback onCreate;
  final Currency currency;

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
        final clientLabel = invoice.clientName.isEmpty
            ? l10n.invoicesClientPlaceholder
            : invoice.clientName;
        return ListTile(
          selected: invoice.id == selectedId,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          leading: StoredLogoThumbnail(storedPath: invoice.clientLogoPath),
          title: Text(invoice.number),
          subtitle: Text('$clientLabel · ${_formatDate(invoice.issuedOn)}'),
          trailing: Text(
            currency.formatUi(invoice.total),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () => onSelect(invoice),
        );
      },
    );
  }
}

class _JobLineDraft {
  _JobLineDraft({
    String description = '',
    String quantity = '1',
    String unitPrice = '0',
  })  : description = TextEditingController(text: description),
        quantity = TextEditingController(text: quantity),
        unitPrice = TextEditingController(text: unitPrice);

  final TextEditingController description;
  final TextEditingController quantity;
  final TextEditingController unitPrice;

  double? get lineTotal {
    final quantity = _tryParseAmount(this.quantity.text);
    final unitPrice = _tryParseAmount(this.unitPrice.text);
    if (quantity == null || unitPrice == null) {
      return null;
    }
    return quantity * unitPrice;
  }

  InvoiceLineInput? toInput() {
    final quantity = _tryParseAmount(this.quantity.text);
    final unitPrice = _tryParseAmount(this.unitPrice.text);
    if (quantity == null || unitPrice == null) {
      return null;
    }
    return InvoiceLineInput(
      description: description.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  void dispose() {
    description.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

class _InvoiceEditor extends StatefulWidget {
  const _InvoiceEditor({
    super.key,
    required this.database,
    required this.localizations,
    required this.templates,
    required this.pdfTemplate,
    this.pdfFont,
    required this.currency,
    required this.systemFonts,
    required this.invoice,
    required this.onSaved,
    this.onDeleted,
  });

  final AppDatabase database;
  final LocalizationCatalog localizations;
  final InvoiceTemplateCatalog templates;
  final String pdfTemplate;
  final String? pdfFont;
  final Currency currency;
  final SystemFontCatalog systemFonts;
  final Invoice? invoice;
  final ValueChanged<Invoice> onSaved;
  final VoidCallback? onDeleted;

  @override
  State<_InvoiceEditor> createState() => _InvoiceEditorState();
}

class _InvoiceEditorState extends State<_InvoiceEditor> {
  final _number = TextEditingController();
  final _lines = <_JobLineDraft>[];
  late Stream<List<Client>> _clientsStream = widget.database.watchClients();

  DateTime _issuedOn = DateTime.now();
  int? _clientId;
  var _loading = true;
  var _saving = false;
  var _deleting = false;
  var _exporting = false;
  var _numberReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void didUpdateWidget(covariant _InvoiceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.database, widget.database)) {
      _clientsStream = widget.database.watchClients();
    }
  }

  @override
  void dispose() {
    _number.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final existing = widget.invoice;
    if (existing == null) {
      _issuedOn = DateTime.now();
      _lines.add(_JobLineDraft());
      final number = await widget.database.nextInvoiceNumber(_issuedOn);
      if (!mounted) {
        return;
      }
      setState(() {
        _number.text = number;
        _numberReady = true;
        _loading = false;
      });
      return;
    }

    final lines = await widget.database.getInvoiceLines(existing.id);
    if (!mounted) {
      return;
    }
    for (final line in _lines) {
      line.dispose();
    }
    _lines
      ..clear()
      ..addAll(
        lines.map(
          (line) => _JobLineDraft(
            description: line.description,
            quantity: line.quantity.toStringAsFixed(2),
            unitPrice: line.unitPrice.toStringAsFixed(2),
          ),
        ),
      );
    if (_lines.isEmpty) {
      _lines.add(_JobLineDraft());
    }
    setState(() {
      _number.text = existing.number;
      _issuedOn = existing.issuedOn;
      _clientId = existing.clientId;
      _numberReady = true;
      _loading = false;
    });
  }

  void _addLine() {
    setState(() => _lines.add(_JobLineDraft()));
  }

  void _removeLine(int index) {
    if (_lines.length <= 1) {
      return;
    }
    setState(() {
      _lines.removeAt(index).dispose();
    });
  }

  double get _total {
    var sum = 0.0;
    for (final line in _lines) {
      sum += line.lineTotal ?? 0;
    }
    return sum;
  }

  Future<void> _pickIssuedOn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedOn,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _issuedOn = picked);

    if (widget.invoice != null || !_numberReady) {
      return;
    }

    final company = await widget.database.getCompany();
    final number = await widget.database.nextInvoiceNumber(
      picked,
      company: company,
    );
    if (!mounted) {
      return;
    }
    final current = _number.text.trim();
    final looksAuto = matchesInvoiceNumberFormat(
      current,
      company.invoiceNumberFormat,
    );
    if (looksAuto || current.isEmpty) {
      setState(() => _number.text = number);
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final clientId = _clientId;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoicesClientRequired)),
      );
      return;
    }

    final lineInputs = <InvoiceLineInput>[];
    for (final line in _lines) {
      final input = line.toInput();
      if (input == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoicesInvalidAmount)),
        );
        return;
      }
      lineInputs.add(input);
    }

    setState(() => _saving = true);
    final isNew = widget.invoice == null;
    try {
      final client = await widget.database.getClient(clientId);
      if (client == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoicesClientRequired)),
        );
        return;
      }

      final company = await widget.database.getCompany();
      final number = _number.text.trim().isEmpty
          ? await widget.database.nextInvoiceNumber(_issuedOn)
          : _number.text.trim();

      final saved = await widget.database.saveInvoice(
        id: widget.invoice?.id,
        data: InvoicesCompanion(
          number: Value(number),
          issuedOn: Value(_issuedOn),
          clientId: Value(client.id),
          clientName: Value(client.name),
          clientEmail: Value(client.email),
          clientPhone: Value(client.phone),
          clientTaxId: Value(client.taxId),
          clientAddress: Value(client.address),
          clientNotes: Value(client.notes),
          clientLogoPath: Value(client.logoPath),
          companyName: Value(company.name),
          companyEmail: Value(company.email),
          companyPhone: Value(company.phone),
          companyTaxId: Value(company.taxId),
          companyAddress: Value(company.address),
          companyPaymentDetails: Value(company.paymentDetails),
          companyNotes: Value(company.notes),
          companyLogoPath: Value(company.logoPath),
        ),
        lines: lineInputs,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? l10n.invoicesCreated : l10n.invoicesSaved),
        ),
      );
      widget.onSaved(saved);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoicesSaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final invoice = widget.invoice;
    if (invoice == null || _deleting) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.invoicesDeleteConfirmTitle),
          content: Text(l10n.invoicesDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              style: destructiveFilledStyle(scheme),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.invoicesDeleteConfirmAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    try {
      await widget.database.deleteInvoice(invoice.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoicesDeleted)),
      );
      widget.onDeleted?.call();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoicesDeleteFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _openExportDialog() async {
    if (_exporting) {
      return;
    }

    final uiL10n = AppLocalizations.of(context);
    if (widget.invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uiL10n.invoicesExportSaveFirst)),
      );
      return;
    }

    Client? client;
    final clientId = _clientId;
    if (clientId != null) {
      client = await widget.database.getClient(clientId);
    }
    if (!mounted) {
      return;
    }
    final preferredTemplate = widget.templates.resolvePreferred(
      clientTemplate: client?.pdfTemplate,
      settingsTemplate: widget.pdfTemplate,
    );

    final choice = await showDialog<_ExportChoice>(
      context: context,
      builder: (dialogContext) {
        return _ExportPdfDialog(
          localizations: widget.localizations,
          templates: widget.templates,
          initialLanguage: AppLocalizations.of(context).name,
          initialTemplate: preferredTemplate.name,
        );
      },
    );

    if (choice == null || !mounted) {
      return;
    }

    await _exportPdf(
      exportL10n: widget.localizations.resolve(choice.language),
      template: widget.templates.resolve(choice.template),
    );
  }

  Future<void> _exportPdf({
    required LocalizationDefinition exportL10n,
    required InvoiceTemplateDefinition template,
  }) async {
    if (_exporting) {
      return;
    }

    final uiL10n = AppLocalizations.of(context);
    final invoice = widget.invoice;
    if (invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uiL10n.invoicesExportSaveFirst)),
      );
      return;
    }

    final lineInputs = <InvoicePdfLine>[];
    for (final line in _lines) {
      final input = line.toInput();
      if (input == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uiL10n.invoicesInvalidAmount)),
        );
        return;
      }
      lineInputs.add(
        InvoicePdfLine(
          description: input.description,
          quantity: input.quantity,
          unitPrice: input.unitPrice,
        ),
      );
    }

    setState(() => _exporting = true);
    try {
      final number =
          _number.text.trim().isEmpty ? invoice.number : _number.text.trim();
      final clientName = invoice.clientName;
      final preferredFamily = widget.systemFonts.resolvePreferred(
        templateFont: template.font,
        settingsFont: widget.pdfFont,
      );
      final logoAndFonts = await (
        _readLogoBytes(invoice.companyLogoPath),
        InvoicePdfFonts.load(
          catalog: widget.systemFonts,
          family: preferredFamily,
        ),
      ).wait;
      final logoBytes = logoAndFonts.$1;
      final fonts = logoAndFonts.$2;
      final bytes = await buildInvoicePdf(
        InvoicePdfData(
          number: number,
          issuedOn: _issuedOn,
          dueOn: _issuedOn.add(const Duration(days: 10)),
          companyName: invoice.companyName,
          companyTaxId: invoice.companyTaxId,
          companyAddress: invoice.companyAddress,
          companyPaymentDetails: invoice.companyPaymentDetails,
          logoBytes: logoBytes,
          fontRegular: fonts.regular,
          fontBold: fonts.bold,
          clientName: clientName,
          clientTaxId: invoice.clientTaxId,
          clientAddress: invoice.clientAddress,
          clientPhone: invoice.clientPhone,
          clientEmail: invoice.clientEmail,
          lines: lineInputs,
          labels: InvoicePdfLabels.fromLocalization(exportL10n),
          template: template,
          currency: widget.currency,
        ),
      );

      final suggested = invoicePdfFileName(
        number: number,
        issuedOn: _issuedOn,
        clientName: clientName,
        languageName: exportL10n.name,
      );

      if (!mounted) {
        return;
      }

      final shouldSave = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => InvoicePdfPreviewPage(
            bytes: bytes,
            fileName: suggested,
          ),
        ),
      );

      if (!mounted || shouldSave != true) {
        return;
      }

      final path = await FilePicker.platform.saveFile(
        dialogTitle: uiL10n.invoicesExport,
        fileName: suggested,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (!mounted || path == null) {
        return;
      }

      final file = File(path.endsWith('.pdf') ? path : '$path.pdf');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uiL10n.invoicesExported)),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uiL10n.invoicesExportFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<Uint8List?> _readLogoBytes(String? storedPath) async {
    if (storedPath == null || storedPath.trim().isEmpty) {
      return null;
    }
    final file = File(MediaStore.absolutePath(storedPath));
    if (!await file.exists()) {
      return null;
    }
    return file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isNew = widget.invoice == null;
    final busy = _saving || _deleting || _loading || _exporting;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormEditorLayout(
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            isNew ? l10n.invoicesEditorNew : widget.invoice!.number,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isNew
                ? l10n.invoicesEditorCreateHint
                : l10n.invoicesEditorViewHint,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FieldGrid(
            children: [
              TextField(
                controller: _number,
                decoration: InputDecoration(
                  labelText: l10n.invoicesFieldNumber,
                ),
              ),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.invoicesFieldIssued,
                ),
                child: InkWell(
                  onTap: busy ? null : _pickIssuedOn,
                  child: Padding(
                    padding: const .symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_issuedOn))),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionClient,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(l10n.invoicesSectionClientBody),
                const SizedBox(height: 12),
                StreamBuilder<List<Client>>(
                  stream: _clientsStream,
                  builder: (context, snapshot) {
                    final clients = snapshot.data ?? const <Client>[];
                    if (clients.isEmpty) {
                      return Text(l10n.invoicesNoClients);
                    }

                    final validIds = clients.map((c) => c.id).toSet();
                    final value =
                        _clientId != null && validIds.contains(_clientId)
                            ? _clientId
                            : null;

                    return DropdownButtonFormField<int>(
                      initialValue: value,
                      decoration: InputDecoration(
                        labelText: l10n.invoicesSectionClient,
                      ),
                      items: [
                        for (final client in clients)
                          DropdownMenuItem(
                            value: client.id,
                            child: Text(
                              client.name.isEmpty
                                  ? l10n.clientsEditorNew
                                  : client.name,
                            ),
                          ),
                      ],
                      onChanged: busy
                          ? null
                          : (id) => setState(() => _clientId = id),
                      hint: Text(l10n.invoicesClientPlaceholder),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionJobs,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(l10n.invoicesSectionJobsBody),
                const SizedBox(height: 12),
                for (var i = 0; i < _lines.length; i++) ...[
                  if (i > 0) const Divider(height: 24),
                  _JobLineRow(
                    line: _lines[i],
                    canRemove: _lines.length > 1 && !busy,
                    onChanged: () => setState(() {}),
                    onRemove: () => _removeLine(i),
                    descriptionLabel: l10n.invoicesFieldDescription,
                    quantityLabel: l10n.invoicesFieldQuantity,
                    unitPriceLabel: l10n.invoicesFieldUnitPrice,
                    removeLabel: l10n.invoicesRemoveJobLine,
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: busy ? null : _addLine,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.invoicesAddJobLine),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: .centerRight,
                  child: Text(
                    '${l10n.invoicesFieldTotal}: ${widget.currency.formatUi(_total)}',
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: l10n.invoicesSectionHistory,
            child: Text(l10n.invoicesSectionHistoryBody),
          ),
        ],
      ),
      actions: Row(
        children: [
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(l10n.invoicesSave),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: busy || isNew ? null : _openExportDialog,
            child: Text(l10n.invoicesExport),
          ),
          if (!isNew) ...[
            const Spacer(),
            FilledButton(
              style: destructiveFilledStyle(scheme),
              onPressed: busy ? null : _delete,
              child: Text(l10n.invoicesDelete),
            ),
          ],
        ],
      ),
    );
  }
}

class _JobLineRow extends StatelessWidget {
  const _JobLineRow({
    required this.line,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    required this.descriptionLabel,
    required this.quantityLabel,
    required this.unitPriceLabel,
    required this.removeLabel,
  });

  final _JobLineDraft line;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final String descriptionLabel;
  final String quantityLabel;
  final String unitPriceLabel;
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        TextField(
          controller: line.description,
          decoration: InputDecoration(labelText: descriptionLabel),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: TextField(
                controller: line.quantity,
                decoration: InputDecoration(labelText: quantityLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: line.unitPrice,
                decoration: InputDecoration(labelText: unitPriceLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const .only(top: 8),
              child: IconButton(
                tooltip: removeLabel,
                onPressed: canRemove ? onRemove : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExportChoice {
  const _ExportChoice({
    required this.language,
    required this.template,
  });

  final String language;
  final String template;
}

class _ExportPdfDialog extends StatefulWidget {
  const _ExportPdfDialog({
    required this.localizations,
    required this.templates,
    required this.initialLanguage,
    required this.initialTemplate,
  });

  final LocalizationCatalog localizations;
  final InvoiceTemplateCatalog templates;
  final String initialLanguage;
  final String initialTemplate;

  @override
  State<_ExportPdfDialog> createState() => _ExportPdfDialogState();
}

class _ExportPdfDialogState extends State<_ExportPdfDialog> {
  late String _language = widget.initialLanguage;
  late String _template = widget.initialTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.invoicesExportDialogTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: .min,
          children: [
            SettingsDropdownMenu.onChanged(
              valueKey: 'export-language-$_language',
              initialSelection: _language,
              label: Text(l10n.invoicesExportLanguage),
              onChanged: (value) => setState(() => _language = value),
              entries: [
                for (final option in widget.localizations.localizations)
                  DropdownMenuEntry(
                    value: option.name,
                    label: option.name,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsDropdownMenu.onChanged(
              valueKey: 'export-template-$_template',
              initialSelection: _template,
              label: Text(l10n.invoicesExportTemplate),
              onChanged: (value) => setState(() => _template = value),
              entries: [
                for (final option in widget.templates.templates)
                  DropdownMenuEntry(
                    value: option.name,
                    label: option.name,
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.invoicesPreviewCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _ExportChoice(language: _language, template: _template),
            );
          },
          child: Text(l10n.invoicesExportConfirm),
        ),
      ],
    );
  }
}
