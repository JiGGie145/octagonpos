import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/presentation/providers/cart_provider.dart';
import 'package:flutter_pos/presentation/widgets/category_filter_chips.dart';
import 'package:flutter_pos/presentation/widgets/order_panel.dart';
import 'package:flutter_pos/presentation/widgets/product_grid.dart';
import 'package:flutter_pos/presentation/widgets/product_search_bar.dart';

/// The primary POS order screen.
///
/// **Tablet / Desktop (≥ 768 px):**
/// Two-panel layout — product browsing on the left, current order on the right.
///
/// **Phone (< 768 px):**
/// Full-screen product grid with a floating cart badge/FAB. Tapping it opens
/// the [OrderPanel] as a bottom sheet.
class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet =
                constraints.maxWidth >= AppSpacing.tabletBreakpoint;

            if (isTablet) {
              return _TabletLayout();
            }
            return _PhoneLayout();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet / Desktop Layout
// ─────────────────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // Left panel — product browsing
        Expanded(
          child: _ProductBrowsingPanel(),
        ),
        // Vertical divider
        VerticalDivider(width: 1, color: AppColors.divider),
        // Right panel — current order
        SizedBox(
          width: AppSpacing.orderPanelWidth,
          child: OrderPanel(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone Layout
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneLayout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Stack(
      children: [
        const _ProductBrowsingPanel(),
        // Cart FAB with badge
        if (cart.isNotEmpty)
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: FloatingActionButton.extended(
              onPressed: () => _showOrderBottomSheet(context),
              backgroundColor: AppColors.primary,
              icon: Badge(
                label: Text(
                  '${cart.totalQuantity}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                child: const Icon(Icons.shopping_cart, color: AppColors.onPrimary),
              ),
              label: const Text(
                'View Order',
                style: TextStyle(color: AppColors.onPrimary),
              ),
            ),
          ),
      ],
    );
  }

  void _showOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: AppSpacing.dragHandleWidth,
                height: AppSpacing.dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
              ),
              const Expanded(child: OrderPanel()),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Product Browsing Panel (used in both layouts)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductBrowsingPanel extends StatelessWidget {
  const _ProductBrowsingPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: ProductSearchBar(),
        ),
        // Category chips
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: CategoryFilterChips(),
        ),
        SizedBox(height: AppSpacing.sm),
        // Product grid
        Expanded(child: ProductGrid()),
      ],
    );
  }
}
