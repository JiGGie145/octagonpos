import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/presentation/providers/product_providers.dart';

/// Horizontal scrollable row of category filter chips.
///
/// Includes an "All" chip at the start. The active chip is filled blue;
/// inactive chips are outlined. Watches [categoryListProvider] for the
/// available categories and toggles [selectedCategoryProvider].
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: AppSpacing.minTapTarget,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        return SizedBox(
          height: AppSpacing.minTapTarget,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            itemCount: categories.length + 1, // +1 for "All"
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryChip(
                  label: 'All',
                  isSelected: selectedCategory == null,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                );
              }
              final category = categories[index - 1];
              return _CategoryChip(
                label: category,
                isSelected: selectedCategory == category,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      selectedCategory == category ? null : category;
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: isSelected
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
