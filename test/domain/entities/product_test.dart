import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';

void main() {
  final now = DateTime(2025, 1, 1, 12, 0);

  Product makeProduct({
    int price = 3500,
    bool isActive = true,
    DateTime? deletedAt,
    String? imageUrl,
    bool trackStock = false,
    bool usesIngredients = false,
    double? stockQty,
    double? lowStockThreshold,
    int? costPrice,
    bool isSellable = true,
  }) {
    return Product(
      localId: 'prod-1',
      name: 'Coffee',
      price: price,
      category: 'Beverages',
      isActive: isActive,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
      deletedAt: deletedAt,
      trackStock: trackStock,
      usesIngredients: usesIngredients,
      stockQty: stockQty,
      lowStockThreshold: lowStockThreshold,
      costPrice: costPrice,
      isSellable: isSellable,
    );
  }

  group('Product', () {
    group('isDeleted', () {
      test('returns false when deletedAt is null', () {
        expect(makeProduct().isDeleted, false);
      });

      test('returns true when deletedAt is set', () {
        expect(makeProduct(deletedAt: DateTime(2025, 6, 1)).isDeleted, true);
      });
    });

    group('priceInMajorUnits', () {
      test('converts cents to major units', () {
        expect(makeProduct(price: 3500).priceInMajorUnits, 35.0);
      });

      test('handles zero', () {
        expect(makeProduct(price: 0).priceInMajorUnits, 0.0);
      });

      test('handles sub-unit amounts', () {
        expect(makeProduct(price: 50).priceInMajorUnits, 0.5);
      });
    });

    group('copyWith', () {
      test('returns same values when no args given', () {
        final p = makeProduct();
        final copy = p.copyWith();
        expect(copy.localId, p.localId);
        expect(copy.name, p.name);
        expect(copy.price, p.price);
        expect(copy.category, p.category);
        expect(copy.isActive, p.isActive);
      });

      test('overrides specified fields', () {
        final p = makeProduct();
        final copy = p.copyWith(name: 'Tea', price: 2500);
        expect(copy.name, 'Tea');
        expect(copy.price, 2500);
        expect(copy.localId, p.localId); // unchanged
      });
    });

    test('defaults', () {
      final p = makeProduct();
      expect(p.isActive, true);
      expect(p.syncStatus, SyncStatus.pending);
      expect(p.imageUrl, isNull);
      expect(p.trackStock, false);
      expect(p.usesIngredients, false);
      expect(p.stockQty, isNull);
      expect(p.lowStockThreshold, isNull);
      expect(p.costPrice, isNull);
      expect(p.isSellable, true);
    });

    test('costPriceInMajorUnits returns converted value when set', () {
      final p = makeProduct(costPrice: 1250);
      expect(p.costPriceInMajorUnits, 12.5);
    });

    test('costPriceInMajorUnits returns null when costPrice is null', () {
      final p = makeProduct(costPrice: null);
      expect(p.costPriceInMajorUnits, isNull);
    });

    test('copyWith overrides inventory-specific fields', () {
      final p = makeProduct();
      final copy = p.copyWith(
        trackStock: true,
        usesIngredients: true,
        stockQty: 3.5,
        lowStockThreshold: 1.0,
        costPrice: 1500,
        isSellable: false,
      );

      expect(copy.trackStock, true);
      expect(copy.usesIngredients, true);
      expect(copy.stockQty, 3.5);
      expect(copy.lowStockThreshold, 1.0);
      expect(copy.costPrice, 1500);
      expect(copy.isSellable, false);
    });
  });
}
