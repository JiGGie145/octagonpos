import 'package:flutter_pos/domain/enums/sync_status.dart';

/// A product available for sale.
///
/// Pure Dart — no Flutter or database imports.
/// Prices are stored as [int] in cents to avoid floating-point errors.
/// Stock quantities are [double] to support fractional units (kg, L, etc.).
class Product {
  final String localId;
  final String name;
  final int price; // in cents
  final String category;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  // ── Inventory fields ──────────────────────────────────────────────
  /// Whether stock is tracked for this product.
  final bool trackStock;

  /// Whether this product is assembled from ingredient products.
  final bool usesIngredients;

  /// Current stock quantity. Null when stock tracking is disabled.
  final double? stockQty;

  /// Per-product low stock threshold override. Falls back to global default when null.
  final double? lowStockThreshold;

  /// Last known cost price in cents. Null if never set.
  final int? costPrice;

  /// Whether this product appears in the sellable catalogue.
  /// Ingredient-only products may set this to false.
  final bool isSellable;

  const Product({
    required this.localId,
    required this.name,
    required this.price,
    required this.category,
    this.isActive = true,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.pending,
    this.trackStock = false,
    this.usesIngredients = false,
    this.stockQty,
    this.lowStockThreshold,
    this.costPrice,
    this.isSellable = true,
  });

  /// Whether this product has been soft-deleted.
  bool get isDeleted => deletedAt != null;

  /// Formatted price in major currency units (e.g. 3500 → 35.00).
  double get priceInMajorUnits => price / 100.0;

  /// Formatted cost price in major units, or null.
  double? get costPriceInMajorUnits =>
      costPrice != null ? costPrice! / 100.0 : null;

  /// Creates a copy with the given fields replaced.
  Product copyWith({
    String? localId,
    String? name,
    int? price,
    String? category,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
    bool? trackStock,
    bool? usesIngredients,
    double? stockQty,
    double? lowStockThreshold,
    int? costPrice,
    bool? isSellable,
  }) {
    return Product(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      trackStock: trackStock ?? this.trackStock,
      usesIngredients: usesIngredients ?? this.usesIngredients,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      costPrice: costPrice ?? this.costPrice,
      isSellable: isSellable ?? this.isSellable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() => 'Product(localId: $localId, name: $name, price: $price)';
}
