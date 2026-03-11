import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pos/core/router/app_router.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';

/// The destination items shown in the navigation rail / bottom bar.
class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

const _destinations = [
  _Destination(
    label: 'Orders',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
    path: AppRoutes.home,
  ),
  _Destination(
    label: 'History',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    path: AppRoutes.orders,
  ),
  _Destination(
    label: 'Products',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    path: AppRoutes.products,
  ),
  _Destination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    path: AppRoutes.settings,
  ),
];

/// App shell that wraps the main content with a [NavigationRail] (tablet) or
/// [BottomNavigationBar] (phone).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // Match longest prefix first for sub-routes like /orders/:id
    for (int i = 0; i < _destinations.length; i++) {
      final path = _destinations[i].path;
      if (path == '/' && location == '/') return i;
      if (path != '/' && location.startsWith(path)) return i;
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final path = _destinations[index].path;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppSpacing.tabletBreakpoint;
        final selectedIndex = _selectedIndex(context);

        if (isTablet) {
          return _TabletShell(
            selectedIndex: selectedIndex,
            onSelected: (i) => _onDestinationSelected(context, i),
            child: child,
          );
        }
        return _PhoneShell(
          selectedIndex: selectedIndex,
          onSelected: (i) => _onDestinationSelected(context, i),
          child: child,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet / Desktop — NavigationRail
// ─────────────────────────────────────────────────────────────────────────────

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              selectedIconTheme:
                  IconThemeData(color: theme.colorScheme.primary),
              selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme:
                  IconThemeData(color: theme.colorScheme.onSurfaceVariant),
              unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            VerticalDivider(width: 1, color: theme.dividerColor),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone — BottomNavigationBar
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneShell extends StatelessWidget {
  const _PhoneShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}
