import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/inventory_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching inventory analytics
class GetInventoryAnalytics {
  final AnalyticsRepository repository;

  const GetInventoryAnalytics(this.repository);

  /// Execute the use case
  Future<Result<InventoryMetrics>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getInventoryAnalytics(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch inventory analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
