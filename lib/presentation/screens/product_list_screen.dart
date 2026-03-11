import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:flutter_pos/presentation/providers/product_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:flutter_pos/presentation/widgets/product_form_dialog.dart';

/// Screen for managing products: view, search, add, edit, and soft-delete.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.whenOrNull(data: (s) => s?.currencySymbol) ?? 'R';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (value) {
                ref.read(productSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          // Product list
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load products.\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (products) {
                // Apply local search filter
                final filtered = searchQuery.isEmpty
                    ? products
                    : products
                        .where((p) =>
                            p.name.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState(context, searchQuery.isNotEmpty);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    return _ProductListTile(
                      product: filtered[index],
                      currencySymbol: currencySymbol,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
            size: AppSpacing.iconHero,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearching ? 'No products match your search' : 'No products yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (!isSearching) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap + to add your first product',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDisabled,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(
        onSave: (name, price, category, isActive, imageUrl) async {
          final createProduct = ref.read(createProductUseCaseProvider);
          await createProduct(
            name: name,
            price: price,
            category: category,
            isActive: isActive,
            imageUrl: imageUrl,
          );
          ref.invalidate(productListProvider);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product List Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProductListTile extends ConsumerWidget {
  const _ProductListTile({
    required this.product,
    required this.currencySymbol,
  });

  final Product product;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      leading: _buildLeadingIcon(),
      title: Text(
        product.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: product.isActive ? AppColors.textPrimary : AppColors.textDisabled,
        ),
      ),
      subtitle: Text(
        '${product.category} · ${formatCurrency(product.price, currencySymbol)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active/inactive badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: product.isActive ? AppColors.successLight : AppColors.disabledBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              product.isActive ? 'Active' : 'Inactive',
              style: theme.textTheme.labelSmall?.copyWith(
                color: product.isActive ? AppColors.success : AppColors.disabled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Edit button
          IconButton(
            onPressed: () => _showEditDialog(context, ref),
            icon: const Icon(Icons.edit_outlined, size: AppSpacing.iconMd),
            color: AppColors.textSecondary,
            tooltip: 'Edit',
          ),
          // Delete button
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, ref),
            icon: const Icon(Icons.delete_outline, size: AppSpacing.iconMd),
            color: AppColors.error,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return Container(
      width: AppSpacing.productLeadingSize,
      height: AppSpacing.productLeadingSize,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  _categoryIcon(product.category),
                  color: AppColors.textSecondary,
                  size: AppSpacing.iconMd + 2,
                ),
              ),
            )
          : Center(
              child: Icon(
                _categoryIcon(product.category),
                color: AppColors.textSecondary,
                size: AppSpacing.iconMd + 2,
              ),
            ),
    );
  }

  static IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'beverages' || 'drinks' => Icons.local_cafe_outlined,
      'food' || 'meals' => Icons.restaurant_outlined,
      'snacks' => Icons.cookie_outlined,
      'desserts' || 'dessert' => Icons.cake_outlined,
      'bakery' || 'bread' => Icons.bakery_dining_outlined,
      'dairy' => Icons.egg_outlined,
      'fruit' || 'fruits' => Icons.apple,
      _ => Icons.shopping_bag_outlined,
    };
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(
        product: product,
        onSave: (name, price, category, isActive, imageUrl) async {
          final updateProduct = ref.read(updateProductUseCaseProvider);
          await updateProduct(product.copyWith(
            name: name,
            price: price,
            category: category,
            isActive: isActive,
            imageUrl: imageUrl,
          ));
          ref.invalidate(productListProvider);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\n\n'
          'This will hide it from the product list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final deleteProduct = ref.read(deleteProductUseCaseProvider);
              await deleteProduct(product.localId);
              ref.invalidate(productListProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${product.name}" deleted'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
