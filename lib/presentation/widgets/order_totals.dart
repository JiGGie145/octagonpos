import 'package:flutter/material.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';

/// Displays the subtotal, tax line, and total for the current order.
///
/// All amounts are in cents; formatted via [formatCurrency].
class OrderTotals extends StatelessWidget {
  const OrderTotals({
    super.key,
    required this.subtotalCents,
    required this.taxPercent,
    required this.taxCents,
    required this.totalCents,
    required this.currencySymbol,
  });

  final int subtotalCents;
  final int taxPercent;
  final int taxCents;
  final int totalCents;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),
          // Subtotal row
          _TotalRow(
            label: 'Subtotal',
            value: formatCurrency(subtotalCents, currencySymbol),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Tax row
          _TotalRow(
            label: 'Tax ($taxPercent%)',
            value: formatCurrency(taxCents, currencySymbol),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),
          // Total row
          _TotalRow(
            label: 'Total',
            value: formatCurrency(totalCents, currencySymbol),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
