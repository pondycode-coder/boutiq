// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 4;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order()
      ..orderId = fields[0] as String
      ..storeId = fields[1] as String
      ..vendorId = fields[2] as String
      ..status = fields[3] as String
      ..createdAt = fields[4] as DateTime
      ..orderItemIds = (fields[5] as List).cast<String>()
      ..paymentMethod = fields[6] as String
      ..paymentStatus = fields[7] as String
      ..subtotal = fields[8] as double
      ..vatAmount = fields[9] as double
      ..totalAmount = fields[10] as double
      ..notes = fields[11] as String?
      ..clientId = fields[12] as String?
      ..salespersonId = fields[13] as String?
      ..cashPaymentId = fields[14] as String?
      ..confirmedAt = fields[15] as DateTime?
      ..deliveredAt = fields[16] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.storeId)
      ..writeByte(2)
      ..write(obj.vendorId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.orderItemIds)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.paymentStatus)
      ..writeByte(8)
      ..write(obj.subtotal)
      ..writeByte(9)
      ..write(obj.vatAmount)
      ..writeByte(10)
      ..write(obj.totalAmount)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.clientId)
      ..writeByte(13)
      ..write(obj.salespersonId)
      ..writeByte(14)
      ..write(obj.cashPaymentId)
      ..writeByte(15)
      ..write(obj.confirmedAt)
      ..writeByte(16)
      ..write(obj.deliveredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 23;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem()
      ..orderItemId = fields[0] as String
      ..orderId = fields[1] as String
      ..productId = fields[2] as String
      ..vendorId = fields[3] as String
      ..quantity = fields[4] as int
      ..unitPrice = fields[5] as double
      ..vatRate = fields[6] as double
      ..lineSubtotal = fields[7] as double
      ..lineVatAmount = fields[8] as double
      ..lineTotal = fields[9] as double
      ..batchNumber = fields[10] as String?
      ..expiryDate = fields[11] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.orderItemId)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.vendorId)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unitPrice)
      ..writeByte(6)
      ..write(obj.vatRate)
      ..writeByte(7)
      ..write(obj.lineSubtotal)
      ..writeByte(8)
      ..write(obj.lineVatAmount)
      ..writeByte(9)
      ..write(obj.lineTotal)
      ..writeByte(10)
      ..write(obj.batchNumber)
      ..writeByte(11)
      ..write(obj.expiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
