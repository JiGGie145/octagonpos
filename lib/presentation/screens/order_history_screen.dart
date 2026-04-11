import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/core/utils/relative_date_formatter.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/presentation/providers/order_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:flutter_pos/presentation/widgets/order_payment_dialog.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

/// Order history screen — filterable list of past orders, excludes soft-deleted.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  static const _maxVisibleItems = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrderListProvider);
    final selectedStatus = ref.watch(selectedOrderStatusProvider);
    final selectedDate = ref.watch(selectedDateFilterProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol =
        settingsAsync.whenOrNull(data: (s) => s?.currencySymbol) ?? 'R';
    final taxPercentage =
        settingsAsync.whenOrNull(data: (s) => s?.taxPercentage) ?? 15;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Order History')),
      body: Column(
        children: [
          // ── Status Filter Chips ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SizedBox(
              height: AppSpacing.chipRowHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: selectedStatus == null,
                    onTap: () => ref
                        .read(selectedOrderStatusProvider.notifier)
                        .state = null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ...OrderStatus.values.map((status) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _FilterChip(
                          label: status.label,
                          isSelected: selectedStatus == status,
                          statusColor:
                              AppColors.orderStatusColor(status.name),
                          onTap: () => ref
                              .read(selectedOrderStatusProvider.notifier)
                              .state = status,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Date Filter Chips ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: SizedBox(
              height: AppSpacing.chipRowHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: DateFilter.values.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _FilterChip(
                        label: filter.label,
                        isSelected: selectedDate == filter,
                        onTap: () => ref
                            .read(selectedDateFilterProvider.notifier)
                            .state = filter,
                      ),
                    )).toList(),
              ),
            ),
          ),

          // ── Order List / Grid ──────────────────────────────────────
          Expanded(
            child: ordersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading orders: $e')),
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyState(context, selectedStatus);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredOrderListProvider);
                    ref.invalidate(orderListProvider);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      if (width < AppSpacing.tabletBreakpoint) {
                        // ── Phone: single-column ListView ──
                        return ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => _OrderCard(
                            order: orders[index],
                            currencySymbol: currencySymbol,
                            taxPercentage: taxPercentage,
                            onTap: () =>
                                _openDetail(context, orders[index]),
                            onPayNow: () =>
                                _payOrder(context, orders[index]),
                          ),
                        );
                      }

                      // ── Tablet / Desktop: masonry grid ──
                      final columns = width >= 1200 ? 3 : 2;

                      return MasonryGridView.count(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        itemCount: orders.length,
                        itemBuilder: (context, index) => _OrderCard(
                          order: orders[index],
                          currencySymbol: currencySymbol,
                          taxPercentage: taxPercentage,
                          onTap: () =>
                              _openDetail(context, orders[index]),
                          onPayNow: () =>
                              _payOrder(context, orders[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OrderStatus? selectedStatus) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: AppSpacing.iconHero,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            selectedStatus != null
                ? 'No ${selectedStatus.label.toLowerCase()} orders'
                : 'No orders yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your completed and unpaid orders will appear here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Order order) {
    context.go('/orders/${order.localId}');
  }

  void _payOrder(BuildContext context, Order order) {
    showOrderPaymentDialog(context, order: order);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.statusColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = statusColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? activeColor : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.currencySymbol,
    required this.taxPercentage,
    required this.onTap,
    required this.onPayNow,
  });

  final Order order;
  final String currencySymbol;
  final int taxPercentage;
  final VoidCallback onTap;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = AppColors.orderStatusColor(order.status.name);
    final statusBgColor =
        AppColors.orderStatusBackgroundColor(order.status.name);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Order number + Status badge ────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.displayOrderNumber}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      order.status.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Items Table ────────────────────────────────────
              _ItemsTable(
                order: order,
                currencySymbol: currencySymbol,
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Subtotal ───────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Subtotal  ${formatCurrency(order.subtotal, currencySymbol)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Payment Status ─────────────────────────────────
              _PaymentSection(
                order: order,
                onPayNow: onPayNow,
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Footer: Relative Timestamp ─────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatRelativeDate(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Items Table (compact QTY | Item | Total)
// ─────────────────────────────────────────────────────────────────────────────

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({
    required this.order,
    required this.currencySymbol,
  });

  final Order order;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = order.items;
    final visibleCount =
        items.length > OrderHistoryScreen._maxVisibleItems
            ? OrderHistoryScreen._maxVisibleItems
            : items.length;
    final overflow = items.length - visibleCount;

    return Column(
      children: [
        for (int i = 0; i < visibleCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${items[i].quantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i].productName,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  formatCurrency(items[i].lineTotal, currencySymbol),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '+ $overflow more item${overflow == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Section
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.order,
    required this.onPayNow,
  });

  final Order order;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (order.status == OrderStatus.paid ||
        order.status == OrderStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.orderStatusBackgroundColor('paid'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: AppSpacing.iconSm,
              color: AppColors.orderStatusColor('paid'),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'PAID',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.orderStatusColor('paid'),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.orderStatusBackgroundColor('pending'),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              'UNPAID',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.orderStatusColor('pending'),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: onPayNow,
            icon: const Icon(Icons.payment_rounded, size: AppSpacing.iconSm),
            label: const Text('Pay Now'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              textStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
        ],
      );
    }

    // Cancelled
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.orderStatusBackgroundColor('cancelled'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'CANCELLED',
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.orderStatusColor('cancelled'),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
