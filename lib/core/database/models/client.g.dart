// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 21;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client()
      ..clientId = fields[0] as String
      ..name = fields[1] as String
      ..nameFr = fields[2] as String
      ..clientType = fields[3] as String
      ..region = fields[4] as String
      ..division = fields[5] as String
      ..subdivision = fields[6] as String
      ..address = fields[7] as String
      ..phone = fields[8] as String
      ..email = fields[9] as String?
      ..contactPerson = fields[10] as String
      ..creditLimit = fields[11] as double
      ..currentBalance = fields[12] as double
      ..paymentTermsDays = fields[13] as int
      ..preferredPaymentMethod = fields[14] as String
      ..assignedRouteId = fields[15] as String
      ..isActive = fields[16] as bool
      ..createdAt = fields[17] as DateTime
      ..updatedAt = fields[18] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.clientId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameFr)
      ..writeByte(3)
      ..write(obj.clientType)
      ..writeByte(4)
      ..write(obj.region)
      ..writeByte(5)
      ..write(obj.division)
      ..writeByte(6)
      ..write(obj.subdivision)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.email)
      ..writeByte(10)
      ..write(obj.contactPerson)
      ..writeByte(11)
      ..write(obj.creditLimit)
      ..writeByte(12)
      ..write(obj.currentBalance)
      ..writeByte(13)
      ..write(obj.paymentTermsDays)
      ..writeByte(14)
      ..write(obj.preferredPaymentMethod)
      ..writeByte(15)
      ..write(obj.assignedRouteId)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
