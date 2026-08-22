import 'package:hive/hive.dart';

part 'store.g.dart';

@HiveType(typeId: 2)
class Store extends HiveObject {
  @HiveField(0)
  late String storeId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String address;

  @HiveField(3)
  late String phone;

  @HiveField(4)
  String? email;

  @HiveField(5)
  late String region;

  @HiveField(6)
  late String ownerId;

  @HiveField(7)
  late bool isActive;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;
}
