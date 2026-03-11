import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';

import 'order_item.dart';

/// A customer order containing one or more [OrderItem]s.
///
/// Pure Dart — no Flutter or database imports.
class Order {
  final String localId;
  final int orderNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  const Order({
    required this.localId,
    required this.orderNumber,
    this.items = const [],
    this.status = OrderStatus.pending,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.pending,
  });

  /// Subtotal in cents (sum of all line item totals).
  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Calculates tax in cents given a tax percentage (e.g. 15 for 15%).
  int taxAmount(int taxPercentage) => (subtotal * taxPercentage) ~/ 100;

  /// Calculates the grand total in cents given a tax percentage.
  int total(int taxPercentage) => subtotal + taxAmount(taxPercentage);

  /// Whether this order has been soft-deleted.
  bool get isDeleted => deletedAt != null;

  /// Whether this order can be modified (only pending orders).
  bool get isEditable => status == OrderStatus.pending;

  /// Formatted order number for display (e.g. "#1998").
  String get displayOrderNumber => '#$orderNumber';

  /// Creates a copy with the given fields replaced.
  Order copyWith({
    String? localId,
    int? orderNumber,
    List<OrderItem>? items,
    OrderStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
  }) {
    return Order(
      localId: localId ?? this.localId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'Order(localId: $localId, #$orderNumber, status: ${status.label}, '
      'items: ${items.length})';
}
