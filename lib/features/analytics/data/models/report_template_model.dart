import '../../domain/entities/report_template.dart';
import '../../domain/entities/report_section.dart';

class ReportTemplateModel extends ReportTemplate {
  const ReportTemplateModel({
    required super.id,
    required super.name,
    required super.type,
    required super.sections,
    required super.frequency,
    required super.defaultFormat,
  });

  factory ReportTemplateModel.fromJson(Map<String, dynamic> json) {
    return ReportTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      sections: (json['sections'] as List)
          .map((e) => ReportSection(
                title: e['title'] as String,
                content: e['content'] as String,
                visualizations: List<String>.from(e['visualizations'] as List),
                tables: (e['tables'] as List).map((t) => Map<String, dynamic>.from(t as Map)).toList(),
              ))
          .toList(),
      frequency: ReportFrequency.values.firstWhere((e) => e.name == json['frequency']),
      defaultFormat: ExportFormat.values.firstWhere((e) => e.name == json['defaultFormat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'sections': sections
          .map((e) => {
                'title': e.title,
                'content': e.content,
                'visualizations': e.visualizations,
                'tables': e.tables,
              })
          .toList(),
      'frequency': frequency.name,
      'defaultFormat': defaultFormat.name,
    };
  }
}
