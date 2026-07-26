import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:invoices/data/app_database.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/widgets/page_chrome.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key, required this.database});

  final AppDatabase database;

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _taxId = TextEditingController();
  final _address = TextEditingController();
  final _payment = TextEditingController();
  final _notes = TextEditingController();

  var _loading = true;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _taxId.dispose();
    _address.dispose();
    _payment.dispose();
    _notes.dispose();
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

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await widget.database.saveCompany(
        CompanyProfilesCompanion(
          name: Value(_name.text.trim()),
          email: Value(_email.text.trim()),
          phone: Value(_phone.text.trim()),
          taxId: Value(_taxId.text.trim()),
          address: Value(_address.text.trim()),
          paymentDetails: Value(_payment.text.trim()),
          notes: Value(_notes.text.trim()),
        ),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.companySaved)),
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
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: _saving ? null : _save,
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
