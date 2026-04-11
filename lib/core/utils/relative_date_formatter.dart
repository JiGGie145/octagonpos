import 'package:intl/intl.dart';

/// Formats a [DateTime] as a human-friendly relative string.
///
/// * Today → "Today 14:32"
/// * Yesterday → "Yesterday 09:10"
/// * Older → "12 Mar 2026 18:02"
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateDay = DateTime(date.year, date.month, date.day);
  final timeStr = DateFormat('HH:mm').format(date);

  if (dateDay == today) {
    return 'Today $timeStr';
  }

  final yesterday = today.subtract(const Duration(days: 1));
  if (dateDay == yesterday) {
    return 'Yesterday $timeStr';
  }

  return '${DateFormat('dd MMM yyyy').format(date)} $timeStr';
}
