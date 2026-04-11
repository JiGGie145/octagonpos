import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/domain/enums/payment_method.dart';
import 'package:flutter_pos/presentation/providers/order_providers.dart';
import 'package:flutter_pos/presentation/providers/printer_provider.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';

/// Shows a payment dialog for an existing [Order].
///
/// Returns `true` if payment was successful, `null` / `false` otherwise.
Future<bool?> showOrderPaymentDialog(
  BuildContext context, {
  required Order order,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OrderPaymentContent(order: order),
  );
}

class _OrderPaymentContent extends ConsumerStatefulWidget {
  const _OrderPaymentContent({required this.order});

  final Order order;

  @override
  ConsumerState<_OrderPaymentContent> createState() =>
      _OrderPaymentContentState();
}

class _OrderPaymentContentState extends ConsumerState<_OrderPaymentContent> {
  PaymentMethod? _selectedMethod;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    final currencySymbol =
        settingsAsync.whenOrNull(data: (s) => s?.currencySymbol) ?? 'R';
    final taxPercent =
        settingsAsync.whenOrNull(data: (s) => s?.taxPercentage) ?? 15;

    final order = widget.order;
    final subtotal = order.subtotal;
    final tax = order.taxAmount(taxPercent);
    final total = order.total(taxPercent);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
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
                    color: theme.colorScheme.outline,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Title ─────────────────────────────────────────────
              Text(
                'Pay Order ${order.displayOrderNumber}',
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
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label:
                          '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                      value: formatCurrency(subtotal, currencySymbol),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SummaryRow(
                      label: 'Tax ($taxPercent%)',
                      value: formatCurrency(tax, currencySymbol),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Divider(
                          height: 1, color: theme.colorScheme.outline),
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
                onPressed: _selectedMethod != null && !_processing
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
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedMethod != null
                            ? 'Confirm ${formatCurrency(total, currencySymbol)}'
                            : 'Select a payment method',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _selectedMethod != null
                              ? Colors.white
                              : AppColors.disabled,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Cancel ────────────────────────────────────────────
              TextButton(
                onPressed:
                    _processing ? null : () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
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
      final processPayment = ref.read(processPaymentUseCaseProvider);
      final payment = await processPayment(
        orderId: widget.order.localId,
        method: _selectedMethod!,
        amount: totalCents,
      );

      // Refresh order list
      ref.invalidate(orderListProvider);
      ref.invalidate(filteredOrderListProvider);

      // Optionally print receipt
      try {
        final settings = await ref.read(settingsProvider.future);
        if (settings != null) {
          final printer = ref.read(printerServiceProvider);
          if (printer.isAvailable) {
            await printer.printReceipt(
              widget.order.copyWith(status: OrderStatus.paid),
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
            backgroundColor: Theme.of(context).colorScheme.error,
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
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: AppSpacing.paymentIconSize,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              method.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
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
