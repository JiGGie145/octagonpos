import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/presentation/providers/cart_provider.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:flutter_pos/presentation/widgets/order_actions.dart';
import 'package:flutter_pos/presentation/widgets/order_header.dart';
import 'package:flutter_pos/presentation/widgets/order_line_item.dart';
import 'package:flutter_pos/presentation/widgets/order_totals.dart';
import 'package:flutter_pos/presentation/widgets/payment_dialog.dart';

/// The right-side order panel showing the current cart contents,
/// totals, and action buttons.
///
/// Used both inline (tablet layout) and as a bottom-sheet (phone layout).
class OrderPanel extends ConsumerWidget {
  const OrderPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final currencySymbol = settingsAsync.when(
      data: (s) => s?.currencySymbol ?? 'R',
      loading: () => 'R',
      error: (_, __) => 'R',
    );
    final taxPercent = settingsAsync.when(
      data: (s) => s?.taxPercentage ?? 15,
      loading: () => 15,
      error: (_, __) => 15,
    );

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          const OrderHeader(),
          Divider(height: 1, color: theme.dividerColor),

          // Line items or empty state
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyState(context)
                : _buildLineItems(ref, cart, currencySymbol),
          ),

          // Totals
          if (cart.isNotEmpty)
            OrderTotals(
              subtotalCents: cart.subtotalCents,
              taxPercent: taxPercent,
              taxCents: cart.taxCents(taxPercent),
              totalCents: cart.totalCents(taxPercent),
              currencySymbol: currencySymbol,
            ),

          // Actions
          OrderActions(
            isEmpty: cart.isEmpty,
            onClear: () => ref.read(cartProvider.notifier).clear(),
            onPay: () => _handlePay(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePay(BuildContext context) async {
    final success = await showPaymentDialog(context);
    if (success == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: AppSpacing.iconXxl,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add items to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItems(
    WidgetRef ref,
    CartState cart,
    String currencySymbol,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: cart.items.length,
      separatorBuilder: (context, __) =>
          Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md, color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return OrderLineItem(
          item: item,
          currencySymbol: currencySymbol,
          onIncrement: () =>
              ref.read(cartProvider.notifier).incrementQuantity(item.localId),
          onDecrement: () =>
              ref.read(cartProvider.notifier).decrementQuantity(item.localId),
          onRemove: () =>
              ref.read(cartProvider.notifier).removeItem(item.localId),
        );
      },
    );
  }
}
