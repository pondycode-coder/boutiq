import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/product.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/entity_data_table.dart';
import '../../../core/theme/design_tokens.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    final products = HiveService.productsBox.values.toList();
    var filtered = products;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.productId.contains(query)).toList();
    }
    if (_categoryFilter != 'All') {
      filtered = filtered.where((p) => p.category == _categoryFilter).toList();
    }
    return filtered;
  }

  List<String> _getCategories() {
    final products = HiveService.productsBox.values.toList();
    final categories = products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<DataColumn> _getColumns() {
    return [
      buildColumn('Product'),
      buildColumn('Sale Price', numeric: true),
      buildColumn('Cost Price', numeric: true),
      buildColumn('Total Cost Value', numeric: true),
      buildColumn('Total Sales Value', numeric: true),
      buildColumn('Profit', numeric: true),
      buildColumn('Category'),
      buildColumn('Stock', numeric: true),
      buildColumn('Status'),
      buildColumn('Actions', numeric: false, sortable: false),
    ];
  }

  List<DataRow> _getRows() {
    final products = _getFilteredProducts();
    products.sort((a, b) => a.name.compareTo(b.name));
    return products.map((p) {
      final stockColor = p.stockQuantity <= 10 && p.stockQuantity > 0
          ? Colors.orange
          : p.stockQuantity == 0
              ? Colors.red
              : Colors.green;
      final totalCostValue = p.costPrice * p.stockQuantity;
      final totalSalesValue = p.price * p.stockQuantity;
      final profit = totalSalesValue - totalCostValue;
      return DataRow(
        cells: [
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (p.description != null && p.description!.isNotEmpty)
                  Text(
                    p.description!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          buildCurrencyCell(p.price, currency: 'XAF'),
          buildCurrencyCell(p.costPrice, currency: 'XAF'),
          buildCurrencyCell(totalCostValue, currency: 'XAF'),
          buildCurrencyCell(totalSalesValue, currency: 'XAF'),
          DataCell(
            Text(
              'XAF ${profit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: profit >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
          buildCell(p.category),
          DataCell(
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: stockColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.stockQuantity.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: stockColor,
                  ),
                ),
              ],
            ),
          ),
          buildStatusChip(p.isActive ? 'Active' : 'Inactive'),
          buildActionCell<Product>(
            context,
            p,
            _editProduct,
            _deleteProduct,
          ),
        ],
      );
    }).toList();
  }

  Future<void> _addProduct() async {
    final result = await _showProductDialog(context);
    if (result != null && context.mounted) {
      await HiveService.productsBox.add(result);
      unawaited(SyncService.pushProducts());
      ref.invalidate(productsProvider);
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await _showProductDialog(context, product: product);
    if (result != null && context.mounted) {
      final index = HiveService.productsBox.values
          .toList()
          .indexWhere((prod) => prod.productId == product.productId);
      if (index >= 0) {
        await HiveService.productsBox.putAt(index, result);
        unawaited(SyncService.pushProducts());
        ref.invalidate(productsProvider);
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final index = HiveService.productsBox.values
          .toList()
          .indexWhere((p) => p.productId == product.productId);
      if (index >= 0) {
        await HiveService.productsBox.deleteAt(index);
        unawaited(SyncService.pushProducts());
        ref.invalidate(productsProvider);
      }
    }
  }

  Future<Product?> _showProductDialog(BuildContext context,
      {Product? product}) async {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final categoryController =
        TextEditingController(text: product?.category ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final costPriceController =
        TextEditingController(text: product?.costPrice.toString() ?? '');
    final unitController = TextEditingController(text: product?.unit ?? '');
    final stockController =
        TextEditingController(text: product?.stockQuantity.toString() ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    bool isActive = product?.isActive ?? true;

    return showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category *'),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Sale Price (XAF) *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingMd),
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(labelText: 'Cost Price (XAF)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit *'),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingMd),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stock *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (v) => isActive = v ?? true,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final category = categoryController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final costPrice = double.tryParse(costPriceController.text) ?? 0;
              final unit = unitController.text.trim();
              final stock = int.tryParse(stockController.text) ?? 0;
              final description = descriptionController.text.trim();

              if (name.isEmpty || category.isEmpty || unit.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              Navigator.pop(context, Product()
                ..productId = product?.productId ?? IdGenerator.generate()
                ..name = name
                ..category = category
                ..price = price
                ..costPrice = costPrice
                ..unit = unit
                ..stockQuantity = stock
                ..description = description.isEmpty ? null : description
                ..isActive = isActive
                ..vendorId = product?.vendorId ?? ''
                ..createdAt = product?.createdAt ?? DateTime.now()
                ..updatedAt = DateTime.now());
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DesignTokens.spacingMd),
            child: DropdownButton<String>(
              value: _categoryFilter,
              underline: const SizedBox(),
              items: categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat, style: GoogleFonts.inter(fontSize: 13)),
              )).toList(),
              onChanged: (value) => setState(() => _categoryFilter = value ?? 'All'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: EntityDataTable<Product>(
        columns: _getColumns(),
        getRows: _getRows,
        onEdit: _editProduct,
        onDelete: _deleteProduct,
        onAdd: _addProduct,
        addLabel: 'Add Product',
        emptyMessage: 'No products found',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return HiveService.productsBox.values.toList();
});