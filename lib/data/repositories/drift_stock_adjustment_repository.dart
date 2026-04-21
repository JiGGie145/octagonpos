import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/stock_adjustment_mapper.dart';
import 'package:flutter_pos/domain/entities/stock_adjustment.dart' as domain;
import 'package:flutter_pos/domain/repositories/stock_adjustment_repository.dart';

/// Drift-backed implementation of [StockAdjustmentRepository].
class DriftStockAdjustmentRepository implements StockAdjustmentRepository {
  final AppDatabase _db;

  DriftStockAdjustmentRepository(this._db);

  @override
  Future<List<domain.StockAdjustment>> getByProductId(
    String productId,
  ) async {
    final rows = await _db.getStockAdjustmentsByProductId(productId);
    return rows.map(StockAdjustmentMapper.toDomain).toList();
  }

  @override
  Future<List<domain.StockAdjustment>> getByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.getStockAdjustmentsByDateRange(from, to);
    return rows.map(StockAdjustmentMapper.toDomain).toList();
  }

  @override
  Future<domain.StockAdjustment> create(domain.StockAdjustment adjustment) async {
    await _db.insertStockAdjustment(
      StockAdjustmentMapper.toCompanion(adjustment),
    );
    return adjustment;
  }

  @override
  Future<void> delete(String localId) async {
    await _db.deleteStockAdjustment(localId);
  }
}
