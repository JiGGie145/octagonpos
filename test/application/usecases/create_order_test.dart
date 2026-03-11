import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/application/usecases/order/create_order.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';

import '../../mocks/mock_order_repository.dart';

void main() {
  late CreateOrder createOrder;
  late MockOrderRepository mockRepo;

  setUp(() {
    mockRepo = MockOrderRepository();
    createOrder = CreateOrder(mockRepo);
  });

  OrderItem makeItem({String localId = 'item-1'}) {
    return OrderItem(
      localId: localId,
      orderId: '', // unassigned before creation
      productId: 'prod-1',
      productName: 'Test',
      quantity: 2,
      unitPrice: 1500,
    );
  }

  group('CreateOrder', () {
    test('throws ArgumentError when items list is empty', () {
      expect(
        () => createOrder(items: []),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('creates order with pending status', () async {
      final result = await createOrder(items: [makeItem()]);
      expect(result.status, OrderStatus.pending);
    });

    test('generates a UUID for localId', () async {
      final result = await createOrder(items: [makeItem()]);
      // UUID v4 format: 8-4-4-4-12 hex chars
      expect(result.localId, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      )));
    });

    test('assigns orderId to all items', () async {
      final result = await createOrder(items: [
        makeItem(localId: 'a'),
        makeItem(localId: 'b'),
      ]);
      for (final item in result.items) {
        expect(item.orderId, result.localId);
      }
    });

    test('passes note through to created order', () async {
      final result = await createOrder(
        items: [makeItem()],
        note: 'No onions',
      );
      expect(result.note, 'No onions');
    });

    test('calls repository.create', () async {
      await createOrder(items: [makeItem()]);
      expect(mockRepo.callLog, contains('create'));
    });

    test('sets createdAt and updatedAt', () async {
      final before = DateTime.now();
      final result = await createOrder(items: [makeItem()]);
      final after = DateTime.now();

      expect(result.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(result.updatedAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });
  });
}
