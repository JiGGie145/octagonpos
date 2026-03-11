import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';

void main() {
  OrderItem makeItem({
    int quantity = 1,
    int unitPrice = 1000,
  }) {
    return OrderItem(
      localId: 'item-1',
      orderId: 'order-1',
      productId: 'prod-1',
      productName: 'Widget',
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  group('OrderItem', () {
    group('lineTotal', () {
      test('returns quantity * unitPrice', () {
        expect(makeItem(quantity: 3, unitPrice: 2500).lineTotal, 7500);
      });

      test('returns unitPrice when quantity is 1', () {
        expect(makeItem(quantity: 1, unitPrice: 999).lineTotal, 999);
      });

      test('returns 0 when quantity is 0', () {
        expect(makeItem(quantity: 0, unitPrice: 5000).lineTotal, 0);
      });

      test('handles large values', () {
        final item = makeItem(quantity: 100, unitPrice: 99999);
        expect(item.lineTotal, 9999900);
      });
    });

    group('copyWith', () {
      test('returns same values when no args given', () {
        final item = makeItem();
        final copy = item.copyWith();
        expect(copy.localId, item.localId);
        expect(copy.orderId, item.orderId);
        expect(copy.productId, item.productId);
        expect(copy.productName, item.productName);
        expect(copy.quantity, item.quantity);
        expect(copy.unitPrice, item.unitPrice);
      });

      test('overrides specified fields', () {
        final item = makeItem(quantity: 1, unitPrice: 1000);
        final copy = item.copyWith(quantity: 5, orderId: 'new-order');
        expect(copy.quantity, 5);
        expect(copy.orderId, 'new-order');
        expect(copy.unitPrice, 1000); // unchanged
      });
    });

    group('equality', () {
      test('items with same localId are equal', () {
        final a = makeItem();
        final b = makeItem(quantity: 99); // different quantity, same localId
        expect(a, equals(b));
      });

      test('items with different localId are not equal', () {
        final a = makeItem();
        final b = OrderItem(
          localId: 'other-id',
          orderId: 'order-1',
          productId: 'prod-1',
          productName: 'Widget',
          quantity: 1,
          unitPrice: 1000,
        );
        expect(a, isNot(equals(b)));
      });
    });

    test('toString contains product name and quantity', () {
      final item = makeItem(quantity: 3);
      final str = item.toString();
      expect(str, contains('Widget'));
      expect(str, contains('3'));
    });
  });
}
