import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/entities/report_document.dart';
import 'package:livestock/features/analytics/domain/repositories/report_repository.dart';

/// Use case for exporting a report to file
class ExportReport {
  final ReportRepository repository;

  const ExportReport(this.repository);

  /// Execute the use case
  /// Returns the file path of the exported report
  Future<Result<String>> call({
    required ReportDocument report,
    required ExportFormat format,
  }) async {
    try {
      return await repository.exportReport(
        report: report,
        format: format,
      );
    } catch (e) {
      return Failure(
        'Failed to export report: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
