import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/livestock_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching livestock analytics
class GetLivestockAnalytics {
  final AnalyticsRepository repository;

  const GetLivestockAnalytics(this.repository);

  /// Execute the use case
  Future<Result<LivestockMetrics>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getLivestockAnalytics(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch livestock analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
