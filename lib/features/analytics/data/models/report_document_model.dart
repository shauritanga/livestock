import '../../domain/entities/report_document.dart';
import '../../domain/entities/report_section.dart';
import 'report_template_model.dart';
import 'analytics_filter_model.dart';

class ReportDocumentModel extends ReportDocument {
  const ReportDocumentModel({
    required super.id,
    required super.template,
    required super.filter,
    required super.generatedAt,
    required super.sections,
    required super.metadata,
    required super.dataSnapshot,
  });

  factory ReportDocumentModel.fromJson(Map<String, dynamic> json) {
    return ReportDocumentModel(
      id: json['id'] as String,
      template: ReportTemplateModel.fromJson(json['template'] as Map<String, dynamic>),
      filter: AnalyticsFilterModel.fromJson(json['filter'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      sections: (json['sections'] as List)
          .map((e) => ReportSection(
                title: e['title'] as String,
                content: e['content'] as String,
                visualizations: List<String>.from(e['visualizations'] as List),
                tables: (e['tables'] as List).map((t) => Map<String, dynamic>.from(t as Map)).toList(),
              ))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      dataSnapshot: Map<String, dynamic>.from(json['dataSnapshot'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template': (template as ReportTemplateModel).toJson(),
      'filter': (filter as AnalyticsFilterModel).toJson(),
      'generatedAt': generatedAt.toIso8601String(),
      'sections': sections
          .map((e) => {
                'title': e.title,
                'content': e.content,
                'visualizations': e.visualizations,
                'tables': e.tables,
              })
          .toList(),
      'metadata': metadata,
      'dataSnapshot': dataSnapshot,
    };
  }
}
