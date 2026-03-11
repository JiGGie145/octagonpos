import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app.
///
/// Never use raw `Colors.red`, `Colors.blue`, etc. in widgets.
/// Always reference [AppColors] or the theme's [ColorScheme].
class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB); // Blue – active filters, prices, PAY button
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color onPrimary = Colors.white;

  // ── Secondary ────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF475569); // Slate gray
  static const Color onSecondary = Colors.white;

  // ── Surfaces ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5); // Light gray page bg
  static const Color surface = Colors.white; // Cards, order panel
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slightly tinted surface
  static const Color onBackground = Color(0xFF1E293B); // Dark text on light bg
  static const Color onSurface = Color(0xFF1E293B);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnDark = Colors.white;

  // ── Borders & Dividers ───────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // ── Semantic / Status ────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A); // Green – paid
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color onSuccess = Colors.white;

  static const Color warning = Color(0xFFF59E0B); // Amber – pending / in-progress
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color onWarning = Colors.white;

  static const Color error = Color(0xFFDC2626); // Red – cancelled, delete
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color onError = Colors.white;

  static const Color info = Color(0xFF0EA5E9); // Sky blue
  static const Color infoLight = Color(0xFFE0F2FE);

  // ── Disabled ─────────────────────────────────────────────────────
  static const Color disabled = Color(0xFF94A3B8);
  static const Color disabledBackground = Color(0xFFF1F5F9);

  // ── Dark Theme Base (future) ─────────────────────────────────────
  static const Color darkBackground = Color(0xFF111315); // RGB(17,19,21)
  static const Color darkSurface = Color(0xFF2D2D2D); // RGB(45,45,45)
  static const Color darkSurfaceVariant = Color(0xFF3A3A3A);

  // ── Order Status Color Map ───────────────────────────────────────
  /// Returns the appropriate color for a given order status string.
  static Color orderStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => warning,
      'paid' => success,
      'completed' => primary,
      'cancelled' => error,
      _ => textSecondary,
    };
  }

  /// Returns the light background tint for a given order status.
  static Color orderStatusBackgroundColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => warningLight,
      'paid' => successLight,
      'completed' => infoLight,
      'cancelled' => errorLight,
      _ => surfaceVariant,
    };
  }

  // ── Category Card Pastels (from existing prototype) ──────────────
  static const Color categoryTeal = Color(0xFFCFDDDB);
  static const Color categoryPurple = Color(0xFFE4CDEE);
  static const Color categoryBlue = Color(0xFFC2DBE9);
  static const Color categoryLavender = Color(0xFFC9CAEE);
  static const Color categoryPink = Color(0xFFFAC2D9);
  static const Color categoryMauve = Color(0xFFE6DADE);
  static const Color categorySalmon = Color(0xFFF0C8CF);
  static const Color categoryMint = Color(0xFFC3E9DE);
}
