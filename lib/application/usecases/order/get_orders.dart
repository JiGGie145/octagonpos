import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';

/// Retrieves orders, optionally filtered by status.
/// Soft-deleted orders are excluded by the repository.
class GetOrders {
  final OrderRepository _repository;

  GetOrders(this._repository);

  /// Returns all non-deleted orders, most recent first.
  Future<List<Order>> call() async {
    return _repository.getAll();
  }

  /// Returns non-deleted orders matching a specific status.
  Future<List<Order>> byStatus(OrderStatus status) async {
    return _repository.getByStatus(status);
  }
}
