import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 21)
class Client extends HiveObject {
  @HiveField(0)
  late String clientId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String nameFr;

  @HiveField(3)
  late String clientType;

  @HiveField(4)
  late String region;

  @HiveField(5)
  late String division;

  @HiveField(6)
  late String subdivision;

  @HiveField(7)
  late String address;

  @HiveField(8)
  late String phone;

  @HiveField(9)
  String? email;

  @HiveField(10)
  late String contactPerson;

  @HiveField(11)
  late double creditLimit;

  @HiveField(12)
  late double currentBalance;

  @HiveField(13)
  late int paymentTermsDays;

  @HiveField(14)
  late String preferredPaymentMethod;

  @HiveField(15)
  late String assignedRouteId;

  @HiveField(16)
  late bool isActive;

  @HiveField(17)
  late DateTime createdAt;

  @HiveField(18)
  late DateTime updatedAt;
}