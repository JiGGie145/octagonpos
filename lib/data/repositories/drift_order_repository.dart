import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/order_mapper.dart';
import 'package:flutter_pos/domain/entities/order.dart' as domain;
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';

/// Drift-backed implementation of [OrderRepository].
class DriftOrderRepository implements OrderRepository {
  final AppDatabase _db;

  DriftOrderRepository(this._db);

  @override
  Future<List<domain.Order>> getAll() async {
    final rows = await _db.getAllOrders();
    final results = <domain.Order>[];
    for (final row in rows) {
      final itemRows = await _db.getOrderItems(row.localId);
      final items = itemRows.map(OrderMapper.itemToDomain).toList();
      results.add(OrderMapper.toDomain(row, items));
    }
    return results;
  }

  @override
  Future<domain.Order?> getById(String localId) async {
    final row = await _db.getOrderByLocalId(localId);
    if (row == null) return null;
    final itemRows = await _db.getOrderItems(localId);
    final items = itemRows.map(OrderMapper.itemToDomain).toList();
    return OrderMapper.toDomain(row, items);
  }

  @override
  Future<List<domain.Order>> getByStatus(OrderStatus status) async {
    final rows = await _db.getOrdersByStatus(status.name);
    final results = <domain.Order>[];
    for (final row in rows) {
      final itemRows = await _db.getOrderItems(row.localId);
      final items = itemRows.map(OrderMapper.itemToDomain).toList();
      results.add(OrderMapper.toDomain(row, items));
    }
    return results;
  }

  @override
  Future<domain.Order> create(domain.Order order) async {
    final companion = OrderMapper.toInsertCompanion(order);
    final orderNumber = await _db.insertOrder(companion);

    // Insert all order items
    final itemCompanions =
        order.items.map(OrderMapper.itemToCompanion).toList();
    if (itemCompanions.isNotEmpty) {
      await _db.insertOrderItems(itemCompanions);
    }

    return order.copyWith(orderNumber: orderNumber);
  }

  @override
  Future<domain.Order> update(domain.Order order) async {
    final companion = OrderMapper.toUpdateCompanion(
      order.copyWith(updatedAt: DateTime.now()),
    );
    await _db.updateOrder(companion);

    // Replace all order items
    await _db.deleteOrderItems(order.localId);
    final itemCompanions =
        order.items.map(OrderMapper.itemToCompanion).toList();
    if (itemCompanions.isNotEmpty) {
      await _db.insertOrderItems(itemCompanions);
    }

    return order;
  }

  @override
  Future<void> updateStatus(String localId, OrderStatus status) async {
    await _db.updateOrderStatus(localId, status.name);
  }

  @override
  Future<void> softDelete(String localId) async {
    await _db.softDeleteOrder(localId);
  }

  @override
  Future<int> getNextOrderNumber() async {
    final max = await _db.getMaxOrderNumber();
    return max + 1;
  }
}
