import 'package:drift/drift.dart';

/// Drift table definition for orders.
///
/// [orderNumber] uses autoIncrement which makes it the implicit primary key.
/// [localId] is a unique UUID for sync readiness.
class Orders extends Table {
  TextColumn get localId => text().unique()();
  IntColumn get orderNumber => integer().autoIncrement()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
}
