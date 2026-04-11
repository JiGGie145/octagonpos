import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';

/// Contract for order data access.
///
/// Implementations live in the data layer.
/// Soft-deleted orders must be excluded from [getAll] by default.
abstract class OrderRepository {
  /// Returns all non-deleted orders, most recent first.
  Future<List<Order>> getAll();

  /// Returns a single order with its items by [localId], or `null`.
  Future<Order?> getById(String localId);

  /// Returns all non-deleted orders matching the given [status].
  Future<List<Order>> getByStatus(OrderStatus status);

  /// Returns non-deleted orders created within [from] (inclusive) to [to] (exclusive).
  Future<List<Order>> getByDateRange(DateTime from, DateTime to);

  /// Returns non-deleted orders matching [status] created within [from] to [to].
  Future<List<Order>> getByStatusAndDateRange(
      OrderStatus status, DateTime from, DateTime to);

  /// Persists a new order with its items. Returns the created order.
  Future<Order> create(Order order);

  /// Updates an existing order (items, note, etc.). Returns the updated order.
  Future<Order> update(Order order);

  /// Updates only the status of an order.
  Future<void> updateStatus(String localId, OrderStatus status);

  /// Soft-deletes an order by setting its [deletedAt] timestamp.
  /// Paid orders must never be hard-deleted.
  Future<void> softDelete(String localId);

  /// Returns the next available order number.
  Future<int> getNextOrderNumber();
}
