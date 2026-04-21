import 'package:drift/drift.dart';

/// Drift table definition for products.
///
/// Prices are stored as integers in cents.
/// Stock quantities are stored as doubles to support fractional units (kg, L).
class Products extends Table {
  TextColumn get localId => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get price => integer()(); // cents
  TextColumn get category => text().withLength(min: 1, max: 100)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  // ── Inventory fields (Phase 1) ──────────────────────────────────────
  BoolColumn get trackStock =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get usesIngredients =>
      boolean().withDefault(const Constant(false))();
  RealColumn get stockQty => real().nullable()();
  RealColumn get lowStockThreshold => real().nullable()();
  IntColumn get costPrice => integer().nullable()(); // cents
  BoolColumn get isSellable =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {localId};
}
