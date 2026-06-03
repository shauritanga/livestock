import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_summary.dart';

/// Trend indicator for comparative metrics
enum TrendIndicator {
  improving,
  declining,
  stable,
}

/// Comparative metrics between two periods
class ComparativeMetrics extends Equatable {
  final AnalyticsSummary currentPeriod;
  final AnalyticsSummary comparisonPeriod;
  final Map<String, double> percentageChanges;
  final Map<String, TrendIndicator> trendIndicators;

  const ComparativeMetrics({
    required this.currentPeriod,
    required this.comparisonPeriod,
    required this.percentageChanges,
    required this.trendIndicators,
  });

  /// Get percentage change for a specific metric
  double getPercentageChange(String metric) {
    return percentageChanges[metric] ?? 0;
  }

  /// Get trend indicator for a specific metric
  TrendIndicator getTrendIndicator(String metric) {
    return trendIndicators[metric] ?? TrendIndicator.stable;
  }

  /// Milk production change
  double get milkProductionChange =>
      getPercentageChange('milkProduction');

  /// Farmer count change
  double get farmerCountChange => getPercentageChange('farmerCount');

  /// Cattle count change
  double get cattleCountChange => getPercentageChange('cattleCount');

  /// Revenue change
  double get revenueChange => getPercentageChange('revenue');

  /// Inventory value change
  double get inventoryValueChange => getPercentageChange('inventoryValue');

  /// Overall performance change (weighted average)
  double get overallPerformanceChange {
    return (milkProductionChange * 0.30) +
        (revenueChange * 0.30) +
        (farmerCountChange * 0.15) +
        (cattleCountChange * 0.15) +
        (inventoryValueChange * 0.10);
  }

  /// Overall trend
  TrendIndicator get overallTrend {
    if (overallPerformanceChange > 5) return TrendIndicator.improving;
    if (overallPerformanceChange < -5) return TrendIndicator.declining;
    return TrendIndicator.stable;
  }

  /// Metrics that improved
  List<String> get improvedMetrics {
    return trendIndicators.entries
        .where((entry) => entry.value == TrendIndicator.improving)
        .map((entry) => entry.key)
        .toList();
  }

  /// Metrics that declined
  List<String> get declinedMetrics {
    return trendIndicators.entries
        .where((entry) => entry.value == TrendIndicator.declining)
        .map((entry) => entry.key)
        .toList();
  }

  /// Metrics that remained stable
  List<String> get stableMetrics {
    return trendIndicators.entries
        .where((entry) => entry.value == TrendIndicator.stable)
        .map((entry) => entry.key)
        .toList();
  }

  /// Performance summary
  String get performanceSummary {
    final improved = improvedMetrics.length;
    final declined = declinedMetrics.length;
    final stable = stableMetrics.length;

    if (improved > declined && improved > stable) {
      return 'Strong Growth';
    } else if (declined > improved) {
      return 'Needs Attention';
    } else if (stable > improved && stable > declined) {
      return 'Steady Performance';
    }
    return 'Mixed Performance';
  }

  @override
  List<Object?> get props => [
        currentPeriod,
        comparisonPeriod,
        percentageChanges,
        trendIndicators,
      ];

  ComparativeMetrics copyWith({
    AnalyticsSummary? currentPeriod,
    AnalyticsSummary? comparisonPeriod,
    Map<String, double>? percentageChanges,
    Map<String, TrendIndicator>? trendIndicators,
  }) {
    return ComparativeMetrics(
      currentPeriod: currentPeriod ?? this.currentPeriod,
      comparisonPeriod: comparisonPeriod ?? this.comparisonPeriod,
      percentageChanges: percentageChanges ?? this.percentageChanges,
      trendIndicators: trendIndicators ?? this.trendIndicators,
    );
  }

  /// Factory method to create comparative metrics from two summaries
  factory ComparativeMetrics.fromSummaries(
    AnalyticsSummary current,
    AnalyticsSummary comparison,
  ) {
    final percentageChanges = <String, double>{};
    final trendIndicators = <String, TrendIndicator>{};

    // Calculate percentage changes
    percentageChanges['milkProduction'] = _calculateChange(
      current.totalMilkLiters,
      comparison.totalMilkLiters,
    );
    percentageChanges['farmerCount'] = _calculateChange(
      current.totalFarmers.toDouble(),
      comparison.totalFarmers.toDouble(),
    );
    percentageChanges['cattleCount'] = _calculateChange(
      current.totalCattle.toDouble(),
      comparison.totalCattle.toDouble(),
    );
    percentageChanges['revenue'] = _calculateChange(
      current.totalRevenue,
      comparison.totalRevenue,
    );
    percentageChanges['inventoryValue'] = _calculateChange(
      current.totalInventoryValue,
      comparison.totalInventoryValue,
    );

    // Determine trend indicators
    percentageChanges.forEach((key, change) {
      trendIndicators[key] = _determineTrend(change);
    });

    return ComparativeMetrics(
      currentPeriod: current,
      comparisonPeriod: comparison,
      percentageChanges: percentageChanges,
      trendIndicators: trendIndicators,
    );
  }

  /// Calculate percentage change
  static double _calculateChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// Determine trend from percentage change
  static TrendIndicator _determineTrend(double change) {
    if (change > 5) return TrendIndicator.improving;
    if (change < -5) return TrendIndicator.declining;
    return TrendIndicator.stable;
  }
}
