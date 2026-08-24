import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/order.dart';
import '../../../core/database/models/user.dart';
import '../../auth/application/auth_provider.dart';
import '../../pos/presentation/receipt_dialog.dart';
import '../../../core/localization/app_localizations.dart';
import '../application/order_provider.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key, this.embedded = false});

  final bool embedded;

  Future<void> _voidOrder(BuildContext context, WidgetRef ref, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.voidOrder),
        content: Text(AppLocalizations.of(context)!.voidOrderContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.keep),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.voidLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(orderNotifierProvider.notifier).voidOrder(order.orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.orderVoided)));
      }
    }
  }

  Future<void> _showReceipt(BuildContext context, WidgetRef ref, Order order) async {
    final notifier = ref.read(orderNotifierProvider.notifier);
    final users = HiveService.usersBox.values.toList();
    final salesperson = order.salespersonId == null
        ? null
        : users.where((u) => u.userId == order.salespersonId).toList();
    final user = (salesperson != null && salesperson.isNotEmpty)
        ? salesperson.first
        : (User()
          ..userId = order.salespersonId ?? 'unknown'
          ..name = 'Unknown'
          ..phone = ''
          ..pin = ''
          ..role = 'salesperson'
          ..isActive = true
          ..createdAt = DateTime(2000)
          ..updatedAt = DateTime(2000));
    await showReceiptDialog(
      context,
      order: order,
      items: notifier.itemsForOrder(order.orderId),
      salesperson: user,
      payment: notifier.paymentForOrder(order.orderId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(orderNotifierProvider);
    final users = HiveService.usersBox.values.toList();
    final currentUser = AuthNotifier.currentUser;
    final isAdmin = AuthNotifier.isAdmin;

    final body = ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          final visible = isAdmin
              ? orders
              : orders.where((o) => o.salespersonId == currentUser?.userId).toList();
          return visible.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noOrdersYet))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final order = visible[index];
                    return _OrderCard(
                      order: order,
                      users: users,
                      canVoid: isAdmin,
                      onReceipt: () => _showReceipt(context, ref, order),
                      onVoid: () => _voidOrder(context, ref, order),
                    );
                  },
                );
        },
      );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.orders)),
      body: body,
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.users,
    required this.canVoid,
    required this.onReceipt,
    required this.onVoid,
  });

  final Order order;
  final List<dynamic> users;
  final bool canVoid;
  final VoidCallback onReceipt;
  final VoidCallback onVoid;

  String get _salespersonName {
    if (order.salespersonId == null) return '—';
    final matching = users
        .where((u) => (u as dynamic).userId == order.salespersonId)
        .toList();
    if (matching.isEmpty) return order.salespersonId!;
    return (matching.first as dynamic).name as String;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final voided = order.status == 'cancelled';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: voided
              ? Colors.grey
              : colorScheme.primary,
          foregroundColor: voided
              ? Colors.grey.shade200
              : colorScheme.onPrimary,
          child: const Icon(Icons.receipt_long),
        ),
        title: Text(
          '#${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: voided ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order.createdAt.toString().split(' ').first} '
              '${order.createdAt.toString().split(' ').last.split('.').first}',
            ),
            Text('${AppLocalizations.of(context)!.soldBy}: $_salespersonName'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CameroonConfig.formatCurrency(order.totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: voided ? TextDecoration.lineThrough : null,
              ),
            ),
            Chip(
              label: Text(voided ? AppLocalizations.of(context)!.voided : order.paymentStatus),
              visualDensity: VisualDensity.compact,
              backgroundColor: voided
                  ? Colors.grey.shade300
                  : order.paymentStatus == 'paid'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
            ),
          ],
        ),
        onTap: onReceipt,
        onLongPress: canVoid && !voided ? onVoid : null,
      ),
    );
  }
}