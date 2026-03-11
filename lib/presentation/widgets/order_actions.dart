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
                  color: isEmpty ? AppColors.disabled : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'CLEAR',
                style: TextStyle(
                  color: isEmpty ? AppColors.disabled : AppColors.textSecondary,
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
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.disabledBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'PAY',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isEmpty ? AppColors.disabled : AppColors.onPrimary,
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
