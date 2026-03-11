/// Supported payment methods for MVP.
enum PaymentMethod {
  cash,
  card;

  /// Human-readable label for display.
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.card => 'Card',
      };

  /// Parse from a stored string value (case-insensitive).
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}
