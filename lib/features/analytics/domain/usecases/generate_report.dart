import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/entities/report_document.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';
import 'package:livestock/features/analytics/domain/repositories/report_repository.dart';

/// Use case for generating a report
class GenerateReport {
  final ReportRepository repository;

  const GenerateReport(this.repository);

  /// Execute the use case
  Future<Result<ReportDocument>> call({
    required ReportTemplate template,
    required AnalyticsFilter filter,
    required ExportFormat format,
  }) async {
    try {
      return await repository.generateReport(
        template: template,
        filter: filter,
        format: format,
      );
    } catch (e) {
      return Failure(
        'Failed to generate report: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
