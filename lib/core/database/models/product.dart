import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 3)
class Product extends HiveObject {
  @HiveField(0)
  late String productId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late double price;

  @HiveField(4)
  late String unit;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  late String vendorId;

  @HiveField(8)
  late int stockQuantity;

  @HiveField(9)
  late bool isActive;

  @HiveField(10)
  late DateTime createdAt;

  @HiveField(11)
  late DateTime updatedAt;

  @HiveField(12, defaultValue: 0.0)
  double costPrice = 0.0;
}
