import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/bar_comparison_chart.dart';
import '../../domain/entities/comparative_metrics.dart';
import '../../domain/entities/date_range.dart';

/// Comparative Analytics Screen (Task 25.1)
/// 
/// Displays side-by-side comparison of metrics between two periods.
class ComparativeAnalyticsScreen extends ConsumerStatefulWidget {
  const ComparativeAnalyticsScreen({super.key});

  @override
  ConsumerState<ComparativeAnalyticsScreen> createState() =>
      _ComparativeAnalyticsScreenState();
}

class _ComparativeAnalyticsScreenState
    extends ConsumerState<ComparativeAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final comparativeMetricsAsync = ref.watch(comparativeAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparative Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showPeriodSelector,
            tooltip: 'Select Periods',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(comparativeAnalyticsProvider);
        },
        child: comparativeMetricsAsync.when(
          data: (metrics) => _buildContent(context, metrics),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(comparativeAnalyticsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ComparativeMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(context, metrics),
          const SizedBox(height: 24),
          _buildOverallPerformance(context, metrics),
          const SizedBox(height: 24),
          _buildKeyMetricsComparison(context, metrics),
          const SizedBox(height: 24),
          _buildCollectionCenterBenchmarking(context, metrics),
          const SizedBox(height: 24),
          _buildFarmerPerformanceBenchmarking(context, metrics),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader(BuildContext context, ComparativeMetrics metrics) {
    final currentFilter = ref.read(analyticsFilterProvider);
    final comparisonFilter = ref.read(comparisonPeriodProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Period',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateRange(currentFilter.dateRange),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.compare_arrows, size: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Comparison Period',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateRange(comparisonFilter.dateRange),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallPerformance(
      BuildContext context, ComparativeMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceIndicator(
                    context,
                    metrics.performanceSummary,
                    metrics.overallPerformanceChange,
                    metrics.overallTrend,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricsSummary(context, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(
    BuildContext context,
    String summary,
    double change,
    TrendIndicator trend,
  ) {
    Color color;
    IconData icon;

    switch (trend) {
      case TrendIndicator.improving:
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case TrendIndicator.declining:
        color = Colors.red;
        icon = Icons.trending_down;
        break;
      case TrendIndicator.stable:
        color = Colors.orange;
        icon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(
            summary,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSummary(
      BuildContext context, ComparativeMetrics metrics) {
    return Column(
      children: [
        _buildMetricRow(
          context,
          'Improved',
          metrics.improvedMetrics.length,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildMetricRow(
          context,
          'Declined',
          metrics.declinedMetrics.length,
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildMetricRow(
          context,
          'Stable',
          metrics.stableMetrics.length,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricRow(
      BuildContext context, String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsComparison(
      BuildContext context, ComparativeMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics Comparison',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            KpiCard(
              title: 'Milk Production',
              value: _formatNumber(metrics.currentPeriod.totalMilkLiters),
              subtitle: 'Liters',
              icon: Icons.water_drop,
              color: Colors.blue,
              percentageChange: metrics.milkProductionChange,
            ),
            KpiCard(
              title: 'Total Farmers',
              value: metrics.currentPeriod.totalFarmers.toString(),
              subtitle: 'Registered',
              icon: Icons.people,
              color: Colors.green,
              percentageChange: metrics.farmerCountChange,
            ),
            KpiCard(
              title: 'Total Cattle',
              value: metrics.currentPeriod.totalCattle.toString(),
              subtitle: 'Head',
              icon: Icons.pets,
              color: Colors.brown,
              percentageChange: metrics.cattleCountChange,
            ),
            KpiCard(
              title: 'Total Revenue',
              value: _formatCurrency(metrics.currentPeriod.totalRevenue),
              subtitle: 'TZS',
              icon: Icons.attach_money,
              color: Colors.purple,
              percentageChange: metrics.revenueChange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailedComparison(context, metrics),
      ],
    );
  }

  Widget _buildDetailedComparison(
      BuildContext context, ComparativeMetrics metrics) {
    final comparisonData = [
      BarChartDataItem(
        label: 'Milk\nProduction',
        value: metrics.currentPeriod.totalMilkLiters,
        comparisonValue: metrics.comparisonPeriod.totalMilkLiters,
      ),
      BarChartDataItem(
        label: 'Farmers',
        value: metrics.currentPeriod.totalFarmers.toDouble(),
        comparisonValue: metrics.comparisonPeriod.totalFarmers.toDouble(),
      ),
      BarChartDataItem(
        label: 'Cattle',
        value: metrics.currentPeriod.totalCattle.toDouble(),
        comparisonValue: metrics.comparisonPeriod.totalCattle.toDouble(),
      ),
      BarChartDataItem(
        label: 'Revenue',
        value: metrics.currentPeriod.totalRevenue,
        comparisonValue: metrics.comparisonPeriod.totalRevenue,
      ),
      BarChartDataItem(
        label: 'Inventory\nValue',
        value: metrics.currentPeriod.totalInventoryValue,
        comparisonValue: metrics.comparisonPeriod.totalInventoryValue,
      ),
    ];

    return BarComparisonChart(
      data: comparisonData,
      title: 'Period Comparison',
      xAxisLabel: 'Metrics',
      yAxisLabel: 'Value',
    );
  }

  Widget _buildCollectionCenterBenchmarking(
      BuildContext context, ComparativeMetrics metrics) {
    // Task 25.2: Collection center benchmarking
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection Center Benchmarking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Compare collection centers by volume, quality, and farmer count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Placeholder for collection center comparison
            // This would show actual center data in a real implementation
            _buildPlaceholderMessage(
              'Collection center comparison data will be displayed here',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerPerformanceBenchmarking(
      BuildContext context, ComparativeMetrics metrics) {
    // Task 25.3: Farmer performance benchmarking
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farmer Performance Benchmarking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Top and bottom performers by milk volume and quality',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Placeholder for farmer performance data
            // This would show actual farmer rankings in a real implementation
            _buildPlaceholderMessage(
              'Farmer performance rankings will be displayed here',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodSelector() {
    // Show dialog to select comparison periods
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Comparison Periods'),
        content: const Text(
          'Period selection functionality will be implemented here',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateRange range) {
    final start = range.startDate;
    final end = range.endDate;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatCurrency(double value) {
    return _formatNumber(value);
  }
}
