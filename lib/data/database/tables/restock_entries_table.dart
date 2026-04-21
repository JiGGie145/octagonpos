import 'package:drift/drift.dart';

/// Drift table definition for restock entries.
///
/// Records each time stock is added to a tracked product.
/// [quantityAdded] supports fractional quantities (e.g. 5.5 kg).
/// [unitCost] and [totalCost] are in cents (nullable — cost tracking is optional).
class RestockEntries extends Table {
  TextColumn get localId => text()();
  TextColumn get productId => text()();

  /// Quantity of stock added (supports fractional units).
  RealColumn get quantityAdded => real()();

  /// Cost per unit at time of restock, in cents. Nullable.
  IntColumn get unitCost => integer().nullable()();

  /// Total cost of this restock in cents. Nullable.
  IntColumn get totalCost => integer().nullable()();

  /// The date this restock occurred (user-provided, may differ from createdAt).
  DateTimeColumn get date => dateTime()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
