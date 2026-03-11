import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';
import 'package:uuid/uuid.dart';

/// Seeds the database with sample products for development / testing purposes.
///
/// Only seeds if the product list is currently empty.
/// Business settings are configured via the setup wizard on first launch.
class DevDataSeeder {
  final ProductRepository _productRepo;

  DevDataSeeder(this._productRepo);

  Future<void> seed() async {
    await _seedProducts();
  }

  Future<void> _seedProducts() async {
    final existing = await _productRepo.getAll();
    if (existing.isNotEmpty) return;

    const uuid = Uuid();
    final now = DateTime.now();

    final products = <Product>[
      // ── Beverages ──────────────────────────────────────────────
      _p(uuid, now, 'Cappuccino', 3500, 'Beverages'),
      _p(uuid, now, 'Flat White', 3800, 'Beverages'),
      _p(uuid, now, 'Americano', 2800, 'Beverages'),
      _p(uuid, now, 'Latte', 4000, 'Beverages'),
      _p(uuid, now, 'Espresso', 2500, 'Beverages'),
      _p(uuid, now, 'Hot Chocolate', 3200, 'Beverages'),
      _p(uuid, now, 'Iced Coffee', 4200, 'Beverages'),
      _p(uuid, now, 'Fresh Orange Juice', 3500, 'Beverages'),

      // ── Food ───────────────────────────────────────────────────
      _p(uuid, now, 'Chicken Wrap', 6500, 'Food'),
      _p(uuid, now, 'BLT Sandwich', 5500, 'Food'),
      _p(uuid, now, 'Caesar Salad', 7000, 'Food'),
      _p(uuid, now, 'Beef Burger', 8500, 'Food'),
      _p(uuid, now, 'Margherita Pizza', 7500, 'Food'),

      // ── Snacks ─────────────────────────────────────────────────
      _p(uuid, now, 'Chocolate Muffin', 3000, 'Snacks'),
      _p(uuid, now, 'Blueberry Muffin', 3000, 'Snacks'),
      _p(uuid, now, 'Croissant', 2500, 'Snacks'),
      _p(uuid, now, 'Biscotti', 1800, 'Snacks'),
      _p(uuid, now, 'Granola Bar', 2200, 'Snacks'),

      // ── Desserts ───────────────────────────────────────────────
      _p(uuid, now, 'Cheesecake Slice', 4500, 'Desserts'),
      _p(uuid, now, 'Chocolate Brownie', 3500, 'Desserts'),
      _p(uuid, now, 'Carrot Cake', 4000, 'Desserts'),
      _p(uuid, now, 'Tiramisu', 5000, 'Desserts'),
    ];

    for (final product in products) {
      await _productRepo.create(product);
    }
  }

  /// Helper to build a [Product] with less boilerplate.
  static Product _p(
    Uuid uuid,
    DateTime now,
    String name,
    int priceInCents,
    String category,
  ) {
    return Product(
      localId: uuid.v4(),
      name: name,
      price: priceInCents,
      category: category,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
  }
}
