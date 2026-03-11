import 'package:flutter/material.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';

/// CLEAR and PAY action buttons at the bottom of the order panel.
///
/// PAY is disabled when the cart is empty.
class OrderActions extends StatelessWidget {
  const OrderActions({
    super.key,
    required this.isEmpty,
    required this.onClear,
    required this.onPay,
  });

  /// Whether the cart is currently empty.
  final bool isEmpty;

  /// Called when the user taps CLEAR.
  final VoidCallback onClear;

  /// Called when the user taps PAY.
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // CLEAR button
          Expanded(
            child: OutlinedButton(
              onPressed: isEmpty ? null : onClear,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
                side: BorderSide(
                  color: isEmpty ? AppColors.disabled : theme.colorScheme.outline,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'CLEAR',
                style: TextStyle(
                  color: isEmpty ? AppColors.disabled : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // PAY button
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isEmpty ? null : onPay,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTapTarget),
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'PAY',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isEmpty ? AppColors.disabled : theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
