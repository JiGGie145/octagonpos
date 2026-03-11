import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/application/usecases/payment/process_payment.dart';

import 'repository_providers.dart';

/// Provides the [ProcessPayment] use case.
final processPaymentUseCaseProvider = Provider<ProcessPayment>((ref) {
  return ProcessPayment(
    ref.watch(paymentRepositoryProvider),
    ref.watch(orderRepositoryProvider),
  );
});

/// Async provider for the current business settings.
/// Returns `null` if settings have not been configured yet (first launch).
final settingsProvider = FutureProvider<BusinessSettings?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.get();
});

/// Whether the initial setup (business settings) has been completed.
final isSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  return settings != null;
});
