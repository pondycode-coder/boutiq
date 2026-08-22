import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/client.dart';
import '../../../core/database/models/product.dart';
import '../../auth/application/auth_provider.dart';
import '../../orders/application/order_provider.dart';
import '../application/cart_provider.dart';
import '../application/products_provider.dart';
import 'receipt_dialog.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  Client? _selectedClient;
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsNotifierProvider);
    final cart = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final user = ref.watch(authNotifierProvider);

    List<String> _getCategories(List<Product> products) {
      final categories = products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList();
      categories.sort();
      return ['All', ...categories];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Register'),
        actions: [
          if (user != null)
            Center(
              child: Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _categoryFilter = value),
            itemBuilder: (context) {
              final productList = productsAsync.valueOrNull ?? [];
              final categories = _getCategories(productList);
              return categories.map((cat) => PopupMenuItem(
                value: cat,
                child: Row(
                  children: [
                    if (_categoryFilter == cat) const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    Text(cat),
                  ],
                ),
              )).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category, size: 20),
                  const SizedBox(width: 4),
                  Text(_categoryFilter, style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              cartNotifier.clear();
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (list) {
                final filtered = _categoryFilter == 'All'
                    ? list
                    : list.where((p) => p.category == _categoryFilter).toList();
                return _ProductGrid(
                  products: filtered,
                  onAdd: (product) => cartNotifier.addItem(product),
                );
              },
            ),
          ),
          _CartPanel(
            cart: cart,
            selectedClient: _selectedClient,
            onPickClient: _pickClient,
            onCheckout: _checkout,
          ),
        ],
      ),
    );
  }

  Future<void> _pickClient() async {
    final clients = HiveService.clientsBox.values.toList();
    final client = await showModalBottomSheet<Client>(
      context: context,
      builder: (context) => _ClientPicker(clients: clients),
    );
    if (client != null) {
      setState(() => _selectedClient = client);
    }
  }

  Future<void> _checkout() async {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final cart = ref.read(cartNotifierProvider);
    final user = ref.read(authNotifierProvider);
    if (cart.isEmpty) {
      _showMessage('Cart is empty');
      return;
    }
    if (user == null) return;

    final total = cartNotifier.total;
    final paymentResult = await _showPaymentDialog(total);
    if (paymentResult == null) return;

    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final client = _selectedClient;
    final order = await orderNotifier.checkout(
      items: cart,
      storeId: user.storeId ?? '',
      salespersonId: user.userId,
      clientId: client?.clientId,
      amountTendered: paymentResult.amountTendered,
      paymentMethod: paymentResult.paymentMethod,
    );
    if (order != null) {
      cartNotifier.clear();
      setState(() => _selectedClient = null);
      await ref.read(productsNotifierProvider.notifier).refresh();
      String message;
      if (paymentResult.paymentMethod == 'credit') {
        message = 'Sale on credit recorded for ${client?.name ?? 'walk-in customer'}';
      } else {
        final change = paymentResult.amountTendered - order.totalAmount;
        message = 'Order completed. Change: ${CameroonConfig.formatCurrency(change < 0 ? 0 : change)}';
      }
      _showMessage(message);
      if (!mounted) return;
      await showReceiptDialog(
        context,
        order: order,
        items: orderNotifier.itemsForOrder(order.orderId),
        salesperson: user,
        payment: orderNotifier.paymentForOrder(order.orderId),
        client: client,
      );
    }
  }

  Future<_PaymentResult?> _showPaymentDialog(double total) async {
    final controller = TextEditingController();
    return showDialog<_PaymentResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total due: ${CameroonConfig.formatCurrency(total)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _PaymentMethodButton(
              icon: Icons.money,
              label: 'Cash Payment',
              subtitle: 'Enter amount received',
              onTap: () async {
                final amount = await _showCashInputDialog(total);
                if (amount != null && context.mounted) {
                  Navigator.pop(context, _PaymentResult(amountTendered: amount, paymentMethod: 'cash'));
                }
              },
            ),
            const SizedBox(height: 8),
            _PaymentMethodButton(
              icon: Icons.credit_card,
              label: 'Pay Later (Credit)',
              subtitle: 'Record as credit for client',
              onTap: () {
                if (_selectedClient == null) {
                  _showMessage('Please select a client for credit sales');
                  return;
                }
                Navigator.pop(context, _PaymentResult(amountTendered: total, paymentMethod: 'credit'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<double?> _showCashInputDialog(double total) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total due: ${CameroonConfig.formatCurrency(total)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount received (FCFA)',
                prefixText: 'FCFA ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              Navigator.pop(context, value);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onAdd});

  final List<Product> products;
  final void Function(Product) onAdd;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products. Add products first.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: InkWell(
            onTap: () => onAdd(product),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CameroonConfig.formatCurrency(product.price),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel({
    required this.cart,
    required this.selectedClient,
    required this.onPickClient,
    required this.onCheckout,
  });

  final List<CartItem> cart;
  final Client? selectedClient;
  final VoidCallback onPickClient;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final subtotal = notifier.subtotal;
    final vat = notifier.vatAmount;
    final total = notifier.total;

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onPickClient,
                      icon: const Icon(Icons.person_outline),
                      label: Text(
                        selectedClient == null
                            ? 'Walk-in customer'
                            : selectedClient!.name,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => notifier.clear(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              if (cart.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.product.name),
                        subtitle: Text(
                            '${item.quantity} x ${CameroonConfig.formatCurrency(item.product.price)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => notifier.decrement(
                                  item.product.productId),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => notifier.increment(
                                  item.product.productId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(CameroonConfig.formatCurrency(subtotal)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('VAT (19.25%)'),
                  Text(CameroonConfig.formatCurrency(vat)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    CameroonConfig.formatCurrency(total),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: cart.isEmpty ? null : onCheckout,
                child: const Text('Complete Sale'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentResult {
  const _PaymentResult({
    required this.amountTendered,
    required this.paymentMethod,
  });
  final double amountTendered;
  final String paymentMethod; // 'cash' or 'credit'
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _ClientPicker extends StatelessWidget {
  const _ClientPicker({required this.clients});

  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: clients.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No clients yet. Add clients in management.'),
            )
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.phone),
                  onTap: () => Navigator.pop(context, client),
                );
              },
            ),
    );
  }
}