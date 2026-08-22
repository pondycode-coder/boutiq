import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/user.dart';
import '../application/admin_provider.dart';

class UserManagerScreen extends ConsumerWidget {
  const UserManagerScreen({super.key});

  Future<void> _addUser(BuildContext context, WidgetRef ref) async {
    final result = await _showUserDialog(context);
    if (result != null) {
      await ref.read(usersNotifierProvider.notifier).addUser(
            name: result.$1,
            phone: result.$2,
            pin: result.$3,
            role: result.$4,
          );
    }
  }

  Future<void> _editUser(BuildContext context, WidgetRef ref, User user) async {
    final result = await _showUserDialog(context, user: user);
    if (result != null) {
      await ref.read(usersNotifierProvider.notifier).updateUser(user, pin: result.$3);
    }
  }

  Future<(String, String, String, String)?> _showUserDialog(
    BuildContext context, {
    User? user,
  }) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final pinController = TextEditingController(text: user?.pin ?? '');

    final result = await showDialog<(String, String, String, String)>(
      context: context,
      builder: (context) {
        var role = user?.role ?? 'salesperson';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(user == null ? 'Add Salesperson' : 'Edit Salesperson'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(labelText: 'PIN (4 digits)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'salesperson', child: Text('Salesperson')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) => setState(() => role = value ?? 'salesperson'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      pinController.text.length != 4) {
                    return;
                  }
                  Navigator.pop(
                    context,
                    (
                      nameController.text.trim(),
                      phoneController.text.trim(),
                      pinController.text,
                      role,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    pinController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Salespersons')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addUser(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Add'),
      ),
      body: usersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) => users.isEmpty
            ? const Center(child: Text('No salespersons. Tap + to add.'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase()),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${user.role}  |  PIN: ${user.pin}  |  '
                      '${user.isActive ? 'active' : 'inactive'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            await _editUser(context, ref, user);
                          case 'toggle':
                            await ref
                                .read(usersNotifierProvider.notifier)
                                .toggleActive(user.userId);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit / Reset PIN')),
                        PopupMenuItem(value: 'toggle', child: Text('Activate/Deactivate')),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}