import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:flutter_pos/presentation/screens/order_detail_screen.dart';
import 'package:flutter_pos/presentation/screens/order_history_screen.dart';
import 'package:flutter_pos/presentation/screens/order_screen.dart';
import 'package:flutter_pos/presentation/screens/product_list_screen.dart';
import 'package:flutter_pos/presentation/screens/settings_screen.dart';
import 'package:flutter_pos/presentation/screens/setup_wizard_screen.dart';
import 'package:flutter_pos/presentation/widgets/app_shell.dart';

/// Route path constants.
abstract class AppRoutes {
  static const home = '/';
  static const products = '/products';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const settings = '/settings';
  static const setup = '/setup';
}

/// Creates the application [GoRouter].
///
/// Uses [ref] to read [isSetupCompleteProvider] for the redirect guard.
GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      final isSetup = await ref.read(isSetupCompleteProvider.future);
      final goingToSetup = state.matchedLocation == AppRoutes.setup;

      if (!isSetup && !goingToSetup) return AppRoutes.setup;
      if (isSetup && goingToSetup) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Setup wizard (no shell) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const SetupWizardScreen(),
      ),

      // ── Main app shell with navigation ──────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrderScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.products,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.orders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrderHistoryScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return OrderDetailScreen(orderId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Riverpod provider for the app router.
/// Keep it alive for the lifetime of the app.
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});
