import 'package:flutter/material.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/product.dart';

/// A product card for the POS grid.
///
/// Shows an optional image (or icon fallback), product name, and price.
/// Tapping the card calls [onTap] (typically adds the product to the cart).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.currencySymbol,
    required this.onTap,
  });

  final Product product;
  final String currencySymbol;
  final VoidCallback onTap;

  /// Maps a category name to a pastel background color for the icon fallback.
  static Color _categoryColor(String category) {
    final colors = [
      AppColors.categoryTeal,
      AppColors.categoryPurple,
      AppColors.categoryBlue,
      AppColors.categoryLavender,
      AppColors.categoryPink,
      AppColors.categoryMauve,
      AppColors.categorySalmon,
      AppColors.categoryMint,
    ];
    return colors[category.hashCode.abs() % colors.length];
  }

  /// Maps a category name to an icon for the fallback.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image or icon fallback
              Expanded(
                child: _buildImage(),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Product name
              Text(
                product.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Price
              Text(
                formatCurrency(product.price, currencySymbol),
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildIconFallback(),
        ),
      );
    }
    return _buildIconFallback();
  }

  Widget _buildIconFallback() {
    final bgColor = _categoryColor(product.category);
    final icon = _categoryIcon(product.category);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Center(
        child: Icon(
          icon,
          size: AppSpacing.iconXl,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
