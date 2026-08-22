import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/client.dart';
import '../../../core/database/models/user.dart';
import '../../../core/utils/id_generator.dart';

final usersNotifierProvider =
    AsyncNotifierProvider<UsersNotifier, List<User>>(UsersNotifier.new);

final clientsNotifierProvider =
    AsyncNotifierProvider<ClientsNotifier, List<Client>>(ClientsNotifier.new);

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return HiveService.usersBox.values.toList();
  }

  Future<void> addUser({
    required String name,
    required String phone,
    required String pin,
    required String role,
    String? storeId,
  }) async {
    final now = DateTime.now();
    final user = User()
      ..userId = IdGenerator.generate()
      ..name = name
      ..phone = phone
      ..pin = pin
      ..role = role
      ..storeId = storeId
      ..isActive = true
      ..createdAt = now
      ..updatedAt = now;
    await HiveService.usersBox.add(user);
    ref.invalidateSelf();
  }

  Future<void> updateUser(User user, {required String pin}) async {
    user.pin = pin;
    user.updatedAt = DateTime.now();
    final box = HiveService.usersBox;
    final index = box.values.toList().indexWhere((u) => u.userId == user.userId);
    if (index >= 0) {
      box.putAt(index, user);
    }
    ref.invalidateSelf();
  }

  Future<void> toggleActive(String userId) async {
    final box = HiveService.usersBox;
    final index = box.values.toList().indexWhere((u) => u.userId == userId);
    if (index < 0) return;
    final user = box.getAt(index);
    if (user == null) return;
    user.isActive = !user.isActive;
    box.putAt(index, user);
    ref.invalidateSelf();
  }
}

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    return HiveService.clientsBox.values.toList();
  }

  Future<void> addClient({
    required String name,
    required String phone,
    required String clientType,
    String region = '',
    String division = '',
    String address = '',
  }) async {
    final now = DateTime.now();
    final client = Client()
      ..clientId = IdGenerator.generate()
      ..name = name
      ..nameFr = name
      ..clientType = clientType
      ..region = region
      ..division = division
      ..subdivision = ''
      ..address = address
      ..phone = phone
      ..contactPerson = ''
      ..creditLimit = 0
      ..currentBalance = 0
      ..paymentTermsDays = 0
      ..preferredPaymentMethod = 'cash'
      ..assignedRouteId = ''
      ..isActive = true
      ..createdAt = now
      ..updatedAt = now;
    await HiveService.clientsBox.add(client);
    ref.invalidateSelf();
  }

  Future<void> deleteClient(String clientId) async {
    final box = HiveService.clientsBox;
    final index =
        box.values.toList().indexWhere((c) => c.clientId == clientId);
    if (index >= 0) {
      box.deleteAt(index);
    }
    ref.invalidateSelf();
  }
}