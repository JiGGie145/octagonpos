import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/stock_adjustment.dart' as domain;

/// Maps between Drift [StockAdjustment] data class and domain [domain.StockAdjustment].
class StockAdjustmentMapper {
  StockAdjustmentMapper._();

  static domain.StockAdjustment toDomain(StockAdjustment row) {
    return domain.StockAdjustment(
      localId: row.localId,
      productId: row.productId,
      quantityChange: row.quantityChange,
      reason: row.reason,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static StockAdjustmentsCompanion toCompanion(domain.StockAdjustment entity) {
    return StockAdjustmentsCompanion(
      localId: Value(entity.localId),
      productId: Value(entity.productId),
      quantityChange: Value(entity.quantityChange),
      reason: Value(entity.reason),
      date: Value(entity.date),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
