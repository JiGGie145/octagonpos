import 'package:drift/drift.dart';

/// Drift table definition for manual stock adjustments.
///
/// Records ad-hoc corrections to a product's stock quantity.
/// [quantityChange] is signed: positive = stock added, negative = stock removed.
class StockAdjustments extends Table {
  TextColumn get localId => text()();
  TextColumn get productId => text()();

  /// Signed quantity change. Positive adds stock, negative removes it.
  RealColumn get quantityChange => real()();

  /// Optional reason for the adjustment (e.g. "damage", "count correction").
  TextColumn get reason => text().nullable()();

  /// The date this adjustment occurred (user-provided).
  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
