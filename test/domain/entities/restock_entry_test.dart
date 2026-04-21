import 'package:flutter_pos/domain/entities/restock_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 1, 1, 10, 0);

  RestockEntry makeEntry({
    String localId = 're-1',
    String productId = 'prod-1',
    double quantityAdded = 10.5,
    int? unitCost = 1200,
    int? totalCost = 12600,
    String? notes = 'Weekly restock',
  }) {
    return RestockEntry(
      localId: localId,
      productId: productId,
      quantityAdded: quantityAdded,
      unitCost: unitCost,
      totalCost: totalCost,
      date: now,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('RestockEntry', () {
    test('copyWith preserves values when no args provided', () {
      final entry = makeEntry();
      final copy = entry.copyWith();

      expect(copy.localId, entry.localId);
      expect(copy.productId, entry.productId);
      expect(copy.quantityAdded, entry.quantityAdded);
      expect(copy.unitCost, entry.unitCost);
      expect(copy.totalCost, entry.totalCost);
      expect(copy.notes, entry.notes);
    });

    test('copyWith overrides provided values', () {
      final entry = makeEntry();
      final copy = entry.copyWith(quantityAdded: 3.25, unitCost: 1500, notes: 'Correction');

      expect(copy.quantityAdded, 3.25);
      expect(copy.unitCost, 1500);
      expect(copy.notes, 'Correction');
      expect(copy.productId, entry.productId);
    });

    test('equality uses localId', () {
      final a = makeEntry(localId: 'same');
      final b = makeEntry(localId: 'same', quantityAdded: 1);
      final c = makeEntry(localId: 'different');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
