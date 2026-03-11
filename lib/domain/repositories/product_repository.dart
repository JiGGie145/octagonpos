import 'package:flutter_pos/domain/entities/product.dart';

/// Contract for product data access.
///
/// Implementations live in the data layer.
/// Soft-deleted products (where [deletedAt] is set) must be excluded
/// from [getAll] and [getByCategory] by default.
abstract class ProductRepository {
  /// Returns all active (non-deleted) products.
  Future<List<Product>> getAll();

  /// Returns a single product by its [localId], or `null` if not found.
  Future<Product?> getById(String localId);

  /// Returns all active products matching the given [category].
  Future<List<Product>> getByCategory(String category);

  /// Persists a new product. Returns the created product.
  Future<Product> create(Product product);

  /// Updates an existing product. Returns the updated product.
  Future<Product> update(Product product);

  /// Soft-deletes a product by setting its [deletedAt] timestamp.
  Future<void> softDelete(String localId);
}
