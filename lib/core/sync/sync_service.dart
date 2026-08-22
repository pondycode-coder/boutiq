import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/hive_service.dart';
import '../database/models/cash_payment.dart';
import '../database/models/client.dart';
import '../database/models/order.dart';
import '../database/models/product.dart';
import '../database/models/user.dart';
import '../database/supabase_service.dart';
import 'sync_status.dart';

class SyncService {
  static bool _syncing = false;

  static Future<void> syncAll() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await pushAll();
      await pullCatalog();
      await pullOrders();
    } finally {
      _syncing = false;
    }
  }

  static Future<void> pushAll() async {
    if (!SupabaseService.isAvailable) {
      updateSyncStatus(const SyncStatus(
        message: 'Not connected',
        ok: false,
      ));
      return;
    }
    updateSyncStatus(const SyncStatus(message: 'Syncing…', syncing: true));
    try {
      final results = await Future.wait([
        pushProducts(),
        pushClients(),
        pushUsers(),
        pushOrders(),
      ]);
      final ok = results.every((r) => r);
      debugPrint('[sync] pushAll -> $results');
      updateSyncStatus(SyncStatus(
        message: ok ? 'Synced OK' : 'Sync incomplete',
        ok: ok,
      ));
    } catch (e) {
      debugPrint('[sync] pushAll FAILED: $e');
      updateSyncStatus(SyncStatus(message: 'Sync failed: $e', ok: false));
    }
  }

  static Future<bool> pushProducts() async {
    if (!SupabaseService.isAvailable) return false;
    final products = HiveService.productsBox.values.toList();
    if (products.isEmpty) return true;
    final rows = products.map(_productRow).toList();
    try {
      await SupabaseService.client.from('products').upsert(rows,
          onConflict: 'id');
      debugPrint('[sync] pushed ${rows.length} products');
      return true;
    } catch (e) {
      debugPrint('[sync] pushProducts FAILED: $e');
      return false;
    }
  }

  static Future<bool> pushClients() async {
    if (!SupabaseService.isAvailable) return false;
    final clients = HiveService.clientsBox.values.toList();
    if (clients.isEmpty) return true;
    final rows = clients.map(_clientRow).toList();
    try {
      await SupabaseService.client.from('clients').upsert(rows,
          onConflict: 'id');
      debugPrint('[sync] pushed ${rows.length} clients');
      return true;
    } catch (e) {
      debugPrint('[sync] pushClients FAILED: $e');
      return false;
    }
  }

  static Future<bool> pushUsers() async {
    if (!SupabaseService.isAvailable) return false;
    final users = HiveService.usersBox.values.toList();
    if (users.isEmpty) return true;
    final rows = users.map(_userRow).toList();
    try {
      await SupabaseService.client.from('users').upsert(rows,
          onConflict: 'id');
      debugPrint('[sync] pushed ${rows.length} users');
      return true;
    } catch (e) {
      debugPrint('[sync] pushUsers FAILED: $e');
      return false;
    }
  }

  static Future<bool> pushOrders() async {
    if (!SupabaseService.isAvailable) return false;
    final orders = HiveService.ordersBox.values.toList();
    final items = HiveService.orderItemsBox.values.toList();
    final payments = HiveService.cashPaymentsBox.values.toList();
    try {
      if (orders.isNotEmpty) {
        await SupabaseService.client
            .from('orders')
            .upsert(orders.map(_orderRow).toList(), onConflict: 'id');
      }
      if (items.isNotEmpty) {
        await SupabaseService.client
            .from('order_items')
            .upsert(items.map(_orderItemRow).toList(), onConflict: 'id');
      }
      if (payments.isNotEmpty) {
        await SupabaseService.client
            .from('cash_payments')
            .upsert(payments.map(_paymentRow).toList(), onConflict: 'id');
      }
      debugPrint(
          '[sync] pushed orders=${orders.length} items=${items.length} payments=${payments.length}');
      return true;
    } catch (e) {
      debugPrint('[sync] pushOrders FAILED: $e');
      return false;
    }
  }

  static Future<void> pullCatalog() async {
    if (!SupabaseService.isAvailable) {
      updateSyncStatus(const SyncStatus(message: 'Not connected', ok: false));
      return;
    }
    try {
      final products = await SupabaseService.client
          .from('products')
          .select()
          .limit(1000);
      final clients = await SupabaseService.client
          .from('clients')
          .select()
          .limit(1000);

      final productsBox = HiveService.productsBox;
      for (final row in products) {
        final id = row['id'] as String?;
        if (id == null) continue;
        final existingIndex = productsBox.values
            .toList()
            .indexWhere((p) => p.productId == id);
        if (existingIndex >= 0) continue;
        await productsBox.add(Product()
          ..productId = id
          ..name = (row['name'] as String?) ?? ''
          ..category = (row['category'] as String?) ?? ''
          ..price = (row['price'] as num?)?.toDouble() ?? 0
          ..costPrice = (row['cost_price'] as num?)?.toDouble() ?? 0
          ..unit = (row['unit'] as String?) ?? ''
          ..description = row['description'] as String?
          ..imageUrl = row['image_url'] as String?
          ..vendorId = ''
          ..stockQuantity = (row['stock_quantity'] as num?)?.toInt() ?? 0
          ..isActive = (row['is_active'] as bool?) ?? true
          ..createdAt =
              DateTime.tryParse((row['created_at'] as String?) ?? '') ??
                  DateTime.now()
          ..updatedAt =
              DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
                  DateTime.now());
      }

      final clientsBox = HiveService.clientsBox;
      for (final row in clients) {
        final id = row['id'] as String?;
        if (id == null) continue;
        final existingIndex =
            clientsBox.values.toList().indexWhere((c) => c.clientId == id);
        if (existingIndex >= 0) continue;
        await clientsBox.add(Client()
          ..clientId = id
          ..name = (row['name'] as String?) ?? ''
          ..nameFr = (row['name_fr'] as String?) ?? ''
          ..clientType = (row['client_type'] as String?) ?? ''
          ..region = (row['region'] as String?) ?? ''
          ..division = (row['division'] as String?) ?? ''
          ..subdivision = (row['subdivision'] as String?) ?? ''
          ..address = (row['address'] as String?) ?? ''
          ..phone = (row['phone'] as String?) ?? ''
          ..email = row['email'] as String?
          ..contactPerson = (row['contact_person'] as String?) ?? ''
          ..creditLimit = (row['credit_limit'] as num?)?.toDouble() ?? 0
          ..currentBalance = (row['current_balance'] as num?)?.toDouble() ?? 0
          ..paymentTermsDays = (row['payment_terms_days'] as num?)?.toInt() ?? 0
          ..preferredPaymentMethod =
              (row['preferred_payment_method'] as String?) ?? ''
          ..assignedRouteId = (row['assigned_route_id'] as String?) ?? ''
          ..isActive = (row['is_active'] as bool?) ?? true
          ..createdAt =
              DateTime.tryParse((row['created_at'] as String?) ?? '') ??
                  DateTime.now()
          ..updatedAt =
              DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
                  DateTime.now());
      }
      debugPrint(
          '[sync] pulled products=${products.length} clients=${clients.length}');
      updateSyncStatus(SyncStatus(
        message: 'Pulled catalog (${products.length} products, '
            '${clients.length} clients)',
        ok: true,
      ));
    } catch (e) {
      debugPrint('[sync] pullCatalog FAILED: $e');
      updateSyncStatus(SyncStatus(message: 'Pull failed: $e', ok: false));
    }
  }

  static Future<void> pullOrders() async {
    if (!SupabaseService.isAvailable) return;
    try {
      final orders = await SupabaseService.client
          .from('orders')
          .select()
          .limit(1000);
      final items = await SupabaseService.client
          .from('order_items')
          .select()
          .limit(1000);
      final payments = await SupabaseService.client
          .from('cash_payments')
          .select()
          .limit(1000);

      final ordersBox = HiveService.ordersBox;
      final existingOrders = ordersBox.values.map((o) => o.orderId).toSet();
      final itemsByOrder = <String, List<dynamic>>{};
      for (final item in items) {
        final oid = item['order_id'] as String?;
        if (oid == null) continue;
        itemsByOrder.putIfAbsent(oid, () => []).add(item);
      }

      for (final row in orders) {
        final id = row['id'] as String?;
        if (id == null || existingOrders.contains(id)) continue;
        final orderItems = itemsByOrder[id] ?? const [];
        final orderItemIds = orderItems
            .map((i) => (i['id'] as String?) ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        final itemsBox = HiveService.orderItemsBox;
        final existingItems = itemsBox.values.map((i) => i.orderItemId).toSet();
        for (final item in orderItems) {
          final iid = item['id'] as String?;
          if (iid == null || existingItems.contains(iid)) continue;
          await itemsBox.add(OrderItem()
            ..orderItemId = iid
            ..orderId = id
            ..productId = (item['product_id'] as String?) ?? ''
            ..vendorId = (item['vendor_id'] as String?) ?? ''
            ..quantity = (item['quantity'] as num?)?.toInt() ?? 0
            ..unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0
            ..vatRate = (item['vat_rate'] as num?)?.toDouble() ?? 0
            ..lineSubtotal = (item['line_subtotal'] as num?)?.toDouble() ?? 0
            ..lineVatAmount = (item['line_vat_amount'] as num?)?.toDouble() ?? 0
            ..lineTotal = (item['line_total'] as num?)?.toDouble() ?? 0);
        }

        await ordersBox.add(Order()
          ..orderId = id
          ..storeId = (row['store_id'] as String?) ?? ''
          ..vendorId = (row['vendor_id'] as String?) ?? ''
          ..status = (row['status'] as String?) ?? 'paid'
          ..createdAt =
              DateTime.tryParse((row['created_at'] as String?) ?? '') ??
                  DateTime.now()
          ..orderItemIds = orderItemIds
          ..paymentMethod = (row['payment_method'] as String?) ?? 'cash'
          ..paymentStatus = (row['payment_status'] as String?) ?? 'paid'
          ..subtotal = (row['subtotal'] as num?)?.toDouble() ?? 0
          ..vatAmount = (row['vat_amount'] as num?)?.toDouble() ?? 0
          ..totalAmount = (row['total_amount'] as num?)?.toDouble() ?? 0
          ..notes = row['notes'] as String?
          ..clientId = row['client_id'] as String?
          ..salespersonId = row['salesperson_id'] as String?
          ..cashPaymentId = row['cash_payment_id'] as String?
          ..confirmedAt = DateTime.tryParse((row['confirmed_at'] as String?) ?? ''));
      }

      final paymentsBox = HiveService.cashPaymentsBox;
      final existingPayments = paymentsBox.values.map((p) => p.paymentId).toSet();
      for (final row in payments) {
        final id = row['id'] as String?;
        if (id == null || existingPayments.contains(id)) continue;
        await paymentsBox.add(CashPayment()
          ..paymentId = id
          ..orderId = (row['order_id'] as String?) ?? ''
          ..storeId = (row['store_id'] as String?) ?? ''
          ..clientId = row['client_id'] as String?
          ..salespersonId = (row['salesperson_id'] as String?) ?? ''
          ..amountTendered = (row['amount_tendered'] as num?)?.toDouble() ?? 0
          ..changeAmount = (row['change_amount'] as num?)?.toDouble() ?? 0
          ..paidAt =
              DateTime.tryParse((row['paid_at'] as String?) ?? '') ??
                  DateTime.now()
          ..notes = row['notes'] as String?);
      }

      debugPrint(
          '[sync] pulled orders=${orders.length} items=${items.length} payments=${payments.length}');
    } catch (e) {
      debugPrint('[sync] pullOrders FAILED: $e');
    }
  }

  static Map<String, dynamic> _productRow(Product p) => {
        'id': p.productId,
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'cost_price': p.costPrice,
        'unit': p.unit,
        'description': p.description,
        'image_url': p.imageUrl,
        'stock_quantity': p.stockQuantity,
        'is_active': p.isActive,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> _clientRow(Client c) => {
        'id': c.clientId,
        'name': c.name,
        'name_fr': c.nameFr,
        'client_type': c.clientType,
        'region': c.region,
        'division': c.division,
        'subdivision': c.subdivision,
        'address': c.address,
        'phone': c.phone,
        'email': c.email,
        'contact_person': c.contactPerson,
        'credit_limit': c.creditLimit,
        'current_balance': c.currentBalance,
        'payment_terms_days': c.paymentTermsDays,
        'preferred_payment_method': c.preferredPaymentMethod,
        'assigned_route_id': c.assignedRouteId,
        'is_active': c.isActive,
        'created_at': c.createdAt.toIso8601String(),
        'updated_at': c.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> _userRow(User u) => {
        'id': u.userId,
        'name': u.name,
        'phone': u.phone,
        'email': u.email,
        'pin': u.pin,
        'role': u.role,
        'vendor_id': u.vendorId,
        'store_id': u.storeId,
        'is_active': u.isActive,
        'created_at': u.createdAt.toIso8601String(),
        'updated_at': u.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> _orderRow(Order o) => {
        'id': o.orderId,
        'store_id': o.storeId,
        'vendor_id': o.vendorId,
        'status': o.status,
        'payment_method': o.paymentMethod,
        'payment_status': o.paymentStatus,
        'subtotal': o.subtotal,
        'vat_amount': o.vatAmount,
        'total_amount': o.totalAmount,
        'notes': o.notes,
        'client_id': o.clientId,
        'salesperson_id': o.salespersonId,
        'cash_payment_id': o.cashPaymentId,
        'confirmed_at': o.confirmedAt?.toIso8601String(),
        'created_at': o.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _orderItemRow(OrderItem i) => {
        'id': i.orderItemId,
        'order_id': i.orderId,
        'product_id': i.productId,
        'vendor_id': i.vendorId,
        'quantity': i.quantity,
        'unit_price': i.unitPrice,
        'vat_rate': i.vatRate,
        'line_subtotal': i.lineSubtotal,
        'line_vat_amount': i.lineVatAmount,
        'line_total': i.lineTotal,
      };

  static Map<String, dynamic> _paymentRow(CashPayment p) => {
        'id': p.paymentId,
        'order_id': p.orderId,
        'store_id': p.storeId,
        'client_id': p.clientId,
        'salesperson_id': p.salespersonId,
        'amount_tendered': p.amountTendered,
        'change_amount': p.changeAmount,
        'paid_at': p.paidAt.toIso8601String(),
        'notes': p.notes,
      };
}