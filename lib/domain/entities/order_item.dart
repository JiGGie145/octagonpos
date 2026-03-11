/// A single line item within an order.
///
/// Pure Dart — no Flutter or database imports.
/// [unitPrice] is stored in cents.
class OrderItem {
  final String localId;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice; // in cents

  const OrderItem({
    required this.localId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  /// Total price for this line item in cents.
  int get lineTotal => quantity * unitPrice;

  /// Creates a copy with the given fields replaced.
  OrderItem copyWith({
    String? localId,
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    int? unitPrice,
  }) {
    return OrderItem(
      localId: localId ?? this.localId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() =>
      'OrderItem(localId: $localId, product: $productName, qty: $quantity)';
}
