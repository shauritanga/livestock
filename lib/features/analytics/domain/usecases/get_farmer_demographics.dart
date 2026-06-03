import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/entities/farmer_metrics.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching farmer demographics analytics
class GetFarmerDemographics {
  final AnalyticsRepository repository;

  const GetFarmerDemographics(this.repository);

  /// Execute the use case
  Future<Result<FarmerMetrics>> call(AnalyticsFilter filter) async {
    try {
      return await repository.getFarmerDemographics(filter);
    } catch (e) {
      return Failure(
        'Failed to fetch farmer demographics: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
