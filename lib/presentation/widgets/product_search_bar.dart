import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/presentation/providers/product_providers.dart';

/// A rounded search bar that updates [productSearchQueryProvider].
///
/// Matches the Figma design: rounded corners, light gray fill,
/// leading search icon, trailing clear button when text is present.
class ProductSearchBar extends ConsumerStatefulWidget {
  const ProductSearchBar({super.key});

  @override
  ConsumerState<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends ConsumerState<ProductSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      onChanged: (value) {
        ref.read(productSearchQueryProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant),
                onPressed: () {
                  _controller.clear();
                  ref.read(productSearchQueryProvider.notifier).state = '';
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
