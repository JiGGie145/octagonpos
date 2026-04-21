import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/product_mapper.dart';
import 'package:flutter_pos/domain/entities/product.dart' as domain;
import 'package:flutter_pos/domain/repositories/product_repository.dart';

/// Drift-backed implementation of [ProductRepository].
class DriftProductRepository implements ProductRepository {
  final AppDatabase _db;

  DriftProductRepository(this._db);

  @override
  Future<List<domain.Product>> getAll() async {
    final rows = await _db.getAllProducts();
    return rows.map(ProductMapper.toDomain).toList();
  }

  @override
  Future<domain.Product?> getById(String localId) async {
    final row = await _db.getProductById(localId);
    return row != null ? ProductMapper.toDomain(row) : null;
  }

  @override
  Future<List<domain.Product>> getByCategory(String category) async {
    final rows = await _db.getProductsByCategory(category);
    return rows.map(ProductMapper.toDomain).toList();
  }

  @override
  Future<domain.Product> create(domain.Product product) async {
    final companion = ProductMapper.toCompanion(product);
    await _db.insertProduct(companion);
    return product;
  }

  @override
  Future<domain.Product> update(domain.Product product) async {
    final companion = ProductMapper.toCompanion(
      product.copyWith(updatedAt: DateTime.now()),
    );
    await _db.updateProduct(companion);
    return product;
  }

  @override
  Future<void> softDelete(String localId) async {
    await _db.softDeleteProduct(localId);
  }

  // ── Inventory-specific ────────────────────────────────────────────

  @override
  Future<List<domain.Product>> getSellableProducts() async {
    final rows = await _db.getSellableProducts();
    return rows.map(ProductMapper.toDomain).toList();
  }

  @override
  Future<List<domain.Product>> getIngredients() async {
    final rows = await _db.getIngredientProducts();
    return rows.map(ProductMapper.toDomain).toList();
  }

  @override
  Future<List<domain.Product>> getAllIncludingIngredients() async {
    final rows = await _db.getAllProducts();
    return rows.map(ProductMapper.toDomain).toList();
  }

  @override
  Future<void> updateStock(String localId, double newQty) async {
    await _db.updateProductStock(localId, newQty);
  }
}
