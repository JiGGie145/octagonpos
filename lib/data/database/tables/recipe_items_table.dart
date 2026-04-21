import 'package:drift/drift.dart';

/// Drift table definition for recipe/BOM (Bill of Materials) items.
///
/// Links a recipe product to its constituent ingredient products.
/// [quantityRequired] is stored as double to support fractional amounts (e.g. 0.5 kg).
class RecipeItems extends Table {
  TextColumn get localId => text()();

  /// The product that is composed of ingredients (the recipe product).
  TextColumn get productId => text()();

  /// The product used as an ingredient in the recipe.
  TextColumn get ingredientProductId => text()();

  /// How much of the ingredient is needed per unit of the recipe product.
  RealColumn get quantityRequired => real()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
