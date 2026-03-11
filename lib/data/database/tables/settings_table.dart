import 'package:drift/drift.dart';

/// Drift table definition for business settings.
///
/// This is a single-row table. [id] is always 1.
class Settings extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1))();
  TextColumn get businessName => text().withLength(min: 1, max: 255)();
  TextColumn get currency => text().withLength(min: 1, max: 10)();
  TextColumn get currencySymbol => text().withLength(min: 1, max: 5)();
  IntColumn get taxPercentage => integer()(); // e.g. 15 for 15%
  TextColumn get receiptFooter => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
