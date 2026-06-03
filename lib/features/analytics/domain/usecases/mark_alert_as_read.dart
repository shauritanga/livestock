import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for marking an alert as read
class MarkAlertAsRead {
  final AnalyticsRepository repository;

  const MarkAlertAsRead(this.repository);

  /// Execute the use case
  Future<Result<void>> call(String alertId) async {
    try {
      return await repository.markAlertAsRead(alertId);
    } catch (e) {
      return Failure(
        'Failed to mark alert as read: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
