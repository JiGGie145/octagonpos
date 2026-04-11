import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/products_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/payments_table.dart';
import 'tables/settings_table.dart';

part 'app_database.g.dart';

/// The main Drift database for the POS application.
///
/// Schema version 1 — initial MVP tables.
@DriftDatabase(tables: [Products, Orders, OrderItems, Payments, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here:
        // if (from < 2) { ... }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'flutter_pos',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRODUCT QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all non-deleted products.
  Future<List<Product>> getAllProducts() {
    return (select(products)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Returns a single product by localId.
  Future<Product?> getProductById(String localId) {
    return (select(products)..where((p) => p.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Returns all non-deleted products in a category.
  Future<List<Product>> getProductsByCategory(String category) {
    return (select(products)
          ..where(
              (p) => p.category.equals(category) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Inserts a new product.
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  /// Updates an existing product.
  Future<bool> updateProduct(ProductsCompanion product) {
    return (update(products)
          ..where((p) => p.localId.equals(product.localId.value)))
        .write(product)
        .then((rows) => rows > 0);
  }

  /// Soft-deletes a product.
  Future<bool> softDeleteProduct(String localId) {
    return (update(products)..where((p) => p.localId.equals(localId)))
        .write(ProductsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ORDER QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all non-deleted orders, most recent first.
  Future<List<Order>> getAllOrders() {
    return (select(orders)
          ..where((o) => o.deletedAt.isNull())
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
  }

  /// Returns a single order by localId.
  Future<Order?> getOrderByLocalId(String localId) {
    return (select(orders)..where((o) => o.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Returns all non-deleted orders with a given status.
  Future<List<Order>> getOrdersByStatus(String status) {
    return (select(orders)
          ..where(
              (o) => o.status.equals(status) & o.deletedAt.isNull())
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
  }

  /// Returns non-deleted orders created within [from] (inclusive) to [to] (exclusive).
  Future<List<Order>> getOrdersByDateRange(DateTime from, DateTime to) {
    return (select(orders)
          ..where((o) =>
              o.deletedAt.isNull() &
              o.createdAt.isBiggerOrEqualValue(from) &
              o.createdAt.isSmallerThanValue(to))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
  }

  /// Returns non-deleted orders matching [status] within [from] to [to].
  Future<List<Order>> getOrdersByStatusAndDateRange(
      String status, DateTime from, DateTime to) {
    return (select(orders)
          ..where((o) =>
              o.status.equals(status) &
              o.deletedAt.isNull() &
              o.createdAt.isBiggerOrEqualValue(from) &
              o.createdAt.isSmallerThanValue(to))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
  }

  /// Inserts a new order and returns the auto-generated order number.
  Future<int> insertOrder(OrdersCompanion order) {
    return into(orders).insert(order);
  }

  /// Updates an existing order.
  Future<bool> updateOrder(OrdersCompanion order) {
    return (update(orders)
          ..where((o) => o.localId.equals(order.localId.value)))
        .write(order)
        .then((rows) => rows > 0);
  }

  /// Updates only the status of an order.
  Future<bool> updateOrderStatus(String localId, String status) {
    return (update(orders)..where((o) => o.localId.equals(localId)))
        .write(OrdersCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  /// Soft-deletes an order.
  Future<bool> softDeleteOrder(String localId) {
    return (update(orders)..where((o) => o.localId.equals(localId)))
        .write(OrdersCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  /// Returns the highest order number, or 0 if no orders exist.
  Future<int> getMaxOrderNumber() async {
    final query = selectOnly(orders)
      ..addColumns([orders.orderNumber.max()]);
    final result = await query.getSingle();
    return result.read(orders.orderNumber.max()) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ORDER ITEM QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all items for a given order.
  Future<List<OrderItem>> getOrderItems(String orderId) {
    return (select(orderItems)
          ..where((i) => i.orderId.equals(orderId)))
        .get();
  }

  /// Inserts a new order item.
  Future<int> insertOrderItem(OrderItemsCompanion item) {
    return into(orderItems).insert(item);
  }

  /// Inserts multiple order items in a batch.
  Future<void> insertOrderItems(List<OrderItemsCompanion> items) {
    return batch((b) {
      b.insertAll(orderItems, items);
    });
  }

  /// Deletes all items for a given order (used when updating an order).
  Future<int> deleteOrderItems(String orderId) {
    return (delete(orderItems)
          ..where((i) => i.orderId.equals(orderId)))
        .go();
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Inserts a new payment.
  Future<int> insertPayment(PaymentsCompanion payment) {
    return into(payments).insert(payment);
  }

  /// Returns the payment for a given order, or null.
  Future<Payment?> getPaymentByOrderId(String orderId) {
    return (select(payments)
          ..where((p) => p.orderId.equals(orderId)))
        .getSingleOrNull();
  }

  // ═══════════════════════════════════════════════════════════════════
  // SETTINGS QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns the business settings, or null if not configured.
  Future<Setting?> getSettings() {
    return (select(settings)..where((s) => s.id.equals(1)))
        .getSingleOrNull();
  }

  /// Inserts or updates the business settings (single row, id=1).
  Future<void> upsertSettings(SettingsCompanion data) {
    return into(settings).insertOnConflictUpdate(data);
  }
}
