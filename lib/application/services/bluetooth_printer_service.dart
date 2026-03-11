import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pos/application/services/printer_service.dart';
import 'package:flutter_pos/application/services/receipt_template.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

/// Printer service for Bluetooth thermal printers (Android first).
///
/// Uses ESC/POS commands via the `blue_thermal_printer` package.
class BluetoothPrinterService implements PrinterService {
  BlueThermalPrinter? _printer;

  @override
  bool get isAvailable => !kIsWeb && Platform.isAndroid;

  /// Connects to the first paired Bluetooth printer found.
  /// Call this before [printReceipt].
  Future<bool> connect() async {
    _printer = BlueThermalPrinter.instance;

    final isConnected = await _printer!.isConnected ?? false;
    if (isConnected) return true;

    final devices = await _printer!.getBondedDevices();
    if (devices.isEmpty) return false;

    // Connect to the first available device
    await _printer!.connect(devices.first);
    return true;
  }

  @override
  Future<void> printReceipt(
    Order order,
    BusinessSettings settings, {
    Payment? payment,
  }) async {
    _printer ??= BlueThermalPrinter.instance;

    final isConnected = await _printer!.isConnected ?? false;
    if (!isConnected) {
      final connected = await connect();
      if (!connected) {
        throw Exception('No Bluetooth printer connected');
      }
    }

    final receiptLines = ReceiptTemplate.generate(
      order,
      settings,
      payment: payment,
    );

    for (final line in receiptLines) {
      if (line.isBold) {
        _printer!.printCustom(line.text, line.size, line.align);
      } else {
        _printer!.printCustom(line.text, line.size, line.align);
      }
    }

    // Feed and cut
    _printer!.printNewLine();
    _printer!.printNewLine();
    _printer!.paperCut();
  }
}
