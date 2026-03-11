import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/application/usecases/order/create_order.dart';
import 'package:flutter_pos/application/usecases/order/get_order_detail.dart';
import 'package:flutter_pos/application/usecases/order/get_orders.dart';
import 'package:flutter_pos/application/usecases/order/update_order_status.dart';

import 'repository_providers.dart';

/// Provides the [GetOrders] use case.
final getOrdersUseCaseProvider = Provider<GetOrders>((ref) {
  return GetOrders(ref.watch(orderRepositoryProvider));
});

/// Provides the [CreateOrder] use case.
final createOrderUseCaseProvider = Provider<CreateOrder>((ref) {
  return CreateOrder(ref.watch(orderRepositoryProvider));
});

/// Provides the [UpdateOrderStatus] use case.
final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatus>((ref) {
  return UpdateOrderStatus(ref.watch(orderRepositoryProvider));
});

/// Provides the [GetOrderDetail] use case.
final getOrderDetailUseCaseProvider = Provider<GetOrderDetail>((ref) {
  return GetOrderDetail(ref.watch(orderRepositoryProvider));
});

/// Async provider for the full order list.
/// Invalidate to refresh after create / status change.
final orderListProvider = FutureProvider<List<Order>>((ref) async {
  final getOrders = ref.watch(getOrdersUseCaseProvider);
  return getOrders();
});

/// Optional status filter for the order list.
final selectedOrderStatusProvider = StateProvider<OrderStatus?>((ref) => null);

/// Filtered order list based on selected status.
final filteredOrderListProvider = FutureProvider<List<Order>>((ref) async {
  final status = ref.watch(selectedOrderStatusProvider);
  final getOrders = ref.watch(getOrdersUseCaseProvider);

  if (status != null) {
    return getOrders.byStatus(status);
  }
  return getOrders();
});

/// Provider for a single order's detail (with items & payments).
final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, localId) async {
  final getOrderDetail = ref.watch(getOrderDetailUseCaseProvider);
  return getOrderDetail(localId);
});
