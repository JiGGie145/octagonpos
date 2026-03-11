import 'package:flutter_pos/domain/repositories/product_repository.dart';

/// Soft-deletes a product by setting its deletedAt timestamp.
/// The product remains in the database but is hidden from queries.
class DeleteProduct {
  final ProductRepository _repository;

  DeleteProduct(this._repository);

  Future<void> call(String localId) async {
    await _repository.softDelete(localId);
  }
}
