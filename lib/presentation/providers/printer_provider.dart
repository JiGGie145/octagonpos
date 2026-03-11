import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/application/services/desktop_printer_service.dart';
import 'package:flutter_pos/application/services/printer_service.dart';

/// Provides the [PrinterService] implementation for the current platform.
///
/// Currently uses [DesktopPrinterService] which works on desktop and web
/// via the `printing` package. On Android with a Bluetooth thermal printer,
/// swap to [BluetoothPrinterService] via settings (future enhancement).
final printerServiceProvider = Provider<PrinterService>((ref) {
  return DesktopPrinterService();
});
