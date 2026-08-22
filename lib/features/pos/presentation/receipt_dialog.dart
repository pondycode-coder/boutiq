import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../core/database/models/cash_payment.dart';
import '../../../core/database/models/client.dart';
import '../../../core/database/models/order.dart';
import '../../../core/database/models/user.dart';
import '../../../core/utils/receipt_service.dart';

Future<void> showReceiptDialog(
  BuildContext context, {
  required Order order,
  required List<OrderItem> items,
  required User salesperson,
  CashPayment? payment,
  Client? client,
  Map<String, String>? productNames,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ReceiptDialog(
      order: order,
      items: items,
      salesperson: salesperson,
      payment: payment,
      client: client,
      productNames: productNames,
    ),
  );
}

class _ReceiptDialog extends StatefulWidget {
  const _ReceiptDialog({
    required this.order,
    required this.items,
    required this.salesperson,
    this.payment,
    this.client,
    this.productNames,
  });

  final Order order;
  final List<OrderItem> items;
  final User salesperson;
  final CashPayment? payment;
  final Client? client;
  final Map<String, String>? productNames;

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  // Build the PDF once and reuse the exact same bytes for preview + print/share.
  late final Future<Uint8List> _pdfFuture = ReceiptService.buildReceiptPdf(
    order: widget.order,
    items: widget.items,
    salesperson: widget.salesperson,
    payment: widget.payment,
    client: widget.client,
    productNames: widget.productNames,
  );

  Future<void> _print() async {
    // Printing.layoutPdf renders the real PDF via the platform print service,
    // independent of the preview rasterization.
    final bytes = await _pdfFuture;
    await Printing.layoutPdf(onLayout: (_) => Future.value(bytes));
  }

  Future<void> _share() async {
    final bytes = await _pdfFuture;
    await Printing.sharePdf(bytes: bytes, filename: 'receipt.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Receipt'),
      content: SizedBox(
        width: 360,
        height: 480,
        child: PdfPreview(
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          build: (_) => _pdfFuture,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
        ElevatedButton.icon(
          onPressed: _print,
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
      ],
    );
  }
}