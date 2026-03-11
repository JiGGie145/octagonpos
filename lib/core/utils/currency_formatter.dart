/// Formats an amount in cents to a display currency string.
///
/// Example:
/// ```dart
/// formatCurrency(3500, 'R')  // → "R35.00"
/// formatCurrency(150, '£')   // → "£1.50"
/// formatCurrency(0, 'R')     // → "R0.00"
/// ```
String formatCurrency(int cents, String symbol) {
  final isNegative = cents < 0;
  final absCents = cents.abs();
  final major = absCents ~/ 100;
  final minor = absCents % 100;
  final sign = isNegative ? '-' : '';
  return '$sign$symbol$major.${minor.toString().padLeft(2, '0')}';
}
