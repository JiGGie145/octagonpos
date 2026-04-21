import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/products_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/payments_table.dart';
import 'tables/settings_table.dart';
import 'tables/recipe_items_table.dart';
import 'tables/restock_entries_table.dart';
import 'tables/stock_adjustments_table.dart';

part 'app_database.g.dart';

/// The main Drift database for the POS application.
///
/// Schema version 2 — adds inventory tables and new product/order-item columns.
@DriftDatabase(tables: [
  Products,
  Orders,
  OrderItems,
  Payments,
  Settings,
  RecipeItems,
  RestockEntries,
  StockAdjustments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add inventory columns to products table
          await m.addColumn(products, products.trackStock);
          await m.addColumn(products, products.usesIngredients);
          await m.addColumn(products, products.stockQty);
          await m.addColumn(products, products.lowStockThreshold);
          await m.addColumn(products, products.costPrice);
          await m.addColumn(products, products.isSellable);

          // Add cost/revenue snapshot columns to order_items table
          await m.addColumn(orderItems, orderItems.costSnapshotTotal);
          await m.addColumn(orderItems, orderItems.revenueSnapshotTotal);

          // Create new inventory tables
          await m.createTable(recipeItems);
          await m.createTable(restockEntries);
          await m.createTable(stockAdjustments);
        }
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

  /// Updates the cost and revenue snapshots for a single order item.
  Future<bool> updateOrderItemSnapshots(
      String localId, int? costSnapshot, int revenueSnapshot) {
    return (update(orderItems)..where((i) => i.localId.equals(localId)))
        .write(OrderItemsCompanion(
          costSnapshotTotal: Value(costSnapshot),
          revenueSnapshotTotal: Value(revenueSnapshot),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
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

  // ═══════════════════════════════════════════════════════════════════
  // RECIPE ITEM QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all recipe items for a given product (its ingredient list).
  Future<List<RecipeItem>> getRecipeItemsByProductId(String productId) {
    return (select(recipeItems)
          ..where((r) => r.productId.equals(productId)))
        .get();
  }

  /// Inserts a new recipe item.
  Future<int> insertRecipeItem(RecipeItemsCompanion item) {
    return into(recipeItems).insert(item);
  }

  /// Deletes all recipe items for a product (used when replacing a recipe).
  Future<int> deleteRecipeItemsByProductId(String productId) {
    return (delete(recipeItems)
          ..where((r) => r.productId.equals(productId)))
        .go();
  }

  // ═══════════════════════════════════════════════════════════════════
  // RESTOCK ENTRY QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all restock entries for a product, newest first.
  Future<List<RestockEntry>> getRestockEntriesByProductId(String productId) {
    return (select(restockEntries)
          ..where((r) => r.productId.equals(productId))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .get();
  }

  /// Returns restock entries within a date range.
  Future<List<RestockEntry>> getRestockEntriesByDateRange(
      DateTime from, DateTime to) {
    return (select(restockEntries)
          ..where((r) =>
              r.date.isBiggerOrEqualValue(from) &
              r.date.isSmallerThanValue(to))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .get();
  }

  /// Inserts a new restock entry.
  Future<int> insertRestockEntry(RestockEntriesCompanion entry) {
    return into(restockEntries).insert(entry);
  }

  /// Deletes a restock entry by localId.
  Future<int> deleteRestockEntry(String localId) {
    return (delete(restockEntries)
          ..where((r) => r.localId.equals(localId)))
        .go();
  }

  // ═══════════════════════════════════════════════════════════════════
  // STOCK ADJUSTMENT QUERIES
  // ═══════════════════════════════════════════════════════════════════

  /// Returns all stock adjustments for a product, newest first.
  Future<List<StockAdjustment>> getStockAdjustmentsByProductId(
      String productId) {
    return (select(stockAdjustments)
          ..where((a) => a.productId.equals(productId))
          ..orderBy([(a) => OrderingTerm.desc(a.date)]))
        .get();
  }

  /// Returns stock adjustments within a date range.
  Future<List<StockAdjustment>> getStockAdjustmentsByDateRange(
      DateTime from, DateTime to) {
    return (select(stockAdjustments)
          ..where((a) =>
              a.date.isBiggerOrEqualValue(from) &
              a.date.isSmallerThanValue(to))
          ..orderBy([(a) => OrderingTerm.desc(a.date)]))
        .get();
  }

  /// Inserts a new stock adjustment.
  Future<int> insertStockAdjustment(StockAdjustmentsCompanion adjustment) {
    return into(stockAdjustments).insert(adjustment);
  }

  /// Deletes a stock adjustment by localId.
  Future<int> deleteStockAdjustment(String localId) {
    return (delete(stockAdjustments)
          ..where((a) => a.localId.equals(localId)))
        .go();
  }

  /// Updates a product's stock quantity directly.
  Future<bool> updateProductStock(String localId, double newQty) {
    return (update(products)..where((p) => p.localId.equals(localId)))
        .write(ProductsCompanion(
          stockQty: Value(newQty),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  /// Returns all products that have stock tracking enabled.
  Future<List<Product>> getTrackedProducts() {
    return (select(products)
          ..where((p) => p.trackStock.equals(true) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Returns all sellable, non-deleted products.
  Future<List<Product>> getSellableProducts() {
    return (select(products)
          ..where((p) =>
              p.isSellable.equals(true) &
              p.isActive.equals(true) &
              p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Returns all ingredient products (trackStock=true, isSellable=false or true).
  Future<List<Product>> getIngredientProducts() {
    return (select(products)
          ..where((p) =>
              p.trackStock.equals(true) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }
}
