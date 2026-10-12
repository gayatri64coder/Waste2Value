import 'package:intl/intl.dart';

/// Formatting utilities for Waste2Value
class Formatters {
  Formatters._();

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00');
  static final NumberFormat _integerFormat = NumberFormat('#,##0');

  /// Format date (e.g., Oct 08, 2026)
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateFormat.format(date);
  }

  /// Format time (e.g., 10:30 AM)
  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return _timeFormat.format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateTimeFormat.format(date);
  }

  /// Format currency amount
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format weight with unit (e.g., "1.45 kg" or "320 g")
  static String formatWeight(double weightKg) {
    if (weightKg < 1.0) {
      final grams = (weightKg * 1000).round();
      return '$grams g';
    }
    return '${_decimalFormat.format(weightKg)} kg';
  }

  /// Format integer credits or numbers
  static String formatCredits(int credits) {
    return _integerFormat.format(credits);
  }

  /// Format double with 2 decimals
  static String formatNumber(double value) {
    return _decimalFormat.format(value);
  }

  /// Format relative time (e.g., "2 min ago", "Yesterday", "Oct 05")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return _dateFormat.format(dateTime);
  }
}
