import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../config/cameroon_config.dart';
import '../database/models/cash_payment.dart';
import '../database/models/client.dart';
import '../database/models/order.dart';
import '../database/models/user.dart';

class ReceiptService {
  static Future<Uint8List> buildReceiptPdf({
    required Order order,
    required List<OrderItem> items,
    required User salesperson,
    CashPayment? payment,
    Client? client,
    String? storeName,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              storeName ?? 'Grocery Store',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text('Cash Receipt', style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.Divider(),
          _row('Order #', order.orderId.substring(0, order.orderId.length > 10 ? 10 : order.orderId.length)),
          _row('Date', _formatDate(order.createdAt)),
          _row('Cashier', salesperson.name),
          if (client != null) _row('Customer', client.name),
          pw.Divider(),
          ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.quantity == 1
                          ? item.productId
                          : '${item.quantity} x ${item.productId}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      '${item.quantity} x ${CameroonConfig.formatCurrency(item.unitPrice)}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        CameroonConfig.formatCurrency(item.lineTotal),
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              )),
          pw.Divider(),
          _row('Subtotal', CameroonConfig.formatCurrency(order.subtotal)),
          _row('VAT (19.25%)', CameroonConfig.formatCurrency(order.vatAmount)),
          _row(
            'TOTAL',
            CameroonConfig.formatCurrency(order.totalAmount),
            bold: true,
          ),
          pw.SizedBox(height: 6),
          if (payment != null) ...[
            _row('Cash received', CameroonConfig.formatCurrency(payment.amountTendered)),
            _row('Change', CameroonConfig.formatCurrency(payment.changeAmount)),
          ],
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text('PAID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text('Thank you for your purchase!',
                style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _row(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: 11,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final date = dt.toString().split(' ').first;
    final time = dt.toString().split(' ').last.split('.').first;
    return '$date $time';
  }
}