import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/financial_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching financial analytics
class GetFinancialAnalytics {
  final AnalyticsRepository repository;

  const GetFinancialAnalytics(this.repository);

  /// Execute the use case
  Future<Result<FinancialMetrics>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getFinancialAnalytics(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch financial analytics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
