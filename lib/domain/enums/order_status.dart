/// Represents the lifecycle status of an order.
enum OrderStatus {
  pending,
  paid,
  completed,
  cancelled;

  /// Human-readable label for display.
  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.paid => 'Paid',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  /// Parse from a stored string value (case-insensitive).
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}
