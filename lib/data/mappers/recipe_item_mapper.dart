import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/recipe_item.dart' as domain;

/// Maps between Drift [RecipeItem] data class and domain [domain.RecipeItem].
class RecipeItemMapper {
  RecipeItemMapper._();

  static domain.RecipeItem toDomain(RecipeItem row) {
    return domain.RecipeItem(
      localId: row.localId,
      productId: row.productId,
      ingredientProductId: row.ingredientProductId,
      quantityRequired: row.quantityRequired,
    );
  }

  static RecipeItemsCompanion toCompanion(domain.RecipeItem entity) {
    return RecipeItemsCompanion(
      localId: Value(entity.localId),
      productId: Value(entity.productId),
      ingredientProductId: Value(entity.ingredientProductId),
      quantityRequired: Value(entity.quantityRequired),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
  }
}
