import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

/// Retrieves products, optionally filtered by category.
/// Soft-deleted products are excluded by the repository.
class GetProducts {
  final ProductRepository _repository;

  GetProducts(this._repository);

  /// Returns all active products.
  Future<List<Product>> call() async {
    return _repository.getAll();
  }

  /// Returns active products in a specific category.
  Future<List<Product>> byCategory(String category) async {
    return _repository.getByCategory(category);
  }
}
