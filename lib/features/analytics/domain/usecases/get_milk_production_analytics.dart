import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/milk_production_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching milk production analytics
class GetMilkProductionAnalytics {
  final AnalyticsRepository repository;

  const GetMilkProductionAnalytics(this.repository);

  /// Execute the use case
  Future<Result<MilkProductionMetrics>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getMilkProductionAnalytics(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch milk production analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
