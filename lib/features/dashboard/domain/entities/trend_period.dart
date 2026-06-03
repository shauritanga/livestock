import 'package:flutter/material.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Time period for collection trend visualization
enum TrendPeriod {
  week,  // Last 7 days
  month, // Last 4-5 weeks
  year,  // Last 12 months
}

/// Extension for TrendPeriod to get display name and days
extension TrendPeriodExtension on TrendPeriod {
  /// Get user-friendly display name (deprecated - use getDisplayName instead)
  @Deprecated('Use getDisplayName(context) instead')
  String get displayName {
    switch (this) {
      case TrendPeriod.week:
        return 'Week';
      case TrendPeriod.month:
        return 'Month';
      case TrendPeriod.year:
        return 'Year';
    }
  }
  
  /// Get localized display name
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TrendPeriod.week:
        return l10n.week;
      case TrendPeriod.month:
        return l10n.month;
      case TrendPeriod.year:
        return l10n.year;
    }
  }

  /// Get number of days for the period
  int get days {
    switch (this) {
      case TrendPeriod.week:
        return 7;
      case TrendPeriod.month:
        return 30;
      case TrendPeriod.year:
        return 365;
    }
  }
}
