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
    });
  });
}
