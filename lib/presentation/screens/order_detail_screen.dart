import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/entities/payment.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/presentation/providers/order_providers.dart';
import 'package:flutter_pos/presentation/providers/printer_provider.dart';
import 'package:flutter_pos/presentation/providers/repository_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:intl/intl.dart';

/// Provider to fetch the payment associated with an order.
final paymentByOrderProvider =
    FutureProvider.family<Payment?, String>((ref, orderId) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getByOrderId(orderId);
});

/// Full order detail view: line items, totals, payment info, timestamps,
/// and status management buttons.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final settingsAsync = ref.watch(settingsProvider);
    final paymentAsync = ref.watch(paymentByOrderProvider(orderId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: orderAsync.whenOrNull(
              data: (order) =>
                  order != null ? Text('Order ${order.displayOrderNumber}') : null,
            ) ??
            const Text('Order Detail'),
        actions: [
          // Print receipt button
          orderAsync.whenOrNull(
                data: (order) {
                  if (order == null) return null;
                  return IconButton(
                    onPressed: () async {
                      try {
                        final settings =
                            await ref.read(settingsProvider.future);
                        if (settings == null) return;
                        final payment = await ref
                            .read(paymentByOrderProvider(orderId).future);
                        final printer = ref.read(printerServiceProvider);
                        await printer.printReceipt(
                          order,
                          settings,
                          payment: payment,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Print failed: $e'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.print_rounded),
                    tooltip: 'Print Receipt',
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading order: $e')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final settings = settingsAsync.valueOrNull;
          final currencySymbol = settings?.currencySymbol ?? 'R';
          final taxPercentage = settings?.taxPercentage ?? 15;
          final payment = paymentAsync.valueOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Status & Info Card ──────────────────────────
                    _OrderInfoCard(
                      order: order,
                      currencySymbol: currencySymbol,
                      taxPercentage: taxPercentage,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Line Items Card ─────────────────────────────
                    _LineItemsCard(
                      order: order,
                      currencySymbol: currencySymbol,
                      taxPercentage: taxPercentage,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Payment Info Card ───────────────────────────
                    if (payment != null)
                      _PaymentInfoCard(
                        payment: payment,
                        currencySymbol: currencySymbol,
                      ),
                    if (payment != null) const SizedBox(height: AppSpacing.md),

                    // ── Timestamps Card ─────────────────────────────
                    _TimestampsCard(order: order),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Status Actions ──────────────────────────────
                    _StatusActions(order: order, orderId: orderId),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({
    required this.order,
    required this.currencySymbol,
    required this.taxPercentage,
  });

  final Order order;
  final String currencySymbol;
  final int taxPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Order number and note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${order.displayOrderNumber}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (order.note != null && order.note!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.note_rounded,
                            size: AppSpacing.iconSm, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            order.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Status badge
            _StatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line Items Card
// ─────────────────────────────────────────────────────────────────────────────

class _LineItemsCard extends StatelessWidget {
  const _LineItemsCard({
    required this.order,
    required this.currencySymbol,
    required this.taxPercentage,
  });

  final Order order;
  final String currencySymbol;
  final int taxPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            // Line items
            ...order.items.map((item) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      // Quantity badge
                      Container(
                        width: AppSpacing.quantityBadgeSize,
                        height: AppSpacing.quantityBadgeSize,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Product name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${formatCurrency(item.unitPrice, currencySymbol)} each',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Line total
                      Text(
                        formatCurrency(item.lineTotal, currencySymbol),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            // Totals
            _TotalRow(
              label: 'Subtotal',
              value: formatCurrency(order.subtotal, currencySymbol),
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.xs),
            _TotalRow(
              label: 'Tax ($taxPercentage%)',
              value: formatCurrency(
                  order.taxAmount(taxPercentage), currencySymbol),
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _TotalRow(
              label: 'Total',
              value:
                  formatCurrency(order.total(taxPercentage), currencySymbol),
              theme: theme,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({
    required this.payment,
    required this.currencySymbol,
  });

  final Payment payment;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.payment_rounded,
              label: 'Method',
              value: payment.method.label,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.attach_money_rounded,
              label: 'Amount',
              value: formatCurrency(payment.amount, currencySymbol),
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Paid at',
              value: dateFormat.format(payment.createdAt),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timestamps Card
// ─────────────────────────────────────────────────────────────────────────────

class _TimestampsCard extends StatelessWidget {
  const _TimestampsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.add_circle_outline_rounded,
              label: 'Created',
              value: dateFormat.format(order.createdAt),
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.update_rounded,
              label: 'Last updated',
              value: dateFormat.format(order.updatedAt),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconMd - 2, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.orderStatusColor(status.name);
    final bgColor = AppColors.orderStatusBackgroundColor(status.name);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Action Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _StatusActions extends ConsumerWidget {
  const _StatusActions({required this.order, required this.orderId});

  final Order order;
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine which status transitions are available
    final actions = _availableTransitions(order.status);

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: actions.map((action) {
            return _StatusActionButton(
              label: action.label,
              icon: action.icon,
              color: action.color,
              onPressed: () => _updateStatus(context, ref, action.targetStatus),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, OrderStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark as ${newStatus.label}?'),
        content: Text(
          'Are you sure you want to change this order\'s status to "${newStatus.label}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updateStatus = ref.read(updateOrderStatusUseCaseProvider);
      await updateStatus(orderId, newStatus);

      // Refresh both the detail and the list
      ref.invalidate(orderDetailProvider(orderId));
      ref.invalidate(orderListProvider);
      ref.invalidate(filteredOrderListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order marked as ${newStatus.label}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Returns available status transitions for the current status.
  List<_StatusAction> _availableTransitions(OrderStatus current) {
    return switch (current) {
      OrderStatus.pending => [
          _StatusAction(
            label: 'Mark as Paid',
            icon: Icons.payments_rounded,
            color: AppColors.success,
            targetStatus: OrderStatus.paid,
          ),
          _StatusAction(
            label: 'Cancel Order',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
            targetStatus: OrderStatus.cancelled,
          ),
        ],
      OrderStatus.paid => [
          _StatusAction(
            label: 'Mark as Completed',
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
            targetStatus: OrderStatus.completed,
          ),
          _StatusAction(
            label: 'Cancel Order',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
            targetStatus: OrderStatus.cancelled,
          ),
        ],
      OrderStatus.completed => [],
      OrderStatus.cancelled => [],
    };
  }
}

class _StatusAction {
  final String label;
  final IconData icon;
  final Color color;
  final OrderStatus targetStatus;

  const _StatusAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.targetStatus,
  });
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: AppSpacing.iconMd - 2),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
      foregroundColor: Colors.white,
        minimumSize: const Size(0, AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
