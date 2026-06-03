import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/time_series_chart.dart';
import '../widgets/distribution_pie_chart.dart';
import '../widgets/bar_comparison_chart.dart';
import '../widgets/geographic_heat_map.dart';
import '../../domain/entities/farmer_metrics.dart';
import '../../domain/entities/time_series_data_point.dart';

/// Farmer Demographics Analytics Tab (Task 21)
/// 
/// Displays comprehensive farmer demographics including:
/// - Total farmers, new farmers, app adoption KPIs
/// - Gender distribution pie chart
/// - Age distribution bar chart
/// - Geographic heat map
/// - Credit score distribution histogram
/// - Registration trend line chart
class FarmerDemographicsTab extends ConsumerWidget {
  const FarmerDemographicsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(farmerDemographicsProvider);

    return metricsAsync.when(
      data: (metrics) => _buildContent(context, metrics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildContent(BuildContext context, FarmerMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards (Task 21.1)
          _buildKpiSection(context, metrics),
          const SizedBox(height: 24),
          
          // Gender Distribution (Task 21.1)
          _buildGenderDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Age Distribution (Task 21.1)
          _buildAgeDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Geographic Heat Map (Task 21.1)
          _buildGeographicDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Credit Score Distribution (Task 21.1)
          _buildCreditScoreDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Registration Trend (Task 21.1)
          _buildRegistrationTrend(context, metrics),
        ],
      ),
    );
  }

  /// KPI Cards Section (Task 21.1)
  Widget _buildKpiSection(BuildContext context, FarmerMetrics metrics) {
    final appAdoptionRate = metrics.totalFarmers > 0
        ? (metrics.farmersWithAppAccess / metrics.totalFarmers) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farmer Demographics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Farmers',
                value: metrics.totalFarmers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'New Farmers',
                value: metrics.newFarmersThisPeriod.toString(),
                subtitle: 'This period',
                icon: Icons.person_add,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          title: 'App Adoption',
          value: '${metrics.farmersWithAppAccess} farmers',
          subtitle: '${appAdoptionRate.toStringAsFixed(1)}% of total',
          icon: Icons.phone_android,
          color: Colors.purple,
        ),
      ],
    );
  }

  /// Gender Distribution Pie Chart (Task 21.1)
  Widget _buildGenderDistribution(BuildContext context, FarmerMetrics metrics) {
    final distribution = {
      'Male': metrics.genderDistribution.maleCount.toDouble(),
      'Female': metrics.genderDistribution.femaleCount.toDouble(),
    };

    return InkWell(
      onTap: () => _showGenderSegmentDialog(context, metrics),
      child: DistributionPieChart(
        distribution: distribution,
        title: 'Gender Distribution',
        colors: const [
          Color(0xFF2196F3), // Blue for Male
          Color(0xFFE91E63), // Pink for Female
        ],
      ),
    );
  }

  /// Age Distribution Bar Chart (Task 21.1)
  Widget _buildAgeDistribution(BuildContext context, FarmerMetrics metrics) {
    final chartData = metrics.ageDistribution.toMap().entries.map((entry) {
      return BarChartDataItem(
        label: entry.key,
        value: entry.value.toDouble(),
      );
    }).toList();

    // Sort by age bracket order
    final ageOrder = ['18-25', '26-35', '36-45', '46-55', '56-65', '65+'];
    chartData.sort((a, b) {
      final indexA = ageOrder.indexOf(a.label);
      final indexB = ageOrder.indexOf(b.label);
      return indexA.compareTo(indexB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showAgeSegmentDialog(context, metrics),
          child: BarComparisonChart(
            data: chartData,
            title: 'Farmers by Age Bracket',
            yAxisLabel: 'Number of Farmers',
            primaryColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Geographic Heat Map (Task 21.1)
  Widget _buildGeographicDistribution(BuildContext context, FarmerMetrics metrics) {
    // Convert Map<String, int> to Map<String, double> for the heat map
    final regionDataDouble = metrics.geographicDistribution.regionBreakdown.map(
      (key, value) => MapEntry(key, value.toDouble()),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geographic Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GeographicHeatMap(
          regionData: regionDataDouble,
          title: 'Farmers by Region',
          minColor: const Color(0xFFE3F2FD),
          maxColor: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 16),
        _buildGeographicDetails(context, metrics),
      ],
    );
  }

  /// Geographic Details Card (Task 21.1)
  Widget _buildGeographicDetails(BuildContext context, FarmerMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geographic Breakdown',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildGeographicRow(
              context,
              'Regions',
              metrics.geographicDistribution.regionBreakdown.length.toString(),
              Icons.map,
            ),
            _buildGeographicRow(
              context,
              'Districts',
              metrics.geographicDistribution.districtBreakdown.length.toString(),
              Icons.location_city,
            ),
            _buildGeographicRow(
              context,
              'Wards',
              metrics.geographicDistribution.wardBreakdown.length.toString(),
              Icons.location_on,
            ),
            _buildGeographicRow(
              context,
              'Villages',
              metrics.geographicDistribution.villageBreakdown.length.toString(),
              Icons.home,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
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

  /// Credit Score Distribution Histogram (Task 21.1)
  Widget _buildCreditScoreDistribution(BuildContext context, FarmerMetrics metrics) {
    final chartData = [
      BarChartDataItem(
        label: '0-300',
        value: metrics.creditScoreDistribution.range0to300.toDouble(),
      ),
      BarChartDataItem(
        label: '301-500',
        value: metrics.creditScoreDistribution.range301to500.toDouble(),
      ),
      BarChartDataItem(
        label: '501-700',
        value: metrics.creditScoreDistribution.range501to700.toDouble(),
      ),
      BarChartDataItem(
        label: '701-850',
        value: metrics.creditScoreDistribution.range701to850.toDouble(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Score Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCreditScoreSegmentDialog(context, metrics),
          child: BarComparisonChart(
            data: chartData,
            title: 'Farmers by Credit Score Range',
            yAxisLabel: 'Number of Farmers',
            primaryColor: Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        _buildCreditScoreStats(context, metrics),
      ],
    );
  }

  Widget _buildCreditScoreStats(BuildContext context, FarmerMetrics metrics) {
    final total = metrics.creditScoreDistribution.range0to300 +
        metrics.creditScoreDistribution.range301to500 +
        metrics.creditScoreDistribution.range501to700 +
        metrics.creditScoreDistribution.range701to850;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final goodCreditCount = metrics.creditScoreDistribution.range501to700 +
        metrics.creditScoreDistribution.range701to850;
    final goodCreditPercentage = (goodCreditCount / total) * 100;

    return Card(
      elevation: 1,
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$goodCreditCount farmers (${goodCreditPercentage.toStringAsFixed(1)}%) have good credit scores (500+)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Registration Trend Line Chart (Task 21.1)
  Widget _buildRegistrationTrend(BuildContext context, FarmerMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registration Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TimeSeriesChart(
          data: metrics.registrationTrend.cast<TimeSeriesDataPoint>(),
          title: 'New Farmer Registrations Over Time',
          yAxisLabel: 'New Farmers',
          lineColor: Colors.green,
        ),
      ],
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
              'Error loading farmer demographics',
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

  /// Show Gender Segment Dialog (Task 21.2)
  void _showGenderSegmentDialog(BuildContext context, FarmerMetrics metrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gender Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentDetailRow(
                context,
                'Male Farmers',
                metrics.genderDistribution.maleCount.toString(),
                '${((metrics.genderDistribution.maleCount / metrics.totalFarmers) * 100).toStringAsFixed(1)}%',
                Icons.male,
                Colors.blue,
              ),
              const Divider(),
              _buildSegmentDetailRow(
                context,
                'Female Farmers',
                metrics.genderDistribution.femaleCount.toString(),
                '${((metrics.genderDistribution.femaleCount / metrics.totalFarmers) * 100).toStringAsFixed(1)}%',
                Icons.female,
                Colors.pink,
              ),
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
              _navigateToFilteredFarmerList(context, 'gender', null);
            },
            child: const Text('View All Farmers'),
          ),
        ],
      ),
    );
  }

  /// Show Age Segment Dialog (Task 21.2)
  void _showAgeSegmentDialog(BuildContext context, FarmerMetrics metrics) {
    final ageData = metrics.ageDistribution.toMap();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Age Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ageData.entries.map((entry) {
              final percentage = metrics.totalFarmers > 0
                  ? (entry.value / metrics.totalFarmers) * 100
                  : 0.0;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToFilteredFarmerList(context, 'age', entry.key);
                    },
                    child: _buildSegmentDetailRow(
                      context,
                      '${entry.key} years',
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.person,
                      Colors.orange,
                    ),
                  ),
                  if (entry.key != ageData.keys.last) const Divider(),
                ],
              );
            }).toList(),
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

  /// Show Credit Score Segment Dialog (Task 21.2)
  void _showCreditScoreSegmentDialog(BuildContext context, FarmerMetrics metrics) {
    final scoreData = {
      '0-300': metrics.creditScoreDistribution.range0to300,
      '301-500': metrics.creditScoreDistribution.range301to500,
      '501-700': metrics.creditScoreDistribution.range501to700,
      '701-850': metrics.creditScoreDistribution.range701to850,
    };

    final total = scoreData.values.fold(0, (sum, count) => sum + count);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credit Score Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: scoreData.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToFilteredFarmerList(context, 'creditScore', entry.key);
                    },
                    child: _buildSegmentDetailRow(
                      context,
                      'Score ${entry.key}',
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.star,
                      Colors.teal,
                    ),
                  ),
                  if (entry.key != scoreData.keys.last) const Divider(),
                ],
              );
            }).toList(),
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

  Widget _buildSegmentDetailRow(
    BuildContext context,
    String label,
    String count,
    String percentage,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                percentage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Navigate to Filtered Farmer List (Task 21.2)
  void _navigateToFilteredFarmerList(BuildContext context, String filterType, String? filterValue) {
    // TODO: Navigate to farmer list screen with filters applied
    // This would integrate with the existing farmer management feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          filterValue != null
              ? 'Viewing farmers filtered by $filterType: $filterValue'
              : 'Viewing all farmers filtered by $filterType',
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
