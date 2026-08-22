import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sabc_distritrack/core/database/hive_service.dart';
import 'package:sabc_distritrack/core/database/models/product.dart';
import 'package:sabc_distritrack/core/database/models/user.dart';
import 'package:sabc_distritrack/core/utils/id_generator.dart';
import 'package:sabc_distritrack/features/orders/application/order_provider.dart';
import 'package:sabc_distritrack/features/pos/application/cart_provider.dart';

void main() {
  late String dirPath;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('pos_test');
    dirPath = dir.path;
    await HiveService.initialize(directory: dirPath);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  setUp(() async {
    await HiveService.productsBox.clear();
    await HiveService.usersBox.clear();
    await HiveService.ordersBox.clear();
    await HiveService.orderItemsBox.clear();
    await HiveService.cashPaymentsBox.clear();
  });

  Future<Product> seedProduct({int stock = 10, double price = 1000}) async {
    final product = Product()
      ..productId = IdGenerator.generate()
      ..name = 'Test Product'
      ..category = 'Grocery'
      ..price = price
      ..unit = 'unit'
      ..vendorId = 'v1'
      ..stockQuantity = stock
      ..isActive = true
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await HiveService.productsBox.add(product);
    return product;
  }

  Future<User> seedUser() async {
    final user = User()
      ..userId = IdGenerator.generate()
      ..name = 'Cashier'
      ..phone = ''
      ..pin = '1234'
      ..role = 'salesperson'
      ..isActive = true
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await HiveService.usersBox.add(user);
    return user;
  }

  test('cart totals include VAT', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final product = await seedProduct(price: 2000);
    final notifier = container.read(cartNotifierProvider.notifier);

    notifier.addItem(product, quantity: 2);

    expect(notifier.itemCount, 2);
    expect(notifier.subtotal, 4000);
    expect(notifier.vatAmount, closeTo(770, 0.001));
    expect(notifier.total, closeTo(4770, 0.001));
  });

  test('checkout creates order, payment and decrements stock', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final product = await seedProduct(stock: 10, price: 1000);
    final user = await seedUser();

    final cartNotifier = container.read(cartNotifierProvider.notifier);
    cartNotifier.addItem(product, quantity: 3);

    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final order = await orderNotifier.checkout(
      items: container.read(cartNotifierProvider),
      storeId: 'store1',
      salespersonId: user.userId,
      amountTendered: 4000,
    );

    expect(order, isNotNull);
    expect(order!.status, 'paid');
    expect(order.paymentMethod, 'cash');
    expect(order.salespersonId, user.userId);

    final storedOrder = HiveService.ordersBox.values.first;
    expect(storedOrder.orderId, order.orderId);
    expect(HiveService.ordersBox.length, 1);
    expect(HiveService.orderItemsBox.length, 1);
    expect(HiveService.cashPaymentsBox.length, 1);

    final payment = HiveService.cashPaymentsBox.values.first;
    expect(payment.amountTendered, 4000);
    expect(payment.changeAmount, closeTo(422.5, 0.001));

    final stored = HiveService.productsBox.values
        .firstWhere((p) => p.productId == product.productId);
    expect(stored.stockQuantity, 7);
  });

  test('voiding an order restores stock', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final product = await seedProduct(stock: 10, price: 1000);
    final user = await seedUser();

    final cartNotifier = container.read(cartNotifierProvider.notifier);
    cartNotifier.addItem(product, quantity: 4);

    final orderNotifier = container.read(orderNotifierProvider.notifier);
    final order = await orderNotifier.checkout(
      items: container.read(cartNotifierProvider),
      storeId: 'store1',
      salespersonId: user.userId,
      amountTendered: 5000,
    );
    expect(order, isNotNull);

    var stored = HiveService.productsBox.values
        .firstWhere((p) => p.productId == product.productId);
    expect(stored.stockQuantity, 6);

    await orderNotifier.voidOrder(order!.orderId);

    final voided = HiveService.ordersBox.values
        .firstWhere((o) => o.orderId == order.orderId);
    expect(voided.status, 'cancelled');
    expect(voided.paymentStatus, 'refunded');

    stored = HiveService.productsBox.values
        .firstWhere((p) => p.productId == product.productId);
    expect(stored.stockQuantity, 10);
  });
}