import 'package:drift/drift.dart';

/// Drift table definition for order line items.
///
/// [unitPrice] is stored in cents.
/// [productName] is denormalized for display even if the product is later deleted.
class OrderItems extends Table {
  TextColumn get localId => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text().withLength(min: 1, max: 255)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()(); // cents
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
