/// A record of stock being added to a tracked product.
///
/// Pure Dart — no Flutter or database imports.
/// [quantityAdded] is double to support fractional units (kg, L, etc.).
/// [unitCost] and [totalCost] are in cents (nullable — cost tracking is optional).
class RestockEntry {
  final String localId;
  final String productId;

  /// Quantity of stock added (supports fractional units).
  final double quantityAdded;

  /// Cost per unit at time of restock, in cents. Null if not recorded.
  final int? unitCost;

  /// Total cost of this restock in cents. Null if not recorded.
  final int? totalCost;

  /// The date this restock occurred.
  final DateTime date;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestockEntry({
    required this.localId,
    required this.productId,
    required this.quantityAdded,
    this.unitCost,
    this.totalCost,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  RestockEntry copyWith({
    String? localId,
    String? productId,
    double? quantityAdded,
    int? unitCost,
    int? totalCost,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestockEntry(
      localId: localId ?? this.localId,
      productId: productId ?? this.productId,
      quantityAdded: quantityAdded ?? this.quantityAdded,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestockEntry &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'RestockEntry(productId: $productId, qty: $quantityAdded, date: $date)';
}
