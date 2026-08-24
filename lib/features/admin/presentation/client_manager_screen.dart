import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/client.dart';
import '../../../core/localization/app_localizations.dart';
import '../application/admin_provider.dart';

class ClientManagerScreen extends ConsumerWidget {
  const ClientManagerScreen({super.key});

  Future<void> _addClient(BuildContext context, WidgetRef ref) async {
    final result = await _showClientDialog(context);
    if (result != null) {
      await ref.read(clientsNotifierProvider.notifier).addClient(
            name: result.$1,
            phone: result.$2,
            clientType: result.$3,
            region: result.$4,
            division: result.$5,
            address: result.$6,
          );
    }
  }

  Future<void> _editClient(BuildContext context, WidgetRef ref, Client client) async {
    final result = await _showClientDialog(context, client: client);
    if (result == null) return;
    final box = HiveService.clientsBox;
    final index =
        box.values.toList().indexWhere((c) => c.clientId == client.clientId);
    if (index < 0) return;
    final stored = box.getAt(index);
    if (stored == null) return;
    stored
      ..name = result.$1
      ..nameFr = result.$1
      ..phone = result.$2
      ..clientType = result.$3
      ..region = result.$4
      ..division = result.$5
      ..address = result.$6
      ..updatedAt = DateTime.now();
    box.putAt(index, stored);
    ref.invalidate(clientsNotifierProvider);
  }

  Future<(String, String, String, String, String, String)?> _showClientDialog(
    BuildContext context, {
    Client? client,
  }) async {
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');
    final divisionController = TextEditingController(text: client?.division ?? '');
    final regionController = TextEditingController(text: client?.region ?? '');

    final result = await showDialog<(String, String, String, String, String, String)>(
      context: context,
      builder: (context) {
        var clientType = client?.clientType ?? 'retailer';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(client == null ? AppLocalizations.of(context)!.addClient : AppLocalizations.of(context)!.editClient),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameField),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneField),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: clientType,
                    decoration: const InputDecoration(labelText: 'Client type'),
                    items: CameroonConfig.clientTypes.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => clientType = value ?? 'retailer'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: regionController,
                    decoration: const InputDecoration(labelText: 'Region'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: divisionController,
                    decoration: const InputDecoration(labelText: 'Division'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  Navigator.pop(
                    context,
                    (
                      nameController.text.trim(),
                      phoneController.text.trim(),
                      clientType,
                      regionController.text.trim(),
                      divisionController.text.trim(),
                      addressController.text.trim(),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    divisionController.dispose();
    regionController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsState = ref.watch(clientsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.clients)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addClient(context, ref),
        icon: const Icon(Icons.person_add),
        label: Text(AppLocalizations.of(context)!.add),
      ),
      body: clientsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (clients) => clients.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noClientsTap))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${client.phone}  |  ${CameroonConfig.clientTypes[client.clientType] ?? client.clientType}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!.deleteClientQuestion),
                            content: Text(AppLocalizations.of(context)!.areYouSureDelete(client.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(AppLocalizations.of(context)!.delete),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(clientsNotifierProvider.notifier)
                              .deleteClient(client.clientId);
                        }
                      },
                    ),
                    onTap: () => _editClient(context, ref, client),
                  );
                },
              ),
      ),
    );
  }
}