import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/time_series_data_point.dart';

/// Predictive analytics metrics with forecasts
class PredictiveMetrics extends Equatable {
  final List<TimeSeriesDataPoint> forecastData;
  final List<TimeSeriesDataPoint> trendLine;
  final List<TimeSeriesDataPoint> confidenceIntervalUpper;
  final List<TimeSeriesDataPoint> confidenceIntervalLower;
  final double forecastAccuracy;
  final Map<String, dynamic> seasonalPatterns;

  const PredictiveMetrics({
    required this.forecastData,
    required this.trendLine,
    required this.confidenceIntervalUpper,
    required this.confidenceIntervalLower,
    required this.forecastAccuracy,
    required this.seasonalPatterns,
  });

  /// Forecast period in days
  int get forecastPeriodDays => forecastData.length;

  /// Average forecasted value
  double get averageForecastedValue {
    if (forecastData.isEmpty) return 0;
    final sum = forecastData.fold<double>(
      0,
      (sum, point) => sum + point.value,
    );
    return sum / forecastData.length;
  }

  /// Trend direction
  String get trendDirection {
    if (trendLine.length < 2) return 'Unknown';

    final first = trendLine.first.value;
    final last = trendLine.last.value;
    final change = ((last - first) / first) * 100;

    if (change > 5) return 'Increasing';
    if (change < -5) return 'Decreasing';
    return 'Stable';
  }

  /// Confidence level
  String get confidenceLevel {
    if (forecastAccuracy >= 90) return 'Very High';
    if (forecastAccuracy >= 75) return 'High';
    if (forecastAccuracy >= 60) return 'Medium';
    return 'Low';
  }

  /// Has seasonal pattern
  bool get hasSeasonalPattern {
    return seasonalPatterns.isNotEmpty &&
        seasonalPatterns.containsKey('detected') &&
        seasonalPatterns['detected'] == true;
  }

  /// Peak season (if seasonal pattern exists)
  String? get peakSeason {
    if (!hasSeasonalPattern) return null;
    return seasonalPatterns['peak_season'] as String?;
  }

  /// Low season (if seasonal pattern exists)
  String? get lowSeason {
    if (!hasSeasonalPattern) return null;
    return seasonalPatterns['low_season'] as String?;
  }

  @override
  List<Object?> get props => [
        forecastData,
        trendLine,
        confidenceIntervalUpper,
        confidenceIntervalLower,
        forecastAccuracy,
        seasonalPatterns,
      ];

  PredictiveMetrics copyWith({
    List<TimeSeriesDataPoint>? forecastData,
    List<TimeSeriesDataPoint>? trendLine,
    List<TimeSeriesDataPoint>? confidenceIntervalUpper,
    List<TimeSeriesDataPoint>? confidenceIntervalLower,
    double? forecastAccuracy,
    Map<String, dynamic>? seasonalPatterns,
  }) {
    return PredictiveMetrics(
      forecastData: forecastData ?? this.forecastData,
      trendLine: trendLine ?? this.trendLine,
      confidenceIntervalUpper:
          confidenceIntervalUpper ?? this.confidenceIntervalUpper,
      confidenceIntervalLower:
          confidenceIntervalLower ?? this.confidenceIntervalLower,
      forecastAccuracy: forecastAccuracy ?? this.forecastAccuracy,
      seasonalPatterns: seasonalPatterns ?? this.seasonalPatterns,
    );
  }
}
