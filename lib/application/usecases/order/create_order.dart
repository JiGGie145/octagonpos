import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';
import 'package:uuid/uuid.dart';

/// Creates a new order from a list of cart items and persists it.
class CreateOrder {
  final OrderRepository _repository;

  CreateOrder(this._repository);

  Future<Order> call({
    required List<OrderItem> items,
    String? note,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Cannot create an order with no items');
    }

    final now = DateTime.now();
    final orderId = const Uuid().v4();

    // Assign the orderId to each item
    final orderItems = items
        .map((item) => item.copyWith(orderId: orderId))
        .toList();

    final order = Order(
      localId: orderId,
      orderNumber: 0, // Will be assigned by auto-increment
      items: orderItems,
      status: OrderStatus.pending,
      note: note,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    return _repository.create(order);
  }
}
