import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';

void main() {
  final now = DateTime(2025, 1, 1, 12, 0);

  Payment makePayment({
    PaymentMethod method = PaymentMethod.cash,
    int amount = 5000,
  }) {
    return Payment(
      localId: 'pay-1',
      orderId: 'order-1',
      method: method,
      amount: amount,
      createdAt: now,
    );
  }

  group('Payment', () {
    test('stores all fields correctly', () {
      final p = makePayment(method: PaymentMethod.card, amount: 12345);
      expect(p.localId, 'pay-1');
      expect(p.orderId, 'order-1');
      expect(p.method, PaymentMethod.card);
      expect(p.amount, 12345);
      expect(p.createdAt, now);
    });

    group('copyWith', () {
      test('returns same values when no args given', () {
        final p = makePayment();
        final copy = p.copyWith();
        expect(copy.localId, p.localId);
        expect(copy.orderId, p.orderId);
        expect(copy.method, p.method);
        expect(copy.amount, p.amount);
        expect(copy.createdAt, p.createdAt);
      });

      test('overrides specified fields', () {
        final p = makePayment();
        final copy = p.copyWith(
          method: PaymentMethod.card,
          amount: 9999,
        );
        expect(copy.method, PaymentMethod.card);
        expect(copy.amount, 9999);
        expect(copy.localId, p.localId); // unchanged
      });
    });

    group('equality', () {
      test('payments with same localId are equal', () {
        final a = makePayment(amount: 100);
        final b = makePayment(amount: 200);
        expect(a, equals(b));
      });

      test('payments with different localId are not equal', () {
        final a = makePayment();
        final b = Payment(
          localId: 'pay-2',
          orderId: 'order-1',
          method: PaymentMethod.cash,
          amount: 5000,
          createdAt: now,
        );
        expect(a, isNot(equals(b)));
      });
    });

    test('toString contains method label and amount', () {
      final p = makePayment(method: PaymentMethod.card, amount: 7500);
      final str = p.toString();
      expect(str, contains('Card'));
      expect(str, contains('7500'));
    });
  });
}
