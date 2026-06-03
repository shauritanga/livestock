import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting analytics data with locale support
class AnalyticsFormatter {
  /// Format large numbers with thousand separators
  /// Example: 1234567 -> "1,234,567" (en) or "1.234.567" (sw)
  static String formatNumber(num value, {String? locale}) {
    final formatter = NumberFormat('#,##0', locale);
    return formatter.format(value);
  }

  /// Format decimal numbers with specified decimal places
  /// Example: 1234.567 -> "1,234.57" (2 decimal places)
  static String formatDecimal(num value, {int decimalPlaces = 2, String? locale}) {
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern, locale);
    return formatter.format(value);
  }

  /// Format currency values with proper symbols
  /// Example: 1234.56 -> "TZS 1,234.56"
  static String formatCurrency(num value, {String? locale, String currencySymbol = 'TZS'}) {
    final formatter = NumberFormat('#,##0.00', locale);
    return '$currencySymbol ${formatter.format(value)}';
  }

  /// Format percentage values
  /// Example: 0.1234 -> "12.34%"
  static String formatPercentage(num value, {int decimalPlaces = 2, String? locale}) {
    final percentage = value * 100;
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern, locale);
    return '${formatter.format(percentage)}%';
  }

  /// Format compact numbers (K, M, B notation)
  /// Example: 1234567 -> "1.23M"
  static String formatCompactNumber(num value, {String? locale}) {
    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(value);
  }

  /// Format liters with unit
  /// Example: 1234.5 -> "1,234.5 L"
  static String formatLiters(num value, {int decimalPlaces = 1, String? locale}) {
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern, locale);
    return '${formatter.format(value)} L';
  }

  /// Format date according to locale
  /// Example: 2024-01-15 -> "15/01/2024" (en) or "15.01.2024" (sw)
  static String formatDate(DateTime date, {String? locale}) {
    final formatter = DateFormat.yMd(locale);
    return formatter.format(date);
  }

  /// Format date with month name
  /// Example: 2024-01-15 -> "15 Jan 2024" (en) or "15 Jan 2024" (sw)
  static String formatDateWithMonth(DateTime date, {String? locale}) {
    final formatter = DateFormat.yMMMd(locale);
    return formatter.format(date);
  }

  /// Format date range
  /// Example: "15 Jan 2024 - 15 Feb 2024"
  static String formatDateRange(DateTime start, DateTime end, {String? locale}) {
    final formatter = DateFormat.yMMMd(locale);
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  /// Format month and year
  /// Example: 2024-01-15 -> "January 2024" (en) or "Januari 2024" (sw)
  static String formatMonthYear(DateTime date, {String? locale}) {
    final formatter = DateFormat.yMMMM(locale);
    return formatter.format(date);
  }

  /// Format time
  /// Example: 14:30 -> "2:30 PM" (en) or "14:30" (sw)
  static String formatTime(DateTime date, {String? locale}) {
    final formatter = DateFormat.jm(locale);
    return formatter.format(date);
  }

  /// Format date and time
  /// Example: "15 Jan 2024, 2:30 PM"
  static String formatDateTime(DateTime date, {String? locale}) {
    final dateFormatter = DateFormat.yMMMd(locale);
    final timeFormatter = DateFormat.jm(locale);
    return '${dateFormatter.format(date)}, ${timeFormatter.format(date)}';
  }

  /// Format relative date for analytics
  /// Example: "2 days ago", "Last week", "Last month"
  static String formatRelativeDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Last week' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Last month' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Last year' : '$years years ago';
    }
  }

  /// Format change indicator with sign
  /// Example: 12.5 -> "+12.5%", -5.3 -> "-5.3%"
  static String formatChangePercentage(num value, {int decimalPlaces = 1, String? locale}) {
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern, locale);
    final sign = value >= 0 ? '+' : '';
    return '$sign${formatter.format(value)}%';
  }

  /// Format duration in days
  /// Example: 30 -> "30 days", 1 -> "1 day"
  static String formatDays(int days) {
    return days == 1 ? '1 day' : '$days days';
  }

  /// Format duration in months
  /// Example: 12 -> "12 months", 1 -> "1 month"
  static String formatMonths(int months) {
    return months == 1 ? '1 month' : '$months months';
  }

  /// Get locale from BuildContext
  static String getLocale(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// Format number with context locale
  static String formatNumberWithContext(BuildContext context, num value) {
    return formatNumber(value, locale: getLocale(context));
  }

  /// Format currency with context locale
  static String formatCurrencyWithContext(BuildContext context, num value, {String currencySymbol = 'TZS'}) {
    return formatCurrency(value, locale: getLocale(context), currencySymbol: currencySymbol);
  }

  /// Format percentage with context locale
  static String formatPercentageWithContext(BuildContext context, num value, {int decimalPlaces = 2}) {
    return formatPercentage(value, decimalPlaces: decimalPlaces, locale: getLocale(context));
  }

  /// Format date with context locale
  static String formatDateWithContext(BuildContext context, DateTime date) {
    return formatDate(date, locale: getLocale(context));
  }

  /// Format decimal with context locale
  static String formatDecimalWithContext(BuildContext context, num value, {int decimalPlaces = 2}) {
    return formatDecimal(value, decimalPlaces: decimalPlaces, locale: getLocale(context));
  }

  /// Format liters with context locale
  static String formatLitersWithContext(BuildContext context, num value, {int decimalPlaces = 1}) {
    return formatLiters(value, decimalPlaces: decimalPlaces, locale: getLocale(context));
  }

  /// Format compact number with context locale
  static String formatCompactNumberWithContext(BuildContext context, num value) {
    return formatCompactNumber(value, locale: getLocale(context));
  }

  /// Format date range with context locale
  static String formatDateRangeWithContext(BuildContext context, DateTime start, DateTime end) {
    return formatDateRange(start, end, locale: getLocale(context));
  }

  /// Format month and year with context locale
  static String formatMonthYearWithContext(BuildContext context, DateTime date) {
    return formatMonthYear(date, locale: getLocale(context));
  }

  /// Format time with context locale
  static String formatTimeWithContext(BuildContext context, DateTime date) {
    return formatTime(date, locale: getLocale(context));
  }

  /// Format date and time with context locale
  static String formatDateTimeWithContext(BuildContext context, DateTime date) {
    return formatDateTime(date, locale: getLocale(context));
  }

  // Private constructor to prevent instantiation
  AnalyticsFormatter._();
}
