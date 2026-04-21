import 'package:flutter_pos/domain/entities/restock_entry.dart';

/// Contract for restock entry data access.
abstract class RestockRepository {
  /// Returns all restock entries for the given [productId].
  Future<List<RestockEntry>> getByProductId(String productId);

  /// Returns all restock entries whose [date] falls within [from]..[to] (inclusive).
  Future<List<RestockEntry>> getByDateRange(DateTime from, DateTime to);

  /// Persists a new restock entry. Returns the created entry.
  Future<RestockEntry> create(RestockEntry entry);

  /// Deletes a restock entry by [localId].
  Future<void> delete(String localId);
}
