import 'package:flutter_pos/domain/entities/recipe_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecipeItem makeItem({
    String localId = 'ri-1',
    String productId = 'prod-1',
    String ingredientProductId = 'ing-1',
    double quantityRequired = 1.5,
  }) {
    return RecipeItem(
      localId: localId,
      productId: productId,
      ingredientProductId: ingredientProductId,
      quantityRequired: quantityRequired,
    );
  }

  group('RecipeItem', () {
    test('copyWith preserves values when no args provided', () {
      final item = makeItem();
      final copy = item.copyWith();

      expect(copy.localId, item.localId);
      expect(copy.productId, item.productId);
      expect(copy.ingredientProductId, item.ingredientProductId);
      expect(copy.quantityRequired, item.quantityRequired);
    });

    test('copyWith overrides provided values', () {
      final item = makeItem();
      final copy = item.copyWith(quantityRequired: 2.25, ingredientProductId: 'ing-2');

      expect(copy.quantityRequired, 2.25);
      expect(copy.ingredientProductId, 'ing-2');
      expect(copy.productId, item.productId);
    });

    test('equality uses localId', () {
      final a = makeItem(localId: 'same');
      final b = makeItem(localId: 'same', quantityRequired: 99);
      final c = makeItem(localId: 'different');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
