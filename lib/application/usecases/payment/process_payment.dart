import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';
import 'package:flutter_pos/domain/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';

/// Processes a payment for an order:
/// 1. Creates a Payment record
/// 2. Updates the order status to Paid
class ProcessPayment {
  final PaymentRepository _paymentRepository;
  final OrderRepository _orderRepository;

  ProcessPayment(this._paymentRepository, this._orderRepository);

  Future<Payment> call({
    required String orderId,
    required PaymentMethod method,
    required int amount,
  }) async {
    final payment = Payment(
      localId: const Uuid().v4(),
      orderId: orderId,
      method: method,
      amount: amount,
      createdAt: DateTime.now(),
    );

    await _paymentRepository.create(payment);
    await _orderRepository.updateStatus(orderId, OrderStatus.paid);

    return payment;
  }
}
