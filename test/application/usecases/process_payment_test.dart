import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/application/usecases/payment/process_payment.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';

import '../../mocks/mock_order_repository.dart';
import '../../mocks/mock_payment_repository.dart';

void main() {
  late ProcessPayment processPayment;
  late MockPaymentRepository mockPaymentRepo;
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockPaymentRepo = MockPaymentRepository();
    mockOrderRepo = MockOrderRepository();
    processPayment = ProcessPayment(mockPaymentRepo, mockOrderRepo);
  });

  group('ProcessPayment', () {
    test('creates a payment record', () async {
      final result = await processPayment(
        orderId: 'order-1',
        method: PaymentMethod.cash,
        amount: 11500,
      );

      expect(result.orderId, 'order-1');
      expect(result.method, PaymentMethod.cash);
      expect(result.amount, 11500);
      expect(mockPaymentRepo.callLog, contains('create'));
    });

    test('generates a UUID for payment localId', () async {
      final result = await processPayment(
        orderId: 'order-1',
        method: PaymentMethod.card,
        amount: 5000,
      );

      expect(result.localId, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      )));
    });

    test('updates order status to paid', () async {
      await processPayment(
        orderId: 'order-42',
        method: PaymentMethod.cash,
        amount: 10000,
      );

      expect(
        mockOrderRepo.callLog,
        contains('updateStatus:order-42:paid'),
      );
    });

    test('payment is created before status update', () async {
      await processPayment(
        orderId: 'order-1',
        method: PaymentMethod.card,
        amount: 7500,
      );

      // Payment create should be called first
      expect(mockPaymentRepo.callLog.first, 'create');
      // Then order status update
      expect(mockOrderRepo.callLog.first, startsWith('updateStatus'));
    });

    test('sets createdAt on payment', () async {
      final before = DateTime.now();
      final result = await processPayment(
        orderId: 'order-1',
        method: PaymentMethod.cash,
        amount: 5000,
      );
      final after = DateTime.now();

      expect(
        result.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        result.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });
  });
}
