import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_summary.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching comprehensive analytics summary
class GetAnalyticsSummary {
  final AnalyticsRepository repository;

  const GetAnalyticsSummary(this.repository);

  /// Execute the use case
  Future<Result<AnalyticsSummary>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getAnalyticsSummary(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch analytics summary: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
