import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

/// Creates a new product and persists it to the repository.
class CreateProduct {
  final ProductRepository _repository;

  CreateProduct(this._repository);

  Future<Product> call({
    required String name,
    required int price,
    required String category,
    bool isActive = true,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    final product = Product(
      localId: const Uuid().v4(),
      name: name,
      price: price,
      category: category,
      isActive: isActive,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
    return _repository.create(product);
  }
}
