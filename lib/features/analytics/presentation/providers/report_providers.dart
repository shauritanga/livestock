import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report_template.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/usecases/generate_report.dart';
import '../../domain/usecases/export_report.dart';
import '../../domain/usecases/schedule_report.dart';
import '../../core/result.dart';
import 'analytics_providers.dart';

// ============================================================================
// Report Generation State (Task 16.6)
// ============================================================================

/// State for report generation
class ReportGenerationState {
  final bool isGenerating;
  final bool isExporting;
  final ReportDocument? generatedReport;
  final String? exportedFilePath;
  final String? error;

  const ReportGenerationState({
    this.isGenerating = false,
    this.isExporting = false,
    this.generatedReport,
    this.exportedFilePath,
    this.error,
  });

  ReportGenerationState copyWith({
    bool? isGenerating,
    bool? isExporting,
    ReportDocument? generatedReport,
    String? exportedFilePath,
    String? error,
  }) {
    return ReportGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      isExporting: isExporting ?? this.isExporting,
      generatedReport: generatedReport ?? this.generatedReport,
      exportedFilePath: exportedFilePath ?? this.exportedFilePath,
      error: error ?? this.error,
    );
  }
}

/// Report generation notifier (Task 16.6)
class ReportGenerationNotifier extends Notifier<ReportGenerationState> {
  late GenerateReport _generateReportUseCase;
  late ExportReport _exportReportUseCase;
  late ScheduleReport _scheduleReportUseCase;
  bool _initialized = false;

  @override
  ReportGenerationState build() {
    _initializeUseCases();
    return const ReportGenerationState();
  }

  Future<void> _initializeUseCases() async {
    if (_initialized) return;
    _generateReportUseCase = await ref.read(generateReportUseCaseProvider.future);
    _exportReportUseCase = await ref.read(exportReportUseCaseProvider.future);
    _scheduleReportUseCase = await ref.read(scheduleReportUseCaseProvider.future);
    _initialized = true;
  }

  /// Generate report (Task 16.6)
  Future<void> generateReport({
    required ReportTemplate template,
    required AnalyticsFilter filter,
    required ExportFormat format,
  }) async {
    await _initializeUseCases();
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final result = await _generateReportUseCase(
        template: template,
        filter: filter,
        format: format,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isGenerating: false,
          generatedReport: result.dataOrNull,
        );
      } else {
        state = state.copyWith(
          isGenerating: false,
          error: result.errorOrNull ?? 'Failed to generate report',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate report: $e',
      );
    }
  }

  /// Export report (Task 16.6)
  Future<void> exportReport({
    required ReportDocument report,
    required ExportFormat format,
  }) async {
    await _initializeUseCases();
    state = state.copyWith(isExporting: true, error: null);

    try {
      final result = await _exportReportUseCase(
        report: report,
        format: format,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isExporting: false,
          exportedFilePath: result.dataOrNull,
        );
      } else {
        state = state.copyWith(
          isExporting: false,
          error: result.errorOrNull ?? 'Failed to export report',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export report: $e',
      );
    }
  }

  /// Schedule report (Task 16.6)
  Future<void> scheduleReport({
    required ReportTemplate template,
    required ReportFrequency frequency,
    required List<String> recipientEmails,
  }) async {
    await _initializeUseCases();
    
    try {
      final result = await _scheduleReportUseCase(
        template: template,
        frequency: frequency,
        recipientEmails: recipientEmails,
      );

      if (result.isSuccess) {
        // Success - report scheduled
        state = state.copyWith(error: null);
      } else {
        state = state.copyWith(error: result.errorOrNull ?? 'Failed to schedule report');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to schedule report: $e',
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const ReportGenerationState();
  }
}

// ============================================================================
// Report Providers
// ============================================================================

/// Use case providers
final generateReportUseCaseProvider = FutureProvider<GenerateReport>((ref) async {
  final repository = await ref.watch(reportRepositoryProvider.future);
  return GenerateReport(repository);
});

final exportReportUseCaseProvider = FutureProvider<ExportReport>((ref) async {
  final repository = await ref.watch(reportRepositoryProvider.future);
  return ExportReport(repository);
});

final scheduleReportUseCaseProvider = FutureProvider<ScheduleReport>((ref) async {
  final repository = await ref.watch(reportRepositoryProvider.future);
  return ScheduleReport(repository);
});

/// Report generation provider (Task 16.6)
final reportGenerationProvider = NotifierProvider<ReportGenerationNotifier, ReportGenerationState>(() {
  return ReportGenerationNotifier();
});

/// Report templates provider
final reportTemplatesProvider = FutureProvider<List<ReportTemplate>>((ref) async {
  final repository = await ref.watch(reportRepositoryProvider.future);
  final result = await repository.getReportTemplates();
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Failed to load report templates');
  }
});

/// Scheduled reports provider
final scheduledReportsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = await ref.watch(reportRepositoryProvider.future);
  final result = await repository.getScheduledReports();
  
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Failed to load scheduled reports');
  }
});

/// Selected report template provider
final selectedReportTemplateProvider = Provider<ReportTemplate?>((ref) => null);

/// Selected export format provider
final selectedExportFormatProvider = Provider<ExportFormat>((ref) => ExportFormat.pdf);
