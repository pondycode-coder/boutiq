import 'package:intl/intl.dart';
import '../config/cameroon_constants.dart';

class CurrencyFormatter {
  static final NumberFormat _xafFormatter = NumberFormat.currency(
    locale: 'fr_CM',
    symbol: CameroonConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _xafFormatterEn = NumberFormat.currency(
    locale: 'en_CM',
    symbol: CameroonConstants.currencySymbol,
    decimalDigits: 0,
  );

  static String formatXAF(double amount, {String locale = 'fr'}) {
    if (amount.isNaN || amount.isInfinite) return '0 ${CameroonConstants.currencySymbol}';
    return locale == 'fr' 
        ? _xafFormatter.format(amount)
        : _xafFormatterEn.format(amount);
  }

  static String formatXAFWithDecimals(double amount, {String locale = 'fr', int decimals = 0}) {
    if (amount.isNaN || amount.isInfinite) return '0 ${CameroonConstants.currencySymbol}';
    final formatter = NumberFormat.currency(
      locale: locale == 'fr' ? 'fr_CM' : 'en_CM',
      symbol: CameroonConstants.currencySymbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  static double parseXAF(String amount) {
    final cleaned = amount.replaceAll(RegExp(r'[^\d.,\-]'), '');
    final normalized = cleaned.replaceAll(',', '');
    return double.tryParse(normalized) ?? 0.0;
  }
}

class TaxCalculator {
  static const double vatRate = CameroonConstants.vatRate;

  static double calculateVat(double amount) {
    return amount * vatRate;
  }

  static double calculateAmountWithVat(double amountExclVat) {
    return amountExclVat * (1 + vatRate);
  }

  static double calculateAmountExclVat(double amountInclVat) {
    return amountInclVat / (1 + vatRate);
  }

  static double calculateBottleDeposit(String bottleSize, int quantity) {
    final depositPerBottle = CameroonConstants.defaultBottleDeposits[bottleSize] ?? 50.0;
    return depositPerBottle * quantity;
  }

  static Map<String, double> calculateOrderTotals({
    required double subtotal,
    required Map<String, int> bottleQuantities,
  }) {
    final vat = calculateVat(subtotal);
    double totalDeposits = 0;
    
    bottleQuantities.forEach((size, qty) {
      totalDeposits += calculateBottleDeposit(size, qty);
    });

    return {
      'subtotal': subtotal,
      'vat': vat,
      'deposits': totalDeposits,
      'total': subtotal + vat + totalDeposits,
    };
  }

  static double roundToNearestXAF(double amount) {
    return amount.roundToDouble();
  }
}

class BottleDepositCalculator {
  static double getDepositForSize(String bottleSize) {
    return CameroonConstants.defaultBottleDeposits[bottleSize] ?? 50.0;
  }

  static double calculateDeposit(String bottleSize, int quantity) {
    return getDepositForSize(bottleSize) * quantity;
  }

  static double calculateRefund(String bottleSize, int returnedQuantity) {
    return getDepositForSize(bottleSize) * returnedQuantity;
  }

  static Map<String, int> parseBottleReturn(String returnString) {
    final Map<String, int> result = {};
    final parts = returnString.split(',');
    for (final part in parts) {
      final sizeQty = part.split(':');
      if (sizeQty.length == 2) {
        final size = sizeQty[0].trim();
        final qty = int.tryParse(sizeQty[1].trim()) ?? 0;
        if (qty > 0) {
          result[size] = qty;
        }
      }
    }
    return result;
  }
}