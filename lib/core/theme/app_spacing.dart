/// Centralized spacing constants.
///
/// Never use raw `SizedBox(height: 12)` or `EdgeInsets.all(8)` in widgets.
/// Always use [AppSpacing] values.
class AppSpacing {
  AppSpacing._();

  // ── Spacing Scale ────────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── Common Border Radii ──────────────────────────────────────────
  static const double radiusXs = 2.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Icon Sizes ───────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
  static const double iconHero = 64.0;

  // ── POS-Specific ─────────────────────────────────────────────────
  /// Minimum tap target size per Material guidelines and POS requirements.
  static const double minTapTarget = 48.0;

  /// Width of the order panel on the right side (tablet layout).
  static const double orderPanelWidth = 380.0;

  /// Breakpoint: below this width, switch to single-column phone layout.
  static const double tabletBreakpoint = 768.0;

  // ── Layout Constants ─────────────────────────────────────────────
  /// Drag handle width (bottom sheets).
  static const double dragHandleWidth = 40.0;

  /// Drag handle height (bottom sheets).
  static const double dragHandleHeight = 4.0;

  /// Maximum width for form panels (settings, setup wizard).
  static const double formMaxWidth = 520.0;

  /// Maximum width for dialogs.
  static const double dialogWidth = 400.0;

  /// Standard product image / leading icon container size.
  static const double productLeadingSize = 44.0;

  /// Quantity badge size in detail views.
  static const double quantityBadgeSize = 28.0;

  /// Filter chip row height.
  static const double chipRowHeight = 40.0;

  /// Loading indicator size (small spinners).
  static const double loadingIndicatorSize = 24.0;

  /// Payment method icon size.
  static const double paymentIconSize = 36.0;
}
