import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/recipe_item_mapper.dart';
import 'package:flutter_pos/domain/entities/recipe_item.dart' as domain;
import 'package:flutter_pos/domain/repositories/recipe_repository.dart';
import 'package:uuid/uuid.dart';

/// Drift-backed implementation of [RecipeRepository].
class DriftRecipeRepository implements RecipeRepository {
  final AppDatabase _db;

  DriftRecipeRepository(this._db);

  @override
  Future<List<domain.RecipeItem>> getByProductId(String productId) async {
    final rows = await _db.getRecipeItemsByProductId(productId);
    return rows.map(RecipeItemMapper.toDomain).toList();
  }

  @override
  Future<void> setRecipe(
    String productId,
    List<domain.RecipeItem> items,
  ) async {
    await _db.transaction(() async {
      await _db.deleteRecipeItemsByProductId(productId);
      for (final item in items) {
        final withId = item.localId.isEmpty
            ? item.copyWith(localId: const Uuid().v4())
            : item;
        await _db.insertRecipeItem(RecipeItemMapper.toCompanion(withId));
      }
    });
  }

  @override
  Future<void> deleteByProductId(String productId) async {
    await _db.deleteRecipeItemsByProductId(productId);
  }
}
