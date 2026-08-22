import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/order.dart';
import '../../../core/database/models/user.dart';

class SalespersonReport {
  SalespersonReport({
    required this.salesperson,
    required this.orderCount,
    required this.totalSales,
    required this.totalVat,
    required this.cashReceived,
  });

  final User salesperson;
  final int orderCount;
  final double totalSales;
  final double totalVat;
  final double cashReceived;
}

class DailySalesReport {
  DailySalesReport({required this.orders, required this.payments});

  final List<Order> orders;
  final double payments;

  double get totalSales =>
      orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  double get totalVat => orders.fold(0.0, (sum, o) => sum + o.vatAmount);

  int get orderCount => orders.length;

  List<SalespersonReport> bySalesperson() {
    final users = HiveService.usersBox.values.toList();
    final byUser = <String, List<Order>>{};
    for (final order in orders) {
      final key = order.salespersonId ?? 'unknown';
      byUser.putIfAbsent(key, () => []).add(order);
    }
    return byUser.entries.map((entry) {
      final matching = users.where((u) => u.userId == entry.key).toList();
      final user = matching.isNotEmpty ? matching.first : null;
      final userOrders = entry.value;
      final total = userOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
      final vat = userOrders.fold(0.0, (sum, o) => sum + o.vatAmount);
      final cash = userOrders.fold(
          0.0,
          (sum, o) =>
              sum +
              (o.paymentMethod == 'cash' ? o.totalAmount : 0));
      return SalespersonReport(
        salesperson: user ??
            User()
              ..userId = entry.key
              ..name = entry.key == 'unknown' ? 'Unassigned' : entry.key
              ..phone = ''
              ..pin = ''
              ..role = 'salesperson'
              ..isActive = true
              ..createdAt = DateTime(2000)
              ..updatedAt = DateTime(2000),
        orderCount: userOrders.length,
        totalSales: total,
        totalVat: vat,
        cashReceived: cash,
      );
    }).toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));
  }
}

final dailySalesReportProvider = FutureProvider<DailySalesReport>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final orders = HiveService.ordersBox.values
      .where((o) =>
          o.status != 'cancelled' &&
          !o.createdAt.isBefore(startOfDay) &&
          o.createdAt.isBefore(endOfDay))
      .toList();

  final payments = HiveService.cashPaymentsBox.values
      .where((p) =>
          !p.paidAt.isBefore(startOfDay) && p.paidAt.isBefore(endOfDay))
      .fold(0.0, (sum, p) => sum + (p.amountTendered - p.changeAmount));

  return DailySalesReport(orders: orders, payments: payments);
});