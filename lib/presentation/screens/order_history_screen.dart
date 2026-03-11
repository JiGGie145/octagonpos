import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/order.dart';
import 'package:flutter_pos/domain/enums/order_status.dart';
import 'package:flutter_pos/presentation/providers/order_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Order history screen — filterable list of past orders, excludes soft-deleted.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrderListProvider);
    final selectedStatus = ref.watch(selectedOrderStatusProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol =
        settingsAsync.whenOrNull(data: (s) => s?.currencySymbol) ?? 'R';
    final taxPercentage =
        settingsAsync.whenOrNull(data: (s) => s?.taxPercentage) ?? 15;

    return Scaffold(
      backgroundColor: AppColors.background,
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

          // ── Order List ─────────────────────────────────────────────
          Expanded(
            child: ordersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading orders: $e')),
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
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
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Orders will appear here once created',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredOrderListProvider);
                    ref.invalidate(orderListProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(
                        order: order,
                        currencySymbol: currencySymbol,
                        taxPercentage: taxPercentage,
                        onTap: () => _openDetail(context, order),
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

  void _openDetail(BuildContext context, Order order) {
    context.go('/orders/${order.localId}');
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
          color: isSelected ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
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
  });

  final Order order;
  final String currencySymbol;
  final int taxPercentage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final statusColor = AppColors.orderStatusColor(order.status.name);
    final statusBgColor =
        AppColors.orderStatusBackgroundColor(order.status.name);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order ${order.displayOrderNumber}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull),
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'} · ${dateFormat.format(order.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (order.note != null && order.note!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Total amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(
                        order.total(taxPercentage), currencySymbol),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'incl. tax',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
