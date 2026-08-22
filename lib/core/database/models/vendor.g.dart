// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VendorAdapter extends TypeAdapter<Vendor> {
  @override
  final int typeId = 1;

  @override
  Vendor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vendor()
      ..vendorId = fields[0] as String
      ..name = fields[1] as String
      ..phone = fields[2] as String
      ..email = fields[3] as String?
      ..address = fields[4] as String
      ..region = fields[5] as String
      ..description = fields[6] as String?
      ..isActive = fields[7] as bool
      ..createdAt = fields[8] as DateTime
      ..updatedAt = fields[9] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Vendor obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.vendorId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.region)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
