import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';

void main() {
  group('PaymentMethod', () {
    group('label', () {
      test('cash → Cash', () {
        expect(PaymentMethod.cash.label, 'Cash');
      });

      test('card → Card', () {
        expect(PaymentMethod.card.label, 'Card');
      });
    });

    group('fromString', () {
      test('parses lowercase value', () {
        expect(PaymentMethod.fromString('card'), PaymentMethod.card);
      });

      test('parses mixed case value', () {
        expect(PaymentMethod.fromString('Cash'), PaymentMethod.cash);
      });

      test('defaults to cash for unknown value', () {
        expect(PaymentMethod.fromString('bitcoin'), PaymentMethod.cash);
      });
    });
  });
}
