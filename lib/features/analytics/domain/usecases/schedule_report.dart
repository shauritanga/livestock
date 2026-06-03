import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/repositories/report_repository.dart';

/// Use case for scheduling a report
class ScheduleReport {
  final ReportRepository repository;

  const ScheduleReport(this.repository);

  /// Execute the use case
  Future<Result<void>> call({
    required ReportTemplate template,
    required ReportFrequency frequency,
    required List<String> recipientEmails,
  }) async {
    try {
      return await repository.scheduleReport(
        template: template,
        frequency: frequency,
        recipientEmails: recipientEmails,
      );
    } catch (e) {
      return Failure(
        'Failed to schedule report: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
