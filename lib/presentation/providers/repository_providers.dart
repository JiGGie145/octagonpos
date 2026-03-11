import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/data/repositories/drift_order_repository.dart';
import 'package:flutter_pos/data/repositories/drift_payment_repository.dart';
import 'package:flutter_pos/data/repositories/drift_product_repository.dart';
import 'package:flutter_pos/data/repositories/drift_settings_repository.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';
import 'package:flutter_pos/domain/repositories/payment_repository.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/repositories/settings_repository.dart';

import 'database_provider.dart';

/// Provides a [ProductRepository] backed by Drift.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return DriftProductRepository(ref.watch(databaseProvider));
});

/// Provides an [OrderRepository] backed by Drift.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return DriftOrderRepository(ref.watch(databaseProvider));
});

/// Provides a [PaymentRepository] backed by Drift.
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return DriftPaymentRepository(ref.watch(databaseProvider));
});

/// Provides a [SettingsRepository] backed by Drift.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(databaseProvider));
});
