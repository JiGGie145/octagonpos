import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:flutter_pos/domain/repositories/payment_repository.dart';

/// A simple in-memory mock of [PaymentRepository] for unit tests.
class MockPaymentRepository implements PaymentRepository {
  final List<Payment> _payments = [];
  final List<String> callLog = [];

  @override
  Future<Payment> create(Payment payment) async {
    callLog.add('create');
    _payments.add(payment);
    return payment;
  }

  @override
  Future<Payment?> getByOrderId(String orderId) async {
    callLog.add('getByOrderId');
    try {
      return _payments.firstWhere((p) => p.orderId == orderId);
    } catch (_) {
      return null;
    }
  }
}
