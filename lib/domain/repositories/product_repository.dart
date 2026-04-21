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

  // ── Inventory-specific queries ────────────────────────────────────

  /// Returns all active products that are marked for sale (isSellable = true).
  Future<List<Product>> getSellableProducts();

  /// Returns all active products that are used as ingredients
  /// (usesIngredients = false, i.e. raw ingredients themselves).
  Future<List<Product>> getIngredients();

  /// Returns all active products including those flagged as ingredients only.
  Future<List<Product>> getAllIncludingIngredients();

  /// Updates the [stockQty] for a given product identified by [localId].
  Future<void> updateStock(String localId, double newQty);
}
