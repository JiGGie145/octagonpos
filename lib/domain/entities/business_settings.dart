/// Business configuration collected on first launch.
///
/// Pure Dart — no Flutter or database imports.
/// [taxPercentage] is stored as a whole integer (e.g. 15 for 15%).
class BusinessSettings {
  final String businessName;
  final String currency;
  final String currencySymbol;
  final int taxPercentage; // e.g. 15 for 15%
  final String receiptFooter;

  const BusinessSettings({
    required this.businessName,
    required this.currency,
    required this.currencySymbol,
    required this.taxPercentage,
    this.receiptFooter = '',
  });

  /// Creates a copy with the given fields replaced.
  BusinessSettings copyWith({
    String? businessName,
    String? currency,
    String? currencySymbol,
    int? taxPercentage,
    String? receiptFooter,
  }) {
    return BusinessSettings(
      businessName: businessName ?? this.businessName,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      receiptFooter: receiptFooter ?? this.receiptFooter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessSettings &&
          runtimeType == other.runtimeType &&
          businessName == other.businessName &&
          currency == other.currency &&
          currencySymbol == other.currencySymbol &&
          taxPercentage == other.taxPercentage &&
          receiptFooter == other.receiptFooter;

  @override
  int get hashCode => Object.hash(
        businessName,
        currency,
        currencySymbol,
        taxPercentage,
        receiptFooter,
      );

  @override
  String toString() =>
      'BusinessSettings(business: $businessName, '
      'currency: $currencySymbol$currency, tax: $taxPercentage%)';
}
