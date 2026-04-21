/// A single ingredient row in a product's recipe (Bill of Materials).
///
/// Pure Dart — no Flutter or database imports.
/// [quantityRequired] is a double to support fractional ingredient amounts.
class RecipeItem {
  final String localId;

  /// The product that is built from this recipe (the composed product).
  final String productId;

  /// The product used as an ingredient.
  final String ingredientProductId;

  /// How much of the ingredient is needed per unit of the recipe product.
  final double quantityRequired;

  const RecipeItem({
    required this.localId,
    required this.productId,
    required this.ingredientProductId,
    required this.quantityRequired,
  });

  RecipeItem copyWith({
    String? localId,
    String? productId,
    String? ingredientProductId,
    double? quantityRequired,
  }) {
    return RecipeItem(
      localId: localId ?? this.localId,
      productId: productId ?? this.productId,
      ingredientProductId: ingredientProductId ?? this.ingredientProductId,
      quantityRequired: quantityRequired ?? this.quantityRequired,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeItem &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'RecipeItem(productId: $productId, ingredient: $ingredientProductId, qty: $quantityRequired)';
}
