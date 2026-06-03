import '../../domain/entities/report_template.dart';
import '../../domain/entities/report_section.dart';

/// Service for managing predefined report templates
/// Task 28.1: Create predefined report templates
class ReportTemplateService {
  /// Get all predefined report templates
  List<ReportTemplate> getPredefinedTemplates() {
    return [
      _createMonthlySummaryTemplate(),
      _createQuarterlyReviewTemplate(),
      _createAnnualReportTemplate(),
      _createGovernmentSubmissionTemplate(),
    ];
  }

  /// Get template by ID
  ReportTemplate? getTemplateById(String id) {
    final templates = getPredefinedTemplates();
    try {
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create monthly summary report template
  ReportTemplate _createMonthlySummaryTemplate() {
    return ReportTemplate(
      id: 'monthly_summary',
      name: 'Monthly Summary Report',
      type: ReportType.monthlySummary,
      sections: [
        ReportSection(
          title: 'Executive Summary',
          content: 'Overview of key performance indicators for the month',
          visualizations: ['kpi_cards', 'trend_summary'],
          tables: [],
        ),
        ReportSection(
          title: 'Milk Production Analysis',
          content: 'Detailed analysis of milk collection and quality metrics',
          visualizations: [
            'daily_production_chart',
            'quality_distribution_pie',
            'collection_center_comparison'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Farmer Demographics',
          content: 'Farmer registration and demographic statistics',
          visualizations: [
            'gender_distribution',
            'age_distribution',
            'geographic_heatmap'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Livestock Statistics',
          content: 'Cattle inventory and health metrics',
          visualizations: [
            'breed_distribution',
            'health_status_chart',
            'lactation_rate_trend'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Financial Performance',
          content: 'Revenue, payments, loans, and insurance metrics',
          visualizations: [
            'revenue_breakdown',
            'payment_trend',
            'loan_performance'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Inventory & Sales',
          content: 'Product inventory and sales performance',
          visualizations: [
            'top_products_chart',
            'category_breakdown',
            'sales_trend'
          ],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.monthly,
      defaultFormat: ExportFormat.pdf,
    );
  }

  /// Create quarterly review report template
  ReportTemplate _createQuarterlyReviewTemplate() {
    return ReportTemplate(
      id: 'quarterly_review',
      name: 'Quarterly Review Report',
      type: ReportType.quarterlyReview,
      sections: [
        ReportSection(
          title: 'Quarter Overview',
          content: 'Summary of quarterly performance across all metrics',
          visualizations: ['quarterly_kpis', 'quarter_comparison'],
          tables: [],
        ),
        ReportSection(
          title: 'Performance Trends',
          content: 'Month-over-month trends and growth analysis',
          visualizations: [
            'monthly_production_trend',
            'farmer_growth_trend',
            'revenue_trend'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Comparative Analysis',
          content: 'Comparison with previous quarter and same quarter last year',
          visualizations: [
            'quarter_over_quarter_comparison',
            'year_over_year_comparison'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Collection Center Performance',
          content: 'Ranking and benchmarking of collection centers',
          visualizations: ['center_ranking_chart', 'center_performance_matrix'],
          tables: [],
        ),
        ReportSection(
          title: 'Financial Health',
          content: 'Comprehensive financial analysis including loans and insurance',
          visualizations: [
            'revenue_sources',
            'loan_portfolio_health',
            'insurance_coverage'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Strategic Insights',
          content: 'Key insights and recommendations for next quarter',
          visualizations: ['predictive_forecast', 'opportunity_areas'],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.quarterly,
      defaultFormat: ExportFormat.pdf,
    );
  }

  /// Create annual report template
  ReportTemplate _createAnnualReportTemplate() {
    return ReportTemplate(
      id: 'annual_report',
      name: 'Annual Report',
      type: ReportType.annualReport,
      sections: [
        ReportSection(
          title: 'Year in Review',
          content: 'Comprehensive overview of the year\'s achievements and challenges',
          visualizations: ['annual_highlights', 'year_timeline'],
          tables: [],
        ),
        ReportSection(
          title: 'Production Performance',
          content: 'Annual milk production analysis with seasonal patterns',
          visualizations: [
            'monthly_production_chart',
            'seasonal_patterns',
            'quality_trends'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Farmer Community Growth',
          content: 'Farmer registration, retention, and engagement metrics',
          visualizations: [
            'farmer_growth_chart',
            'retention_analysis',
            'engagement_metrics'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Livestock Development',
          content: 'Cattle population growth and health improvements',
          visualizations: [
            'cattle_population_trend',
            'breed_evolution',
            'health_improvements'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Financial Summary',
          content: 'Complete financial performance including all revenue streams',
          visualizations: [
            'annual_revenue_chart',
            'revenue_sources_breakdown',
            'profitability_analysis'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Inventory & Sales Performance',
          content: 'Annual inventory management and sales analysis',
          visualizations: [
            'sales_performance_chart',
            'product_category_trends',
            'inventory_efficiency'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Key Achievements',
          content: 'Major milestones and accomplishments',
          visualizations: ['achievement_highlights'],
          tables: [],
        ),
        ReportSection(
          title: 'Future Outlook',
          content: 'Projections and strategic plans for the coming year',
          visualizations: ['growth_projections', 'strategic_initiatives'],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.annual,
      defaultFormat: ExportFormat.pdf,
    );
  }

  /// Create government submission report template
  ReportTemplate _createGovernmentSubmissionTemplate() {
    return ReportTemplate(
      id: 'government_submission',
      name: 'Government Submission Report',
      type: ReportType.governmentSubmission,
      sections: [
        ReportSection(
          title: 'Cooperative Overview',
          content: 'Basic information about the cooperative and its operations',
          visualizations: ['cooperative_structure'],
          tables: [],
        ),
        ReportSection(
          title: 'Production Statistics',
          content: 'Aggregated milk production data (anonymized)',
          visualizations: [
            'production_volume_chart',
            'quality_distribution',
            'regional_production'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Farmer Statistics',
          content: 'Anonymized farmer demographic and participation data',
          visualizations: [
            'farmer_distribution_map',
            'demographic_breakdown',
            'participation_rates'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Livestock Statistics',
          content: 'Aggregated cattle and farm asset data',
          visualizations: [
            'cattle_population_chart',
            'breed_distribution',
            'farm_assets_overview'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Economic Impact',
          content: 'Financial impact on farmers and local economy',
          visualizations: [
            'payments_to_farmers',
            'economic_contribution',
            'employment_impact'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Financial Services',
          content: 'Loans and insurance services provided to farmers',
          visualizations: [
            'loan_disbursement_chart',
            'insurance_coverage_chart',
            'financial_inclusion'
          ],
          tables: [],
        ),
        ReportSection(
          title: 'Compliance & Standards',
          content: 'Quality standards compliance and regulatory adherence',
          visualizations: ['quality_compliance_chart', 'standards_adherence'],
          tables: [],
        ),
      ],
      frequency: ReportFrequency.quarterly,
      defaultFormat: ExportFormat.excel,
    );
  }
}
