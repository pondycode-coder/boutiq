// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 3;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product()
      ..productId = fields[0] as String
      ..name = fields[1] as String
      ..category = fields[2] as String
      ..price = fields[3] as double
      ..unit = fields[4] as String
      ..description = fields[5] as String?
      ..imageUrl = fields[6] as String?
      ..vendorId = fields[7] as String
      ..stockQuantity = fields[8] as int
      ..isActive = fields[9] as bool
      ..createdAt = fields[10] as DateTime
      ..updatedAt = fields[11] as DateTime
      ..costPrice = fields[12] == null ? 0.0 : fields[12] as double;
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.vendorId)
      ..writeByte(8)
      ..write(obj.stockQuantity)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.costPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
