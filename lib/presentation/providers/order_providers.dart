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

/// Represents the date range filter for the order list.
enum DateFilter {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  allTime('All Time');

  final String label;
  const DateFilter(this.label);

  /// Returns the [from, to) date range for this filter, or `null` for all time.
  ({DateTime from, DateTime to})? get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      DateFilter.today => (from: today, to: today.add(const Duration(days: 1))),
      DateFilter.yesterday => (
          from: today.subtract(const Duration(days: 1)),
          to: today,
        ),
      DateFilter.last7Days => (
          from: today.subtract(const Duration(days: 6)),
          to: today.add(const Duration(days: 1)),
        ),
      DateFilter.last30Days => (
          from: today.subtract(const Duration(days: 29)),
          to: today.add(const Duration(days: 1)),
        ),
      DateFilter.allTime => null,
    };
  }
}

/// Selected date filter — defaults to today.
final selectedDateFilterProvider =
    StateProvider<DateFilter>((ref) => DateFilter.today);

/// Filtered order list based on selected status and date filter.
final filteredOrderListProvider = FutureProvider<List<Order>>((ref) async {
  final status = ref.watch(selectedOrderStatusProvider);
  final dateFilter = ref.watch(selectedDateFilterProvider);
  final getOrders = ref.watch(getOrdersUseCaseProvider);

  final range = dateFilter.dateRange;

  if (status != null && range != null) {
    return getOrders.byStatusAndDateRange(status, range.from, range.to);
  }
  if (status != null) {
    return getOrders.byStatus(status);
  }
  if (range != null) {
    return getOrders.byDateRange(range.from, range.to);
  }
  return getOrders();
});

/// Provider for a single order's detail (with items & payments).
final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, localId) async {
  final getOrderDetail = ref.watch(getOrderDetailUseCaseProvider);
  return getOrderDetail(localId);
});
