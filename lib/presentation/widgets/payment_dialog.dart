import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';
import 'package:flutter_pos/presentation/providers/cart_provider.dart';
import 'package:flutter_pos/presentation/providers/order_providers.dart';
import 'package:flutter_pos/presentation/providers/printer_provider.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';

/// Shows the payment dialog as a modal bottom sheet.
///
/// Returns `true` if payment was successful, `null` / `false` otherwise.
Future<bool?> showPaymentDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PaymentDialogContent(),
  );
}

class _PaymentDialogContent extends ConsumerStatefulWidget {
  const _PaymentDialogContent();

  @override
  ConsumerState<_PaymentDialogContent> createState() =>
      _PaymentDialogContentState();
}

class _PaymentDialogContentState extends ConsumerState<_PaymentDialogContent> {
  PaymentMethod? _selectedMethod;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final currencySymbol = settingsAsync.whenOrNull(
          data: (s) => s?.currencySymbol,
        ) ??
        'R';
    final taxPercent = settingsAsync.whenOrNull(
          data: (s) => s?.taxPercentage,
        ) ??
        15;

    final subtotal = cart.subtotalCents;
    final tax = cart.taxCents(taxPercent);
    final total = cart.totalCents(taxPercent);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag Handle ───────────────────────────────────────
              Center(
                child: Container(
                  width: AppSpacing.dragHandleWidth,
                  height: AppSpacing.dragHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Title ─────────────────────────────────────────────
              Text(
                'Complete Payment',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Order Summary ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label:
                          '${cart.lineCount} item${cart.lineCount == 1 ? '' : 's'}',
                      value: formatCurrency(subtotal, currencySymbol),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SummaryRow(
                      label: 'Tax ($taxPercent%)',
                      value: formatCurrency(tax, currencySymbol),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _SummaryRow(
                      label: 'Total',
                      value: formatCurrency(total, currencySymbol),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Payment Method Selection ──────────────────────────
              Text(
                'Payment Method',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: PaymentMethod.values.map((method) {
                  final isSelected = _selectedMethod == method;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: method != PaymentMethod.values.last
                            ? AppSpacing.sm
                            : 0,
                      ),
                      child: _PaymentMethodButton(
                        method: method,
                        isSelected: isSelected,
                        onTap: _processing
                            ? null
                            : () =>
                                setState(() => _selectedMethod = method),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Confirm Button ────────────────────────────────────
              FilledButton(
                onPressed:
                    _selectedMethod != null && !_processing
                        ? () => _confirmPayment(total)
                        : null,
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(AppSpacing.minTapTarget + 8),
                  backgroundColor: AppColors.success,
                  disabledBackgroundColor: AppColors.disabledBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        width: AppSpacing.loadingIndicatorSize,
                        height: AppSpacing.loadingIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        _selectedMethod != null
                            ? 'Confirm ${formatCurrency(total, currencySymbol)}'
                            : 'Select a payment method',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _selectedMethod != null
                              ? AppColors.onPrimary
                              : AppColors.disabled,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Cancel ────────────────────────────────────────────
              TextButton(
                onPressed: _processing
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPayment(int totalCents) async {
    if (_selectedMethod == null) return;

    setState(() => _processing = true);

    try {
      // 1. Create the order from the cart
      final cart = ref.read(cartProvider);
      final createOrder = ref.read(createOrderUseCaseProvider);
      final order = await createOrder(
        items: cart.items,
        note: cart.note,
      );

      // 2. Process the payment — creates Payment record & marks order Paid
      final processPayment = ref.read(processPaymentUseCaseProvider);
      final payment = await processPayment(
        orderId: order.localId,
        method: _selectedMethod!,
        amount: totalCents,
      );

      // 3. Clear the cart
      ref.read(cartProvider.notifier).clear();

      // 4. Refresh order list
      ref.invalidate(orderListProvider);
      ref.invalidate(filteredOrderListProvider);

      // 5. Optionally print receipt
      try {
        final settings = await ref.read(settingsProvider.future);
        if (settings != null) {
          final printer = ref.read(printerServiceProvider);
          if (printer.isAvailable) {
            await printer.printReceipt(
              order,
              settings,
              payment: payment,
            );
          }
        }
      } catch (_) {
        // Don't block payment success if printing fails
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Method Button
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.method,
    required this.isSelected,
    this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  IconData get _icon => switch (method) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.card => Icons.credit_card_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: AppSpacing.paymentIconSize,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              method.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Row
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
