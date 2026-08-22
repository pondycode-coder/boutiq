import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String userId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  late String pin;

  @HiveField(5)
  late String role;

  @HiveField(6)
  String? vendorId;

  @HiveField(7)
  String? storeId;

  @HiveField(8)
  late bool isActive;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  late DateTime updatedAt;
}
