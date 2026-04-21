import 'package:flutter_pos/domain/entities/recipe_item.dart';

/// Contract for recipe (Bill of Materials) data access.
///
/// A recipe defines which ingredient products — and in what quantities —
/// are needed to produce one unit of a composed product.
abstract class RecipeRepository {
  /// Returns all [RecipeItem]s for the given [productId].
  Future<List<RecipeItem>> getByProductId(String productId);

  /// Replaces the full recipe for [productId] with [items].
  ///
  /// Implementations should delete existing recipe rows and insert the new set
  /// within a single transaction.
  Future<void> setRecipe(String productId, List<RecipeItem> items);

  /// Deletes all recipe items for the given [productId].
  Future<void> deleteByProductId(String productId);
}
