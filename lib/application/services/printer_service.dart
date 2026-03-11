import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/domain/entities/payment.dart';

/// Abstract printer service.
///
/// UI must not depend on printer implementation directly.
/// Implementations: [DesktopPrinterService], [BluetoothPrinterService].
abstract class PrinterService {
  /// Prints a receipt for the given order using the business settings
  /// for formatting (currency, tax, footer).
  ///
  /// If [payment] is provided, payment method and amount are included.
  Future<void> printReceipt(
    Order order,
    BusinessSettings settings, {
    Payment? payment,
  });

  /// Whether this printer service is available on the current platform.
  bool get isAvailable;
}
