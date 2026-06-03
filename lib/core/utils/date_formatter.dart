import 'package:intl/intl.dart';

/// Utility class for date formatting
class DateFormatter {
  // Date formats
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String shortDateFormat = 'dd MMM yyyy';
  
  /// Format date to default format (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return DateFormat(defaultDateFormat).format(date);
  }
  
  /// Format time to default format (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat(defaultTimeFormat).format(date);
  }
  
  /// Format date and time to default format (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime date) {
    return DateFormat(defaultDateTimeFormat).format(date);
  }
  
  /// Format date to month and year (MMMM yyyy)
  static String formatMonthYear(DateTime date) {
    return DateFormat(monthYearFormat).format(date);
  }
  
  /// Format date to short format (dd MMM yyyy)
  static String formatShortDate(DateTime date) {
    return DateFormat(shortDateFormat).format(date);
  }
  
  /// Format date with custom format
  static String formatCustom(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
  
  /// Get relative time (e.g., "2 hours ago", "yesterday")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Private constructor to prevent instantiation
  DateFormatter._();
}
