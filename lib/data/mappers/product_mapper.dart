import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/product.dart' as domain;
import 'package:flutter_pos/domain/enums/sync_status.dart';

/// Maps between Drift [Product] data class and domain [domain.Product] entity.
class ProductMapper {
  ProductMapper._();

  /// Converts a Drift [Product] row to a domain entity.
  static domain.Product toDomain(Product row) {
    return domain.Product(
      localId: row.localId,
      name: row.name,
      price: row.price,
      category: row.category,
      isActive: row.isActive,
      imageUrl: row.imageUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      syncStatus: SyncStatus.fromString(row.syncStatus),
    );
  }

  /// Converts a domain entity to a Drift [ProductsCompanion] for insert/update.
  static ProductsCompanion toCompanion(domain.Product entity) {
    return ProductsCompanion(
      localId: Value(entity.localId),
      name: Value(entity.name),
      price: Value(entity.price),
      category: Value(entity.category),
      isActive: Value(entity.isActive),
      imageUrl: Value(entity.imageUrl),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: Value(entity.syncStatus.name),
    );
  }
}
