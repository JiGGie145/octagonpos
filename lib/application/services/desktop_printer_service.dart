import 'package:flutter_pos/application/services/printer_service.dart';
import 'package:flutter_pos/application/services/receipt_template.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Printer service for desktop platforms and web.
///
/// Uses the `printing` package to generate a PDF and send it to
/// the system print dialog (or browser print dialog on web).
class DesktopPrinterService implements PrinterService {
  @override
  bool get isAvailable => true;

  @override
  Future<void> printReceipt(
    Order order,
    BusinessSettings settings, {
    Payment? payment,
  }) async {
    final receiptLines = ReceiptTemplate.generate(
      order,
      settings,
      payment: payment,
    );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: receiptLines.map((line) {
              if (line.isBold) {
                return pw.Text(
                  line.text,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: line.fontSize,
                  ),
                );
              }
              return pw.Text(
                line.text,
                style: pw.TextStyle(fontSize: line.fontSize),
              );
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => doc.save(),
    );
  }
}
