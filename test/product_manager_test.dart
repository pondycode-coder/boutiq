import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sabc_distritrack/core/database/hive_service.dart';
import 'package:sabc_distritrack/core/utils/id_generator.dart';
import 'package:sabc_distritrack/core/database/models/product.dart';
import 'package:sabc_distritrack/features/admin/presentation/product_manager_screen.dart';
import 'package:sabc_distritrack/features/pos/application/products_provider.dart';

Future<Product> seedProduct(String name) async {
  final product = Product()
    ..productId = IdGenerator.generate()
    ..name = name
    ..category = 'Dairy'
    ..price = 1500
    ..unit = 'L'
    ..vendorId = ''
    ..stockQuantity = 20
    ..isActive = true
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();
  await HiveService.productsBox.add(product);
  return product;
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('product_test');
    await HiveService.initialize(directory: dir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  setUp(() async {
    await HiveService.productsBox.clear();
  });

  test('saveProduct persists and refreshes provider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(productsNotifierProvider.notifier);
    await notifier.saveProduct(await seedProduct('Milk'));

    expect(HiveService.productsBox.length, 1);
    final list = await container.read(productsNotifierProvider.future);
    expect(list.length, 1);
    expect(list.first.name, 'Milk');
  });

  testWidgets('product manager lists seeded products', (tester) async {
    await tester.runAsync(() async {
      await seedProduct('Milk');
      await seedProduct('Bread');
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProductManagerScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);
  });
}