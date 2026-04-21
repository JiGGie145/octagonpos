import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/restock_entry.dart' as domain;

/// Maps between Drift [RestockEntry] data class and domain [domain.RestockEntry].
class RestockEntryMapper {
  RestockEntryMapper._();

  static domain.RestockEntry toDomain(RestockEntry row) {
    return domain.RestockEntry(
      localId: row.localId,
      productId: row.productId,
      quantityAdded: row.quantityAdded,
      unitCost: row.unitCost,
      totalCost: row.totalCost,
      date: row.date,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static RestockEntriesCompanion toCompanion(domain.RestockEntry entity) {
    return RestockEntriesCompanion(
      localId: Value(entity.localId),
      productId: Value(entity.productId),
      quantityAdded: Value(entity.quantityAdded),
      unitCost: Value(entity.unitCost),
      totalCost: Value(entity.totalCost),
      date: Value(entity.date),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
