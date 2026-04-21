import 'package:flutter_pos/domain/entities/stock_adjustment.dart';

/// Contract for stock adjustment data access.
abstract class StockAdjustmentRepository {
  /// Returns all adjustments for the given [productId].
  Future<List<StockAdjustment>> getByProductId(String productId);

  /// Returns all adjustments whose [date] falls within [from]..[to] (inclusive).
  Future<List<StockAdjustment>> getByDateRange(DateTime from, DateTime to);

  /// Persists a new stock adjustment. Returns the created adjustment.
  Future<StockAdjustment> create(StockAdjustment adjustment);

  /// Deletes an adjustment by [localId].
  Future<void> delete(String localId);
}
