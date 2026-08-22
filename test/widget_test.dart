import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sabc_distritrack/main.dart';
import 'package:sabc_distritrack/core/database/hive_service.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('cash_register_test');
    await HiveService.initialize(directory: dir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CashRegisterApp()));
    expect(find.byType(CashRegisterApp), findsOneWidget);
  });
}