import 'package:flutter_pos/domain/entities/stock_adjustment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 1, 1, 10, 0);

  StockAdjustment makeAdjustment({
    String localId = 'sa-1',
    String productId = 'prod-1',
    double quantityChange = -2.5,
    String? reason = 'Damage',
  }) {
    return StockAdjustment(
      localId: localId,
      productId: productId,
      quantityChange: quantityChange,
      reason: reason,
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('StockAdjustment', () {
    test('copyWith preserves values when no args provided', () {
      final adjustment = makeAdjustment();
      final copy = adjustment.copyWith();

      expect(copy.localId, adjustment.localId);
      expect(copy.productId, adjustment.productId);
      expect(copy.quantityChange, adjustment.quantityChange);
      expect(copy.reason, adjustment.reason);
    });

    test('copyWith overrides provided values', () {
      final adjustment = makeAdjustment();
      final copy = adjustment.copyWith(quantityChange: 4.0, reason: 'Stock count fix');

      expect(copy.quantityChange, 4.0);
      expect(copy.reason, 'Stock count fix');
      expect(copy.productId, adjustment.productId);
    });

    test('equality uses localId', () {
      final a = makeAdjustment(localId: 'same');
      final b = makeAdjustment(localId: 'same', quantityChange: 8);
      final c = makeAdjustment(localId: 'different');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
