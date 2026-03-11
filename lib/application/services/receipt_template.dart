import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:intl/intl.dart';

/// A single line in a receipt.
class ReceiptLine {
  final String text;
  final bool isBold;
  final double fontSize;
  final int size; // for thermal: 0=small, 1=normal, 2=medium, 3=large
  final int align; // for thermal: 0=left, 1=center, 2=right

  const ReceiptLine(
    this.text, {
    this.isBold = false,
    this.fontSize = 10,
    this.size = 1,
    this.align = 0,
  });
}

/// Generates receipt content from an [Order] and [BusinessSettings].
class ReceiptTemplate {
  ReceiptTemplate._();

  /// Formats a price in cents to a display string (e.g. 3500 → "R35.00").
  static String _formatPrice(int cents, String symbol) {
    final amount = (cents / 100).toStringAsFixed(2);
    return '$symbol$amount';
  }

  /// Generates the full receipt as a list of [ReceiptLine]s.
  static List<ReceiptLine> generate(
    Order order,
    BusinessSettings settings, {
    Payment? payment,
  }) {
    final lines = <ReceiptLine>[];
    final dateFormat = DateFormat('dd MMM yyyy  HH:mm');
    final symbol = settings.currencySymbol;

    // ── Header ───────────────────────────────────────────────────
    lines.add(ReceiptLine(
      settings.businessName,
      isBold: true,
      fontSize: 14,
      size: 3,
      align: 1,
    ));
    lines.add(const ReceiptLine(''));
    lines.add(ReceiptLine(
      dateFormat.format(order.createdAt),
      fontSize: 9,
      size: 0,
      align: 1,
    ));
    lines.add(ReceiptLine(
      'Order ${order.displayOrderNumber}',
      isBold: true,
      fontSize: 12,
      size: 2,
      align: 1,
    ));
    lines.add(const ReceiptLine('--------------------------------'));

    // ── Line Items ───────────────────────────────────────────────
    for (final item in order.items) {
      final lineTotal = _formatPrice(item.lineTotal, symbol);
      lines.add(ReceiptLine(
        '${item.productName} x${item.quantity}',
      ));
      lines.add(ReceiptLine(
        '  ${_formatPrice(item.unitPrice, symbol)} each    $lineTotal',
        align: 2,
      ));
    }

    lines.add(const ReceiptLine('--------------------------------'));

    // ── Totals ───────────────────────────────────────────────────
    final subtotal = _formatPrice(order.subtotal, symbol);
    final tax = _formatPrice(
      order.taxAmount(settings.taxPercentage),
      symbol,
    );
    final total = _formatPrice(
      order.total(settings.taxPercentage),
      symbol,
    );

    lines.add(ReceiptLine('Subtotal:               $subtotal'));
    lines.add(ReceiptLine(
      'Tax (${settings.taxPercentage}%):              $tax',
    ));
    lines.add(const ReceiptLine('--------------------------------'));
    lines.add(ReceiptLine(
      'TOTAL:                  $total',
      isBold: true,
      fontSize: 12,
      size: 2,
    ));
    lines.add(const ReceiptLine(''));

    // ── Payment ──────────────────────────────────────────────────
    if (payment != null) {
      lines.add(const ReceiptLine('--------------------------------'));
      lines.add(ReceiptLine(
        'Paid via:               ${payment.method.label}',
      ));
      lines.add(ReceiptLine(
        'Amount:                 ${_formatPrice(payment.amount, symbol)}',
      ));
      lines.add(const ReceiptLine(''));
    }

    // ── Footer ───────────────────────────────────────────────────
    if (settings.receiptFooter.isNotEmpty) {
      lines.add(ReceiptLine(
        settings.receiptFooter,
        fontSize: 9,
        size: 0,
        align: 1,
      ));
    }

    lines.add(const ReceiptLine(''));

    return lines;
  }
}
