import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/repositories/order_repository.dart';

/// Updates the status of an existing order.
class UpdateOrderStatus {
  final OrderRepository _repository;

  UpdateOrderStatus(this._repository);

  Future<void> call(String localId, OrderStatus newStatus) async {
    await _repository.updateStatus(localId, newStatus);
  }
}
