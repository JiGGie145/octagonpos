import 'package:drift/drift.dart';

/// Drift table definition for payments.
///
/// [amount] is stored in cents.
class Payments extends Table {
  TextColumn get localId => text()();
  TextColumn get orderId => text()();
  TextColumn get method => text()(); // 'cash' or 'card'
  IntColumn get amount => integer()(); // cents
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
