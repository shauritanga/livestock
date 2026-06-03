import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/time_series_chart.dart';
import '../widgets/distribution_pie_chart.dart';
import '../widgets/bar_comparison_chart.dart';
import '../../domain/entities/milk_production_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';

/// Milk Production Analytics Tab (Task 20)
/// 
/// Displays comprehensive milk production analytics including:
/// - Total liters, average per day, average per farmer KPIs
/// - Quality distribution pie chart
/// - Daily trend line chart with period options
/// - Collection center breakdown bar chart
/// - Hourly distribution heat map
class MilkProductionTab extends ConsumerStatefulWidget {
  const MilkProductionTab({super.key});

  @override
  ConsumerState<MilkProductionTab> createState() => _MilkProductionTabState();
}

class _MilkProductionTabState extends ConsumerState<MilkProductionTab> {
  String _selectedPeriod = '30'; // 7, 30, or 90 days

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(milkProductionAnalyticsProvider);

    return metricsAsync.when(
      data: (metrics) => _buildContent(metrics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildContent(MilkProductionMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards (Task 20.1)
          _buildKpiSection(metrics),
          const SizedBox(height: 24),
          
          // Quality Distribution (Task 20.1)
          _buildQualityDistribution(metrics),
          const SizedBox(height: 24),
          
          // Daily Trend (Task 20.1)
          _buildDailyTrend(metrics),
          const SizedBox(height: 24),
          
          // Collection Center Breakdown (Task 20.1)
          _buildCollectionCenterBreakdown(metrics),
          const SizedBox(height: 24),
          
          // Hourly Distribution (Task 20.1)
          _buildHourlyDistribution(metrics),
        ],
      ),
    );
  }

  /// KPI Cards Section (Task 20.1)
  Widget _buildKpiSection(MilkProductionMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milk Production Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Liters',
                value: '${metrics.totalLiters.toStringAsFixed(0)}L',
                icon: Icons.water_drop,
                color: Colors.blue,
                percentageChange: metrics.percentageChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Avg per Day',
                value: '${metrics.averageLitersPerDay.toStringAsFixed(1)}L',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          title: 'Average per Farmer',
          value: '${metrics.averageLitersPerFarmer.toStringAsFixed(1)}L',
          subtitle: 'Per farmer per day',
          icon: Icons.person,
          color: Colors.orange,
        ),
      ],
    );
  }

  /// Quality Distribution Pie Chart (Task 20.1)
  Widget _buildQualityDistribution(MilkProductionMetrics metrics) {
    final distribution = {
      'Premium': metrics.qualityDistribution.premiumCount.toDouble(),
      'Standard': metrics.qualityDistribution.standardCount.toDouble(),
      'Substandard': metrics.qualityDistribution.substandardCount.toDouble(),
    };

    return DistributionPieChart(
      distribution: distribution,
      title: 'Quality Distribution',
      colors: const [
        Color(0xFF4CAF50), // Green for Premium
        Color(0xFF2196F3), // Blue for Standard
        Color(0xFFFF5722), // Red for Substandard
      ],
    );
  }

  /// Daily Trend Line Chart (Task 20.1)
  Widget _buildDailyTrend(MilkProductionMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _buildPeriodSelector(),
          ],
        ),
        const SizedBox(height: 8),
        TimeSeriesChart(
          data: _filterDataByPeriod(metrics.dailyTrend).cast<TimeSeriesDataPoint>(),
          title: 'Milk Production Over Time',
          yAxisLabel: 'Liters',
          lineColor: Colors.blue,
        ),
      ],
    );
  }

  /// Period Selector for Daily Trend (Task 20.1)
  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '7', label: Text('7D')),
        ButtonSegment(value: '30', label: Text('30D')),
        ButtonSegment(value: '90', label: Text('90D')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
        });
      },
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  /// Collection Center Breakdown Bar Chart (Task 20.1)
  Widget _buildCollectionCenterBreakdown(MilkProductionMetrics metrics) {
    final chartData = metrics.centerBreakdown.map((center) {
      return BarChartDataItem(
        label: _truncateCenterName(center.centerName),
        value: center.totalLiters,
      );
    }).toList();

    // Sort by total liters descending and take top 10
    chartData.sort((a, b) => b.value.compareTo(a.value));
    final topCenters = chartData.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection Center Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        BarComparisonChart(
          data: topCenters,
          title: 'Top 10 Collection Centers by Volume',
          yAxisLabel: 'Liters',
          primaryColor: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildCollectionCenterList(metrics),
      ],
    );
  }

  /// Collection Center List with Details (Task 20.2)
  Widget _buildCollectionCenterList(MilkProductionMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Collection Centers',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...metrics.centerBreakdown.map((center) {
              return InkWell(
                onTap: () => _showCollectionCenterDetails(center),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              center.centerName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              '${center.farmerCount} farmers',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${center.totalLiters.toStringAsFixed(0)}L',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${center.percentageOfTotal.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Hourly Distribution Heat Map (Task 20.1)
  Widget _buildHourlyDistribution(MilkProductionMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hourly Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildHourlyHeatMap(metrics.hourlyDistribution),
          ],
        ),
      ),
    );
  }

  /// Hourly Heat Map Visualization (Task 20.1)
  Widget _buildHourlyHeatMap(Map<int, double> hourlyDistribution) {
    final maxValue = hourlyDistribution.values.isEmpty 
        ? 1.0 
        : hourlyDistribution.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Morning hours (6 AM - 12 PM)
        _buildHourlyRow('Morning', 6, 12, hourlyDistribution, maxValue),
        const SizedBox(height: 8),
        // Afternoon hours (12 PM - 6 PM)
        _buildHourlyRow('Afternoon', 12, 18, hourlyDistribution, maxValue),
        const SizedBox(height: 8),
        // Evening hours (6 PM - 12 AM)
        _buildHourlyRow('Evening', 18, 24, hourlyDistribution, maxValue),
        const SizedBox(height: 16),
        _buildHeatMapLegend(maxValue),
      ],
    );
  }

  Widget _buildHourlyRow(
    String label,
    int startHour,
    int endHour,
    Map<int, double> distribution,
    double maxValue,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(endHour - startHour, (index) {
              final hour = startHour + index;
              final value = distribution[hour] ?? 0;
              final intensity = maxValue > 0 ? (value / maxValue).toDouble() : 0.0;
              
              return Expanded(
                child: Tooltip(
                  message: '${_formatHour(hour)}: ${value.toStringAsFixed(0)}L',
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getHeatMapColor(intensity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        hour.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: intensity > 0.5 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatMapLegend(double maxValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Low',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final intensity = (index + 1) / 5;
          return Container(
            width: 30,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getHeatMapColor(intensity),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'High',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _getHeatMapColor(double intensity) {
    if (intensity == 0) return Colors.grey[200]!;
    
    // Blue gradient from light to dark
    return Color.lerp(
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFF1565C0), // Dark blue
      intensity.toDouble(),
    )!;
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading milk production analytics',
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

  /// Show Collection Center Details Dialog (Task 20.2)
  void _showCollectionCenterDetails(dynamic center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(center.centerName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Total Liters', '${center.totalLiters.toStringAsFixed(0)}L'),
            _buildDetailRow('Farmer Count', center.farmerCount.toString()),
            _buildDetailRow('Percentage of Total', '${center.percentageOfTotal.toStringAsFixed(1)}%'),
            _buildDetailRow('Avg per Farmer', '${center.averageLitersPerFarmer.toStringAsFixed(1)}L'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to farmer list for this center
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Farmer list view coming soon'),
                ),
              );
            },
            child: const Text('View Farmers'),
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

  List<dynamic> _filterDataByPeriod(List<dynamic> data) {
    final days = int.parse(_selectedPeriod);
    if (data.length <= days) return data;
    return data.sublist(data.length - days);
  }

  String _truncateCenterName(String name) {
    if (name.length <= 15) return name;
    return '${name.substring(0, 12)}...';
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
