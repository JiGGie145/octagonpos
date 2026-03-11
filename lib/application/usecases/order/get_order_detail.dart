import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';

/// Retrieves a single order with all its items and details.
class GetOrderDetail {
  final OrderRepository _repository;

  GetOrderDetail(this._repository);

  Future<Order?> call(String localId) async {
    return _repository.getById(localId);
  }
}
