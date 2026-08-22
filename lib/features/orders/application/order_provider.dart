import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/cash_payment.dart';
import '../../../core/database/models/order.dart';
import '../../../core/database/models/product.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../pos/application/cart_provider.dart';

final orderNotifierProvider =
    AsyncNotifierProvider<OrderNotifier, List<Order>>(OrderNotifier.new);

class OrderNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    return HiveService.ordersBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Order?> checkout({
    required List<CartItem> items,
    required String storeId,
    required String salespersonId,
    String? clientId,
    required double amountTendered,
    String? notes,
    String paymentMethod = 'cash',
  }) async {
    if (items.isEmpty) return null;

    final orderId = IdGenerator.generate();
    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineSubtotal);
    final vatAmount = subtotal * CameroonConfig.vatRate;
    final total = subtotal + vatAmount;
    final change =
        (amountTendered - total).clamp(0.0, double.infinity).toDouble();

    final now = DateTime.now();
    final isCredit = paymentMethod == 'credit';

    final order = Order()
      ..orderId = orderId
      ..storeId = storeId
      ..vendorId = ''
      ..status = isCredit ? 'pending' : 'paid'
      ..createdAt = now
      ..orderItemIds = []
      ..paymentMethod = paymentMethod
      ..paymentStatus = isCredit ? 'pending' : 'paid'
      ..subtotal = subtotal
      ..vatAmount = vatAmount
      ..totalAmount = total
      ..notes = notes
      ..clientId = clientId
      ..salespersonId = salespersonId
      ..confirmedAt = now;

    final orderItemsBox = HiveService.orderItemsBox;
    final orderItemIds = <String>[];

    for (final item in items) {
      final lineSubtotal = item.lineSubtotal;
      final lineVat = item.lineVatAmount;
      final orderItem = OrderItem()
        ..orderItemId = IdGenerator.generate()
        ..orderId = orderId
        ..productId = item.product.productId
        ..vendorId = item.product.vendorId
        ..quantity = item.quantity
        ..unitPrice = item.product.price
        ..vatRate = CameroonConfig.vatRate
        ..lineSubtotal = lineSubtotal
        ..lineVatAmount = lineVat
        ..lineTotal = lineSubtotal + lineVat;
      await orderItemsBox.add(orderItem);
      orderItemIds.add(orderItem.orderItemId);
      _adjustStock(item.product, -item.quantity);
    }
    order.orderItemIds = orderItemIds;

    String? paymentId;
    if (!isCredit) {
      paymentId = IdGenerator.generate();
      final cashPayment = CashPayment()
        ..paymentId = paymentId
        ..orderId = orderId
        ..storeId = storeId
        ..clientId = clientId
        ..salespersonId = salespersonId
        ..amountTendered = amountTendered
        ..changeAmount = change
        ..paidAt = now
        ..notes = notes;
      await HiveService.cashPaymentsBox.add(cashPayment);
      order.cashPaymentId = paymentId;
    }

    await HiveService.ordersBox.add(order);

    unawaited(SyncService.pushOrders());
    unawaited(SyncService.pushProducts());
    ref.invalidateSelf();
    return order;
  }

  Future<void> voidOrder(String orderId) async {
    final box = HiveService.ordersBox;
    final index = box.values.toList().indexWhere((o) => o.orderId == orderId);
    if (index < 0) return;
    final order = box.getAt(index);
    if (order == null || order.status == 'cancelled') return;

    order.status = 'cancelled';
    order.paymentStatus = 'refunded';
    box.putAt(index, order);

    final items = HiveService.orderItemsBox.values
        .where((i) => i.orderId == orderId)
        .toList();
    for (final item in items) {
      _adjustStockByProductId(item.productId, item.quantity);
    }

    unawaited(SyncService.pushOrders());
    unawaited(SyncService.pushProducts());
    ref.invalidateSelf();
  }

  Order? orderById(String orderId) {
    final matches =
        HiveService.ordersBox.values.where((o) => o.orderId == orderId);
    return matches.isEmpty ? null : matches.first;
  }

  List<OrderItem> itemsForOrder(String orderId) {
    return HiveService.orderItemsBox.values
        .where((i) => i.orderId == orderId)
        .toList();
  }

  CashPayment? paymentForOrder(String orderId) {
    final matches = HiveService.cashPaymentsBox.values
        .where((p) => p.orderId == orderId);
    return matches.isEmpty ? null : matches.first;
  }

  void _adjustStock(Product product, int delta) {
    _adjustStockByProductId(product.productId, delta);
  }

  void _adjustStockByProductId(String productId, int delta) {
    final box = HiveService.productsBox;
    final index =
        box.values.toList().indexWhere((p) => p.productId == productId);
    if (index < 0) return;
    final stored = box.getAt(index);
    if (stored == null) return;
    final next = stored.stockQuantity + delta;
    stored.stockQuantity = next < 0 ? 0 : next;
    box.putAt(index, stored);
  }
}