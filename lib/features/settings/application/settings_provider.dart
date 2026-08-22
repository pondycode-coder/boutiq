import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  static const String _vatRateKey = 'vat_rate';
  static const double _defaultVatRate = 0.1925; // 19.25%

  static Future<double> getVatRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_vatRateKey) ?? _defaultVatRate;
  }

  static Future<void> setVatRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vatRateKey, rate);
  }
}

final vatRateProvider = FutureProvider<double>((ref) async {
  return SettingsProvider.getVatRate();
});

final vatRateNotifierProvider = Provider<VatRateNotifier>((ref) {
  return VatRateNotifier(ref);
});

class VatRateNotifier {
  final Ref ref;
  VatRateNotifier(this.ref);

  Future<void> setVatRate(double rate) async {
    await SettingsProvider.setVatRate(rate);
    ref.invalidate(vatRateProvider);
  }
}