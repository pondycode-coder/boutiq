import 'dart:math';

class IdGenerator {
  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomPart = List.generate(6, (_) => _random.nextInt(36).toRadixString(36)).join();
    return '$timestamp-$randomPart';
  }
}