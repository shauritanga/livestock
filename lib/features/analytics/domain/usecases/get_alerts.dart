import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/alert.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for fetching alerts
class GetAlerts {
  final AnalyticsRepository repository;

  const GetAlerts(this.repository);

  /// Execute the use case
  Future<Result<List<Alert>>> call({
    AlertSeverity? minSeverity,
    bool? unreadOnly,
  }) async {
    try {
      return await repository.getAlerts(
        minSeverity: minSeverity,
        unreadOnly: unreadOnly,
      );
    } catch (e) {
      return Failure(
        'Failed to fetch alerts: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
