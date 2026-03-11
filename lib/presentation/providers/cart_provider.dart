import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/domain/entities/order_item.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:uuid/uuid.dart';

/// Represents the current cart state before an order is placed.
class CartState {
  final List<OrderItem> items;
  final String? note;

  const CartState({
    this.items = const [],
    this.note,
  });

  /// Whether the cart is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the cart has items.
  bool get isNotEmpty => items.isNotEmpty;

  /// Total number of distinct line items.
  int get lineCount => items.length;

  /// Total quantity of all items.
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal in cents (sum of all line totals).
  int get subtotalCents =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Calculates tax amount in cents for a given tax percentage.
  /// [taxPercent] is a whole integer (e.g. 15 for 15%).
  int taxCents(int taxPercent) => (subtotalCents * taxPercent) ~/ 100;

  /// Total in cents = subtotal + tax.
  int totalCents(int taxPercent) => subtotalCents + taxCents(taxPercent);

  CartState copyWith({
    List<OrderItem>? items,
    String? note,
  }) {
    return CartState(
      items: items ?? this.items,
      note: note ?? this.note,
    );
  }
}

/// Notifier that manages the cart state.
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Adds a product to the cart. If it already exists, increments quantity.
  void addProduct(Product product) {
    final existingIndex =
        state.items.indexWhere((item) => item.productId == product.localId);

    if (existingIndex >= 0) {
      // Increment existing item quantity
      final updatedItems = [...state.items];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      final newItem = OrderItem(
        localId: const Uuid().v4(),
        orderId: '', // Will be assigned when order is created
        productId: product.localId,
        productName: product.name,
        quantity: 1,
        unitPrice: product.price,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  /// Removes an item from the cart by its localId.
  void removeItem(String itemLocalId) {
    state = state.copyWith(
      items: state.items.where((item) => item.localId != itemLocalId).toList(),
    );
  }

  /// Updates the quantity of a specific item.
  /// If quantity <= 0, the item is removed.
  void updateQuantity(String itemLocalId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemLocalId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.localId == itemLocalId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Increments the quantity of a specific item by 1.
  void incrementQuantity(String itemLocalId) {
    final item = state.items.firstWhere((i) => i.localId == itemLocalId);
    updateQuantity(itemLocalId, item.quantity + 1);
  }

  /// Decrements the quantity of a specific item by 1.
  /// Removes the item if quantity reaches 0.
  void decrementQuantity(String itemLocalId) {
    final item = state.items.firstWhere((i) => i.localId == itemLocalId);
    updateQuantity(itemLocalId, item.quantity - 1);
  }

  /// Sets a note for the order.
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Clears the entire cart.
  void clear() {
    state = const CartState();
  }
}

/// The main cart provider.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
