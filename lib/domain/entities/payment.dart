import 'package:flutter_pos/domain/enums/payment_method.dart';

/// A payment record for an order.
///
/// Pure Dart — no Flutter or database imports.
/// [amount] is stored in cents.
class Payment {
  final String localId;
  final String orderId;
  final PaymentMethod method;
  final int amount; // in cents
  final DateTime createdAt;

  const Payment({
    required this.localId,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.createdAt,
  });

  /// Creates a copy with the given fields replaced.
  Payment copyWith({
    String? localId,
    String? orderId,
    PaymentMethod? method,
    int? amount,
    DateTime? createdAt,
  }) {
    return Payment(
      localId: localId ?? this.localId,
      orderId: orderId ?? this.orderId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'Payment(localId: $localId, order: $orderId, '
      'method: ${method.label}, amount: $amount)';
}
