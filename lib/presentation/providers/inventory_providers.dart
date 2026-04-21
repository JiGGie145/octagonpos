import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/entities/recipe_item.dart';
import 'package:flutter_pos/domain/entities/restock_entry.dart';
import 'package:flutter_pos/domain/entities/stock_adjustment.dart';

import 'repository_providers.dart';

/// Visible product slices for inventory UIs.
enum InventoryProductView {
  sellable,
  ingredients,
  all,
}

/// The active inventory product filter tab.
final inventoryProductViewProvider =
    StateProvider<InventoryProductView>((ref) => InventoryProductView.sellable);

/// Search query for inventory screens.
final inventorySearchQueryProvider = StateProvider<String>((ref) => '');

/// Sellable products used in inventory contexts.
final sellableInventoryProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getSellableProducts();
});

/// Ingredient candidates used by recipe builders.
final ingredientInventoryProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getIngredients();
});

/// Full active catalog including ingredient-only products.
final allInventoryProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getAllIncludingIngredients();
});

/// Tracked products only (stock-enabled).
final trackedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final all = await ref.watch(allInventoryProductsProvider.future);
  return all.where((p) => p.trackStock).toList();
});

/// Visible products for inventory list screens (tab + query aware).
final inventoryVisibleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final view = ref.watch(inventoryProductViewProvider);
  final query = ref.watch(inventorySearchQueryProvider).trim().toLowerCase();

  final products = switch (view) {
    InventoryProductView.sellable =>
      await ref.watch(sellableInventoryProductsProvider.future),
    InventoryProductView.ingredients =>
      await ref.watch(ingredientInventoryProductsProvider.future),
    InventoryProductView.all => await ref.watch(allInventoryProductsProvider.future),
  };

  if (query.isEmpty) return products;
  return products
      .where((p) => p.name.toLowerCase().contains(query))
      .toList();
});

/// Recipe lines for a single product.
final recipeByProductProvider =
    FutureProvider.family<List<RecipeItem>, String>((ref, productId) {
  return ref.watch(recipeRepositoryProvider).getByProductId(productId);
});

/// Restock history for a single product.
final restocksByProductProvider =
    FutureProvider.family<List<RestockEntry>, String>((ref, productId) {
  return ref.watch(restockRepositoryProvider).getByProductId(productId);
});

/// Stock adjustment history for a single product.
final stockAdjustmentsByProductProvider =
    FutureProvider.family<List<StockAdjustment>, String>((ref, productId) {
  return ref.watch(stockAdjustmentRepositoryProvider).getByProductId(productId);
});
