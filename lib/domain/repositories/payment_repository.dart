import 'package:flutter_pos/domain/entities/payment.dart';

/// Contract for payment data access.
///
/// Implementations live in the data layer.
abstract class PaymentRepository {
  /// Persists a new payment record. Returns the created payment.
  Future<Payment> create(Payment payment);

  /// Returns the payment associated with the given [orderId], or `null`.
  Future<Payment?> getByOrderId(String orderId);
}
