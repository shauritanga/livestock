import 'package:equatable/equatable.dart';
import 'package:livestock/features/analytics/domain/entities/report_template.dart';
import 'package:livestock/features/analytics/domain/entities/report_section.dart';
import 'package:livestock/features/analytics/domain/entities/analytics_filter.dart';

/// Report document entity
class ReportDocument extends Equatable {
  final String id;
  final ReportTemplate template;
  final AnalyticsFilter filter;
  final DateTime generatedAt;
  final List<ReportSection> sections;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> dataSnapshot;

  const ReportDocument({
    required this.id,
    required this.template,
    required this.filter,
    required this.generatedAt,
    required this.sections,
    required this.metadata,
    required this.dataSnapshot,
  });

  /// Report title
  String get title => template.name;

  /// Report type
  ReportType get type => template.type;

  /// Period covered
  String get period {
    final start = filter.dateRange.startDate;
    final end = filter.dateRange.endDate;
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  /// Number of sections
  int get sectionCount => sections.length;

  /// Has data
  bool get hasData => dataSnapshot.isNotEmpty;

  /// Format date helper
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        template,
        filter,
        generatedAt,
        sections,
        metadata,
        dataSnapshot,
      ];

  ReportDocument copyWith({
    String? id,
    ReportTemplate? template,
    AnalyticsFilter? filter,
    DateTime? generatedAt,
    List<ReportSection>? sections,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? dataSnapshot,
  }) {
    return ReportDocument(
      id: id ?? this.id,
      template: template ?? this.template,
      filter: filter ?? this.filter,
      generatedAt: generatedAt ?? this.generatedAt,
      sections: sections ?? this.sections,
      metadata: metadata ?? this.metadata,
      dataSnapshot: dataSnapshot ?? this.dataSnapshot,
    );
  }
}
