// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User()
      ..userId = fields[0] as String
      ..name = fields[1] as String
      ..phone = fields[2] as String
      ..email = fields[3] as String?
      ..pin = fields[4] as String
      ..role = fields[5] as String
      ..vendorId = fields[6] as String?
      ..storeId = fields[7] as String?
      ..isActive = fields[8] as bool
      ..createdAt = fields[9] as DateTime
      ..updatedAt = fields[10] as DateTime;
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.pin)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.vendorId)
      ..writeByte(7)
      ..write(obj.storeId)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
