import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../auth/application/auth_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AuthNotifier.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Text('Restricted: Admin only'),
        ),
      );
    }
    final currentUser = ref.watch(authNotifierProvider);
    final productsCount = HiveService.productsBox.length;
    final usersCount = HiveService.usersBox.length;
    final clientsCount = HiveService.clientsBox.length;
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          if (currentUser != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(currentUser.name),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: syncStatus.ok
                    ? Colors.green
                    : syncStatus.syncing
                        ? Colors.amber
                        : Colors.grey,
                foregroundColor: Colors.white,
                child: syncStatus.syncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(syncStatus.ok ? Icons.cloud_done : Icons.cloud_off),
              ),
              title: const Text('Cloud sync',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(syncStatus.message),
              trailing: TextButton(
                onPressed: () async {
                  ref
                      .read(syncStatusProvider.notifier)
                      .set(const SyncStatus(message: 'Syncing…', syncing: true));
                  await SyncService.syncAll();
                },
                child: const Text('Sync now'),
              ),
            ),
          ),
          _AdminTile(
            icon: Icons.inventory_2,
            title: 'Products',
            subtitle: '$productsCount products',
            onTap: () => context.push('/admin/products'),
          ),
          _AdminTile(
            icon: Icons.group,
            title: 'Salespersons',
            subtitle: '$usersCount staff members',
            onTap: () => context.push('/admin/salespersons'),
          ),
          _AdminTile(
            icon: Icons.people,
            title: 'Clients',
            subtitle: '$clientsCount clients',
            onTap: () => context.push('/admin/clients'),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}