import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/payment.dart' as domain;
import 'package:flutter_pos/domain/enums/payment_method.dart';

/// Maps between Drift [Payment] data class and domain [domain.Payment] entity.
class PaymentMapper {
  PaymentMapper._();

  /// Converts a Drift [Payment] row to a domain entity.
  static domain.Payment toDomain(Payment row) {
    return domain.Payment(
      localId: row.localId,
      orderId: row.orderId,
      method: PaymentMethod.fromString(row.method),
      amount: row.amount,
      createdAt: row.createdAt,
    );
  }

  /// Converts a domain entity to a Drift [PaymentsCompanion].
  static PaymentsCompanion toCompanion(domain.Payment entity) {
    return PaymentsCompanion(
      localId: Value(entity.localId),
      orderId: Value(entity.orderId),
      method: Value(entity.method.name),
      amount: Value(entity.amount),
      createdAt: Value(entity.createdAt),
    );
  }
}
