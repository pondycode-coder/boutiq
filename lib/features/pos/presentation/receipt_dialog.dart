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
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ReceiptDialog(
      order: order,
      items: items,
      salesperson: salesperson,
      payment: payment,
      client: client,
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
  });

  final Order order;
  final List<OrderItem> items;
  final User salesperson;
  final CashPayment? payment;
  final Client? client;

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  Future<Uint8List> _build(PdfPageFormat format) async {
    return ReceiptService.buildReceiptPdf(
      order: widget.order,
      items: widget.items,
      salesperson: widget.salesperson,
      payment: widget.payment,
      client: widget.client,
    );
  }

  Future<void> _print() async {
    await Printing.layoutPdf(onLayout: _build);
  }

  Future<void> _share() async {
    final bytes = await _build(PdfPageFormat.roll80);
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
          build: _build,
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