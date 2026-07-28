import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:invoices/data/app_database.dart';
import 'package:invoices/data/invoice_number_format.dart';
import 'package:invoices/data/logo_draft.dart';
import 'package:invoices/data/logo_save.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/widgets/page_chrome.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key, required this.database});

  final AppDatabase database;

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  static const _logoCategory = 'company';

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _taxId = TextEditingController();
  final _address = TextEditingController();
  final _payment = TextEditingController();
  final _notes = TextEditingController();
  final _invoiceNumberFormat = TextEditingController();
  final _lastInvoiceSequence = TextEditingController();
  final _logo = LogoDraft(category: _logoCategory);

  var _loading = true;
  var _saving = false;
  var _importing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    unawaited(_logo.discardStaging());
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _taxId.dispose();
    _address.dispose();
    _payment.dispose();
    _notes.dispose();
    _invoiceNumberFormat.dispose();
    _lastInvoiceSequence.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final company = await widget.database.getCompany();
      if (!mounted) {
        return;
      }
      _name.text = company.name;
      _email.text = company.email;
      _phone.text = company.phone;
      _taxId.text = company.taxId;
      _address.text = company.address;
      _payment.text = company.paymentDetails;
      _notes.text = company.notes;
      _invoiceNumberFormat.text = resolveInvoiceNumberFormat(
        company.invoiceNumberFormat,
      );
      final lastSequence = lastInvoiceSequenceForYear(
        lastSequence: company.lastInvoiceSequence,
        lastSequenceYear: company.lastInvoiceSequenceYear,
        year: DateTime.now().year,
      );
      _lastInvoiceSequence.text =
          lastSequence > 0 ? lastSequence.toString() : '';
      _logo.resetFromStored(company.logoPath);
      await _logo.discardStaging();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).companyLoadFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickLogo() async {
    setState(() => _importing = true);
    try {
      final picked = await _logo.pick();
      if (!picked || !mounted) {
        return;
      }
      setState(() {});
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).logoImportFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _removeLogo() async {
    await _logo.clear();
    setState(() {});
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final lastSequence =
        int.tryParse(_lastInvoiceSequence.text.trim()) ?? 0;
    try {
      final outcome = await LogoSave.run<void>(
        category: _logo.category,
        previousLogo: _logo.storedPath,
        cleared: _logo.cleared,
        hasStaged: _logo.hasStaged,
        persist: (nextLogo) async {
          await widget.database.saveCompany(
            CompanyProfilesCompanion(
              name: Value(_name.text.trim()),
              email: Value(_email.text.trim()),
              phone: Value(_phone.text.trim()),
              taxId: Value(_taxId.text.trim()),
              address: Value(_address.text.trim()),
              paymentDetails: Value(_payment.text.trim()),
              notes: Value(_notes.text.trim()),
              invoiceNumberFormat: Value(
                resolveInvoiceNumberFormat(_invoiceNumberFormat.text),
              ),
              lastInvoiceSequence: Value(lastSequence),
              lastInvoiceSequenceYear: Value(DateTime.now().year),
              logoPath: Value(nextLogo),
            ),
          );
        },
      );

      if (!mounted) {
        return;
      }
      setState(() => _logo.acceptSaved(outcome.nextLogo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.companySaved)),
      );
    } on FormatException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logoImportFailed)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.companySaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final previewPath = _logo.previewPath;
    final busy = _saving || _importing;

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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(l10n.companyProfile,
                            style: textTheme.headlineMedium),
                        const SizedBox(height: 6),
                        Text(l10n.companyHint, style: textTheme.bodyMedium),
                        const SizedBox(height: 24),
                        LogoUploadTile(
                          title: l10n.companyLogoTitle,
                          subtitle: l10n.companyLogoSubtitle,
                          icon: Icons.apartment_outlined,
                          size: 72,
                          imagePath: previewPath,
                          uploadLabel: l10n.logoUpload,
                          removeLabel: l10n.logoRemove,
                          onUpload: busy ? null : _pickLogo,
                          onRemove: (busy || previewPath == null)
                              ? null
                              : _removeLogo,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FieldGrid(
                          children: [
                            TextField(
                              controller: _email,
                              decoration: InputDecoration(
                                labelText: l10n.companyFieldEmail,
                              ),
                            ),
                            TextField(
                              controller: _phone,
                              decoration: InputDecoration(
                                labelText: l10n.companyFieldPhone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _taxId,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldTax,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _address,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldAddress,
                          ),
                          minLines: 3,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _payment,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldPayment,
                          ),
                          minLines: 3,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notes,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldNotes,
                          ),
                          minLines: 2,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _invoiceNumberFormat,
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldInvoiceNumberFormat,
                            helperText:
                                l10n.companyFieldInvoiceNumberFormatHint,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lastInvoiceSequence,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.companyFieldLastInvoiceNumber,
                            helperText:
                                l10n.companyFieldLastInvoiceNumberHint,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: busy ? null : _save,
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
