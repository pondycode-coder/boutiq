import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/product.dart';
import '../../../core/sync/sync_service.dart';

final productsNotifierProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return HiveService.productsBox.values.toList();
  }

  Future<void> refresh() async {
    state = AsyncData(HiveService.productsBox.values.toList());
  }

  Future<void> saveProduct(Product product) async {
    final box = HiveService.productsBox;
    final index =
        box.values.toList().indexWhere((p) => p.productId == product.productId);
    product.updatedAt = DateTime.now();
    if (index >= 0) {
      box.putAt(index, product);
    } else {
      await box.add(product);
    }
    state = AsyncData(HiveService.productsBox.values.toList());
    unawaited(SyncService.pushProducts());
  }

  Future<void> deleteProduct(String productId) async {
    final box = HiveService.productsBox;
    final index =
        box.values.toList().indexWhere((p) => p.productId == productId);
    if (index >= 0) {
      box.deleteAt(index);
    }
    state = AsyncData(HiveService.productsBox.values.toList());
    unawaited(SyncService.pushProducts());
  }
}