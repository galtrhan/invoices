import 'package:flutter/material.dart';

import 'package:invoices/widgets/master_detail.dart';
import 'package:invoices/widgets/page_chrome.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  _Detail _detail = const _Detail.empty();
  final List<_ClientDraft> _clients = [];

  void _startCreate() => setState(() => _detail = const _Detail.create());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PageToolbar(
          title: 'Clients',
          subtitle: 'Invoice parties with contact details and logo',
          actions: [
            FilledButton.icon(
              onPressed: _startCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New client'),
            ),
          ],
        ),
        Expanded(
          child: MasterDetail(
            master: _ClientList(
              clients: _clients,
              selectedId: switch (_detail) {
                _Selected(:final client) => client.id,
                _ => null,
              },
              onSelect: (client) {
                setState(() => _detail = _Detail.selected(client));
              },
              onCreate: _startCreate,
            ),
            detail: switch (_detail) {
              _Create() => const _ClientEditor.create(),
              _Selected(:final client) => _ClientEditor.view(client),
              _Empty() => EmptyPane(
                title: 'No client selected',
                message:
                    'Clients supply the bill-to block on invoices. Edits are versioned so past invoices keep historical details.',
                actionLabel: 'New client',
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
  const factory _Detail.selected(_ClientDraft client) = _Selected;
}

final class _Empty extends _Detail {
  const _Empty();
}

final class _Create extends _Detail {
  const _Create();
}

final class _Selected extends _Detail {
  const _Selected(this.client);
  final _ClientDraft client;
}

class _ClientDraft {
  const _ClientDraft({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}

class _ClientList extends StatelessWidget {
  const _ClientList({
    required this.clients,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
  });

  final List<_ClientDraft> clients;
  final String? selectedId;
  final ValueChanged<_ClientDraft> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return EmptyPane(
        title: 'No clients yet',
        message: 'Add the businesses or people you invoice.',
        actionLabel: 'New client',
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
          title: Text(client.name),
          subtitle: Text(client.email),
          onTap: () => onSelect(client),
        );
      },
    );
  }
}

class _ClientEditor extends StatelessWidget {
  const _ClientEditor.create() : client = null;
  const _ClientEditor.view(this.client);

  final _ClientDraft? client;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNew = client == null;

    return FormPageBody(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            isNew ? 'New client' : client!.name,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Changes are kept historically so regenerating an old invoice can use the details from that time.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const FieldGrid(
            children: [
              TextField(decoration: InputDecoration(labelText: 'Name')),
              TextField(decoration: InputDecoration(labelText: 'Email')),
              TextField(decoration: InputDecoration(labelText: 'Phone')),
              TextField(decoration: InputDecoration(labelText: 'Tax / VAT ID')),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Address'),
            minLines: 3,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Contact notes'),
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const LogoUploadTile(
            title: 'Logo',
            subtitle: 'Used on invoices for this client when relevant.',
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton(
                onPressed: () {},
                child: Text(isNew ? 'Create client' : 'Save changes'),
              ),
              const SizedBox(width: 8),
              if (!isNew)
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('View history'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
