import 'package:equatable/equatable.dart';

/// Report section entity
class ReportSection extends Equatable {
  final String title;
  final String content;
  final List<String> visualizations;
  final List<Map<String, dynamic>> tables;

  const ReportSection({
    required this.title,
    required this.content,
    required this.visualizations,
    required this.tables,
  });

  /// Has visualizations
  bool get hasVisualizations => visualizations.isNotEmpty;

  /// Has tables
  bool get hasTables => tables.isNotEmpty;

  /// Is empty section
  bool get isEmpty =>
      content.isEmpty && visualizations.isEmpty && tables.isEmpty;

  @override
  List<Object?> get props => [
        title,
        content,
        visualizations,
        tables,
      ];

  ReportSection copyWith({
    String? title,
    String? content,
    List<String>? visualizations,
    List<Map<String, dynamic>>? tables,
  }) {
    return ReportSection(
      title: title ?? this.title,
      content: content ?? this.content,
      visualizations: visualizations ?? this.visualizations,
      tables: tables ?? this.tables,
    );
  }
}
