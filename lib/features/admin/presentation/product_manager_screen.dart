import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/product.dart';
import '../../../core/utils/id_generator.dart';
import '../../pos/application/products_provider.dart';

class ProductManagerScreen extends ConsumerWidget {
  const ProductManagerScreen({super.key});

  Future<void> _addProduct(BuildContext context, WidgetRef ref) async {
    final product = await showDialog<Product>(
      context: context,
      builder: (context) => _ProductFormDialog(
        title: 'Add Product',
        product: Product()
          ..productId = IdGenerator.generate()
          ..name = ''
          ..category = ''
          ..price = 0
          ..unit = ''
          ..vendorId = ''
          ..stockQuantity = 0
          ..isActive = true
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
      ),
    );
    if (product != null) {
      await ref.read(productsNotifierProvider.notifier).saveProduct(product);
    }
  }

  Future<void> _editProduct(
      BuildContext context, WidgetRef ref, Product product) async {
    final updated = await showDialog<Product>(
      context: context,
      builder: (context) => _ProductFormDialog(title: 'Edit Product', product: product),
    );
    if (updated != null) {
      await ref.read(productsNotifierProvider.notifier).saveProduct(updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProduct(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products. Tap + to add.'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: product.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.shopping_bag),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${CameroonConfig.formatCurrency(product.price)}  |  '
                      'Stock: ${product.stockQuantity}  |  ${product.category}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            await _editProduct(context, ref, product);
                          case 'toggle':
                            final box = HiveService.productsBox;
                            final index = box.values.toList().indexWhere(
                                (p) => p.productId == product.productId);
                            if (index >= 0) {
                              final stored = box.getAt(index);
                              if (stored != null) {
                                stored.isActive = !stored.isActive;
                                box.putAt(index, stored);
                              }
                            }
                            await ref
                                .read(productsNotifierProvider.notifier)
                                .refresh();
                          case 'delete':
                            await ref
                                .read(productsNotifierProvider.notifier)
                                .deleteProduct(product.productId);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'toggle', child: Text('Activate/Deactivate')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({required this.title, required this.product});

  final String title;
  final Product product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _costPrice;
  late final TextEditingController _stock;
  late final TextEditingController _category;
  late final TextEditingController _unit;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product.name.isEmpty ? '' : widget.product.name);
    _price = TextEditingController(
        text: widget.product.price == 0 ? '' : widget.product.price.toString());
    _costPrice = TextEditingController(
        text: widget.product.costPrice == 0 ? '' : widget.product.costPrice.toString());
    _stock = TextEditingController(
        text: widget.product.stockQuantity == 0
            ? ''
            : widget.product.stockQuantity.toString());
    _category = TextEditingController(text: widget.product.category);
    _unit = TextEditingController(text: widget.product.unit);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _costPrice.dispose();
    _stock.dispose();
    _category.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Sale Price (FCFA)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _costPrice,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cost Price (FCFA)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock quantity'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
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
            final price = double.tryParse(_price.text.replaceAll(',', '.')) ?? 0;
            final costPrice = double.tryParse(_costPrice.text.replaceAll(',', '.')) ?? 0;
            final stock = int.tryParse(_stock.text) ?? 0;
            widget.product
              ..name = _name.text.trim()
              ..price = price
              ..costPrice = costPrice
              ..stockQuantity = stock
              ..category = _category.text.trim()
              ..unit = _unit.text.trim();
            Navigator.pop(context, widget.product);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}