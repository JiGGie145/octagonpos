import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

/// Updates an existing product's details.
class UpdateProduct {
  final ProductRepository _repository;

  UpdateProduct(this._repository);

  Future<Product> call(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    return _repository.update(updated);
  }
}
