import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/presentation/providers/cart_provider.dart';

void main() {
  final now = DateTime(2025, 1, 1, 12, 0);

  Product makeProduct({
    String localId = 'prod-1',
    String name = 'Coffee',
    int price = 3500,
  }) {
    return Product(
      localId: localId,
      name: name,
      price: price,
      category: 'Beverages',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CartState', () {
    test('empty cart defaults', () {
      const state = CartState();
      expect(state.isEmpty, true);
      expect(state.isNotEmpty, false);
      expect(state.lineCount, 0);
      expect(state.totalQuantity, 0);
      expect(state.subtotalCents, 0);
      expect(state.note, isNull);
    });

    test('computed properties with items', () {
      final state = CartState(items: [
        OrderItem(
          localId: 'a',
          orderId: '',
          productId: 'prod-1',
          productName: 'Coffee',
          quantity: 2,
          unitPrice: 3500,
        ),
        OrderItem(
          localId: 'b',
          orderId: '',
          productId: 'prod-2',
          productName: 'Muffin',
          quantity: 1,
          unitPrice: 2000,
        ),
      ]);

      expect(state.isEmpty, false);
      expect(state.isNotEmpty, true);
      expect(state.lineCount, 2);
      expect(state.totalQuantity, 3); // 2 + 1
      expect(state.subtotalCents, 9000); // 7000 + 2000
    });

    test('taxCents calculates correctly', () {
      final state = CartState(items: [
        OrderItem(
          localId: 'a',
          orderId: '',
          productId: 'prod-1',
          productName: 'Item',
          quantity: 1,
          unitPrice: 10000,
        ),
      ]);
      expect(state.taxCents(15), 1500);
      expect(state.taxCents(0), 0);
    });

    test('totalCents = subtotal + tax', () {
      final state = CartState(items: [
        OrderItem(
          localId: 'a',
          orderId: '',
          productId: 'prod-1',
          productName: 'Item',
          quantity: 1,
          unitPrice: 10000,
        ),
      ]);
      expect(state.totalCents(15), 11500);
    });

    test('copyWith preserves and overrides', () {
      final state = CartState(
        items: [
          OrderItem(
            localId: 'a',
            orderId: '',
            productId: 'prod-1',
            productName: 'Item',
            quantity: 1,
            unitPrice: 1000,
          ),
        ],
        note: 'hello',
      );
      final copy = state.copyWith(note: 'world');
      expect(copy.note, 'world');
      expect(copy.lineCount, 1);
    });
  });

  group('CartNotifier', () {
    late CartNotifier notifier;

    setUp(() {
      notifier = CartNotifier();
    });

    test('starts with empty state', () {
      expect(notifier.state.isEmpty, true);
    });

    group('addProduct', () {
      test('adds new product as line item', () {
        notifier.addProduct(makeProduct());
        expect(notifier.state.lineCount, 1);
        expect(notifier.state.items.first.productName, 'Coffee');
        expect(notifier.state.items.first.quantity, 1);
        expect(notifier.state.items.first.unitPrice, 3500);
      });

      test('increments quantity for duplicate product', () {
        final product = makeProduct();
        notifier.addProduct(product);
        notifier.addProduct(product);
        expect(notifier.state.lineCount, 1);
        expect(notifier.state.items.first.quantity, 2);
      });

      test('adds different products as separate items', () {
        notifier.addProduct(makeProduct(localId: 'a', name: 'Coffee'));
        notifier.addProduct(makeProduct(localId: 'b', name: 'Tea'));
        expect(notifier.state.lineCount, 2);
      });
    });

    group('removeItem', () {
      test('removes item by localId', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.removeItem(itemId);
        expect(notifier.state.isEmpty, true);
      });

      test('does nothing if id not found', () {
        notifier.addProduct(makeProduct());
        notifier.removeItem('nonexistent');
        expect(notifier.state.lineCount, 1);
      });
    });

    group('updateQuantity', () {
      test('updates quantity to specified value', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.updateQuantity(itemId, 5);
        expect(notifier.state.items.first.quantity, 5);
      });

      test('removes item if quantity <= 0', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.updateQuantity(itemId, 0);
        expect(notifier.state.isEmpty, true);
      });
    });

    group('incrementQuantity', () {
      test('increases quantity by 1', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.incrementQuantity(itemId);
        expect(notifier.state.items.first.quantity, 2);
      });
    });

    group('decrementQuantity', () {
      test('decreases quantity by 1', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.addProduct(makeProduct()); // qty=2
        notifier.decrementQuantity(itemId);
        expect(notifier.state.items.first.quantity, 1);
      });

      test('removes item when quantity reaches 0', () {
        notifier.addProduct(makeProduct());
        final itemId = notifier.state.items.first.localId;
        notifier.decrementQuantity(itemId);
        expect(notifier.state.isEmpty, true);
      });
    });

    group('setNote', () {
      test('sets note on cart state', () {
        notifier.setNote('Extra napkins');
        expect(notifier.state.note, 'Extra napkins');
      });

      test('passing null preserves existing note (copyWith limitation)', () {
        notifier.setNote('something');
        notifier.setNote(null);
        // copyWith uses `note ?? this.note`, so null doesn't clear it
        expect(notifier.state.note, 'something');
      });
    });

    group('clear', () {
      test('resets to empty state', () {
        notifier.addProduct(makeProduct());
        notifier.setNote('test');
        notifier.clear();
        expect(notifier.state.isEmpty, true);
        expect(notifier.state.note, isNull);
      });
    });
  });
}
