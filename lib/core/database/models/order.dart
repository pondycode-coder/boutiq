import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 4)
class Order extends HiveObject {
  @HiveField(0)
  late String orderId;

  @HiveField(1)
  late String storeId;

  @HiveField(2)
  late String vendorId;

  @HiveField(3)
  late String status;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late List<String> orderItemIds;

  @HiveField(6)
  late String paymentMethod;

  @HiveField(7)
  late String paymentStatus;

  @HiveField(8)
  late double subtotal;

  @HiveField(9)
  late double vatAmount;

  @HiveField(10)
  late double totalAmount;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  String? clientId;

  @HiveField(13)
  String? salespersonId;

  @HiveField(14)
  String? cashPaymentId;

  @HiveField(15)
  DateTime? confirmedAt;

  @HiveField(16)
  DateTime? deliveredAt;
}

@HiveType(typeId: 23)
class OrderItem extends HiveObject {
  @HiveField(0)
  late String orderItemId;

  @HiveField(1)
  late String orderId;

  @HiveField(2)
  late String productId;

  @HiveField(3)
  late String vendorId;

  @HiveField(4)
  late int quantity;

  @HiveField(5)
  late double unitPrice;

  @HiveField(6)
  late double vatRate;

  @HiveField(7)
  late double lineSubtotal;

  @HiveField(8)
  late double lineVatAmount;

  @HiveField(9)
  late double lineTotal;

  @HiveField(10)
  String? batchNumber;

  @HiveField(11)
  DateTime? expiryDate;
}
