// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CashPaymentAdapter extends TypeAdapter<CashPayment> {
  @override
  final int typeId = 24;

  @override
  CashPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashPayment()
      ..paymentId = fields[0] as String
      ..orderId = fields[1] as String
      ..storeId = fields[2] as String
      ..clientId = fields[3] as String?
      ..salespersonId = fields[4] as String
      ..amountTendered = fields[5] as double
      ..changeAmount = fields[6] as double
      ..paidAt = fields[7] as DateTime
      ..notes = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, CashPayment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.paymentId)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.storeId)
      ..writeByte(3)
      ..write(obj.clientId)
      ..writeByte(4)
      ..write(obj.salespersonId)
      ..writeByte(5)
      ..write(obj.amountTendered)
      ..writeByte(6)
      ..write(obj.changeAmount)
      ..writeByte(7)
      ..write(obj.paidAt)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
