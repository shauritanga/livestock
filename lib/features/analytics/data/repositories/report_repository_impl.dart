import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:livestock/core/constants/firebase_constants.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/report_template.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../core/result.dart';
import '../services/report_generator_service.dart';
import '../services/pdf_generator.dart';
import '../services/excel_generator.dart';
import '../services/csv_generator.dart';
import '../services/report_template_service.dart';
import '../models/report_template_model.dart';

/// Implementation of ReportRepository (Task 15.5, 28.3)
class ReportRepositoryImpl implements ReportRepository {
  final ReportGeneratorService reportGenerator;
  final PdfGenerator pdfGenerator;
  final ExcelGenerator excelGenerator;
  final CsvGenerator csvGenerator;
  final ReportTemplateService templateService;
  final FirebaseFirestore firestore;

  ReportRepositoryImpl({
    required this.reportGenerator,
    required this.pdfGenerator,
    required this.excelGenerator,
    required this.csvGenerator,
    required this.templateService,
    required this.firestore,
  });

  /// Get predefined report templates (Task 15.5, 28.1)
  @override
  Future<Result<List<ReportTemplate>>> getReportTemplates() async {
    try {
      // Use ReportTemplateService to get predefined templates
      final templates = templateService.getPredefinedTemplates();
      return Success(templates);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get report templates: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Generate report using ReportGeneratorService (Task 15.5)
  @override
  Future<Result<ReportDocument>> generateReport({
    required ReportTemplate template,
    required AnalyticsFilter filter,
    required ExportFormat format,
  }) async {
    try {
      final report = await reportGenerator.generateReport(
        template: template,
        filter: filter,
      );
      
      return Success(report);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to generate report: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Export report with format selection (Task 15.5)
  @override
  Future<Result<String>> exportReport({
    required ReportDocument report,
    required ExportFormat format,
  }) async {
    try {
      String filePath;
      
      switch (format) {
        case ExportFormat.pdf:
          final pdfBytes = await pdfGenerator.exportToPdf(report);
          filePath = await _saveToFile(
            pdfBytes,
            'report_${report.id}.pdf',
          );
          break;
          
        case ExportFormat.excel:
          final excelBytes = await excelGenerator.exportToExcel(report);
          filePath = await _saveToFile(
            excelBytes,
            'report_${report.id}.xlsx',
          );
          break;
          
        case ExportFormat.csv:
          final csvString = await csvGenerator.exportToCsv(report);
          filePath = await _saveToFile(
            csvString.codeUnits,
            'report_${report.id}.csv',
          );
          break;
      }
      
      return Success(filePath);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to export report: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Schedule report storing in Firestore (Task 15.5)
  @override
  Future<Result<void>> scheduleReport({
    required ReportTemplate template,
    required ReportFrequency frequency,
    required List<String> recipientEmails,
  }) async {
    try {
      await firestore.collection(FirebaseConstants.scheduledReportsCollection).add({
        'templateId': template.id,
        'templateName': template.name,
        'frequency': frequency.name,
        'recipientEmails': recipientEmails,
        'isActive': true,
        'createdAt': Timestamp.now(),
        'lastGenerated': null,
        'nextScheduled': _calculateNextScheduledDate(frequency),
      });
      
      return Success(null);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to schedule report: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get scheduled reports
  @override
  Future<Result<List<ScheduledReport>>> getScheduledReports() async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.scheduledReportsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        final templateData = data['template'] as Map<String, dynamic>;
        return ScheduledReport(
          id: doc.id,
          template: ReportTemplateModel.fromJson(templateData),
          frequency: ReportFrequency.values.firstWhere((e) => e.name == data['frequency']),
          recipientEmails: List<String>.from(data['recipientEmails'] as List),
          lastGenerated: data['lastGenerated'] != null 
              ? (data['lastGenerated'] as Timestamp).toDate() 
              : null,
          nextScheduled: data['nextScheduled'] != null 
              ? (data['nextScheduled'] as Timestamp).toDate() 
              : null,
          isActive: data['isActive'] as bool,
        );
      }).toList();
      
      return Success(reports);
    } catch (e, stackTrace) {
      return Failure(
        'Failed to get scheduled reports: $e',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }



  /// Save bytes to file (Task 28.3)
  Future<String> _saveToFile(List<int> bytes, String filename) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Create reports subdirectory if it doesn't exist
      final reportsDir = Directory('${directory.path}/reports');
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      
      // Create the file
      final file = File('${reportsDir.path}/$filename');
      
      // Write bytes to file
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  /// Calculate next scheduled date based on frequency
  Timestamp _calculateNextScheduledDate(ReportFrequency frequency) {
    final now = DateTime.now();
    DateTime nextDate;
    
    switch (frequency) {
      case ReportFrequency.daily:
        nextDate = now.add(Duration(days: 1));
        break;
      case ReportFrequency.weekly:
        nextDate = now.add(Duration(days: 7));
        break;
      case ReportFrequency.monthly:
        nextDate = DateTime(now.year, now.month + 1, now.day);
        break;
      case ReportFrequency.quarterly:
        nextDate = DateTime(now.year, now.month + 3, now.day);
        break;
      case ReportFrequency.annual:
        nextDate = DateTime(now.year + 1, now.month, now.day);
        break;
      case ReportFrequency.onDemand:
        nextDate = now; // On-demand reports don't have a next scheduled date
        break;
    }
    
    return Timestamp.fromDate(nextDate);
  }
}
