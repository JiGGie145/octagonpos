import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/order.dart' as domain;
import 'package:flutter_pos/domain/entities/order_item.dart' as domain;
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';

/// Maps between Drift [Order]/[OrderItem] data classes and domain entities.
class OrderMapper {
  OrderMapper._();

  /// Converts a Drift [Order] row + its items to a domain entity.
  static domain.Order toDomain(Order row, List<domain.OrderItem> items) {
    return domain.Order(
      localId: row.localId,
      orderNumber: row.orderNumber,
      items: items,
      status: OrderStatus.fromString(row.status),
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      syncStatus: SyncStatus.fromString(row.syncStatus),
    );
  }

  /// Converts a domain order to a Drift [OrdersCompanion] for insert.
  /// Note: [orderNumber] is auto-incremented, so it's absent on insert.
  static OrdersCompanion toInsertCompanion(domain.Order entity) {
    return OrdersCompanion(
      localId: Value(entity.localId),
      status: Value(entity.status.name),
      note: Value(entity.note),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: Value(entity.syncStatus.name),
    );
  }

  /// Converts a domain order to a Drift [OrdersCompanion] for update.
  static OrdersCompanion toUpdateCompanion(domain.Order entity) {
    return OrdersCompanion(
      localId: Value(entity.localId),
      orderNumber: Value(entity.orderNumber),
      status: Value(entity.status.name),
      note: Value(entity.note),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: Value(entity.syncStatus.name),
    );
  }

  /// Converts a Drift [OrderItem] row to a domain entity.
  static domain.OrderItem itemToDomain(OrderItem row) {
    return domain.OrderItem(
      localId: row.localId,
      orderId: row.orderId,
      productId: row.productId,
      productName: row.productName,
      quantity: row.quantity,
      unitPrice: row.unitPrice,
      costSnapshotTotal: row.costSnapshotTotal,
      revenueSnapshotTotal: row.revenueSnapshotTotal,
    );
  }

  /// Converts a domain order item to a Drift [OrderItemsCompanion].
  static OrderItemsCompanion itemToCompanion(domain.OrderItem entity) {
    return OrderItemsCompanion(
      localId: Value(entity.localId),
      orderId: Value(entity.orderId),
      productId: Value(entity.productId),
      productName: Value(entity.productName),
      quantity: Value(entity.quantity),
      unitPrice: Value(entity.unitPrice),
      costSnapshotTotal: Value(entity.costSnapshotTotal),
      revenueSnapshotTotal: Value(entity.revenueSnapshotTotal),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
  }
}
