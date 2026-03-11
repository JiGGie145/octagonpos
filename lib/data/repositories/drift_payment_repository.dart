import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/payment_mapper.dart';
import 'package:flutter_pos/domain/entities/payment.dart' as domain;
import 'package:flutter_pos/domain/repositories/payment_repository.dart';

/// Drift-backed implementation of [PaymentRepository].
class DriftPaymentRepository implements PaymentRepository {
  final AppDatabase _db;

  DriftPaymentRepository(this._db);

  @override
  Future<domain.Payment> create(domain.Payment payment) async {
    final companion = PaymentMapper.toCompanion(payment);
    await _db.insertPayment(companion);
    return payment;
  }

  @override
  Future<domain.Payment?> getByOrderId(String orderId) async {
    final row = await _db.getPaymentByOrderId(orderId);
    return row != null ? PaymentMapper.toDomain(row) : null;
  }
}
