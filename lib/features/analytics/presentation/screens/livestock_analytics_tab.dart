import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/distribution_pie_chart.dart';
import '../widgets/bar_comparison_chart.dart';
import '../../domain/entities/livestock_metrics.dart';

/// Livestock Analytics Tab (Task 22)
/// 
/// Displays comprehensive livestock analytics including:
/// - Total cattle, lactation rate, average per farmer KPIs
/// - Breed distribution pie chart
/// - Health status distribution bar chart
/// - Cattle age distribution histogram
/// - Farm assets breakdown
class LivestockAnalyticsTab extends ConsumerWidget {
  const LivestockAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(livestockAnalyticsProvider);

    return metricsAsync.when(
      data: (metrics) => _buildContent(context, metrics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildContent(BuildContext context, LivestockMetrics metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards (Task 22.1)
          _buildKpiSection(context, metrics),
          const SizedBox(height: 24),
          
          // Cattle Gender Breakdown (Task 22.1)
          _buildCattleGenderBreakdown(context, metrics),
          const SizedBox(height: 24),
          
          // Breed Distribution (Task 22.1)
          _buildBreedDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Health Status Distribution (Task 22.1)
          _buildHealthStatusDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Cattle Age Distribution (Task 22.1)
          _buildCattleAgeDistribution(context, metrics),
          const SizedBox(height: 24),
          
          // Farm Assets Breakdown (Task 22.1)
          _buildFarmAssetsBreakdown(context, metrics),
        ],
      ),
    );
  }

  /// KPI Cards Section (Task 22.1)
  Widget _buildKpiSection(BuildContext context, LivestockMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livestock Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Total Cattle',
                value: metrics.totalCattle.toString(),
                icon: Icons.pets,
                color: Colors.brown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Lactation Rate',
                value: '${(metrics.lactationRate * 100).toStringAsFixed(1)}%',
                subtitle: '${metrics.lactatingCattle} lactating',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KpiCard(
          title: 'Average per Farmer',
          value: metrics.averageCattlePerFarmer.toStringAsFixed(1),
          subtitle: 'Cattle per farmer',
          icon: Icons.person,
          color: Colors.green,
        ),
      ],
    );
  }

  /// Cattle Gender Breakdown (Task 22.1)
  Widget _buildCattleGenderBreakdown(BuildContext context, LivestockMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cattle Gender Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    context,
                    'Male',
                    metrics.maleCattle,
                    metrics.totalCattle,
                    Icons.male,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderCard(
                    context,
                    'Female',
                    metrics.femaleCattle,
                    metrics.totalCattle,
                    Icons.female,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    String label,
    int count,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Breed Distribution Pie Chart (Task 22.1)
  Widget _buildBreedDistribution(BuildContext context, LivestockMetrics metrics) {
    final distribution = metrics.breedDistribution.map(
      (breed, count) => MapEntry(breed, count.toDouble()),
    );

    return InkWell(
      onTap: () => _showBreedSegmentDialog(context, metrics),
      child: DistributionPieChart(
        distribution: distribution,
        title: 'Breed Distribution',
        colors: const [
          Color(0xFF8D6E63), // Brown
          Color(0xFF6D4C41), // Dark Brown
          Color(0xFFA1887F), // Light Brown
          Color(0xFF5D4037), // Darker Brown
          Color(0xFFBCAAA4), // Very Light Brown
          Color(0xFF4E342E), // Darkest Brown
        ],
      ),
    );
  }

  /// Health Status Distribution Bar Chart (Task 22.1)
  Widget _buildHealthStatusDistribution(BuildContext context, LivestockMetrics metrics) {
    final chartData = metrics.healthStatusDistribution.entries.map((entry) {
      return BarChartDataItem(
        label: entry.key,
        value: entry.value.toDouble(),
      );
    }).toList();

    // Sort by status priority
    final statusOrder = ['Healthy', 'Under Treatment', 'Sick'];
    chartData.sort((a, b) {
      final indexA = statusOrder.indexOf(a.label);
      final indexB = statusOrder.indexOf(b.label);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Status Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showHealthStatusSegmentDialog(context, metrics),
          child: BarComparisonChart(
            data: chartData,
            title: 'Cattle by Health Status',
            yAxisLabel: 'Number of Cattle',
            primaryColor: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        _buildHealthStatusStats(context, metrics),
      ],
    );
  }

  Widget _buildHealthStatusStats(BuildContext context, LivestockMetrics metrics) {
    final healthyCount = metrics.healthStatusDistribution['Healthy'] ?? 0;
    final total = metrics.healthStatusDistribution.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final healthyPercentage = (healthyCount / total) * 100;
    final color = healthyPercentage >= 80 ? Colors.green : Colors.orange;

    return Card(
      elevation: 1,
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.health_and_safety, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$healthyCount cattle (${healthyPercentage.toStringAsFixed(1)}%) are healthy',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cattle Age Distribution Histogram (Task 22.1)
  Widget _buildCattleAgeDistribution(BuildContext context, LivestockMetrics metrics) {
    final chartData = metrics.cattleAgeDistribution.toMap().entries.map((entry) {
      return BarChartDataItem(
        label: entry.key,
        value: entry.value.toDouble(),
      );
    }).toList();

    // Sort by age bracket order
    final ageOrder = ['0-1', '1-2', '2-3', '3-5', '5+'];
    chartData.sort((a, b) {
      final indexA = ageOrder.indexOf(a.label);
      final indexB = ageOrder.indexOf(b.label);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cattle Age Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showAgeSegmentDialog(context, metrics),
          child: BarComparisonChart(
            data: chartData,
            title: 'Cattle by Age (Years)',
            yAxisLabel: 'Number of Cattle',
            primaryColor: Colors.purple,
          ),
        ),
      ],
    );
  }

  /// Farm Assets Breakdown (Task 22.1)
  Widget _buildFarmAssetsBreakdown(BuildContext context, LivestockMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Assets Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAssetRow(
              context,
              'Avocado Trees',
              metrics.farmAssets.totalAvocadoTrees,
              metrics.farmAssets.averageAvocadoTreesPerFarmer,
              Icons.park,
              Colors.green,
            ),
            const Divider(),
            _buildAssetRow(
              context,
              'Chickens',
              metrics.farmAssets.totalChickens,
              metrics.farmAssets.averageChickensPerFarmer,
              Icons.egg,
              Colors.orange,
            ),
            const Divider(),
            _buildAssetRow(
              context,
              'Beehives',
              metrics.farmAssets.totalBeehives,
              metrics.farmAssets.averageBeehivesPerFarmer,
              Icons.hive,
              Colors.amber,
            ),
            const Divider(),
            _buildAssetRow(
              context,
              'Banana Plants',
              metrics.farmAssets.totalBananaPlants,
              metrics.farmAssets.averageBananaPlantsPerFarmer,
              Icons.nature,
              Colors.yellow,
            ),
            const Divider(),
            _buildAssetRow(
              context,
              'Passion Seedlings',
              metrics.farmAssets.totalPassionSeedlings,
              metrics.farmAssets.averagePassionSeedlingsPerFarmer,
              Icons.local_florist,
              Colors.purple,
            ),
            const Divider(),
            _buildAssetRow(
              context,
              'Potato Hectares',
              metrics.farmAssets.totalPotatoHectares,
              metrics.farmAssets.averagePotatoHectaresPerFarmer,
              Icons.grass,
              Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(
    BuildContext context,
    String label,
    dynamic total,
    double average,
    IconData icon,
    Color color,
  ) {
    // Handle both int and double for total
    final totalValue = total is double ? total.toInt() : total as int;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Avg: ${average.toStringAsFixed(1)} per farmer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Text(
            totalValue.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              'Error loading livestock analytics',
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

  /// Show Breed Segment Dialog (Task 22.2)
  void _showBreedSegmentDialog(BuildContext context, LivestockMetrics metrics) {
    final total = metrics.breedDistribution.values.fold(0, (sum, count) => sum + count);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Breed Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metrics.breedDistribution.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToFilteredCattleList(context, 'breed', entry.key);
                    },
                    child: _buildSegmentDetailRow(
                      context,
                      entry.key,
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.pets,
                      Colors.brown,
                    ),
                  ),
                  if (entry.key != metrics.breedDistribution.keys.last) const Divider(),
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

  /// Show Health Status Segment Dialog (Task 22.2)
  void _showHealthStatusSegmentDialog(BuildContext context, LivestockMetrics metrics) {
    final total = metrics.healthStatusDistribution.values.fold(0, (sum, count) => sum + count);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Status Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metrics.healthStatusDistribution.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
              final color = entry.key == 'Healthy' ? Colors.green : 
                           entry.key == 'Under Treatment' ? Colors.orange : Colors.red;
              
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToFilteredCattleList(context, 'healthStatus', entry.key);
                    },
                    child: _buildSegmentDetailRow(
                      context,
                      entry.key,
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.health_and_safety,
                      color,
                    ),
                  ),
                  if (entry.key != metrics.healthStatusDistribution.keys.last) const Divider(),
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

  /// Show Age Segment Dialog (Task 22.2)
  void _showAgeSegmentDialog(BuildContext context, LivestockMetrics metrics) {
    final ageData = metrics.cattleAgeDistribution.toMap();
    final total = ageData.values.fold(0, (sum, count) => sum + count);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cattle Age Distribution Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ageData.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToFilteredCattleList(context, 'age', entry.key);
                    },
                    child: _buildSegmentDetailRow(
                      context,
                      '${entry.key} years',
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                      Icons.calendar_today,
                      Colors.purple,
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

  /// Navigate to Filtered Cattle List (Task 22.2)
  void _navigateToFilteredCattleList(BuildContext context, String filterType, String filterValue) {
    // TODO: Navigate to cattle list screen with filters applied
    // This would integrate with the existing cattle management feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing cattle filtered by $filterType: $filterValue'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
