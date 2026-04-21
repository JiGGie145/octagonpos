import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/restock_entry_mapper.dart';
import 'package:flutter_pos/domain/entities/restock_entry.dart' as domain;
import 'package:flutter_pos/domain/repositories/restock_repository.dart';

/// Drift-backed implementation of [RestockRepository].
class DriftRestockRepository implements RestockRepository {
  final AppDatabase _db;

  DriftRestockRepository(this._db);

  @override
  Future<List<domain.RestockEntry>> getByProductId(String productId) async {
    final rows = await _db.getRestockEntriesByProductId(productId);
    return rows.map(RestockEntryMapper.toDomain).toList();
  }

  @override
  Future<List<domain.RestockEntry>> getByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.getRestockEntriesByDateRange(from, to);
    return rows.map(RestockEntryMapper.toDomain).toList();
  }

  @override
  Future<domain.RestockEntry> create(domain.RestockEntry entry) async {
    await _db.insertRestockEntry(RestockEntryMapper.toCompanion(entry));
    return entry;
  }

  @override
  Future<void> delete(String localId) async {
    await _db.deleteRestockEntry(localId);
  }
}
