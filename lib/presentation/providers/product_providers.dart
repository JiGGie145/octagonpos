import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/application/usecases/product/create_product.dart';
import 'package:flutter_pos/application/usecases/product/delete_product.dart';
import 'package:flutter_pos/application/usecases/product/get_products.dart';
import 'package:flutter_pos/application/usecases/product/update_product.dart';

import 'repository_providers.dart';

/// Provides the [GetProducts] use case.
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

/// Provides the [CreateProduct] use case.
final createProductUseCaseProvider = Provider<CreateProduct>((ref) {
  return CreateProduct(ref.watch(productRepositoryProvider));
});

/// Provides the [UpdateProduct] use case.
final updateProductUseCaseProvider = Provider<UpdateProduct>((ref) {
  return UpdateProduct(ref.watch(productRepositoryProvider));
});

/// Provides the [DeleteProduct] use case.
final deleteProductUseCaseProvider = Provider<DeleteProduct>((ref) {
  return DeleteProduct(ref.watch(productRepositoryProvider));
});

/// Async provider for the full product list.
/// Invalidate this to refresh after create/update/delete.
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final getProducts = ref.watch(getProductsUseCaseProvider);
  return getProducts();
});

/// The currently selected category filter (null = "All").
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// The current search query.
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered product list based on category and search query.
final filteredProductListProvider = FutureProvider<List<Product>>((ref) async {
  final allProducts = await ref.watch(productListProvider.future);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(productSearchQueryProvider).toLowerCase();

  var filtered = allProducts;

  // Filter by category
  if (category != null && category.isNotEmpty) {
    filtered = filtered
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Filter by search query
  if (query.isNotEmpty) {
    filtered = filtered
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  return filtered;
});

/// Extracts unique categories from the product list.
final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final products = await ref.watch(productListProvider.future);
  final categories = products.map((p) => p.category).toSet().toList();
  categories.sort();
  return categories;
});
