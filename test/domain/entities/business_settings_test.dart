import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';

void main() {
  BusinessSettings makeSettings({
    String businessName = 'Test Café',
    String currency = 'ZAR',
    String currencySymbol = 'R',
    int taxPercentage = 15,
    String receiptFooter = 'Thank you!',
  }) {
    return BusinessSettings(
      businessName: businessName,
      currency: currency,
      currencySymbol: currencySymbol,
      taxPercentage: taxPercentage,
      receiptFooter: receiptFooter,
    );
  }

  group('BusinessSettings', () {
    test('stores all fields correctly', () {
      final s = makeSettings();
      expect(s.businessName, 'Test Café');
      expect(s.currency, 'ZAR');
      expect(s.currencySymbol, 'R');
      expect(s.taxPercentage, 15);
      expect(s.receiptFooter, 'Thank you!');
    });

    test('receiptFooter defaults to empty string', () {
      const s = BusinessSettings(
        businessName: 'Shop',
        currency: 'USD',
        currencySymbol: '\$',
        taxPercentage: 10,
      );
      expect(s.receiptFooter, '');
    });

    group('copyWith', () {
      test('returns same values when no args given', () {
        final s = makeSettings();
        final copy = s.copyWith();
        expect(copy, equals(s));
      });

      test('overrides specified fields', () {
        final s = makeSettings();
        final copy = s.copyWith(
          businessName: 'New Name',
          taxPercentage: 20,
        );
        expect(copy.businessName, 'New Name');
        expect(copy.taxPercentage, 20);
        expect(copy.currency, s.currency); // unchanged
      });
    });

    group('equality', () {
      test('settings with same fields are equal', () {
        final a = makeSettings();
        final b = makeSettings();
        expect(a, equals(b));
      });

      test('settings with different fields are not equal', () {
        final a = makeSettings(businessName: 'A');
        final b = makeSettings(businessName: 'B');
        expect(a, isNot(equals(b)));
      });

      test('hashCode is consistent with equality', () {
        final a = makeSettings();
        final b = makeSettings();
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    test('toString contains business name and tax', () {
      final s = makeSettings();
      final str = s.toString();
      expect(str, contains('Test Café'));
      expect(str, contains('15%'));
    });
  });
}
