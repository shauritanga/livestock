import 'package:livestock/features/analytics/core/result.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/entities/report_document.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';

/// Scheduled report entity
class ScheduledReport {
  final String id;
  final ReportTemplate template;
  final ReportFrequency frequency;
  final List<String> recipientEmails;
  final DateTime? lastGenerated;
  final DateTime? nextScheduled;
  final bool isActive;

  const ScheduledReport({
    required this.id,
    required this.template,
    required this.frequency,
    required this.recipientEmails,
    this.lastGenerated,
    this.nextScheduled,
    required this.isActive,
  });
}

/// Repository interface for report generation
abstract class ReportRepository {
  /// Get available report templates
  Future<Result<List<ReportTemplate>>> getReportTemplates();

  /// Generate a report
  Future<Result<ReportDocument>> generateReport({
    required ReportTemplate template,
    required AnalyticsFilter filter,
    required ExportFormat format,
  });

  /// Export report to file
  Future<Result<String>> exportReport({
    required ReportDocument report,
    required ExportFormat format,
  });

  /// Schedule a report
  Future<Result<void>> scheduleReport({
    required ReportTemplate template,
    required ReportFrequency frequency,
    required List<String> recipientEmails,
  });

  /// Get scheduled reports
  Future<Result<List<ScheduledReport>>> getScheduledReports();
}
