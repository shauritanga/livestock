import 'package:csv/csv.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/report_section.dart';

/// CSV generator service
/// Task 28.3: Implement CSV export functionality
class CsvGenerator {
  /// Export report to CSV
  /// Returns a string containing CSV data
  Future<String> exportToCsv(ReportDocument report) async {
    final buffer = StringBuffer();

    // Add report header
    buffer.writeln(_generateReportHeader(report));
    buffer.writeln();

    // Add each section as a separate table
    for (var i = 0; i < report.sections.length; i++) {
      if (i > 0) {
        buffer.writeln();
        buffer.writeln();
      }
      buffer.writeln(_generateSectionCsv(report.sections[i]));
    }

    return buffer.toString();
  }

  String _generateReportHeader(ReportDocument report) {
    final rows = <List<String>>[
      ['Report Name', report.template.name],
      ['Report Type', report.template.type.toString().split('.').last],
      [
        'Report Period',
        '${_formatDate(report.filter.dateRange.startDate)} - ${_formatDate(report.filter.dateRange.endDate)}'
      ],
      ['Generated On', _formatDateTime(report.generatedAt)],
      ['Report ID', report.id],
    ];

    if (report.filter.cooperativeIds != null &&
        report.filter.cooperativeIds!.isNotEmpty) {
      rows.add([
        'Cooperatives',
        report.filter.cooperativeIds!.length.toString(),
      ]);
    }

    if (report.filter.collectionCenterIds != null &&
        report.filter.collectionCenterIds!.isNotEmpty) {
      rows.add([
        'Collection Centers',
        report.filter.collectionCenterIds!.length.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String _generateSectionCsv(ReportSection section) {
    final buffer = StringBuffer();

    // Section header
    buffer.writeln(const ListToCsvConverter().convert([
      ['Section', section.title]
    ]));
    buffer.writeln(const ListToCsvConverter().convert([
      ['Description', section.content]
    ]));
    buffer.writeln();

    // Visualizations
    if (section.visualizations.isNotEmpty) {
      buffer.writeln(const ListToCsvConverter().convert([
        ['Visualizations']
      ]));
      for (final viz in section.visualizations) {
        buffer.writeln(const ListToCsvConverter().convert([
          [_formatVisualizationName(viz)]
        ]));
      }
      buffer.writeln();
    }

    // Tables
    if (section.tables.isNotEmpty) {
      buffer.writeln(const ListToCsvConverter().convert([
        ['Data Tables']
      ]));
      buffer.writeln();

      for (final table in section.tables) {
        final tableName = table['name'] as String? ?? 'Table';
        buffer.writeln(const ListToCsvConverter().convert([
          [_formatVisualizationName(tableName)]
        ]));

        // Add sample table data
        final tableData = _generateSampleTableData(tableName);
        buffer.writeln(const ListToCsvConverter().convert(tableData));
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  List<List<String>> _generateSampleTableData(String tableName) {
    // Generate sample data structure based on table name
    // In a real implementation, this would fetch actual data

    if (tableName.contains('summary') || tableName.contains('metrics')) {
      return [
        ['Metric', 'Value', 'Change', 'Trend'],
        ['Total Volume', '10,000', '+15%', 'Up'],
        ['Average Quality', '85%', '+5%', 'Up'],
        ['Active Farmers', '250', '+10', 'Up'],
      ];
    } else if (tableName.contains('breakdown') ||
        tableName.contains('distribution')) {
      return [
        ['Category', 'Count', 'Percentage'],
        ['Category A', '100', '40%'],
        ['Category B', '80', '32%'],
        ['Category C', '70', '28%'],
      ];
    } else if (tableName.contains('trend') || tableName.contains('time')) {
      return [
        ['Date', 'Value', 'Change'],
        ['2024-01', '1000', '-'],
        ['2024-02', '1100', '+10%'],
        ['2024-03', '1200', '+9%'],
      ];
    } else {
      return [
        ['Column 1', 'Column 2', 'Column 3'],
        ['Data 1', 'Data 2', 'Data 3'],
        ['Data 4', 'Data 5', 'Data 6'],
      ];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatVisualizationName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
