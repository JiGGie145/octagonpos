/// A manual correction to a product's stock quantity.
///
/// Pure Dart — no Flutter or database imports.
/// [quantityChange] is signed: positive = stock added, negative = stock removed.
class StockAdjustment {
  final String localId;
  final String productId;

  /// Signed quantity change. Positive adds stock, negative removes stock.
  final double quantityChange;

  /// Optional reason for the adjustment (e.g. "damage", "count correction").
  final String? reason;

  /// The date this adjustment occurred.
  final DateTime date;

  final DateTime createdAt;
  final DateTime updatedAt;

  const StockAdjustment({
    required this.localId,
    required this.productId,
    required this.quantityChange,
    this.reason,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  StockAdjustment copyWith({
    String? localId,
    String? productId,
    double? quantityChange,
    String? reason,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockAdjustment(
      localId: localId ?? this.localId,
      productId: productId ?? this.productId,
      quantityChange: quantityChange ?? this.quantityChange,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdjustment &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'StockAdjustment(productId: $productId, change: $quantityChange, date: $date)';
}
