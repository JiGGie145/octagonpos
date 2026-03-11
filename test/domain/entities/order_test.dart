import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';

void main() {
  final now = DateTime(2025, 1, 1, 12, 0);

  OrderItem makeItem({
    String localId = 'item-1',
    String orderId = 'order-1',
    int quantity = 1,
    int unitPrice = 1000,
  }) {
    return OrderItem(
      localId: localId,
      orderId: orderId,
      productId: 'prod-1',
      productName: 'Test Product',
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  Order makeOrder({
    List<OrderItem>? items,
    OrderStatus status = OrderStatus.pending,
    DateTime? deletedAt,
    String? note,
  }) {
    return Order(
      localId: 'order-1',
      orderNumber: 42,
      items: items ?? [makeItem()],
      status: status,
      note: note,
      createdAt: now,
      updatedAt: now,
      deletedAt: deletedAt,
    );
  }

  group('Order', () {
    group('subtotal', () {
      test('returns sum of all line item totals', () {
        final order = makeOrder(items: [
          makeItem(localId: 'a', quantity: 2, unitPrice: 1500), // 3000
          makeItem(localId: 'b', quantity: 1, unitPrice: 500), // 500
        ]);
        expect(order.subtotal, 3500);
      });

      test('returns 0 for empty items', () {
        final order = makeOrder(items: []);
        expect(order.subtotal, 0);
      });

      test('handles single item', () {
        final order = makeOrder(items: [
          makeItem(quantity: 3, unitPrice: 2000),
        ]);
        expect(order.subtotal, 6000);
      });
    });

    group('taxAmount', () {
      test('calculates 15% tax correctly', () {
        final order = makeOrder(items: [
          makeItem(quantity: 1, unitPrice: 10000), // R100.00
        ]);
        expect(order.taxAmount(15), 1500); // R15.00
      });

      test('uses integer division (truncates)', () {
        final order = makeOrder(items: [
          makeItem(quantity: 1, unitPrice: 333), // R3.33
        ]);
        // 333 * 15 / 100 = 49.95 → truncated to 49
        expect(order.taxAmount(15), 49);
      });

      test('returns 0 for 0% tax', () {
        final order = makeOrder(items: [
          makeItem(quantity: 1, unitPrice: 10000),
        ]);
        expect(order.taxAmount(0), 0);
      });
    });

    group('total', () {
      test('returns subtotal + tax', () {
        final order = makeOrder(items: [
          makeItem(quantity: 1, unitPrice: 10000),
        ]);
        // subtotal=10000, tax=1500, total=11500
        expect(order.total(15), 11500);
      });

      test('returns subtotal when tax is 0', () {
        final order = makeOrder(items: [
          makeItem(quantity: 2, unitPrice: 5000),
        ]);
        expect(order.total(0), 10000);
      });
    });

    group('isDeleted', () {
      test('returns false when deletedAt is null', () {
        final order = makeOrder(deletedAt: null);
        expect(order.isDeleted, false);
      });

      test('returns true when deletedAt is set', () {
        final order = makeOrder(deletedAt: DateTime(2025, 6, 1));
        expect(order.isDeleted, true);
      });
    });

    group('isEditable', () {
      test('returns true for pending orders', () {
        expect(makeOrder(status: OrderStatus.pending).isEditable, true);
      });

      test('returns false for paid orders', () {
        expect(makeOrder(status: OrderStatus.paid).isEditable, false);
      });

      test('returns false for completed orders', () {
        expect(makeOrder(status: OrderStatus.completed).isEditable, false);
      });

      test('returns false for cancelled orders', () {
        expect(makeOrder(status: OrderStatus.cancelled).isEditable, false);
      });
    });

    group('displayOrderNumber', () {
      test('formats with # prefix', () {
        final order = makeOrder();
        expect(order.displayOrderNumber, '#42');
      });
    });

    group('copyWith', () {
      test('returns same values when no args given', () {
        final order = makeOrder();
        final copy = order.copyWith();
        expect(copy.localId, order.localId);
        expect(copy.orderNumber, order.orderNumber);
        expect(copy.status, order.status);
        expect(copy.note, order.note);
      });

      test('overrides specified fields', () {
        final order = makeOrder(note: 'original');
        final copy = order.copyWith(
          status: OrderStatus.paid,
          note: 'updated',
          orderNumber: 99,
        );
        expect(copy.status, OrderStatus.paid);
        expect(copy.note, 'updated');
        expect(copy.orderNumber, 99);
        expect(copy.localId, order.localId); // unchanged
      });
    });

    group('equality', () {
      test('orders with same localId are equal', () {
        final a = makeOrder();
        final b = makeOrder();
        expect(a, equals(b));
      });

      test('orders with different localId are not equal', () {
        final a = makeOrder();
        final b = Order(
          localId: 'different-id',
          orderNumber: 42,
          createdAt: now,
          updatedAt: now,
        );
        expect(a, isNot(equals(b)));
      });
    });

    test('toString contains useful info', () {
      final order = makeOrder();
      final str = order.toString();
      expect(str, contains('order-1'));
      expect(str, contains('#42'));
      expect(str, contains('Pending'));
    });
  });
}
