import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';

void main() {
  group('OrderStatus', () {
    group('label', () {
      test('pending → Pending', () {
        expect(OrderStatus.pending.label, 'Pending');
      });

      test('paid → Paid', () {
        expect(OrderStatus.paid.label, 'Paid');
      });

      test('completed → Completed', () {
        expect(OrderStatus.completed.label, 'Completed');
      });

      test('cancelled → Cancelled', () {
        expect(OrderStatus.cancelled.label, 'Cancelled');
      });
    });

    group('fromString', () {
      test('parses lowercase value', () {
        expect(OrderStatus.fromString('paid'), OrderStatus.paid);
      });

      test('parses mixed case value', () {
        expect(OrderStatus.fromString('Completed'), OrderStatus.completed);
      });

      test('defaults to pending for unknown value', () {
        expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
      });

      test('defaults to pending for empty string', () {
        expect(OrderStatus.fromString(''), OrderStatus.pending);
      });
    });
  });
}
