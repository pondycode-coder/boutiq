import 'package:hive/hive.dart';

part 'cash_payment.g.dart';

@HiveType(typeId: 24)
class CashPayment extends HiveObject {
  @HiveField(0)
  late String paymentId;

  @HiveField(1)
  late String orderId;

  @HiveField(2)
  late String storeId;

  @HiveField(3)
  String? clientId;

  @HiveField(4)
  late String salespersonId;

  @HiveField(5)
  late double amountTendered;

  @HiveField(6)
  late double changeAmount;

  @HiveField(7)
  late DateTime paidAt;

  @HiveField(8)
  String? notes;
}