import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';

void main() {
  group('formatCurrency', () {
    test('formats standard amount', () {
      expect(formatCurrency(3500, 'R'), 'R35.00');
    });

    test('formats with different symbol', () {
      expect(formatCurrency(150, '£'), '£1.50');
    });

    test('formats zero', () {
      expect(formatCurrency(0, 'R'), 'R0.00');
    });

    test('formats sub-unit only', () {
      expect(formatCurrency(5, '\$'), '\$0.05');
    });

    test('pads minor units with leading zero', () {
      expect(formatCurrency(101, 'R'), 'R1.01');
    });

    test('formats large amount', () {
      expect(formatCurrency(1234567, 'R'), 'R12345.67');
    });

    test('handles negative amount', () {
      expect(formatCurrency(-500, 'R'), '-R5.00');
    });

    test('handles negative sub-unit', () {
      expect(formatCurrency(-3, 'R'), '-R0.03');
    });
  });
}
