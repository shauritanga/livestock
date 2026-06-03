import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/comparative_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching comparative analytics between two periods
class GetComparativeAnalytics {
  final AnalyticsRepository repository;

  const GetComparativeAnalytics(this.repository);

  /// Execute the use case
  Future<Result<ComparativeMetrics>> call({
    required AnalyticsFilter currentPeriod,
    required AnalyticsFilter comparisonPeriod,
  }) async {
    try {
      return await repository.getComparativeAnalytics(
        currentPeriod,
        comparisonPeriod,
      );
    } catch (e) {
      return Failure(
        'Failed to fetch comparative analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
