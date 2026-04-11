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

  /// Returns non-deleted orders created within [from] (inclusive) to [to] (exclusive).
  Future<List<Order>> byDateRange(DateTime from, DateTime to) async {
    return _repository.getByDateRange(from, to);
  }

  /// Returns non-deleted orders matching [status] within [from] to [to].
  Future<List<Order>> byStatusAndDateRange(
      OrderStatus status, DateTime from, DateTime to) async {
    return _repository.getByStatusAndDateRange(status, from, to);
  }
}
