import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/time_series_chart.dart';
import '../widgets/distribution_pie_chart.dart';
import '../widgets/bar_comparison_chart.dart';
import '../../domain/entities/financial_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';

/// Financial Analytics Tab (Task 23)
/// 
/// Displays comprehensive financial analytics including:
/// - Total payments, average price, total revenue KPIs
/// - Payment trend line chart
/// - Loan metrics (disbursed, outstanding, repayment rate, default rate)
/// - Insurance metrics (active policies, premium collected, coverage)
/// - Revenue breakdown pie chart
class FinancialAnalyticsTab extends ConsumerWidget {
  const FinancialAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(financialAnalyticsProvider);

    return metricsAsync.when(
      data: (metrics) => _buildContent(context, metrics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildContent(BuildContext context, FinancialMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards (Task 23.1)
          _buildKpiSection(context, metrics),
          const SizedBox(height: 24),
          
          // Payment Trend (Task 23.1)
          _buildPaymentTrend(context, metrics),
          const SizedBox(height: 24),
          
          // Loan Metrics (Task 23.1)
          _buildLoanMetrics(context, metrics),
          const SizedBox(height: 24),
          
          // Insurance Metrics (Task 23.1)
          _buildInsuranceMetrics(context, metrics),
          const SizedBox(height: 24),
          
          // Revenue Breakdown (Task 23.1)
          _buildRevenueBreakdown(context, metrics),
          const SizedBox(height: 24),
          
          // Financial Health Summary (Task 23.1)
          _buildFinancialHealthSummary(context, metrics),
        ],
      ),
    );
  }

  /// KPI Cards Section (Task 23.1)
  Widget _buildKpiSection(BuildContext context, FinancialMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Payments',
                value: 'TZS ${_formatCurrency(metrics.totalMilkPayments)}',
                subtitle: 'Milk payments',
                icon: Icons.payments,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Avg Price',
                value: 'TZS ${metrics.averagePricePerLiter.toStringAsFixed(0)}',
                subtitle: 'Per liter',
                icon: Icons.attach_money,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          title: 'Total Revenue',
          value: 'TZS ${_formatCurrency(metrics.totalRevenue)}',
          subtitle: 'All revenue streams',
          icon: Icons.account_balance_wallet,
          color: Colors.purple,
        ),
      ],
    );
  }

  /// Payment Trend Line Chart (Task 23.1)
  Widget _buildPaymentTrend(BuildContext context, FinancialMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TimeSeriesChart(
          data: metrics.paymentTrend.cast<TimeSeriesDataPoint>(),
          title: 'Milk Payments Over Time',
          yAxisLabel: 'TZS',
          lineColor: Colors.green,
        ),
      ],
    );
  }

  /// Loan Metrics Section (Task 23.1)
  Widget _buildLoanMetrics(BuildContext context, FinancialMetrics metrics) {
    final loanMetrics = metrics.loanMetrics;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loan Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                InkWell(
                  onTap: () => _showLoanDetailsDialog(context, metrics),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loan KPIs
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Total Disbursed',
                    'TZS ${_formatCurrency(loanMetrics.totalDisbursed)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Outstanding',
                    'TZS ${_formatCurrency(loanMetrics.totalOutstanding)}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Repayment Rate',
                    '${loanMetrics.repaymentRate.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Default Rate',
                    '${loanMetrics.defaultRate.toStringAsFixed(1)}%',
                    Icons.warning,
                    _getDefaultRateColor(loanMetrics.defaultRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loan Status Distribution
            _buildLoanStatusDistribution(context, loanMetrics),
            
            // Risk Level Indicator
            const SizedBox(height: 12),
            _buildRiskLevelIndicator(context, loanMetrics),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanStatusDistribution(BuildContext context, dynamic loanMetrics) {
    final chartData = [
      BarChartDataItem(
        label: 'Active',
        value: loanMetrics.activeLoanCount.toDouble(),
      ),
      BarChartDataItem(
        label: 'Completed',
        value: loanMetrics.completedLoanCount.toDouble(),
      ),
      BarChartDataItem(
        label: 'Defaulted',
        value: loanMetrics.defaultedLoanCount.toDouble(),
      ),
    ];

    return BarComparisonChart(
      data: chartData,
      title: 'Loan Status Distribution',
      yAxisLabel: 'Number of Loans',
      primaryColor: Colors.blue,
    );
  }

  Widget _buildRiskLevelIndicator(BuildContext context, dynamic loanMetrics) {
    final riskLevel = loanMetrics.riskLevel;
    final color = _getRiskLevelColor(riskLevel);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level: $riskLevel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  _getRiskLevelDescription(riskLevel),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Insurance Metrics Section (Task 23.1)
  Widget _buildInsuranceMetrics(BuildContext context, FinancialMetrics metrics) {
    final insuranceMetrics = metrics.insuranceMetrics;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Insurance Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                InkWell(
                  onTap: () => _showInsuranceDetailsDialog(context, metrics),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Insurance KPIs
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Active Policies',
                    insuranceMetrics.activePolicies.toString(),
                    Icons.policy,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Premium Collected',
                    'TZS ${_formatCurrency(insuranceMetrics.totalPremiumCollected)}',
                    Icons.money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Coverage',
                    '${insuranceMetrics.coveragePercentage.toStringAsFixed(1)}%',
                    Icons.shield_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Overdue',
                    insuranceMetrics.overdueCount.toString(),
                    Icons.warning_amber,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Coverage Status Indicator
            _buildCoverageStatusIndicator(context, insuranceMetrics),
            
            // Outstanding Premium Alert
            if (insuranceMetrics.outstandingPremium > 0) ...[
              const SizedBox(height: 12),
              _buildOutstandingPremiumAlert(context, insuranceMetrics),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageStatusIndicator(BuildContext context, dynamic insuranceMetrics) {
    final status = insuranceMetrics.coverageStatus;
    final color = _getCoverageStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coverage Status: $status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  '${insuranceMetrics.totalCattleCovered} of ${insuranceMetrics.totalCattleInSystem} cattle covered',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingPremiumAlert(BuildContext context, dynamic insuranceMetrics) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Outstanding Premium: TZS ${_formatCurrency(insuranceMetrics.outstandingPremium)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Revenue Breakdown Pie Chart (Task 23.1)
  Widget _buildRevenueBreakdown(BuildContext context, FinancialMetrics metrics) {
    final distribution = metrics.revenueBreakdownPercentages;

    return InkWell(
      onTap: () => _showRevenueBreakdownDialog(context, metrics),
      child: DistributionPieChart(
        distribution: distribution,
        title: 'Revenue Breakdown',
        colors: const [
          Color(0xFF4CAF50), // Green for Milk Payments
          Color(0xFF2196F3), // Blue for Loan Interest
          Color(0xFF9C27B0), // Purple for Insurance Premium
          Color(0xFFFF9800), // Orange for Other
        ],
      ),
    );
  }

  /// Financial Health Summary (Task 23.1)
  Widget _buildFinancialHealthSummary(BuildContext context, FinancialMetrics metrics) {
    final healthStatus = metrics.financialHealthStatus;
    final color = _getHealthStatusColor(healthStatus);
    
    return Card(
      elevation: 2,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Health: $healthStatus',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        'Revenue Diversity Score: ${metrics.revenueDiversityScore.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildHealthMetricRow(
              context,
              'Loan Risk',
              metrics.loanMetrics.riskLevel,
              _getRiskLevelColor(metrics.loanMetrics.riskLevel),
            ),
            _buildHealthMetricRow(
              context,
              'Insurance Coverage',
              metrics.insuranceMetrics.coverageStatus,
              _getCoverageStatusColor(metrics.insuranceMetrics.coverageStatus),
            ),
            _buildHealthMetricRow(
              context,
              'Revenue Diversity',
              _getDiversityLevel(metrics.revenueDiversityScore),
              _getDiversityColor(metrics.revenueDiversityScore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading financial analytics',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Loan Details Dialog (Task 23.2)
  void _showLoanDetailsDialog(BuildContext context, FinancialMetrics metrics) {
    final loanMetrics = metrics.loanMetrics;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loan Performance Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Total Disbursed', 'TZS ${_formatCurrency(loanMetrics.totalDisbursed)}'),
              _buildDetailRow('Total Outstanding', 'TZS ${_formatCurrency(loanMetrics.totalOutstanding)}'),
              _buildDetailRow('Total Repaid', 'TZS ${_formatCurrency(loanMetrics.totalRepaid)}'),
              const Divider(),
              _buildDetailRow('Repayment Rate', '${loanMetrics.repaymentRate.toStringAsFixed(1)}%'),
              _buildDetailRow('Default Rate', '${loanMetrics.defaultRate.toStringAsFixed(1)}%'),
              _buildDetailRow('Repayment Percentage', '${loanMetrics.repaymentPercentage.toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Active Loans', loanMetrics.activeLoanCount.toString()),
              _buildDetailRow('Completed Loans', loanMetrics.completedLoanCount.toString()),
              _buildDetailRow('Defaulted Loans', loanMetrics.defaultedLoanCount.toString()),
              _buildDetailRow('Total Loans', loanMetrics.totalLoans.toString()),
              const Divider(),
              _buildDetailRow('Average Loan Size', 'TZS ${_formatCurrency(loanMetrics.averageLoanSize)}'),
              _buildDetailRow('Risk Level', loanMetrics.riskLevel),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLoansList(context);
            },
            child: const Text('View Loans'),
          ),
        ],
      ),
    );
  }

  /// Show Insurance Details Dialog (Task 23.2)
  void _showInsuranceDetailsDialog(BuildContext context, FinancialMetrics metrics) {
    final insuranceMetrics = metrics.insuranceMetrics;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insurance Performance Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Active Policies', insuranceMetrics.activePolicies.toString()),
              _buildDetailRow('Policies in Good Standing', insuranceMetrics.policiesInGoodStanding.toString()),
              _buildDetailRow('Overdue Policies', insuranceMetrics.overdueCount.toString()),
              const Divider(),
              _buildDetailRow('Total Premium Collected', 'TZS ${_formatCurrency(insuranceMetrics.totalPremiumCollected)}'),
              _buildDetailRow('Outstanding Premium', 'TZS ${_formatCurrency(insuranceMetrics.outstandingPremium)}'),
              _buildDetailRow('Collection Rate', '${insuranceMetrics.collectionRate.toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Coverage Percentage', '${insuranceMetrics.coveragePercentage.toStringAsFixed(1)}%'),
              _buildDetailRow('Cattle Covered', insuranceMetrics.totalCattleCovered.toString()),
              _buildDetailRow('Total Cattle', insuranceMetrics.totalCattleInSystem.toString()),
              const Divider(),
              _buildDetailRow('Avg Premium per Policy', 'TZS ${_formatCurrency(insuranceMetrics.averagePremiumPerPolicy)}'),
              _buildDetailRow('Avg Cattle per Policy', insuranceMetrics.averageCattlePerPolicy.toStringAsFixed(1)),
              _buildDetailRow('Coverage Status', insuranceMetrics.coverageStatus),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToInsuranceList(context);
            },
            child: const Text('View Policies'),
          ),
        ],
      ),
    );
  }

  /// Show Revenue Breakdown Dialog (Task 23.2)
  void _showRevenueBreakdownDialog(BuildContext context, FinancialMetrics metrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revenue Breakdown Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Total Revenue', 'TZS ${_formatCurrency(metrics.totalRevenue)}'),
              const Divider(),
              _buildDetailRow('Milk Payments', 'TZS ${_formatCurrency(metrics.totalMilkPayments)}'),
              _buildDetailRow('  Percentage', '${metrics.milkPaymentsPercentage.toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Loan Interest', 'TZS ${_formatCurrency(metrics.loanInterestRevenue)}'),
              _buildDetailRow('  Percentage', '${((metrics.loanInterestRevenue / metrics.totalRevenue) * 100).toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Insurance Premium', 'TZS ${_formatCurrency(metrics.insurancePremiumRevenue)}'),
              _buildDetailRow('  Percentage', '${((metrics.insurancePremiumRevenue / metrics.totalRevenue) * 100).toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Other Revenue', 'TZS ${_formatCurrency(metrics.otherRevenue)}'),
              _buildDetailRow('  Percentage', '${((metrics.otherRevenue / metrics.totalRevenue) * 100).toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Revenue Diversity Score', metrics.revenueDiversityScore.toStringAsFixed(1)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Navigate to Loans List (Task 23.2)
  void _navigateToLoansList(BuildContext context) {
    // TODO: Navigate to loans list screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loans list view coming soon'),
      ),
    );
  }

  /// Navigate to Insurance List (Task 23.2)
  void _navigateToInsuranceList(BuildContext context) {
    // TODO: Navigate to insurance policies list screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Insurance policies list view coming soon'),
      ),
    );
  }

  // Helper methods
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getDefaultRateColor(double rate) {
    if (rate < 5) return Colors.green;
    if (rate < 10) return Colors.orange;
    if (rate < 20) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getRiskLevelColor(String level) {
    switch (level) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.deepOrange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRiskLevelDescription(String level) {
    switch (level) {
      case 'Low':
        return 'Loan portfolio is performing well';
      case 'Medium':
        return 'Monitor loan performance closely';
      case 'High':
        return 'Take action to reduce defaults';
      case 'Critical':
        return 'Immediate intervention required';
      default:
        return '';
    }
  }

  Color _getCoverageStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDiversityLevel(double score) {
    if (score >= 70) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 30) return 'Fair';
    return 'Poor';
  }

  Color _getDiversityColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 30) return Colors.orange;
    return Colors.red;
  }
}
