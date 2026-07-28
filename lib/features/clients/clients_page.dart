import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:invoices/data/app_database.dart';
import 'package:invoices/data/logo_draft.dart';
import 'package:invoices/data/logo_save.dart';
import 'package:invoices/data/media_store.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/pdf/invoice_template_catalog.dart';
import 'package:invoices/widgets/master_detail.dart';
import 'package:invoices/widgets/page_chrome.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({
    super.key,
    required this.database,
    required this.templates,
  });

  final AppDatabase database;
  final InvoiceTemplateCatalog templates;

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  _Detail _detail = const _Detail.empty();
  late Stream<List<Client>> _clientsStream = widget.database.watchClients();

  @override
  void didUpdateWidget(covariant ClientsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.database, widget.database)) {
      _clientsStream = widget.database.watchClients();
    }
  }

  void _startCreate() => setState(() => _detail = const _Detail.create());

  void _select(Client client) {
    setState(() => _detail = _Detail.selected(client.id));
  }

  void _onSaved(Client client) {
    setState(() => _detail = _Detail.selected(client.id));
  }

  void _onDeleted() {
    setState(() => _detail = const _Detail.empty());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: l10n.clientsTitle,
          subtitle: l10n.clientsSubtitle,
          actions: [
            FilledButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.clientsNew),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<Client>>(
            stream: _clientsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return EmptyPane(
                  title: l10n.clientsLoadFailed,
                  message: l10n.clientsLoadFailed,
                );
              }

              final clients = snapshot.data ?? const <Client>[];
              final selectedId = switch (_detail) {
                _Selected(:final id) => id,
                _ => null,
              };
              final selected = selectedId == null
                  ? null
                  : clients.where((c) => c.id == selectedId).firstOrNull;

              return MasterDetail(
                master: _ClientList(
                  clients: clients,
                  selectedId: selectedId,
                  onSelect: _select,
                  onCreate: _startCreate,
                ),
                detail: switch (_detail) {
                  _Create() => _ClientEditor(
                      key: const ValueKey('new'),
                      database: widget.database,
                      templates: widget.templates,
                      client: null,
                      onSaved: _onSaved,
                    ),
                  _Selected() when selected != null => _ClientEditor(
                      key: ValueKey(selected.id),
                      database: widget.database,
                      templates: widget.templates,
                      client: selected,
                      onSaved: _onSaved,
                      onDeleted: _onDeleted,
                    ),
                  _Selected() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  _Empty() => EmptyPane(
                      title: l10n.clientsNoneSelectedTitle,
                      message: l10n.clientsNoneSelectedMessage,
                      actionLabel: l10n.clientsNew,
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

class _ClientList extends StatelessWidget {
  const _ClientList({
    required this.clients,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
  });

  final List<Client> clients;
  final int? selectedId;
  final ValueChanged<Client> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (clients.isEmpty) {
      return EmptyPane(
        title: l10n.clientsEmptyTitle,
        message: l10n.clientsEmptyMessage,
        actionLabel: l10n.clientsNew,
        onAction: onCreate,
      );
    }

    return ListView.separated(
      itemCount: clients.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final client = clients[index];
        return ListTile(
          selected: client.id == selectedId,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            client.name.isEmpty ? l10n.clientsEditorNew : client.name,
          ),
          subtitle: Text(client.email),
          onTap: () => onSelect(client),
        );
      },
    );
  }
}

class _ClientEditor extends StatefulWidget {
  const _ClientEditor({
    super.key,
    required this.database,
    required this.templates,
    required this.client,
    required this.onSaved,
    this.onDeleted,
  });

  final AppDatabase database;
  final InvoiceTemplateCatalog templates;
  final Client? client;
  final ValueChanged<Client> onSaved;
  final VoidCallback? onDeleted;

  @override
  State<_ClientEditor> createState() => _ClientEditorState();
}

class _ClientEditorState extends State<_ClientEditor> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _taxId = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  late final LogoDraft _logo;

  /// Null means use Settings default.
  String? _pdfTemplate;

  var _saving = false;
  var _importing = false;
  var _deleting = false;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    final category = client == null
        ? MediaStore.newClientLogoCategory()
        : (MediaStore.categoryFromStoredPath(client.logoPath) ??
            MediaStore.clientLogoCategory(client.id));
    _logo = LogoDraft(category: category, storedPath: client?.logoPath);
    _applyClient(client);
    unawaited(_logo.discardStaging());
  }

  @override
  void dispose() {
    unawaited(_logo.discardStaging());
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _taxId.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _applyClient(Client? client) {
    _name.text = client?.name ?? '';
    _email.text = client?.email ?? '';
    _phone.text = client?.phone ?? '';
    _taxId.text = client?.taxId ?? '';
    _address.text = client?.address ?? '';
    _notes.text = client?.notes ?? '';
    final stored = client?.pdfTemplate?.trim();
    _pdfTemplate = (stored == null || stored.isEmpty)
        ? null
        : widget.templates.resolve(stored).name;
    _logo.resetFromStored(client?.logoPath);
  }

  ClientsCompanion _fields({required String? logoPath}) {
    return ClientsCompanion(
      name: Value(_name.text.trim()),
      email: Value(_email.text.trim()),
      phone: Value(_phone.text.trim()),
      taxId: Value(_taxId.text.trim()),
      address: Value(_address.text.trim()),
      notes: Value(_notes.text.trim()),
      pdfTemplate: Value(_pdfTemplate),
      logoPath: Value(logoPath),
    );
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
    final isNew = widget.client == null;
    try {
      final outcome = await LogoSave.run<Client>(
        category: _logo.category,
        previousLogo: _logo.storedPath,
        cleared: _logo.cleared,
        hasStaged: _logo.hasStaged,
        persist: (nextLogo) {
          return widget.database.saveClient(
            id: widget.client?.id,
            data: _fields(logoPath: nextLogo),
          );
        },
      );

      if (!mounted) {
        return;
      }
      setState(() => _logo.acceptSaved(outcome.nextLogo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? l10n.clientsCreated : l10n.clientsSaved),
        ),
      );
      widget.onSaved(outcome.value);
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
        SnackBar(content: Text(l10n.clientsSaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final client = widget.client;
    if (client == null || _deleting) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.clientsDeleteConfirmTitle),
          content: Text(l10n.clientsDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              style: destructiveFilledStyle(scheme),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.clientsDeleteConfirmAction),
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
      await widget.database.deleteClient(client.id);
      // Logo cleanup is best-effort after the row is gone.
      try {
        await MediaStore.deleteCategory(_logo.category);
      } catch (_) {}
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clientsDeleted)),
      );
      widget.onDeleted?.call();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clientsDeleteFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isNew = widget.client == null;
    final previewPath = _logo.previewPath;
    final busy = _saving || _importing || _deleting;
    final client = widget.client;
    final title = (client == null || client.name.isEmpty)
        ? l10n.clientsEditorNew
        : client.name;

    return FormEditorLayout(
      body: Column(
        crossAxisAlignment: .start,
        children: [
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(l10n.clientsEditorHint, style: textTheme.bodyMedium),
          const SizedBox(height: 24),
          FieldGrid(
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.clientsFieldName),
              ),
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.clientsFieldEmail),
              ),
              TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.clientsFieldPhone),
              ),
              TextField(
                controller: _taxId,
                decoration: InputDecoration(labelText: l10n.clientsFieldTax),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _address,
            decoration: InputDecoration(labelText: l10n.clientsFieldAddress),
            minLines: 3,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l10n.clientsFieldNotes),
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownMenu<String?>(
            key: ValueKey('client-pdf-template-$_pdfTemplate'),
            initialSelection: _pdfTemplate,
            label: Text(l10n.clientsFieldPdfTemplate),
            expandedInsets: .zero,
            enabled: !busy,
            onSelected: (value) => setState(() => _pdfTemplate = value),
            dropdownMenuEntries: [
              DropdownMenuEntry(
                value: null,
                label: l10n.clientsPdfTemplateDefault,
              ),
              for (final option in widget.templates.templates)
                DropdownMenuEntry(
                  value: option.name,
                  label: option.name,
                ),
            ],
          ),
          const SizedBox(height: 16),
          LogoUploadTile(
            title: l10n.clientsLogoTitle,
            subtitle: l10n.clientsLogoSubtitle,
            icon: Icons.image_outlined,
            imagePath: previewPath,
            uploadLabel: l10n.logoUpload,
            removeLabel: l10n.logoRemove,
            onUpload: busy ? null : _pickLogo,
            onRemove: (busy || previewPath == null) ? null : _removeLogo,
          ),
        ],
      ),
      actions: Row(
        children: [
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(isNew ? l10n.clientsCreate : l10n.clientsSave),
          ),
          if (!isNew) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: Text(l10n.clientsViewHistory),
            ),
            const Spacer(),
            FilledButton(
              style: destructiveFilledStyle(scheme),
              onPressed: busy ? null : _delete,
              child: Text(l10n.clientsDelete),
            ),
          ],
        ],
      ),
    );
  }
}
