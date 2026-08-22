import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/user.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends Notifier<User?> with ChangeNotifier {
  static User? currentUser;

  static final ValueNotifier<int> refresh = ValueNotifier(0);

  static bool get isAdmin => currentUser?.role == 'admin';

  @override
  User? build() => currentUser;

  Future<User?> login(String pin) async {
    final users = HiveService.usersBox;
    for (final user in users.values) {
      if (user.pin == pin && user.isActive) {
        currentUser = user;
        state = user;
        notifyListeners();
        refresh.value++;
        return user;
      }
    }
    return null;
  }

  void logout() {
    currentUser = null;
    state = null;
    notifyListeners();
    refresh.value++;
  }
}