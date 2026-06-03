import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/predictive_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching predictive analytics with forecasts
class GetPredictiveAnalytics {
  final AnalyticsRepository repository;

  const GetPredictiveAnalytics(this.repository);

  /// Execute the use case
  Future<Result<PredictiveMetrics>> call({
    required AnalyticsFilter historicalFilter,
    required int forecastDays,
  }) async {
    try {
      return await repository.getPredictiveAnalytics(
        historicalFilter,
        forecastDays,
      );
    } catch (e) {
      return Failure(
        'Failed to fetch predictive analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
