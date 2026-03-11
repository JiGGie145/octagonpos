import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/presentation/providers/cart_provider.dart';
import 'package:flutter_pos/presentation/providers/product_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:flutter_pos/presentation/widgets/product_card.dart';

/// Adaptive grid of product cards.
///
/// Watches [filteredProductListProvider] and renders products grouped by
/// category with section headers. Adapts the cross-axis count based on
/// available width.
class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s?.currencySymbol ?? 'R',
      loading: () => 'R',
      error: (_, __) => 'R',
    );

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Failed to load products.\n$e',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildGrid(context, ref, products, currencySymbol);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: AppSpacing.iconHero,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No products yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add products to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDisabled,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    String currencySymbol,
  ) {
    // Group products by category
    final grouped = <String, List<Product>>{};
    for (final product in products) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }

    final sortedCategories = grouped.keys.toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive column count: ~140px per card
        final crossAxisCount = (constraints.maxWidth / 140).floor().clamp(2, 6);

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          itemCount: sortedCategories.length,
          itemBuilder: (context, sectionIndex) {
            final category = sortedCategories[sectionIndex];
            final categoryProducts = grouped[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    category,
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ),
                // Product grid for this category
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categoryProducts.length,
                  itemBuilder: (context, index) {
                    final product = categoryProducts[index];
                    return ProductCard(
                      product: product,
                      currencySymbol: currencySymbol,
                      onTap: () {
                        ref.read(cartProvider.notifier).addProduct(product);
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
