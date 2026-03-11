import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';

/// A simple in-memory mock of [OrderRepository] for unit tests.
class MockOrderRepository implements OrderRepository {
  final List<Order> _orders = [];
  final List<String> callLog = [];
  Order? createResult;

  @override
  Future<Order> create(Order order) async {
    callLog.add('create');
    _orders.add(order);
    return createResult ?? order.copyWith(orderNumber: _orders.length);
  }

  @override
  Future<List<Order>> getAll() async {
    callLog.add('getAll');
    return _orders.where((o) => !o.isDeleted).toList();
  }

  @override
  Future<Order?> getById(String localId) async {
    callLog.add('getById');
    try {
      return _orders.firstWhere((o) => o.localId == localId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Order>> getByStatus(OrderStatus status) async {
    callLog.add('getByStatus');
    return _orders.where((o) => o.status == status && !o.isDeleted).toList();
  }

  @override
  Future<Order> update(Order order) async {
    callLog.add('update');
    final index = _orders.indexWhere((o) => o.localId == order.localId);
    if (index >= 0) _orders[index] = order;
    return order;
  }

  @override
  Future<void> updateStatus(String localId, OrderStatus status) async {
    callLog.add('updateStatus:$localId:${status.name}');
    final index = _orders.indexWhere((o) => o.localId == localId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }

  @override
  Future<void> softDelete(String localId) async {
    callLog.add('softDelete');
    final index = _orders.indexWhere((o) => o.localId == localId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(deletedAt: DateTime.now());
    }
  }
}
