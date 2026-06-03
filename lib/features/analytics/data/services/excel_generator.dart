import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/report_section.dart';

/// Excel generator service
/// Task 28.3: Implement Excel export functionality
class ExcelGenerator {
  /// Export report to Excel
  Future<Uint8List> exportToExcel(ReportDocument report) async {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Add summary sheet
    _addSummarySheet(excel, report);

    // Add a sheet for each section
    for (final section in report.sections) {
      _addSectionSheet(excel, section, report);
    }

    // Encode to bytes
    final bytes = excel.encode();
    return Uint8List.fromList(bytes!);
  }

  void _addSummarySheet(Excel excel, ReportDocument report) {
    final sheet = excel['Summary'];

    // Title
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('D1'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(report.template.name);
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
    );

    // Report metadata
    int row = 3;
    _addRow(sheet, row++, ['Report Period:', '']);
    _addRow(sheet, row++, [
      'Start Date:',
      _formatDate(report.filter.dateRange.startDate),
    ]);
    _addRow(sheet, row++, [
      'End Date:',
      _formatDate(report.filter.dateRange.endDate),
    ]);
    _addRow(sheet, row++, [
      'Generated:',
      _formatDateTime(report.generatedAt),
    ]);

    row += 2;

    // Sections list
    _addRow(sheet, row++, ['Sections Included:', ''], bold: true);
    for (var i = 0; i < report.sections.length; i++) {
      _addRow(sheet, row++, ['${i + 1}.', report.sections[i].title]);
    }

    // Auto-fit columns
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 40);
  }

  void _addSectionSheet(
    Excel excel,
    ReportSection section,
    ReportDocument report,
  ) {
    // Sanitize sheet name (Excel has restrictions)
    final sheetName = _sanitizeSheetName(section.title);
    final sheet = excel[sheetName];

    int row = 0;

    // Section title
    sheet.merge(
      CellIndex.indexByString('A${row + 1}'),
      CellIndex.indexByString('D${row + 1}'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A${row + 1}'));
    titleCell.value = TextCellValue(section.title);
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
    );
    row += 2;

    // Section content
    _addRow(sheet, row++, ['Description:', section.content]);
    row++;

    // Visualizations
    if (section.visualizations.isNotEmpty) {
      _addRow(sheet, row++, ['Visualizations:', ''], bold: true);
      for (final viz in section.visualizations) {
        _addRow(sheet, row++, ['•', _formatVisualizationName(viz)]);
      }
      row++;
    }

    // Tables
    if (section.tables.isNotEmpty) {
      _addRow(sheet, row++, ['Data Tables:', ''], bold: true);
      row++;

      for (final table in section.tables) {
        final tableName = table['name'] as String? ?? 'Table';
        _addRow(sheet, row++, [_formatVisualizationName(tableName)], bold: true);
        row++;

        // Add sample table structure
        _addTableHeaders(sheet, row++, ['Metric', 'Value', 'Change']);
        _addRow(sheet, row++, ['Sample Data 1', '100', '+10%']);
        _addRow(sheet, row++, ['Sample Data 2', '200', '+20%']);
        _addRow(sheet, row++, ['Sample Data 3', '300', '+30%']);
        row += 2;
      }
    }

    // Auto-fit columns
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 40);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
  }

  void _addRow(
    Sheet sheet,
    int rowIndex,
    List<String> values, {
    bool bold = false,
  }) {
    for (var i = 0; i < values.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(values[i]);
      if (bold) {
        cell.cellStyle = CellStyle(bold: true);
      }
    }
  }

  void _addTableHeaders(Sheet sheet, int rowIndex, List<String> headers) {
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromInt(0xFFF5F5F5),
      );
    }
  }

  String _sanitizeSheetName(String name) {
    // Excel sheet names can't exceed 31 characters and can't contain: \ / ? * [ ]
    String sanitized = name
        .replaceAll(RegExp(r'[\\/?*\[\]]'), '')
        .replaceAll(':', '-');
    if (sanitized.length > 31) {
      sanitized = sanitized.substring(0, 31);
    }
    return sanitized;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatVisualizationName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
