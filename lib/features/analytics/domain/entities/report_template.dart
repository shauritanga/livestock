import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/report_section.dart';

/// Report type enumeration
enum ReportType {
  monthlySummary,
  quarterlyReview,
  annualReport,
  governmentSubmission,
  customReport,
}

/// Report frequency enumeration
enum ReportFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  annual,
  onDemand,
}

/// Export format enumeration
enum ExportFormat {
  pdf,
  excel,
  csv,
}

/// Report template entity
class ReportTemplate extends Equatable {
  final String id;
  final String name;
  final ReportType type;
  final List<ReportSection> sections;
  final ReportFrequency frequency;
  final ExportFormat defaultFormat;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.sections,
    required this.frequency,
    required this.defaultFormat,
  });

  /// Type label
  String get typeLabel {
    switch (type) {
      case ReportType.monthlySummary:
        return 'Monthly Summary';
      case ReportType.quarterlyReview:
        return 'Quarterly Review';
      case ReportType.annualReport:
        return 'Annual Report';
      case ReportType.governmentSubmission:
        return 'Government Submission';
      case ReportType.customReport:
        return 'Custom Report';
    }
  }

  /// Frequency label
  String get frequencyLabel {
    switch (frequency) {
      case ReportFrequency.daily:
        return 'Daily';
      case ReportFrequency.weekly:
        return 'Weekly';
      case ReportFrequency.monthly:
        return 'Monthly';
      case ReportFrequency.quarterly:
        return 'Quarterly';
      case ReportFrequency.annual:
        return 'Annual';
      case ReportFrequency.onDemand:
        return 'On Demand';
    }
  }

  /// Format label
  String get formatLabel {
    switch (defaultFormat) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.csv:
        return 'CSV';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        sections,
        frequency,
        defaultFormat,
      ];

  ReportTemplate copyWith({
    String? id,
    String? name,
    ReportType? type,
    List<ReportSection>? sections,
    ReportFrequency? frequency,
    ExportFormat? defaultFormat,
  }) {
    return ReportTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sections: sections ?? this.sections,
      frequency: frequency ?? this.frequency,
      defaultFormat: defaultFormat ?? this.defaultFormat,
    );
  }
}
