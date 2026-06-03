import '../../domain/entities/report_template.dart';
import '../../domain/entities/report_document.dart';
import '../../domain/entities/report_section.dart';
import '../../domain/entities/analytics_filter.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../core/result.dart';
import '../models/report_document_model.dart';
import '../models/report_template_model.dart';
import '../models/analytics_filter_model.dart';

/// Service for generating reports from analytics data (Task 15.1)
/// 
/// Fetches all required analytics data and assembles it into a structured report.
class ReportGeneratorService {
  final AnalyticsRepository analyticsRepository;

  ReportGeneratorService({required this.analyticsRepository});

  /// Generate report from template and filter (Task 15.1)
  Future<ReportDocument> generateReport({
    required ReportTemplate template,
    required AnalyticsFilter filter,
  }) async {
    // Fetch all required analytics data based on template sections
    final sections = <ReportSection>[];

    for (final templateSection in template.sections) {
      final section = await _generateSection(templateSection, filter);
      sections.add(section);
    }

    // Create report document
    final report = ReportDocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      template: template as ReportTemplateModel,
      filter: filter as AnalyticsFilterModel,
      generatedAt: DateTime.now(),
      sections: sections,
      metadata: {
        'generatedBy': 'ReportGeneratorService',
        'version': '1.0.0',
        'templateId': template.id,
        'templateName': template.name,
      },
      dataSnapshot: {}, // Would contain raw data for reference
    );

    return report;
  }

  /// Generate a single report section
  Future<ReportSection> _generateSection(
    ReportSection templateSection,
    AnalyticsFilter filter,
  ) async {
    // Based on section title, fetch appropriate data
    // This is a simplified implementation
    // In production, you'd have more sophisticated logic

    final content = await _fetchSectionContent(templateSection.title, filter);

    return ReportSection(
      title: templateSection.title,
      content: content,
      visualizations: templateSection.visualizations,
      tables: templateSection.tables,
    );
  }

  /// Fetch content for a specific section
  Future<String> _fetchSectionContent(
    String sectionTitle,
    AnalyticsFilter filter,
  ) async {
    // Simplified content generation
    // In production, this would fetch actual data and format it

    if (sectionTitle.toLowerCase().contains('milk')) {
      final result = await analyticsRepository.getMilkProductionAnalytics(filter);
      return result.fold(
        (failure) => 'Error loading milk production data: ${failure.message}',
        (success) {
          final metrics = success.data;
          return '''
Total Milk Production: ${metrics.totalLiters.toStringAsFixed(2)} liters
Average per Day: ${metrics.averageLitersPerDay.toStringAsFixed(2)} liters
Average per Farmer: ${metrics.averageLitersPerFarmer.toStringAsFixed(2)} liters
Change: ${metrics.percentageChange.toStringAsFixed(1)}%
''';
        },
      );
    }

    if (sectionTitle.toLowerCase().contains('farmer')) {
      final result = await analyticsRepository.getFarmerDemographics(filter);
      return result.fold(
        (failure) => 'Error loading farmer data: ${failure.message}',
        (success) {
          final metrics = success.data;
          return '''
Total Farmers: ${metrics.totalFarmers}
New Farmers: ${metrics.newFarmersThisPeriod}
App Access: ${metrics.farmersWithAppAccess}
Male: ${metrics.genderDistribution.maleCount}
Female: ${metrics.genderDistribution.femaleCount}
''';
        },
      );
    }

    if (sectionTitle.toLowerCase().contains('livestock')) {
      final result = await analyticsRepository.getLivestockAnalytics(filter);
      return result.fold(
        (failure) => 'Error loading livestock data: ${failure.message}',
        (success) {
          final metrics = success.data;
          return '''
Total Cattle: ${metrics.totalCattle}
Lactating: ${metrics.lactatingCattle}
Lactation Rate: ${metrics.lactationRate.toStringAsFixed(1)}%
Average per Farmer: ${metrics.averageCattlePerFarmer.toStringAsFixed(1)}
''';
        },
      );
    }

    if (sectionTitle.toLowerCase().contains('financial')) {
      final result = await analyticsRepository.getFinancialAnalytics(filter);
      return result.fold(
        (failure) => 'Error loading financial data: ${failure.message}',
        (success) {
          final metrics = success.data;
          return '''
Total Milk Payments: \$${metrics.totalMilkPayments.toStringAsFixed(2)}
Average Price/Liter: \$${metrics.averagePricePerLiter.toStringAsFixed(2)}
Total Revenue: \$${metrics.totalRevenue.toStringAsFixed(2)}
Active Loans: ${metrics.loanMetrics.activeLoanCount}
Repayment Rate: ${metrics.loanMetrics.repaymentRate.toStringAsFixed(1)}%
''';
        },
      );
    }

    if (sectionTitle.toLowerCase().contains('inventory')) {
      final result = await analyticsRepository.getInventoryAnalytics(filter);
      return result.fold(
        (failure) => 'Error loading inventory data: ${failure.message}',
        (success) {
          final metrics = success.data;
          return '''
Total Inventory Value: \$${metrics.totalInventoryValue.toStringAsFixed(2)}
Total Products: ${metrics.totalProducts}
Low Stock: ${metrics.lowStockProducts}
Out of Stock: ${metrics.outOfStockProducts}
Sales Revenue: \$${metrics.totalSalesRevenue.toStringAsFixed(2)}
''';
        },
      );
    }

    return 'Section content for: $sectionTitle';
  }
}
