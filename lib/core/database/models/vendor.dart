import 'package:hive/hive.dart';

part 'vendor.g.dart';

@HiveType(typeId: 1)
class Vendor extends HiveObject {
  @HiveField(0)
  late String vendorId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late String region;

  @HiveField(6)
  String? description;

  @HiveField(7)
  late bool isActive;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;
}
