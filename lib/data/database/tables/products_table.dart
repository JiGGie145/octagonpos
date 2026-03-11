import 'package:drift/drift.dart';

/// Drift table definition for products.
///
/// Prices are stored as integers in cents.
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

  @override
  Set<Column> get primaryKey => {localId};
}
